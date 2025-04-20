-- Módulo KillAura Otimizado para Raids
-- Versão 4.0 - Focado em combate contra múltiplos inimigos
local CombatModule = {}

-- Configurações principais
CombatModule.active = false
CombatModule.attackRange = 60 -- Aumentado para detectar inimigos mais cedo
CombatModule.targetEnemy = nil
CombatModule.enemies = {} -- Armazena todos os inimigos próximos
CombatModule.normalAttackCooldown = false
CombatModule.skillKeys = {"Z", "X", "C"}
CombatModule.evading = false -- Estado de evasão
CombatModule.statusCallback = function(message) print(message) end

-- Configurações avançadas
CombatModule.skillsActive = true
CombatModule.comboModeActive = true
CombatModule.prioritizeLowHealth = true -- Prioriza inimigos com pouca vida
CombatModule.safeDistance = 15 -- Distância segura para manter de grupos
CombatModule.clickDelay = 0.08 -- Reduzido para ataques mais rápidos
CombatModule.comboHitCount = 0
CombatModule.maxComboHits = 4 -- Reduzido para combos mais curtos e ágeis
CombatModule.maxEnemyGroupSize = 3 -- Limite de inimigos para considerar grupo

-- Sistema de cooldown para skills
CombatModule.skillCooldowns = {
    Z = {active = false, cooldown = 2.5}, -- Cooldowns reduzidos
    X = {active = false, cooldown = 4},
    C = {active = false, cooldown = 6}
}

-- Funções utilitárias
function CombatModule.IsLowHealth(humanoid)
    return humanoid and humanoid.Health <= humanoid.MaxHealth * 0.4 -- Aumentado para 40%
end

function CombatModule.GetAvailableSkills()
    local available = {}
    for key, data in pairs(CombatModule.skillCooldowns) do
        if not data.active then table.insert(available, key) end
    end
    return available
end

-- Sistema de detecção de grupos de inimigos
function CombatModule.IsInDangerousGroup(enemy)
    if not enemy or not enemy:FindFirstChild("HumanoidRootPart") then return false end
    
    local enemyPos = enemy.HumanoidRootPart.Position
    local groupSize = 0
    
    for _, otherEnemy in pairs(CombatModule.enemies) do
        if otherEnemy ~= enemy and otherEnemy:FindFirstChild("HumanoidRootPart") then
            local distance = (enemyPos - otherEnemy.HumanoidRootPart.Position).Magnitude
            if distance < 12 then -- Próximos o suficiente para ser considerados grupo
                groupSize = groupSize + 1
                if groupSize >= CombatModule.maxEnemyGroupSize then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Sistema de evasão melhorado
function CombatModule.EvadeFromGroups()
    if CombatModule.evading then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- Verificar se há grupos perigosos próximos
    local dangerousGroups = {}
    for _, enemy in pairs(CombatModule.enemies) do
        if CombatModule.IsInDangerousGroup(enemy) then
            table.insert(dangerousGroups, enemy)
        end
    end
    
    if #dangerousGroups > 0 then
        CombatModule.evading = true
        CombatModule.statusCallback("⚠️ Evasão de grupo iniciada!")
        
        -- Encontrar direção de fuga (oposta ao centro do grupo)
        local groupCenter = Vector3.new(0,0,0)
        for _, enemy in pairs(dangerousGroups) do
            if enemy:FindFirstChild("HumanoidRootPart") then
                groupCenter = groupCenter + enemy.HumanoidRootPart.Position
            end
        end
        groupCenter = groupCenter / #dangerousGroups
        
        -- Direção oposta ao grupo + alguma altura
        local direction = (hrp.Position - groupCenter).Unit
        local escapePos = hrp.Position + direction * 20 + Vector3.new(0, 5, 0)
        
        -- Executar a evasão
        local oldPos = hrp.CFrame
        hrp.CFrame = CFrame.new(escapePos)
        
        -- Esperar até completar a evasão
        spawn(function()
            wait(0.5)
            CombatModule.evading = false
        end)
    end
