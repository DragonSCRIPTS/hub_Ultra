-- Subsistema de Lógica de Combate

-- Sistema de evasão melhorado
function KillAuraModule.EvadeFromGroups()
    if KillAuraModule.evading then
        return
    end
    
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- Verifique se há grupos perigosos próximos
    local dangerousGroups = {}
    for _, enemy in pairs(KillAuraModule.enemies) do
        if KillAuraModule.IsInDangerousGroup(enemy) then
            table.insert(dangerousGroups, enemy)
        end
    end
    
    if #dangerousGroups > 0 then
        KillAuraModule.evading = true
        KillAuraModule.statusCallback("⚠️ Evasão de grupo iniciada!")
        
        -- Encontrar direção de fuga (oposta ao centro do grupo)
        local groupCenter = Vector3.new(0, 0, 0)
        for _, enemy in pairs(dangerousGroups) do
            if enemy:FindFirstChild("HumanoidRootPart") then
                groupCenter = groupCenter + enemy.HumanoidRootPart.Position
            end
        end
        
        groupCenter = groupCenter / #dangerousGroups
        
        -- Direção oposta ao grupo + alguma altura
        local direction = (hrp.Position - groupCenter).Unit
        local escapePos = hrp.Position + direction * 20 + Vector3.new(0, 5, 0)
        
        -- Executar uma evasão
        local oldPos = hrp.CFrame
        hrp.CFrame = CFrame.new(escapePos)
        
        -- Esperar até completar uma evasão
        spawn(function()
            wait(0.5)
            KillAuraModule.evading = false
        end)
    end
end

-- Função para usar uma habilidade específica
function KillAuraModule.UseSkill(key)
    if KillAuraModule.skillCooldowns[key].active then
        return false
    end
    
    -- Marcar a habilidade como em cooldown
    KillAuraModule.skillCooldowns[key].active = true
    
    -- Usar uma habilidade com input virtual
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    wait(0.08)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
    
    -- Reiniciar o status do combo
    KillAuraModule.comboHitCount = 0
    
    -- Iniciar o cooldown
    spawn(function()
        wait(KillAuraModule.skillCooldowns[key].cooldown)
        KillAuraModule.skillCooldowns[key].active = false
    end)
    
    KillAuraModule.statusCallback("Skill " .. key .. " ⚡")
    return true
end

-- Função para selecionar e usar a melhor habilidade baseada na situação
function KillAuraModule.UseBestSkill(enemy)
    local availableSkills = KillAuraModule.GetAvailableSkills()
    if #availableSkills == 0 then
        return false
    end
    
    local isLowHealth = KillAuraModule.IsLowHealth(enemy:FindFirstChild("Humanoid"))
    local isInGroup = KillAuraModule.IsInDangerousGroup(enemy)
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
        if math.random(1, 10) <= 4 then -- 40% de chance de usar habilidade
            for _, key in ipairs({"Z", "X", "C"}) do
                if table.find(availableSkills, key) then
                    selectedKey = key
                    break
                end
            end
        end
    end
    
    if selectedKey then
        return KillAuraModule.UseSkill(selectedKey)
    end
    
    return false
end

-- Sistema de Combo Otimizado
function KillAuraModule.ExecuteComboAttack()
    if KillAuraModule.normalAttackCooldown then
        return false
    end
    
    KillAuraModule.normalAttackCooldown = true
    
    -- Sistema de combo dinâmico
    if KillAuraModule.comboHitCount >= KillAuraModule.maxComboHits then
        KillAuraModule.comboHitCount = 0
        wait(0.3) -- Pausa curta ao final do combo
    else
        KillAuraModule.comboHitCount = KillAuraModule.comboHitCount + 1
    end
    
    -- Clique para atacar com padrão de combo variável
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    -- Padrões diferentes de ataque baseados no número do combo
    if KillAuraModule.comboHitCount % 4 == 1 then
        -- Ataque rápido simples
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.04)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    elseif KillAuraModule.comboHitCount % 4 == 2 then
        -- Clique duplo
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    elseif KillAuraModule.comboHitCount % 4 == 3 then
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
        wait(KillAuraModule.clickDelay)
        KillAuraModule.normalAttackCooldown = false
    end)
    
    return true
end

