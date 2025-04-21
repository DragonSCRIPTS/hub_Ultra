-- Auto Module para Roblox - Combinação de Auto Quest e KillAura
-- Módulo otimizado para carregamento direto via loadstring(game:HttpGet())

local AutoModule = {}

-- Serviços do Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Configurações de Quest
local playerLevel = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 1
local currentWorld = 1
local currentQuestData = nil
local hasActiveQuest = false
local questCheckCooldown = 0
local lastQuestName = ""

-- Configurações de Combate
local attackRange = 1000  -- Aumentado conforme solicitado
local targetEnemy = nil
local enemies = {}
local normalAttackCooldown = false
local skillKeys = {"Z", "X", "C"}
local evading = false
local comboHitCount = 0

-- Cooldowns de habilidades
local skillCooldowns = {
    Z = {active = false, cooldown = 2.5},
    X = {active = false, cooldown = 4},
    C = {active = false, cooldown = 6}
}

-- Configurações avançadas
local skillsActive = true
local comboModeActive = true
local prioritizeLowHealth = true
local safeDistance = 15
local clickDelay = 0.08
local maxComboHits = 4
local maxEnemyGroupSize = 3

-- Sistemas de dados de mundo
local World1, World2, World3

-- Funções utilitárias
local function log(message)
    print("[AutoModule] " .. message)
end

-- Determina o mundo atual com base no PlaceId ou nível do jogador
local function determineCurrentWorld()
    if game.PlaceId == 2753915549 then
        currentWorld = 1
    elseif game.PlaceId == 4442272183 then
        currentWorld = 2
    elseif game.PlaceId == 7449423635 then
        currentWorld = 3
    else
        if playerLevel <= 700 then
            currentWorld = 1
        elseif playerLevel <= 1500 then
            currentWorld = 2
        else
            currentWorld = 3
        end
    end
    
    return currentWorld
end

-- Carrega os dados do mundo correto
local function loadWorldData()
    local success, result = pcall(function()
        -- Tentativa de carregar dados de mundo
        local worldData = {
            [1] = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/dragonscript/refs/heads/main/World1.lua"))(),
            [2] = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/dragonscript/refs/heads/main/World2.lua"))(),
            [3] = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/dragonscript/refs/heads/main/World3.lua"))()
        }
        return worldData
    end)
    
    if success then
        World1 = result[1]
        World2 = result[2]
        World3 = result[3]
        log("Dados de mundo carregados com sucesso!")
    else
        log("Erro ao carregar dados de mundo: " .. tostring(result))
        -- Usar dados de fallback ou retornar falso
        return false
    end
    
    return true
end

-- Verifica se o jogador já tem uma quest ativa
local function checkActiveQuest()
    local questInfo = {Active = false}
    
    -- Procura no PlayerGui por informações da quest
    if LocalPlayer.PlayerGui then
        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if mainGui then
            local quest = mainGui:FindFirstChild("Quest")
            if quest and quest.Visible then
                local container = quest:FindFirstChild("Container")
                if container then
                    local questTitle = container:FindFirstChild("QuestTitle")
                    if questTitle and questTitle.Text ~= "" and not questTitle.Text:find("QUEST COMPLETA") then
                        questInfo.Active = true
                        questInfo.Title = questTitle.Text
                        return questInfo
                    end
                end
            end
        end
    end
    
    return questInfo
end

