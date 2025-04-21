-- Arquivo para definir o alcance do KillAura

-- Verificar se o módulo principal está carregado
if not KillAuraModule then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/funções/Combate e esquiva/Main_Module.lua"))()
    wait(0.1)
end

-- Função para solicitar o alcance
local function promptRange()
    local valid = false
    local newRange = KillAuraModule.attackRange
    
    -- Criar prompt para entrada do alcance
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RangePrompt"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 150)
    frame.Position = UDim2.new(0.5, -125, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.Text = "Definir Alcance"
    title.TextSize = 18
    title.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.8, 0, 0, 30)
    input.Position = UDim2.new(0.1, 0, 0.4, -15)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderText = "Digite o alcance (atual: " .. KillAuraModule.attackRange .. ")"
    input.Text = ""
    input.Font = Enum.Font.SourceSans
    input.TextSize = 16
    input.Parent = frame
    
    local okButton = Instance.new("TextButton")
    okButton.Size = UDim2.new(0.4, 0, 0, 30)
    okButton.Position = UDim2.new(0.1, 0, 0.7, 0)
    okButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    okButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    okButton.Font = Enum.Font.SourceSansBold
    okButton.Text = "OK"
    okButton.TextSize = 16
    okButton.Parent = frame
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0.4, 0, 0, 30)
    cancelButton.Position = UDim2.new(0.5, 0, 0.7, 0)
    cancelButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.Font = Enum.Font.SourceSansBold
    cancelButton.Text = "Cancelar"
    cancelButton.TextSize = 16
    cancelButton.Parent = frame
    
    -- Conexões dos botões
    okButton.MouseButton1Click:Connect(function()
        local inputRange = tonumber(input.Text)
        if inputRange and inputRange > 0 then
            newRange = inputRange
            valid = true
            screenGui:Destroy()
        else
            input.Text = ""
            input.PlaceholderText = "Valor inválido! Tente novamente."
        end
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Aguardar até que o prompt seja fechado
    repeat
        wait(0.1) 
    until not screenGui.Parent or valid
    
    return valid and newRange or KillAuraModule.attackRange
end

-- Definir o novo alcance
local newRange = promptRange()
KillAuraModule.SetRange(newRange)

return newRange
