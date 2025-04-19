-- ImobilizarNPCs.lua
local module = {}

function module.Ativar()
    getgenv().ImobilizarNPCs = true
    task.spawn(function()
        while getgenv().ImobilizarNPCs do
            task.wait(0.1)
            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                    local root = enemy.HumanoidRootPart
                    root.Anchored = true
                    root.Velocity = Vector3.new(0, 0, 0)
                    enemy.Humanoid.PlatformStand = true
                end
            end
        end
    end)
end

function module.Desativar()
    getgenv().ImobilizarNPCs = false
    -- Desancorar NPCs se quiser "liberar" eles ao desligar
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") then
            enemy.HumanoidRootPart.Anchored = false
            enemy.Humanoid.PlatformStand = false
        end
    end
end

return module
