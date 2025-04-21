-- Subsistema de Detecção de Inimigos

-- Função para atualizar a lista de inimigos próximos
function KillAuraModule.UpdateEnemiesList()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    KillAuraModule.enemies = {}
    
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
                if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and 
                   obj.Humanoid.Health > 0 and obj ~= character then
                    
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
                        if distance <= KillAuraModule.attackRange then
                            table.insert(KillAuraModule.enemies, obj)
                        end
                    end
                end
            end
        end
    end
    
    return #KillAuraModule.enemies
end

-- Função para selecionar o melhor alvo baseado na situação
function KillAuraModule.SelectBestTarget()
    if #KillAuraModule.enemies == 0 then
        return nil
    end
    
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Primeira prioridade: inimigos isolados com pouca vida
    if KillAuraModule.prioritizeLowHealth then
        for _, enemy in pairs(KillAuraModule.enemies) do
            if enemy:FindFirstChild("Humanoid") and 
               KillAuraModule.IsLowHealth(enemy.Humanoid) and 
               not KillAuraModule.IsInDangerousGroup(enemy) then
                return enemy
            end
        end
    end
    
    -- Segunda prioridade: inimigo mais próximo que não está em grupo
    local closestDistance = KillAuraModule.attackRange
    local closestEnemy = nil
    
    for _, enemy in pairs(KillAuraModule.enemies) do
        if enemy:FindFirstChild("HumanoidRootPart") and 
           not KillAuraModule.IsInDangerousGroup(enemy) then
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
    
    for _, enemy in pairs(KillAuraModule.enemies) do
        if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            if enemy.Humanoid.Health < lowestHealth then
                lowestHealth = enemy.Humanoid.Health
                weakestEnemy = enemy
            end
        end
    end
    
    return weakestEnemy
end

-- Sistema de detecção de grupos inimigos
function KillAuraModule.IsInDangerousGroup(enemy)
    if not enemy or not enemy:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local enemyPos = enemy.HumanoidRootPart.Position
    local groupSize = 0
    
    for _, otherEnemy in pairs(KillAuraModule.enemies) do
        if otherEnemy ~= enemy and otherEnemy:FindFirstChild("HumanoidRootPart") then
            local distance = (enemyPos - otherEnemy.HumanoidRootPart.Position).Magnitude
            if distance < 12 then -- Próximo o suficiente para ser considerado grupo
                groupSize = groupSize + 1
                if groupSize >= KillAuraModule.maxEnemyGroupSize then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Funções de retorno
return KillAuraModule
