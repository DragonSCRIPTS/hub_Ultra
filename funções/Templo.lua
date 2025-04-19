-- IrParaTemplo.lua (Módulo)

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

-- Função para mover o personagem até o Templo do Tempo
local function IrParaTemplo()
    -- Definindo a posição do Templo
    local temploPos = Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875)
    
    -- Movendo o personagem até o Templo com o movimento de Tween
    Tween(CFrame.new(temploPos))  -- Aqui usamos o CFrame para o movimento do personagem
    
    -- Solicita a entrada no Templo após o movimento ser concluído
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", temploPos)
end

-- Retorna a função principal para ser chamada de fora
return IrParaTemplo