-- Função simples para ataque rápido
function KillAuraModule.UseQuickAttack()
    if KillAuraModule.normalAttackCooldown then
        return false
    end
    
    KillAuraModule.normalAttackCooldown = true
    
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    wait(0.04)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    spawn(function()
        wait(KillAuraModule.clickDelay)
        KillAuraModule.normalAttackCooldown = false
    end)
    
    return true
end

-- Função principal KillAura otimizada
function KillAuraModule.PerformKillAura()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- Expandir raio de simulação para alcançar mais longe
    pcall(function()
        sethiddenproperty(player, "SimulationRadius", 1000)
    end)
    
    -- Atualizar lista de inimigos
    KillAuraModule.UpdateEnemiesList()
    
    -- Verifique se precisamos evitar grupos
    if #KillAuraModule.enemies >= KillAuraModule.maxEnemyGroupSize then
        KillAuraModule.EvadeFromGroups()
        if KillAuraModule.evading then
            return
        end -- Aguardar evasão completar
    end
    
    -- Exibir informações de status
    local cooldownInfo = ""
    for key, data in pairs(KillAuraModule.skillCooldowns) do
        cooldownInfo = cooldownInfo .. (data.active and "⌛" or "✅") .. key .. " "
    end
    
    -- Selecionar o melhor alvo
    local bestTarget = KillAuraModule.SelectBestTarget()
    
    -- Temos um alvo válido
    if bestTarget and bestTarget:FindFirstChild("Humanoid") and 
       bestTarget.Humanoid.Health > 0 and bestTarget:FindFirstChild("HumanoidRootPart") then
        
        local distance = (hrp.Position - bestTarget.HumanoidRootPart.Position).Magnitude
        local isInGroup = KillAuraModule.IsInDangerousGroup(bestTarget)
        
        -- Posicionamento tático
        local posOffset = isInGroup and 7 or 4 -- Maior distância se for grupo
        
        -- Salvar posição original
        local oldPos = hrp.CFrame
        
        -- Estratégia de ataque
        if isInGroup then
            -- Para grupos: manter distância e usar habilidades mais fortes
            hrp.CFrame = bestTarget.HumanoidRootPart.CFrame * CFrame.new(0, 1, posOffset)
            
            -- Prioridade absoluta para habilidades em grupos
            if KillAuraModule.skillsActive then
                KillAuraModule.UseBestSkill(bestTarget)
            else
                KillAuraModule.UseQuickAttack() -- Ataque rápido sem combo para grupos
            end
        else
            -- Para inimigos isolados: aproximar e usar combo ou habilidade
            hrp.CFrame = bestTarget.HumanoidRootPart.CFrame * CFrame.new(0, 0, posOffset)
            
            -- Certifique-se de usar habilidade ou ataque normal
            local usedSkill = false
            if KillAuraModule.skillsActive then
                -- Priorizar habilidade se inimigo com pouca vida
                if KillAuraModule.IsLowHealth(bestTarget.Humanoid) then
                    usedSkill = KillAuraModule.UseBestSkill(bestTarget)
                elseif math.random(1, 10) <= 3 then -- 30% de chance para outros casos
                    usedSkill = KillAuraModule.UseBestSkill(bestTarget)
                end
            end
            
            -- Se não usar habilidade, use ataque normal
            if not usedSkill then
                if KillAuraModule.comboModeActive then
                    KillAuraModule.ExecuteComboAttack()
                else
                    KillAuraModule.UseQuickAttack()
                end
            end
        end
        
        -- Status do alvo
        local health = math.floor((bestTarget.Humanoid.Health / bestTarget.Humanoid.MaxHealth) * 100)
        local statusIcon = isInGroup and "⚠️ GRUPO" or "🎯"
        KillAuraModule.statusCallback(statusIcon .. " Alvo: " .. health .. "% | " .. cooldownInfo)
        
        -- Verifique se o alvo morreu
        if bestTarget.Humanoid.Health <= 0 then
            KillAuraModule.statusCallback("✅ Inimigo eliminado!")
        end
        
        -- Voltar à posição original com delay
        spawn(function()
            wait(0.15)
            hrp.CFrame = oldPos
        end)
    else
        KillAuraModule.statusCallback("🔍 Procurando (" .. #KillAuraModule.enemies .. " próximos) | " .. cooldownInfo)
    end
end

return KillAuraModule