-- Função para mover o personagem para uma posição
local function moveToPosition(targetCFrame, height)
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Remover qualquer BodyPosition anterior
    for _, v in pairs(HumanoidRootPart:GetChildren()) do
        if v:IsA("BodyPosition") then
            v:Destroy()
        end
    end
    
    local targetPos = targetCFrame.Position
    
    -- Verificar se já estamos próximos do alvo
    if (HumanoidRootPart.Position - targetPos).Magnitude < 10 then
        return true -- Já estamos no local
    end
    
    -- Criar BodyPosition para controle do movimento
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(15000, 200000, 15000)
    bodyPos.P = 3000
    bodyPos.D = 1000
    bodyPos.Parent = HumanoidRootPart
    
    -- Etapa 1: Subir rapidamente
    local desiredHeight = math.max(HumanoidRootPart.Position.Y + height, targetPos.Y + height)
    
    local startTime = tick()
    while (HumanoidRootPart.Position.Y - desiredHeight) < -5 and (tick() - startTime) < 3 do
        bodyPos.Position = Vector3.new(HumanoidRootPart.Position.X, desiredHeight, HumanoidRootPart.Position.Z)
        RunService.Heartbeat:Wait()
    end
    
    -- Etapa 2: Movimento horizontal
    startTime = tick()
    while (Vector3.new(HumanoidRootPart.Position.X, 0, HumanoidRootPart.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude > 5 and (tick() - startTime) < 10 do
        bodyPos.Position = Vector3.new(targetPos.X, desiredHeight, targetPos.Z)
        RunService.Heartbeat:Wait()
    end
    
    -- Etapa 3: Descer suavemente
    startTime = tick()
    while (HumanoidRootPart.Position.Y - targetPos.Y) > 5 and (tick() - startTime) < 3 do
        bodyPos.Position = Vector3.new(targetPos.X, targetPos.Y + 5, targetPos.Z)
        RunService.Heartbeat:Wait()
    end
    
    -- Limpeza
    if bodyPos and bodyPos.Parent then
        bodyPos:Destroy()
    end
    
    -- Teleportar para a posição final exata
    HumanoidRootPart.CFrame = CFrame.new(targetPos)
    
    return true
end

-- Função para obter dados da quest atual
local function getQuestData()
    local world = determineCurrentWorld()
    local questData = nil
    
    if world == 1 and World1 then
        questData = World1:GetQuestData(playerLevel)
    elseif world == 2 and World2 then
        questData = World2:GetQuestData(playerLevel)
    elseif world == 3 and World3 then
        questData = World3:GetQuestData(playerLevel)
    end
    
    return questData
end

-- FUNÇÃO 1: COLETAR MISSÃO
function AutoModule.coletarMissao()
    log("Iniciando coleta de missão...")
    
    -- Verificar e atualizar o nível do jogador
    if LocalPlayer.Data and LocalPlayer.Data.Level then
        playerLevel = LocalPlayer.Data.Level.Value
    end
    
    -- Verificar se já temos uma quest ativa
    if tick() - questCheckCooldown > 3 then
        local questStatus = checkActiveQuest()
        questCheckCooldown = tick()
        
        if questStatus.Active then
            hasActiveQuest = true
            log("Quest ativa encontrada: " .. questStatus.Title)
            return true
        else
            hasActiveQuest = false
        end
    end
    
    -- Se não temos quest ativa, vamos pegar uma
    if not hasActiveQuest then
        local questData = getQuestData()
        if not questData then
            log("Nenhuma quest disponível para o nível atual")
            return false
        }
        
        currentQuestData = questData
        log("Quest selecionada: " .. questData.Quest.Title)
        
        -- Ir até o NPC da quest
        local world = determineCurrentWorld()
        local target = nil
        
        if world == 1 and World1 then
            target = World1:NavigateToQuest(questData)
        elseif world == 2 and World2 then
            target = World2:NavigateToQuest(questData)
        elseif world == 3 and World3 then
            target = World3:NavigateToQuest(questData)
        end
        
        if target then
            -- Mover para o NPC da quest
            log("Movendo para o NPC da quest...")
            moveToPosition(target, 50)
            
            -- Aceitar a quest
            log("Aceitando a quest...")
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", questData.Quest.Name, questData.Quest.Level)
            
            -- Armazenar informações da quest atual
            lastQuestName = questData.Quest.Name
            hasActiveQuest = true
            
            wait(1) -- Pequena pausa para garantir que a quest seja aceita
            log("Quest aceita com sucesso!")
            return true
        else
            log("Não foi possível encontrar o NPC da quest")
            return false
        end
    end
    
    return hasActiveQuest
end

-- Atualiza a lista de inimigos próximos
local function updateEnemiesList()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Expandir raio de simulação
    pcall(function() 
        sethiddenproperty(player, "SimulationRadius", 1000)
    end)
    
    enemies = {}
    
    -- Pesquisar em locais comuns de inimigos
    local searchLocations = {
        game.Workspace:FindFirstChild("Enemies"),
        game.Workspace:FindFirstChild("NPCs"),
        game.Workspace:FindFirstChild("Mobs"),
        game.Workspace:FindFirstChild("Raid"),
        game.Workspace:FindFirstChild("RaidBosses"),
        game.Workspace
    }
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetChildren()) do
                if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj.Humanoid.Health > 0 and obj ~= character then
                    -- Verificar se não é um jogador
                    local isPlayer = false
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if p.Character == obj then
                            isPlayer = true
                            break
                        end
                    end
                    
                    if not isPlayer then
                        local distance = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
                        if distance <= attackRange then
                            table.insert(enemies, obj)
                        end
                    end
                end
            end
        end
    end
    
    return #enemies
