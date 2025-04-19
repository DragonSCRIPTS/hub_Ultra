-- auto_trial.lua (Módulo)

-- Função para verificar a raça do jogador
local function GetPlayerRace()
    return game:GetService("Players").LocalPlayer.Data.Race.Value
end

-- Função para teleportar para o alvo usando Tween
local function Tween(targetCFrame)
    local humanoidRootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(
            (targetCFrame.Position - humanoidRootPart.Position).Magnitude / 250,
            Enum.EasingStyle.Linear
        )
        
        local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Função para teleportar diretamente para uma posição
local function toTarget(targetCFrame)
    local humanoidRootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = targetCFrame
    end
end

-- Função para usar habilidades
local function UseSkill()
    local skillKeys = {"Z", "X", "C", "V", "F"}
    for _, key in pairs(skillKeys) do
        game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
        wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
        wait(0.5)
    end
end

-- Função para matar todos os inimigos (para trials de Human e Ghoul)
local function KillAura()
    for i, v in pairs(game.Workspace.Enemies:GetDescendants()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            pcall(function()
                v.Humanoid.Health = 0
                v.HumanoidRootPart.CanCollide = false
                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
            end)
        end
    end
end

-- Função principal de Auto Trial
local function AutoTrial()
    -- Variáveis de controle
    local KillAuraActive = false
    local AutoTrialActive = false
    
    -- Configuração da interface do usuário (UI)
    local function SetupUI(raceTab)
        -- Toggle para Human/Ghoul Trial
        local humanGhoulToggle = raceTab:AddToggle({
            Title = "Auto Human/Ghoul Trial",
            Default = false
        })
        
        humanGhoulToggle:OnChanged(function(state)
            KillAuraActive = state
            
            spawn(function()
                while KillAuraActive do
                    wait()
                    KillAura()
                end
            end)
        end)
        
        -- Toggle para Auto Race Trial
        local autoTrialToggle = raceTab:AddToggle({
            Title = "Auto Trial de Raça",
            Default = false
        })
        
        autoTrialToggle:OnChanged(function(state)
            AutoTrialActive = state
            
            spawn(function()
                pcall(function()
                    while wait() do
                        if AutoTrialActive then
                            local RaceValue = GetPlayerRace()
                            
                            if RaceValue == "Human" then
                                KillAura()
                            elseif RaceValue == "Skypiea" then
                                for i, v in pairs(game:GetService("Workspace").Map.SkyTrial.Model:GetDescendants()) do
                                    if v.Name == "snowisland_Cylinder.081" then
                                        toTarget(v.CFrame * CFrame.new(0, 0, 0))
                                    end
                                end
                            elseif RaceValue == "Fishman" then
                                for i, v in pairs(game:GetService("Workspace").SeaBeasts.SeaBeast1:GetDescendants()) do
                                    if v.Name == "HumanoidRootPart" then
                                        Tween(v.CFrame * CFrame.new(0, 30, 0))
                                        UseSkill()
                                    end
                                end
                            elseif RaceValue == "Cyborg" then
                                Tween(CFrame.new(28654, 14898.7832, -30, 1, 0, 0, 0, 1, 0, 0, 0, 1))
                            elseif RaceValue == "Ghoul" then
                                KillAura()
                            elseif RaceValue == "Mink" then
                                for i, v in pairs(game:GetService("Workspace"):GetDescendants()) do
                                    if v.Name == "StartPoint" then
                                        Tween(v.CFrame * CFrame.new(0, 10, 0))
                                    end
                                end
                            end
                        end
                    end
                end)
            end)
        end)
        
        return {
            humanGhoulToggle = humanGhoulToggle,
            autoTrialToggle = autoTrialToggle
        }
    end
    
    -- Retornar a função de configuração da UI
    return SetupUI
end

-- Retorna a função principal para ser chamada de fora
return AutoTrial()