end

-- Função para usar uma skill específica
function CombatModule.UseSkill(key)
    if CombatModule.skillCooldowns[key].active then return false end
    
    -- Marcar a skill como em cooldown
    CombatModule.skillCooldowns[key].active = true
    
    -- Usar a skill com input virtual
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    wait(0.08) -- Reduzido para 80ms
    VirtualInputManager:SendKeyEvent(false, key, false, game)
    
    -- Reiniciar o status de combo
    CombatModule.comboHitCount = 0
    
    -- Iniciar o cooldown
    spawn(function()
        wait(CombatModule.skillCooldowns[key].cooldown)
        CombatModule.skillCooldowns[key].active = false
    end)
    
    CombatModule.statusCallback("Skill " .. key .. " ⚡")
    return true
end

-- Função para selecionar e usar a melhor skill baseada nas circunstâncias
function CombatModule.UseBestSkill(enemy)
    local availableSkills = CombatModule.GetAvailableSkills()
    if #availableSkills == 0 then return false end
    
    local isLowHealth = CombatModule.IsLowHealth(enemy:FindFirstChild("Humanoid"))
    local isInGroup = CombatModule.IsInDangerousGroup(enemy)
    local selectedKey
    
    -- Lógica de prioridade avançada
    if isInGroup then
        -- Priorizar skills AOE/fortes para grupos
        for _, key in ipairs({"C", "X", "Z"}) do
            if table.find(availableSkills, key) then
                selectedKey = key
                break
            end
        end
    elseif isLowHealth then
        -- Priorizar skills de finalização
        for _, key in ipairs({"Z", "X"}) do
            if table.find(availableSkills, key) then
                selectedKey = key
                break
            end
        end
    else
        -- Em outros casos, economizar skills fortes
        if math.random(1, 10) <= 4 then -- 40% de chance de usar skill
            for _, key in ipairs({"Z", "X", "C"}) do
                if table.find(availableSkills, key) then
                    selectedKey = key
                    break
                end
            end
        end
    end
    
    if selectedKey then
        return CombatModule.UseSkill(selectedKey)
    end
    
    return false
end

-- Sistema de Combo Otimizado
function CombatModule.ExecuteComboAttack()
    if CombatModule.normalAttackCooldown then return false end
    CombatModule.normalAttackCooldown = true
    
    -- Sistema de combo dinâmico
    if CombatModule.comboHitCount >= CombatModule.maxComboHits then
        CombatModule.comboHitCount = 0
        wait(0.3) -- Pausa curta ao final do combo
    else
        CombatModule.comboHitCount = CombatModule.comboHitCount + 1
    end
    
    -- Clique para atacar com padrão de combo variável
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    -- Padrões diferentes de ataque baseados no número do combo
    if CombatModule.comboHitCount % 4 == 1 then
        -- Ataque rápido simples
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.04)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    elseif CombatModule.comboHitCount % 4 == 2 then
        -- Clique duplo
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    elseif CombatModule.comboHitCount % 4 == 3 then
        -- Ataque segurado
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
    
    -- Cooldown entre hits do combo
    spawn(function()
        wait(CombatModule.clickDelay)
        CombatModule.normalAttackCooldown = false
    end)
    
    return true
end

-- Função simples para ataque rápido
function CombatModule.UseQuickAttack()
    if CombatModule.normalAttackCooldown then return false end
    
    CombatModule.normalAttackCooldown = true
    
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    wait(0.04)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    spawn(function()
        wait(CombatModule.clickDelay)
        CombatModule.normalAttackCooldown = false
    end)
    
    return true
end

-- Função para atualizar a lista de inimigos próximos
function CombatModule.UpdateEnemiesList()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    CombatModule.enemies = {}
    
    -- Buscar em locais comuns de inimigos
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
                if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and 
                   obj.Humanoid.Health > 0 and obj ~= character then
                    
                    -- Verificar se não é um jogador
                    local isPlayer = false
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if p.Character == obj then isPlayer = true break end
                    end
                    
                    if not isPlayer then
                        local distance = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
                        if distance <= CombatModule.attackRange then
                            table.insert(CombatModule.enemies, obj)
                        end
                    end
                end
            end
        end
    end
    
    return #CombatModule.enemies