end

-- Verifica se um inimigo está com pouca vida
local function isLowHealth(humanoid)
    return humanoid and humanoid.Health <= humanoid.MaxHealth * 0.4
end

-- Verifica se um inimigo está em um grupo perigoso
local function isInDangerousGroup(enemy)
    if not enemy or not enemy:FindFirstChild("HumanoidRootPart") then 
        return false
    end
    
    local enemyPos = enemy.HumanoidRootPart.Position
    local groupSize = 0
    
    for _, otherEnemy in pairs(enemies) do
        if otherEnemy ~= enemy and otherEnemy:FindFirstChild("HumanoidRootPart") then
            local distance = (enemyPos - otherEnemy.HumanoidRootPart.Position).Magnitude
            if distance < 12 then
                groupSize = groupSize + 1
                if groupSize >= maxEnemyGroupSize then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Sistema de evasão para grupos perigosos
local function evadeFromGroups()
    if evading then
        return
    end
    
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Verificar se há grupos perigosos próximos
    local dangerousGroups = {}
    for _, enemy in pairs(enemies) do
        if isInDangerousGroup(enemy) then
            table.insert(dangerousGroups, enemy)
        end
    end
    
    if #dangerousGroups > 0 then
        evading = true
        log("⚠️ Evasão de grupo iniciada!")
        
        -- Encontrar direção de fuga (oposta ao centro do grupo)
        local groupCenter = Vector3.new(0, 0, 0)
        for _, enemy in pairs(dangerousGroups) do
            if enemy:FindFirstChild("HumanoidRootPart") then
                groupCenter = groupCenter + enemy.HumanoidRootPart.Position
            end
        end
        
        groupCenter = groupCenter / #dangerousGroups
        local direction = (hrp.Position - groupCenter).Unit
        local escapePos = hrp.Position + direction * 20 + Vector3.new(0, 5, 0)
        
        -- Executar evasão
        local oldPos = hrp.CFrame
        hrp.CFrame = CFrame.new(escapePos)
        
        -- Esperar até completar evasão
        spawn(function()
            wait(0.5)
            evading = false
        end)
    end
end

-- Função para usar uma habilidade específica
local function useSkill(key)
    if skillCooldowns[key].active then
        return false
    end
    
    -- Marcar a habilidade como em cooldown
    skillCooldowns[key].active = true
    
    -- Usar uma habilidade com input virtual
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    wait(0.08)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
    
    -- Reiniciar o status do combo
    comboHitCount = 0
    
    -- Iniciar o cooldown
    spawn(function()
        wait(skillCooldowns[key].cooldown)
        skillCooldowns[key].active = false
    end)
    
    log("Skill " .. key .. " ⚡")
    return true
end

-- Função para selecionar e usar a melhor habilidade
local function useBestSkill(enemy)
    -- Verificar habilidades disponíveis
    local availableSkills = {}
    for key, data in pairs(skillCooldowns) do
        if not data.active then
            table.insert(availableSkills, key)
        end
    end
    
    if #availableSkills == 0 then
        return false
    end
    
    local isLowHealth = enemy:FindFirstChild("Humanoid") and isLowHealth(enemy.Humanoid)
    local isInGroup = isInDangerousGroup(enemy)
    local selectedKey
    
    -- Lógica de prioridade avançada
    if isInGroup then
        -- Priorizar habilidades AOE/fortes para grupos
        for _, key in ipairs({"C", "X", "Z"}) do
            if table.find(availableSkills, key) then
                selectedKey = key
                break
            end
        end
    elseif isLowHealth then
        -- Priorizar habilidades de finalização
        for _, key in ipairs({"Z", "X"}) do
            if table.find(availableSkills, key) then
                selectedKey = key
                break
            end
        end
    else
        -- Em outros casos, permita habilidades fortes
        if math.random(1, 10) <= 4 then
            -- 40% de chance de usar habilidade
            for _, key in ipairs({"Z", "X", "C"}) do
                if table.find(availableSkills, key) then
                    selectedKey = key
                    break
                end
            end
        end
    end
    
    if selectedKey then
        return useSkill(selectedKey)
    end
    
    return false
