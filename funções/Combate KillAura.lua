-- Módulo de Combate KillAura sem Interface
-- Criado para ser carregado via loadstring
local CombatModule = {}

-- Variáveis do módulo
CombatModule.killAuraActive = false
CombatModule.skillsActive = true
CombatModule.comboModeActive = true
CombatModule.attackRange = 50
CombatModule.targetEnemy = nil
CombatModule.normalAttackCooldown = false
CombatModule.skillKeys = {"Z", "X", "C"} -- Teclas de skill
CombatModule.clickDelay = 0.1 -- Delay para ataques em combo
CombatModule.isInCombo = false
CombatModule.comboHitCount = 0
CombatModule.maxComboHits = 6 -- Número máximo de hits em um combo
CombatModule.statusCallback = function(message) print(message) end -- Callback para status (pode ser substituído)

-- Sistema de cooldown individual para cada skill
CombatModule.skillCooldowns = {
    Z = {active = false, cooldown = 3}, -- 3 segundos de cooldown para Z
    X = {active = false, cooldown = 5}, -- 5 segundos para X
    C = {active = false, cooldown = 7}  -- 7 segundos para C
}

-- Função para verificar se o inimigo está com pouca vida
function CombatModule.IsLowHealth(humanoid)
    return humanoid.Health <= humanoid.MaxHealth * 0.3 -- Considera baixa quando está abaixo de 30%
end

-- Função para verificar quais skills estão disponíveis
function CombatModule.GetAvailableSkills()
    local available = {}
    for key, data in pairs(CombatModule.skillCooldowns) do
        if not data.active then
            table.insert(available, key)
        end
    end
    return available
end

-- Função para usar uma skill específica
function CombatModule.UseSkill(key)
    if CombatModule.skillCooldowns[key].active then return false end
    
    -- Marcar a skill como em cooldown
    CombatModule.skillCooldowns[key].active = true
    
    -- Usar a skill
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
    
    -- Interromper qualquer combo atual
    CombatModule.isInCombo = false
    CombatModule.comboHitCount = 0
    
    -- Iniciar o cooldown
    spawn(function()
        wait(CombatModule.skillCooldowns[key].cooldown)
        CombatModule.skillCooldowns[key].active = false
    end)
    
    CombatModule.statusCallback("Usando skill " .. key)
    return true
end

-- Função para selecionar e usar a melhor skill disponível
function CombatModule.UseBestAvailableSkill(isLowHealth)
    local availableSkills = CombatModule.GetAvailableSkills()
    
    if #availableSkills == 0 then
        CombatModule.statusCallback("Todas skills em cooldown")
        return false
    end
    
    local selectedKey
    
    if isLowHealth then
        -- Prioridade para skills fortes quando inimigo está com pouca vida
        for _, key in ipairs({"C", "X", "Z"}) do
            if table.find(availableSkills, key) then
                selectedKey = key
                break
            end
        end
    else
        -- Em outros casos, priorizamos skills mais fracas para economizar as fortes
        for _, key in ipairs({"Z", "X", "C"}) do
            if table.find(availableSkills, key) then
                selectedKey = key
                break
            end
        end
    end
    
    -- Se não encontrou nenhuma das preferidas, pega a primeira disponível
    if not selectedKey and #availableSkills > 0 then
        selectedKey = availableSkills[1]
    end
    
    if selectedKey then
        return CombatModule.UseSkill(selectedKey)
    end
    
    return false
end

-- Sistema de Combo Aprimorado
function CombatModule.ExecuteComboAttack()
    if CombatModule.normalAttackCooldown then return false end
    
    CombatModule.normalAttackCooldown = true
    
    -- Se não estiver em um combo, iniciamos um novo
    if not CombatModule.isInCombo then
        CombatModule.isInCombo = true
        CombatModule.comboHitCount = 1
    else
        -- Se já estiver em um combo, incrementamos o contador
        CombatModule.comboHitCount = CombatModule.comboHitCount + 1
        if CombatModule.comboHitCount > CombatModule.maxComboHits then
            -- Resetar o combo após atingir o máximo
            wait(0.5) -- Pausa para finalizar o combo
            CombatModule.isInCombo = false
            CombatModule.comboHitCount = 0
            CombatModule.normalAttackCooldown = false
            return true
        end
    end
    
    -- Ajustar a posição do atacante em relação ao alvo para maximizar o hit
    -- Posições diferentes para cada hit do combo, girando ao redor do alvo
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    if CombatModule.targetEnemy and CombatModule.targetEnemy:FindFirstChild("HumanoidRootPart") then
        local angle = (CombatModule.comboHitCount % 4) * (math.pi / 2) -- Gira em 90 graus
        local offset = CFrame.new(math.cos(angle) * 3, 0, math.sin(angle) * 3)
        
        -- Salvar posição original
        local originalPos = hrp.CFrame
        
        -- Movimentar para a posição ideal de ataque
        hrp.CFrame = CombatModule.targetEnemy.HumanoidRootPart.CFrame * offset
        
        -- Executar o ataque com variações baseadas no número do combo
        wait(0.05) -- Pequena pausa para garantir o posicionamento
        
        -- Variação no tipo de clique baseado no número do combo
        if CombatModule.comboHitCount % 3 == 1 then
            -- Clique simples (jab)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        elseif CombatModule.comboHitCount % 3 == 2 then
            -- Clique duplo rápido (combo hit)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            wait(0.03)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            wait(0.03)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            wait(0.03)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        else
            -- Clique segurando (poder)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            wait(0.15) -- Segura por mais tempo
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
        
        -- Voltar à posição original com ligeiro atraso para simular movimento natural
        wait(0.02)
        hrp.CFrame = originalPos
    end
    
    -- Definir um tempo de cooldown mais curto para manter o ritmo do combo
    local comboSpeed = 0.15 -- Tempo entre hits do combo
    
    spawn(function()
        wait(comboSpeed)
        CombatModule.normalAttackCooldown = false
    end)
    
    CombatModule.statusCallback("Combo Hit #" .. CombatModule.comboHitCount)
    return true
