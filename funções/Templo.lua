-- Módulo: Ir ao Templo

-- Adiciona a seção para o Templo do Tempo
raceTab:AddSection("Templo do Tempo")

-- Adiciona o botão de entrada para o Templo
raceTab:AddButton({
    Title = "Ir ao Templo",  -- Título do botão
    Callback = function()    -- Função de callback ao clicar no botão
        -- Solicita a entrada no Templo do Tempo com as coordenadas específicas
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(
            "requestEntrance", 
            Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875)
        )
    end
})
