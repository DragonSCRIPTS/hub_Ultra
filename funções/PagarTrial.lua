-- PagarTrial.lua (Módulo)

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

-- Função para pagar o trial
local function PagarTrial()
    -- Solicita a entrada no local de pagamento (ou qualquer outro comando relacionado)
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875))
    
    -- Aguarda um breve intervalo
    wait(0.5)
    
    -- Movimenta o personagem até a posição do pagamento do trial
    Tween(CFrame.new(28981.552734375, 14888.4267578125, -120.245849609375))
end

-- Retorna a função principal para ser chamada de fora
return PagarTrial
