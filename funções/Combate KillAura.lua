-- Módulo KillAura Otimizado para Raids - Versão 5.0
-- Focado em combate esquiva-ataque contra múltiplos inimigos
local KillAura = {}

-- Configurações principais (simplificadas)
KillAura.active = false
KillAura.enemies = {}
KillAura.cooldown = false
KillAura.evading = false
KillAura.detectionRange = 1000 -- Detecção máxima fixa
KillAura.comboCount = 0
KillAura.maxCombo = 3
KillAura.skillKeys = {"Z", "X", "C"}
KillAura.log = function(msg) print(msg) end

-- Cooldowns de skills
KillAura.skills = {
    Z = {cooldown = false, time = 2.0},
    X = {cooldown = false, time = 3.5},
    C = {cooldown = false, time = 5.0}
}

-- Sistema de combate avançado
function KillAura.Attack(enemy)
    if KillAura.cooldown then return end
    KillAura.cooldown = true
    
    local VIM = game:GetService("VirtualInputManager")
    local isLowHealth = enemy:FindFirstChild("Humanoid") and 
                        enemy.Humanoid.Health <= enemy.Humanoid.MaxHealth * 0.4
    local isGroup = KillAura.IsInDangerousGroup(enemy)
    
    -- Escolher melhor ataque baseado na situação
    if isGroup then
        -- Contra grupos: usar skills poderosas ou ataques rápidos
        local skillUsed = false
        
        -- Tentar usar a skill mais forte disponível
        for _, key in ipairs({"C", "X", "Z"}) do
            if not KillAura.skills[key].cooldown then
                KillAura.UseSkill(key)
                skillUsed = true
                break
            end
        end
        
        -- Se não usou skill, fazer um ataque rápido
        if not skillUsed then
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            wait(0.04)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    elseif isLowHealth then
        -- Contra inimigos fracos: finalizar com skill
        local skillUsed = false
        for _, key in ipairs({"Z", "X"}) do
            if not KillAura.skills[key].cooldown then
                KillAura.UseSkill(key)
                skillUsed = true
                break
            end
        end
        
        -- Se não tiver skills, usar combo
        if not skillUsed then KillAura.ExecuteCombo() end
    else
        -- Em outros casos: usar combo normal
        KillAura.ExecuteCombo()
    end
    
    -- Resetar cooldown
    spawn(function()
        wait(0.07)
        KillAura.cooldown = false
    end)
end

-- Sistema de combo otimizado
function KillAura.ExecuteCombo()
    local VIM = game:GetService("VirtualInputManager")
    
    -- Atualizar contador de combo
    KillAura.comboCount = (KillAura.comboCount % KillAura.maxCombo) + 1
    
    -- Executar ataque baseado no número do combo
    if KillAura.comboCount == 1 then
        -- Ataque inicial rápido
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.03)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    elseif KillAura.comboCount == 2 then
        -- Ataque duplo
        for i = 1, 2 do
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            wait(0.03)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            wait(0.03)
        end
    else
        -- Ataque final forte
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.1)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

-- Sistema de esquiva avançado
function KillAura.Evade()
    if KillAura.evading then return end
    KillAura.evading = true
    
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Determinar direção de esquiva (oposta à maior concentração de inimigos)
    local enemiesCenter = Vector3.new(0,0,0)
    local count = 0
    
    for _, enemy in pairs(KillAura.enemies) do
        if enemy:FindFirstChild("HumanoidRootPart") then
            enemiesCenter = enemiesCenter + enemy.HumanoidRootPart.Position
            count = count + 1
        end
    end
    
    if count > 0 then
        enemiesCenter = enemiesCenter / count
        local direction = (hrp.Position - enemiesCenter).Unit
        local escapePos = hrp.Position + direction * 25 + Vector3.new(0, 8, 0)
        local oldPos = hrp.CFrame
        
        -- Executar teleporte evasivo
        hrp.CFrame = CFrame.new(escapePos)
        KillAura.log("⚡ Esquiva executada!")
        
        -- Esperar e retornar ao combate
        spawn(function()
            wait(0.7)
            KillAura.evading = false
        end)
    else
        KillAura.evading = false
    end
end

-- Verificar se inimigo está em grupo perigoso
function KillAura.IsInDangerousGroup(enemy)
    if not enemy or not enemy:FindFirstChild("HumanoidRootPart") then return false end
    
    local enemyPos = enemy.HumanoidRootPart.Position
    local nearbyCount = 0
    
    for _, other in pairs(KillAura.enemies) do
        if other ~= enemy and other:FindFirstChild("HumanoidRootPart") then
            local dist = (enemyPos - other.HumanoidRootPart.Position).Magnitude
            if dist < 15 then -- Aumentado para melhor detecção de grupos
                nearbyCount = nearbyCount + 1
                if nearbyCount >= 2 then -- 3 total incluindo este
                    return true
                end
            end
        end
    end
    
    return false
end