end

-- Sistema de Combo Otimizado
local function executeComboAttack()
    if normalAttackCooldown then
        return false
    end
    
    normalAttackCooldown = true
    
    -- Sistema de combo dinâmico
    if comboHitCount >= maxComboHits then
        comboHitCount = 0
        wait(0.3) -- Pausa curta ao final do combo
    else
        comboHitCount = comboHitCount + 1
    end
    
    -- Clique para atacar com padrão de combo variável
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    -- Padrões diferentes de ataque baseados no número do combo
    if comboHitCount % 4 == 1 then
        -- Ataque rápido simples
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.04)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    elseif comboHitCount % 4 == 2 then
        -- Clique duplo
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    elseif comboHitCount % 4 == 3 then
        -- Ataque seguro
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.12)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    else
        -- Ataque final
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
    
    -- Tempo de recarga entre acertos do combo
    spawn(function()
        wait(clickDelay)
        normalAttackCooldown = false
    end)
    
    return true
end

-- Função simples para ataque rápido
local function useQuickAttack()
    if normalAttackCooldown then
        return false
    end
    
    normalAttackCooldown = true
    
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    wait(0.04)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    spawn(function()
        wait(clickDelay)
        normalAttackCooldown = false
    end)
    
    return true
end

-- Função para escolher o melhor alvo baseado na situação
local function selectBestTarget()
    if #enemies == 0 then
        return nil
    end
    
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Primeira prioridade: inimigos isolados com pouca vida
    if prioritizeLowHealth then
        for _, enemy in pairs(enemies) do
            if enemy:FindFirstChild("Humanoid") and isLowHealth(enemy.Humanoid) and not isInDangerousGroup(enemy) then
                return enemy
            end
        end
    end
    
    -- Segunda prioridade: inimigo mais próximo que não está em grupo
    local closestDistance = attackRange
    local closestEnemy = nil
    
    for _, enemy in pairs(enemies) do
        if enemy:FindFirstChild("HumanoidRootPart") and not isInDangerousGroup(enemy) then
            local distance = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestEnemy = enemy
            end
        end
    end
    
    if closestEnemy then
        return closestEnemy
    end
    
    -- Terceira prioridade: qualquer inimigo, até mesmo em grupo
    -- Mas vamos pegar o mais fraco do grupo
    local weakestEnemy = nil
    local lowestHealth = math.huge
    
    for _, enemy in pairs(enemies) do
        if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            if enemy.Humanoid.Health < lowestHealth then
                lowestHealth = enemy.Humanoid.Health
                weakestEnemy = enemy
            end
        end
    end
    
    return weakestEnemy
end