end

-- Função para usar ataque normal (sem combo)
function CombatModule.UseNormalAttack()
    if CombatModule.normalAttackCooldown then return false end
    
    CombatModule.normalAttackCooldown = true
    
    -- Simula um clique do mouse para ataque normal
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    -- Define um tempo de cooldown para não sobrecarregar
    spawn(function()
        wait(CombatModule.clickDelay) -- Delay entre ataques normais
        CombatModule.normalAttackCooldown = false
    end)
    
    CombatModule.statusCallback("Usando ataque normal")
    return true
end

-- Função KillAura Aprimorada
function CombatModule.PerformKillAura()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Expandir o raio de simulação
    pcall(function()
        sethiddenproperty(player, "SimulationRadius", math.huge)
    end)
    
    -- Exibir informações de cooldown das skills
    local cooldownInfo = "Skills: "
    for key, data in pairs(CombatModule.skillCooldowns) do
        if data.active then
            cooldownInfo = cooldownInfo .. key .. "(CD), "
        else
            cooldownInfo = cooldownInfo .. key .. "(✓), "
        end
    end
    cooldownInfo = cooldownInfo:sub(1, -3) -- Remover última vírgula e espaço
    
    -- Se já temos um alvo, verifica se ele ainda é válido
    if CombatModule.targetEnemy and CombatModule.targetEnemy:FindFirstChild("Humanoid") and 
       CombatModule.targetEnemy.Humanoid.Health > 0 and CombatModule.targetEnemy:FindFirstChild("HumanoidRootPart") then
        local distance = (hrp.Position - CombatModule.targetEnemy.HumanoidRootPart.Position).Magnitude
        
        if distance <= CombatModule.attackRange then
            -- Atualizar status
            local statusText = "Atacando a " .. math.floor(distance) .. " studs"
            if CombatModule.isInCombo then
                statusText = statusText .. " | Combo: " .. CombatModule.comboHitCount .. "/" .. CombatModule.maxComboHits
            end
            CombatModule.statusCallback(statusText .. " | " .. cooldownInfo)
            
            -- Guardar posição original
            local oldPos = hrp.CFrame
            
            -- Verificar se inimigo está com pouca vida
            local isLowHealth = CombatModule.IsLowHealth(CombatModule.targetEnemy.Humanoid)
            
            -- Posicionar estrategicamente perto do inimigo para atacar
            -- No modo combo, o posicionamento será feito na função ExecuteComboAttack
            if not CombatModule.comboModeActive or not CombatModule.isInCombo then
                hrp.CFrame = CombatModule.targetEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
            
            local attackSuccess = false
            
            -- Sistema de ataque priorizado
            if CombatModule.skillsActive then
                -- Quando inimigo tem pouca vida, usar skills sempre que possível
                if isLowHealth then
                    -- Tentar usar a melhor skill disponível
                    attackSuccess = CombatModule.UseBestAvailableSkill(true)
                else
                    -- Quando inimigo tem muita vida, usar skills com 30% de chance
                    -- Reduzido para dar mais prioridade aos combos no modo normal
                    if math.random(1, 10) <= 3 then
                        attackSuccess = CombatModule.UseBestAvailableSkill(false)
                    end
                end
            end
            
            -- Se não conseguiu usar skill, usar ataque (normal ou combo)
            if not attackSuccess then
                if CombatModule.comboModeActive then
                    CombatModule.ExecuteComboAttack()
                else
                    CombatModule.UseNormalAttack()
                end
            end
            
            -- Verificar se o inimigo morreu
            if not CombatModule.targetEnemy:FindFirstChild("Humanoid") or CombatModule.targetEnemy.Humanoid.Health <= 0 then
                CombatModule.statusCallback("Inimigo eliminado! | " .. cooldownInfo)
                CombatModule.targetEnemy = nil
                CombatModule.isInCombo = false
                CombatModule.comboHitCount = 0
            end
            
            -- Voltar à posição original (se não estiver em combo)
            if not CombatModule.isInCombo then
                wait(0.1)
                hrp.CFrame = oldPos
            end
            
            return -- Saímos da função porque já processamos o alvo
        else
            -- Alvo fora de alcance, limpa o alvo atual
            CombatModule.targetEnemy = nil
            CombatModule.isInCombo = false
            CombatModule.comboHitCount = 0
            CombatModule.statusCallback("Alvo fora de alcance | " .. cooldownInfo)
        end
    else
        -- Limpa o alvo se não for mais válido
        CombatModule.targetEnemy = nil
        CombatModule.isInCombo = false
        CombatModule.comboHitCount = 0
    end
    
    -- Se não temos um alvo, procurar por novos inimigos
    local nearestDistance = CombatModule.attackRange
    local nearestEnemy = nil
    
    -- Verificar em Workspace.Enemies (estrutura comum em muitos jogos)
    if game.Workspace:FindFirstChild("Enemies") then
        for _, enemy in pairs(game.Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                local distance = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
                
                if distance <= nearestDistance then
                    nearestDistance = distance
                    nearestEnemy = enemy
                end
            end
        end
    end
    
    -- Se não encontrou em Enemies, procura direto no Workspace (para jogos que usam outra estrutura)
    if not nearestEnemy then
        for _, obj in pairs(game.Workspace:GetChildren()) do
            if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and 
               obj.Humanoid.Health > 0 and obj ~= character then
                
                -- Verificar se parece ser um inimigo (não é outro jogador)
                local isPlayer = false
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p.Character == obj then
                        isPlayer = true
                        break
                    end
                end
                
                if not isPlayer then
                    local distance = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
                    if distance <= nearestDistance then
                        nearestDistance = distance
                        nearestEnemy = obj
                    end
                end
            end
        end
    end
    
    -- Se encontramos um novo alvo, definimos ele como o alvo atual
    if nearestEnemy then
        CombatModule.targetEnemy = nearestEnemy
        CombatModule.statusCallback("Novo alvo a " .. math.floor(nearestDistance) .. " studs | " .. cooldownInfo)
    else
        CombatModule.statusCallback("Procurando alvos... | " .. cooldownInfo)
    end
end

-- Função para iniciar o KillAura
function CombatModule.StartKillAura()
    if CombatModule.killAuraActive then return end
    
    CombatModule.killAuraActive = true
    CombatModule.statusCallback("KillAura ativado")
    
    -- Inicia o loop do KillAura
    spawn(function()
        while CombatModule.killAuraActive and wait(0.2) do -- 0.2 segundos para ser mais responsivo
            pcall(CombatModule.PerformKillAura)
        end
    end)
end

-- Função para parar o KillAura
function CombatModule.StopKillAura()
    CombatModule.killAuraActive = false
    CombatModule.statusCallback("KillAura desativado")
    CombatModule.targetEnemy = nil -- Limpar alvo ao desativar
    CombatModule.isInCombo = false -- Resetar estado de combo
    CombatModule.comboHitCount = 0
end

-- Função para alternar o KillAura
function CombatModule.ToggleKillAura()
    if CombatModule.killAuraActive then
        CombatModule.StopKillAura()
    else
        CombatModule.StartKillAura()
    end
    return CombatModule.killAuraActive
end

-- Função para ativar/desativar o uso de skills
function CombatModule.ToggleSkills()
    CombatModule.skillsActive = not CombatModule.skillsActive
    
    if CombatModule.skillsActive then
        CombatModule.statusCallback("Skills ativadas")
    else
        CombatModule.statusCallback("Skills desativadas")
    end
    
    return CombatModule.skillsActive
end

-- Função para ativar/desativar o modo combo
function CombatModule.ToggleComboMode()
    CombatModule.comboModeActive = not CombatModule.comboModeActive
    CombatModule.isInCombo = false -- Resetar estado de combo ao trocar de modo
    CombatModule.comboHitCount = 0
    
    if CombatModule.comboModeActive then
        CombatModule.statusCallback("Modo Combo ativado")
    else
        CombatModule.statusCallback("Modo Combo desativado")
    end
    
    return CombatModule.comboModeActive
end

-- Função para definir o alcance do KillAura
function CombatModule.SetRange(range)
    if tonumber(range) and tonumber(range) > 0 then
        CombatModule.attackRange = tonumber(range)
        CombatModule.statusCallback("Alcance ajustado para " .. CombatModule.attackRange)
        return true
    end
    return false
end

-- Função para definir callback de status (para integração com UI)
function CombatModule.SetStatusCallback(callback)
    if type(callback) == "function" then
        CombatModule.statusCallback = callback
        return true
    end
    return false
end

-- Mensagem de inicialização
print("Módulo de Combate KillAura Avançado v3 carregado!")

return CombatModule