-- Usar skill com cooldown
function KillAura.UseSkill(key)
    if KillAura.skills[key].cooldown then return false end
    
    -- Marcar como em cooldown
    KillAura.skills[key].cooldown = true
    
    -- Usar skill
    local VIM = game:GetService("VirtualInputManager")
    VIM:SendKeyEvent(true, key, false, game)
    wait(0.06)
    VIM:SendKeyEvent(false, key, false, game)
    
    -- Iniciar cooldown
    spawn(function()
        wait(KillAura.skills[key].time)
        KillAura.skills[key].cooldown = false
    end)
    
    KillAura.log("Skill " .. key .. " ⚡")
    return true
end

-- Atualizar lista de inimigos
function KillAura.ScanEnemies()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    KillAura.enemies = {}
    
    -- Expandir raio de simulação
    pcall(function() 
        sethiddenproperty(player, "SimulationRadius", KillAura.detectionRange)
    end)
    
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
                        if distance <= KillAura.detectionRange then
                            table.insert(KillAura.enemies, obj)
                        end
                    end
                end
            end
        end
    end
end

-- Selecionar melhor alvo
function KillAura.SelectTarget()
    if #KillAura.enemies == 0 then return nil end
    
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Prioridade 1: Inimigo isolado com pouca vida
    for _, enemy in pairs(KillAura.enemies) do
        if enemy:FindFirstChild("Humanoid") and 
           enemy.Humanoid.Health <= enemy.Humanoid.MaxHealth * 0.4 and
           not KillAura.IsInDangerousGroup(enemy) then
            return enemy
        end
    end
    
    -- Prioridade 2: Inimigo isolado mais próximo
    local nearest = nil
    local minDist = KillAura.detectionRange
    
    for _, enemy in pairs(KillAura.enemies) do
        if enemy:FindFirstChild("HumanoidRootPart") and
           not KillAura.IsInDangerousGroup(enemy) then
            
            local dist = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = enemy
            end
        end
    end
    
    if nearest then return nearest end
    
    -- Prioridade 3: Qualquer inimigo (com preferência ao mais fraco)
    local weakest = nil
    local lowestHealth = math.huge
    
    for _, enemy in pairs(KillAura.enemies) do
        if enemy:FindFirstChild("Humanoid") then
            if enemy.Humanoid.Health < lowestHealth then
                lowestHealth = enemy.Humanoid.Health
                weakest = enemy
            end
        end
    end
    
    return weakest
end

-- Executor principal do KillAura
function KillAura.Execute()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Atualizar inimigos
    KillAura.ScanEnemies()
    
    -- Decidir se esquivar baseado na quantidade de inimigos e grupos
    local groupCount = 0
    for _, enemy in pairs(KillAura.enemies) do
        if KillAura.IsInDangerousGroup(enemy) then
            groupCount = groupCount + 1
        end
    end
    
    -- Se temos muitos grupos ou inimigos, esquivar
    if groupCount >= 1 or #KillAura.enemies >= (3) then
        KillAura.Evade()
        -- Retornar e esperar próximo ciclo depois da esquiva
        if KillAura.evading then return end
    end
    
    -- Selecionar alvo
    local target = KillAura.SelectTarget()
    
    -- Atacar se tiver alvo
    if target and target:FindFirstChild("HumanoidRootPart") and 
       target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
        
        local isGroup = KillAura.IsInDangerousGroup(target)
        local distance = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
        
        -- Posicionamento tático
        local attackDist = isGroup and 10 or 5 -- Maior distância para grupos
        
        -- Posicionar para ataque
        local oldPos = hrp.CFrame
        hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, isGroup and 2 or 0, attackDist)
        
        -- Executar ataque
        KillAura.Attack(target)
        
        -- Mostrar status
        local health = math.floor((target.Humanoid.Health / target.Humanoid.MaxHealth) * 100)
        local status = isGroup and "⚠️ GRUPO" or "🎯"
        KillAura.log(status .. " Alvo: " .. health .. "% | " .. (#KillAura.enemies) .. " inimigos")
        
        -- Retornar à posição após breve delay
        spawn(function()
            wait(0.1)
            if KillAura.active then
                hrp.CFrame = oldPos
            end
        end)
    else
        KillAura.log("🔍 Procurando | " .. #KillAura.enemies .. " inimigos próximos")
    end
    
    -- Verificar se precisamos esquivar após o ataque
    if #KillAura.enemies >= 3 and math.random(1, 3) == 1 then
        KillAura.Evade()
    end
end

-- Iniciar o KillAura
function KillAura.Start()
    if KillAura.active then return end
    
    KillAura.active = true
    KillAura.log("✅ KillAura Ativado (Detecção: " .. KillAura.detectionRange .. ")")
    
    -- Loop principal
    spawn(function()
        while KillAura.active and wait(0.1) do -- Mais rápido para melhor responsividade
            pcall(KillAura.Execute)
        end
    end)
end

-- Parar o KillAura
function KillAura.Stop()
    KillAura.active = false
    KillAura.log("❌ KillAura Desativado")
end

-- Alternar KillAura
function KillAura.Toggle()
    if KillAura.active then
        KillAura.Stop()
    else
        KillAura.Start()
    end
    return KillAura.active
end

return KillAura
