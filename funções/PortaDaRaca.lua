-- PortaDaRaca.lua (Módulo)

-- Função para mover o personagem até a coordenada utilizando Tween
local function Tween(Pos)
    local HRP = game.Players.LocalPlayer.Character.HumanoidRootPart
    local Distance = (HRP.Position - Pos.Position).Magnitude
    local tween = game:GetService("TweenService"):Create(
        HRP,
        TweenInfo.new(Distance/300, Enum.EasingStyle.Linear),  -- Define a velocidade do movimento
        {CFrame = Pos}  -- Movimenta o personagem para a nova posição
    )
    tween:Play()
    tween.Completed:Wait()  -- Espera até que o movimento esteja completo antes de continuar
end

-- Função para ir até a porta da raça
local function PortaDaRaca()
    -- Solicita a entrada (ou qualquer outro comando relacionado)
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875))
    
    -- Aguarda um breve intervalo
    wait(0.5)
    
    -- Identifica a raça do jogador
    local RaceValue = game:GetService("Players").LocalPlayer.Data.Race.Value
    
    -- Move o jogador até a porta da raça específica
    if RaceValue == "Human" then
        Tween(CFrame.new(29221.822265625, 14890.9755859375, -205.99114990234375))
    elseif RaceValue == "Skypiea" then
        Tween(CFrame.new(28960.158203125, 14919.6240234375, 235.03948974609375))
    elseif RaceValue == "Fishman" then
        Tween(CFrame.new(28231.17578125, 14890.9755859375, -211.64173889160156))
    elseif RaceValue == "Cyborg" then
        Tween(CFrame.new(28502.681640625, 14895.9755859375, -423.7279357910156))
    elseif RaceValue == "Ghoul" then
        Tween(CFrame.new(28674.244140625, 14890.6767578125, 445.4310607910156))
    elseif RaceValue == "Mink" then
        Tween(CFrame.new(29012.341796875, 14890.9755859375, -380.1492614746094))
    end
end

-- Retorna a função principal para ser chamada de fora
return PortaDaRaca