-- FUNÇÃO 2: DETECTAR E ATACAR NPCS
function AutoModule.detectarEAtacarNPCs()
    log("Iniciando detecção e ataque...")
    
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Expandir raio de simulação para alcançar mais longe
    pcall(function()
        sethiddenproperty(player, "SimulationRadius", 1000)
    end)
    
    -- Atualizar lista de inimigos
    updateEnemiesList()
    
    -- Verificar se precisamos evitar grupos
    if #enemies >= maxEnemyGroupSize then
        evadeFromGroups()
        if evading then
            return
        end
    end
    
    -- Selecionar o melhor alvo
    local bestTarget = selectBestTarget()
    
    -- Temos um alvo válido
    if bestTarget and bestTarget:FindFirstChild("Humanoid") and bestTarget.Humanoid.Health > 0 and bestTarget:FindFirstChild("HumanoidRootPart") then
        local distance = (hrp.Position - bestTarget.HumanoidRootPart.Position).Magnitude
        local isInGroup = isInDangerousGroup(bestTarget)
        
        -- Posicionamento tático
        local posOffset = isInGroup and 7 or 4 -- Maior distância se for grupo
        
        -- Salvar posição original
        local oldPos = hrp.CFrame
        
        -- Estratégia de ataque
        if isInGroup then
            -- Para grupos: manter distância e usar habilidades mais fortes
            hrp.CFrame = bestTarget.HumanoidRootPart.CFrame * CFrame.new(0, 1, posOffset)
            
            -- Prioridade absoluta para habilidades em grupos
            if skillsActive then
                useBestSkill(bestTarget)
            else
                useQuickAttack() -- Ataque rápido sem combo para grupos
            end
        else
            -- Para inimigos isolados: aproximar e usar combo ou habilidade
            hrp.CFrame = bestTarget.HumanoidRootPart.CFrame * CFrame.new(0, 0, posOffset)
            
            -- Certifique-se de usar habilidade ou ataque normal
            local usedSkill = false
            
            if skillsActive then
                -- Priorizar habilidade se inimigo com pouca vida
                if isLowHealth(bestTarget.Humanoid) then
                    usedSkill = useBestSkill(bestTarget)
                elseif math.random(1, 10) <= 3 then
                    -- 30% de chance para outros casos
                    usedSkill = useBestSkill(bestTarget)
                end
            end
            
            -- Se não usar habilidade, use ataque normal
            if not usedSkill then
                if comboModeActive then
                    executeComboAttack()
                else
                    useQuickAttack()
                end
            end
        end
        
        -- Status do alvo
        local health = math.floor((bestTarget.Humanoid.Health / bestTarget.Humanoid.MaxHealth) * 100)
        local statusIcon = isInGroup and "⚠️ GRUPO" or "🎯"
        
        log(statusIcon .. " Alvo: " .. health .. "%")
        
        -- Verificar se o alvo morreu para verificação de quest
        if bestTarget.Humanoid.Health <= 0 then
            log("✅ Inimigo eliminado!")
            
            -- Verificar status da quest
            local questStatus = checkActiveQuest()
            if not questStatus.Active then
                hasActiveQuest = false
                log("Quest completada! Procurando nova quest...")
            end
        end
        
        -- Voltar à posição original com delay
        spawn(function()
            wait(0.15)
            hrp.CFrame = oldPos
        end)
    else
        log("🔍 Procurando (" .. #enemies .. " próximos)")
    end
    
    -- Pequena pausa entre ataques
    wait(0.1)
end

-- Inicialização do módulo
function AutoModule.init()
    log("Inicializando AutoModule...")
    
    -- Carregar dados de mundo
    local worldDataLoaded = loadWorldData()
    if not worldDataLoaded then
        log("AVISO: Não foi possível carregar dados de mundo, algumas funcionalidades podem estar limitadas")
    end
    
    -- Detectar mundo inicial
    currentWorld = determineCurrentWorld()
    log("Mundo detectado: " .. currentWorld)
    
    -- Verificar nível do jogador
    if LocalPlayer.Data and LocalPlayer.Data.Level then
        playerLevel = LocalPlayer.Data.Level.Value
        log("Nível do jogador: " .. playerLevel)
    end
    
    -- Verificar se já existe uma quest ativa
    local questStatus = checkActiveQuest()
    hasActiveQuest = questStatus.Active
    
    if hasActiveQuest then
        log("Quest ativa encontrada: " .. (questStatus.Title or "Desconhecida"))
    else
        log("Nenhuma quest ativa encontrada")
    end
    
    -- Iniciar o loop principal
    spawn(function()
        log("Loop principal iniciado")
        while true do
            pcall(function()
                AutoModule.coletarMissao()
                AutoModule.detectarEAtacarNPCs()
            end)
            wait(0.5) -- Pequena pausa para evitar sobrecarga
        end
    end)
    
    return true
end

-- Iniciar o módulo automaticamente
AutoModule.init()

-- Retornar o módulo para uso caso necessário
return AutoModule