end

-- Função para escolher o melhor alvo baseado na situação
function CombatModule.SelectBestTarget()
    if #CombatModule.enemies == 0 then return nil end
    
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Primeira prioridade: inimigos isolados com pouca vida
    if CombatModule.prioritizeLowHealth then
        for _, enemy in pairs(CombatModule.enemies) do
            if enemy:FindFirstChild("Humanoid") and 
               CombatModule.IsLowHealth(enemy.Humanoid) and
               not CombatModule.IsInDangerousGroup(enemy) then
                
                return enemy
            end
        end
    end
    
    -- Segunda prioridade: inimigo mais próximo que não esteja em grupo
    local nearestDistance = CombatModule.attackRange
    local nearestEnemy = nil
    
    for _, enemy in pairs(CombatModule.enemies) do
        if enemy:FindFirstChild("HumanoidRootPart") and
           not CombatModule.IsInDangerousGroup(enemy) then
            
            local distance = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestEnemy = enemy
            end
        end
    end
    
    if nearestEnemy then return nearestEnemy end
    
    -- Terceira prioridade: qualquer inimigo, até mesmo em grupo
    -- Mas vamos pegar o mais fraco do grupo
    local weakestEnemy = nil
    local lowestHealth = math.huge
    
    for _, enemy in pairs(CombatModule.enemies) do
        if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            if enemy.Humanoid.Health < lowestHealth then
                lowestHealth = enemy.Humanoid.Health
                weakestEnemy = enemy
            end
        end
    end
    
    return weakestEnemy
end

