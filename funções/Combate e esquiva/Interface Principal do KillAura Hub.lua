-- Interface Principal do KillAura Hub
local KillAuraHub = {}

-- Configuração da GUI
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KillAuraHubGUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.8, 0, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.Text = "KillAura Anti-Raid v4.0"
    title.TextSize = 18
    title.Parent = mainFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 60)
    statusLabel.Position = UDim2.new(0, 10, 0, 40)
    statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Text = "Status: Desativado\nInimigos próximos: 0"
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.Parent = mainFrame
    
    -- Função para criar botões
    local function createButton(name, text, posY, callback)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(0.9, 0, 0, 40)
        button.Position = UDim2.new(0.05, 0, 0, posY)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.SourceSansBold
        button.Text = text
        button.TextSize = 16
        button.Parent = mainFrame
        
        button.MouseButton1Click:Connect(callback)
        return button
    end
    
    -- Botões de ação
    local killAuraButton = createButton("KillAuraToggle", "🔄 Ativar KillAura", 110, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/funções/Combate e esquiva/KillAura_Toggle.lua"))()
        wait(0.1)
        killAuraButton.Text = KillAuraModule and KillAuraModule.active and "❌ Desativar KillAura" or "✅ Ativar KillAura"
    end)
    
    local skillsButton = createButton("SkillsToggle", "🔄 Habilidades", 160, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/funções/Combate e esquiva/Skills_Toggle.lua"))()
        wait(0.1)
        skillsButton.Text = KillAuraModule and KillAuraModule.skillsActive and "❌ Desativar Habilidades" or "✅ Ativar Habilidades"
    end)
    
    local comboButton = createButton("ComboToggle", "🔄 Modo Combo", 210, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/funções/Combate e esquiva/Combo_Toggle.lua"))()
        wait(0.1)
        comboButton.Text = KillAuraModule and KillAuraModule.comboModeActive and "❌ Desativar Combo" or "✅ Ativar Combo"
    end)
    
    local rangeButton = createButton("RangeSet", "🔍 Alcance: 60", 260, function()
        local currentRange = KillAuraModule and KillAuraModule.attackRange or 60
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/funções/Combate e esquiva/Range_Set.lua"))()
        wait(0.1)
        rangeButton.Text = "🔍 Alcance: " .. (KillAuraModule and KillAuraModule.attackRange or currentRange)
    end)
    
    local clearButton = createButton("ResetModule", "🔄 Reiniciar Script", 310, function()
        if KillAuraModule and KillAuraModule.active then
            KillAuraModule.Stop()
        end
        
        -- Recarregar o módulo principal
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/funções/Combate e esquiva/Main_Module.lua"))()
        wait(0.1)
        statusLabel.Text = "Script reiniciado!"
        
        -- Atualizar estados dos botões
        killAuraButton.Text = "✅ Ativar KillAura"
        skillsButton.Text = KillAuraModule and KillAuraModule.skillsActive and "❌ Desativar Habilidades" or "✅ Ativar Habilidades"
        comboButton.Text = KillAuraModule and KillAuraModule.comboModeActive and "❌ Desativar Combo" or "✅ Ativar Combo"
        rangeButton.Text = "🔍 Alcance: " .. (KillAuraModule and KillAuraModule.attackRange or 60)
    end)
    
    -- Função para atualizar o status
    local function updateStatus(message)
        statusLabel.Text = message
    end
    
    return {
        screenGui = screenGui,
        mainFrame = mainFrame,
        statusLabel = statusLabel,
        updateStatus = updateStatus
    }
end

-- Inicializar a interface
local gui = createGui()

-- Carregar o módulo principal primeiro
loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/funções/Combate e esquiva/Main_Module.lua"))()

-- Configurar o callback de status
if KillAuraModule then
    KillAuraModule.SetStatusCallback(function(message)
        gui.updateStatus(message)
    end)
end

return KillAuraHub