-- Função principal KillAura otimizada
function CombatModule.PerformKillAura()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- Expandir raio de simulação para alcançar mais longe
    pcall(function() 
        sethiddenproperty(player, "SimulationRadius", 1000)
    end)
    
    -- Atualizar lista de inimigos
    CombatModule.UpdateEnemiesList()
    
    -- Verificar se precisamos evadir de grupos
    if #CombatModule.enemies >= CombatModule.maxEnemyGroupSize then
        CombatModule.EvadeFromGroups()
        if CombatModule.evading then return end -- Aguardar evasão completar
    end
    
    -- Exibir informações de status
    local cooldownInfo = ""
    for key, data in pairs(CombatModule.skillCooldowns) do
        cooldownInfo = cooldownInfo .. (data.active and "⌛" or "✅") .. key .. " "
    end
    
    -- Selecionar o melhor alvo
    local bestTarget = CombatModule.SelectBestTarget()
    
    -- Se temos um alvo válido
    if bestTarget and bestTarget:FindFirstChild("Humanoid") and 
       bestTarget.Humanoid.Health > 0 and bestTarget:FindFirstChild("HumanoidRootPart") then
        
        local distance = (hrp.Position - bestTarget.HumanoidRootPart.Position).Magnitude
        local isInGroup = CombatModule.IsInDangerousGroup(bestTarget)
        
        -- Posicionamento tático
        local posOffset = isInGroup and 7 or 4 -- Maior distância se for grupo
        
        -- Salvar posição original
        local oldPos = hrp.CFrame
        
        -- Estratégia de ataque
        if isInGroup then
            -- Para grupos: manter distância e usar skills mais fortes
            hrp.CFrame = bestTarget.HumanoidRootPart.CFrame * CFrame.new(0, 1, posOffset)
            
            -- Prioridade absoluta para skills em grupos
            if CombatModule.skillsActive then
                CombatModule.UseBestSkill(bestTarget)
            else
                CombatModule.UseQuickAttack() -- Ataque rápido sem combo para grupos
            end
        else
            -- Para inimigos isolados: aproximar e usar combo ou skill
            hrp.CFrame = bestTarget.HumanoidRootPart.CFrame * CFrame.new(0, 0, posOffset)
            
            -- Verificar se devemos usar skill ou ataque normal
            local usedSkill = false
            if CombatModule.skillsActive then
                -- Priorizar skill se inimigo com pouca vida
                if CombatModule.IsLowHealth(bestTarget.Humanoid) then
                    usedSkill = CombatModule.UseBestSkill(bestTarget)
                elseif math.random(1, 10) <= 3 then
                    -- 30% de chance para outros casos
                    usedSkill = CombatModule.UseBestSkill(bestTarget)
                end
            end
            
            -- Se não usou skill, usar ataque normal
            if not usedSkill then
                if CombatModule.comboModeActive then
                    CombatModule.ExecuteComboAttack()
                else
                    CombatModule.UseQuickAttack()
                end
            end
        end
        
        -- Status do alvo
        local health = math.floor((bestTarget.Humanoid.Health / bestTarget.Humanoid.MaxHealth) * 100)
        local statusIcon = isInGroup and "⚠️ GRUPO" or "🎯"
        CombatModule.statusCallback(statusIcon .. " Alvo: " .. health .. "% | " .. cooldownInfo)
        
        -- Verificar se o alvo morreu
        if bestTarget.Humanoid.Health <= 0 then
            CombatModule.statusCallback("✅ Inimigo eliminado!")
        end
        
        -- Voltar à posição original com delay
        spawn(function()
            wait(0.15)
            hrp.CFrame = oldPos
        end)
    else
        CombatModule.statusCallback("🔍 Procurando (" .. #CombatModule.enemies .. " próximos) | " .. cooldownInfo)
    end
end

-- Função para iniciar o KillAura
function CombatModule.Start()
    if CombatModule.active then return end
    
    CombatModule.active = true
    CombatModule.statusCallback("✅ KillAura Anti-Raid ativado")
    
    -- Loop principal otimizado
    spawn(function()
        while CombatModule.active and wait(0.15) do -- Loop mais rápido para melhor resposta
            pcall(CombatModule.PerformKillAura)
        end
    end)
end

-- Função para parar o KillAura
function CombatModule.Stop()
    CombatModule.active = false
    CombatModule.statusCallback("❌ KillAura desativado")
    CombatModule.comboHitCount = 0
    CombatModule.enemies = {}
end

-- Função para alternar o KillAura
function CombatModule.Toggle()
    if CombatModule.active then
        CombatModule.Stop()
    else
        CombatModule.Start()
    end
    return CombatModule.active
end

-- Funções auxiliares mantidas para compatibilidade
CombatModule.ToggleKillAura = CombatModule.Toggle
CombatModule.StartKillAura = CombatModule.Start
CombatModule.StopKillAura = CombatModule.Stop
CombatModule.killAuraActive = CombatModule.active

-- Função para alternar uso de skills
function CombatModule.ToggleSkills()
    CombatModule.skillsActive = not CombatModule.skillsActive
    CombatModule.statusCallback(CombatModule.skillsActive and "Skills ✅" or "Skills ❌")
    return CombatModule.skillsActive
end

-- Função para alternar modo combo
function CombatModule.ToggleComboMode()
    CombatModule.comboModeActive = not CombatModule.comboModeActive
    CombatModule.comboHitCount = 0
    CombatModule.statusCallback(CombatModule.comboModeActive and "Combo ✅" or "Combo ❌")
    return CombatModule.comboModeActive
end

-- Função para definir o alcance
function CombatModule.SetRange(range)
    if tonumber(range) and tonumber(range) > 0 then
        CombatModule.attackRange = tonumber(range)
        CombatModule.statusCallback("Alcance: " .. CombatModule.attackRange)
        return true
    end
    return false
end

-- Função para definir callback de status
function CombatModule.SetStatusCallback(callback)
    if type(callback) == "function" then
        CombatModule.statusCallback = callback
        return true
    end
    return false
end

print("Módulo KillAura Anti-Raid v4.0 carregado!")

return CombatModule
