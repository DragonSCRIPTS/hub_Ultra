-- DragonHUB Interface - Parte 1
-- Implementação do cabeçalho, logo e barra de status
-- Compatível com executor Delta

-- Configurações e variáveis globais
local DragonHUB = {}
DragonHUB.settings = {
    width = 0,
    height = 0,
    version = "1.0.0",
    theme = {
        primary = Color3.fromRGB(41, 53, 68),        -- Azul escuro base
        secondary = Color3.fromRGB(87, 115, 153),    -- Azul médio
        accent = Color3.fromRGB(10, 255, 255),       -- Ciano neon
        accentDark = Color3.fromRGB(0, 180, 216),    -- Ciano escuro
        background = Color3.fromRGB(22, 27, 34),     -- Fundo escuro
        text = Color3.fromRGB(240, 240, 255),        -- Texto claro
        shadow = Color3.fromRGB(10, 12, 18),         -- Sombras
        inactive = Color3.fromRGB(120, 130, 160),    -- Status inativo
        warning = Color3.fromRGB(255, 175, 0),       -- Aviso
        danger = Color3.fromRGB(255, 70, 70),        -- Perigo
    },
    fonts = {
        title = Enum.Font.GothamBold,
        regular = Enum.Font.Gotham,
        monospace = Enum.Font.Code
    }
}

-- Utilitários
local function createRoundedRect(parent, size, position, cornerRadius, color)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, cornerRadius)
    
    return frame
end

local function createGradient(parent, colorSequence, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colorSequence
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function createGlow(parent, size, transparency, color)
    local glow = Instance.new("ImageLabel")
    glow.BackgroundTransparency = 1
    glow.Size = UDim2.new(size, size)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Image = "rbxassetid://1316045217" -- Radial gradient asset
    glow.ImageTransparency = transparency
    glow.ImageColor3 = color
    glow.Parent = parent
    return glow
end

-- Sistema de Animação
DragonHUB.Animator = {}

function DragonHUB.Animator.new()
    local animator = {}
    animator.connections = {}
    animator.tweens = {}
    
    function animator:tween(object, properties, duration, style, direction)
        local info = TweenInfo.new(
            duration or 0.5,
            style or Enum.EasingStyle.Quad,
            direction or Enum.EasingDirection.Out
        )
        
        if self.tweens[object] then
            self.tweens[object]:Cancel()
        end
        
        self.tweens[object] = game:GetService("TweenService"):Create(object, info, properties)
        self.tweens[object]:Play()
        
        return self.tweens[object]
    end
    
    function animator:pulse(object, property, min, max, duration)
        local info = TweenInfo.new(
            duration or 1,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut,
            -1, -- Repetições infinitas
            true -- Yoyo (vai e volta)
        )
        
        local goals = {}
        goals[property] = max
        
        if self.tweens[object] then
            self.tweens[object]:Cancel()
        end
        
        object[property] = min
        self.tweens[object] = game:GetService("TweenService"):Create(object, info, goals)
        self.tweens[object]:Play()
        
        return self.tweens[object]
    end
    
    function animator:cleanup()
        for _, tween in pairs(self.tweens) do
            tween:Cancel()
        end
        
        for _, connection in pairs(self.connections) do
            connection:Disconnect()
        end
        
        self.tweens = {}
        self.connections = {}
    end
    
    return animator
end

-- Criação da Interface Principal
function DragonHUB:createInterface()
    -- Detectar tamanho da tela
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DragonHUB"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Armazenar referência
    self.gui = screenGui
    
    -- Frame principal que conterá toda a interface
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainContainer"
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = self.settings.theme.background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Arredondar bordas do frame principal
    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = UDim.new(0, 12)
    
    -- Adicionar sombra ao frame principal
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1.05, 0, 1.05, 0)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217" -- Radial gradient
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ZIndex = 0
    shadow.Parent = mainFrame
    
    -- Criar header container
    self:createHeader(mainFrame)
    
    -- Criar área para o conteúdo principal (será preenchido nas partes seguintes)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, 0, 0.88, 0)
    contentContainer.Position = UDim2.new(0, 0, 0.12, 0)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    
    -- Armazenar referência para uso futuro
    self.contentContainer = contentContainer
    
    -- Iniciar animador
    self.animator = self.Animator.new()
    
    -- Iniciar atualizações em tempo real
    self:startRealtimeUpdates()
    
    return self
end

-- Criação do Header e Logo
function DragonHUB:createHeader(parent)
    -- Container do Header
    local headerContainer = Instance.new("Frame")
    headerContainer.Name = "HeaderContainer"
    headerContainer.Size = UDim2.new(1, 0, 0.12, 0)
    headerContainer.BackgroundColor3 = self.settings.theme.primary
    headerContainer.BorderSizePixel = 0
    headerContainer.Parent = parent
    
    -- Arredondar cantos superiores
    local headerCorner = Instance.new("UICorner", headerContainer)
    headerCorner.CornerRadius = UDim.new(0, 12)
    
    -- Garantir que só os cantos superiores sejam arredondados
    local bottomFrame = Instance.new("Frame")
    bottomFrame.Size = UDim2.new(1, 0, 0.5, 0)
    bottomFrame.Position = UDim2.new(0, 0, 0.5, 0)
    bottomFrame.BackgroundColor3 = self.settings.theme.primary
    bottomFrame.BorderSizePixel = 0
    bottomFrame.Parent = headerContainer
    
    -- Adicionar gradiente
    local headerGradient = createGradient(
        headerContainer,
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.settings.theme.primary),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(51, 67, 90)),
            ColorSequenceKeypoint.new(1, self.settings.theme.primary)
        }),
        45
    )
    
    -- Criar Logo DragonHUB com efeito metálico 3D
    self:createLogo(headerContainer)
    
    -- Barra de status
    self:createStatusBar(headerContainer)
    
    -- Botões de controle
    self:createControlButtons(headerContainer)
    
    return headerContainer
end

-- Criação do Logo com efeitos 3D
function DragonHUB:createLogo(parent)
    -- Container para o logo
    local logoContainer = Instance.new("Frame")
    logoContainer.Name = "LogoContainer"
    logoContainer.Size = UDim2.new(0.5, 0, 0.6, 0)
    logoContainer.Position = UDim2.new(0.5, 0, 0.25, 0)
    logoContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    logoContainer.BackgroundTransparency = 1
    logoContainer.Parent = parent
    
    -- Texto base para o logo
    local logoText = Instance.new("TextLabel")
    logoText.Name = "LogoText"
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Font = self.settings.fonts.title
    logoText.Text = "DragonHUB"
    logoText.TextSize = 32
    logoText.TextColor3 = self.settings.theme.text
    logoText.Parent = logoContainer
    
    -- Camada de sombra para efeito 3D
    local shadowText = Instance.new("TextLabel")
    shadowText.Name = "ShadowText"
    shadowText.Size = UDim2.new(1, 2, 1, 2)
    shadowText.Position = UDim2.new(0, 2, 0, 2)
    shadowText.BackgroundTransparency = 1
    shadowText.Font = self.settings.fonts.title
    shadowText.Text = "DragonHUB"
    shadowText.TextSize = 32
    shadowText.TextColor3 = self.settings.theme.shadow
    shadowText.ZIndex = logoText.ZIndex - 1
    shadowText.Parent = logoContainer
    
    -- Camada de brilho superior
    local glowText = Instance.new("TextLabel")
    glowText.Name = "GlowText"
    glowText.Size = UDim2.new(1, -1, 1, -1)
    glowText.Position = UDim2.new(0, -1, 0, -1)
    glowText.BackgroundTransparency = 1
    glowText.Font = self.settings.fonts.title
    glowText.Text = "DragonHUB"
    glowText.TextSize = 32
    glowText.TextColor3 = Color3.fromRGB(255, 255, 255)
    glowText.TextTransparency = 0.7
    glowText.ZIndex = logoText.ZIndex + 1
    glowText.Parent = logoContainer
    
    -- Adicionar efeito de brilho neon em volta do texto
    local neonGlow = createGlow(logoContainer, 1.1, 0.7, self.settings.theme.accent)
    
    -- Criar efeito de brilho pulsante
    self.animator:pulse(neonGlow, "ImageTransparency", 0.85, 0.7, 2.5)
    self.animator:pulse(glowText, "TextTransparency", 0.8, 0.5, 3)
    
    -- Adicionar efeito metálico ao texto principal
    local logoGradient = createGradient(
        logoText,
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 220, 255)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(150, 170, 200)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(100, 130, 170)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 160, 190))
        }),
        70
    )
    
    -- Animar o gradiente para criar efeito de reflexo metálico movendo
    local gradientOffset = 0
    local connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
        gradientOffset = (gradientOffset + dt * 0.2) % 1
        logoGradient.Offset = Vector2.new(gradientOffset, 0)
    end)
    
    table.insert(self.animator.connections, connection)
    
    return logoContainer
end

-- Criação da barra de status
function DragonHUB:createStatusBar(parent)
    -- Container para a barra de status
    local statusContainer = Instance.new("Frame")
    statusContainer.Name = "StatusContainer"
    statusContainer.Size = UDim2.new(0.9, 0, 0.18, 0)
    statusContainer.Position = UDim2.new(0.5, 0, 0.75, 0)
    statusContainer.AnchorPoint = Vector2.new(0.5, 0)
    statusContainer.BackgroundColor3 = self.settings.theme.shadow
    statusContainer.BackgroundTransparency = 0.6
    statusContainer.BorderSizePixel = 0
    statusContainer.Parent = parent
    
    -- Arredondar bordas
    local statusCorner = Instance.new("UICorner", statusContainer)
    statusCorner.CornerRadius = UDim.new(0, 8)
    
    -- Adicionar linha brilhante no topo
    local topGlow = Instance.new("Frame")
    topGlow.Name = "TopGlow"
    topGlow.Size = UDim2.new(0.98, 0, 0, 1)
    topGlow.Position = UDim2.new(0.5, 0, 0, 0)
    topGlow.AnchorPoint = Vector2.new(0.5, 0)
    topGlow.BackgroundColor3 = self.settings.theme.accent
    topGlow.BorderSizePixel = 0
    topGlow.Parent = statusContainer
    
    -- Adicionar brilho à linha
    createGlow(topGlow, 2, 0.7, self.settings.theme.accent)
    
    -- Criar indicadores de status
    self:createStatusIndicators(statusContainer)
    
    return statusContainer
end

-- Criação de indicadores na barra de status
function DragonHUB:createStatusIndicators(parent)
    -- Criar lista de indicadores
    local indicators = {
        {name = "Time", icon = "⏱️", getValue = function() return os.date("%H:%M:%S") end},
        {name = "FPS", icon = "📊", getValue = function() return math.floor(workspace:GetRealPhysicsFPS()) end},
        {name = "Ping", icon = "📶", getValue = function() 
            local stats = game:GetService("Stats")
            return math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end},
        {name = "Notif", icon = "🔔", getValue = function() return "0" end}
    }
    
    -- Container de layout horizontal
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 15)
    layout.Parent = parent
    
    -- Criar cada indicador
    for i, indicator in ipairs(indicators) do
        local indicatorFrame = Instance.new("Frame")
        indicatorFrame.Name = indicator.name .. "Indicator"
        indicatorFrame.Size = UDim2.new(0, 70, 0.8, 0)
        indicatorFrame.BackgroundTransparency = 1
        indicatorFrame.LayoutOrder = i
        indicatorFrame.Parent = parent
        
        -- Ícone
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.Size = UDim2.new(0, 20, 0, 20)
        iconLabel.Position = UDim2.new(0, 0, 0.5, 0)
        iconLabel.AnchorPoint = Vector2.new(0, 0.5)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.Text = indicator.icon
        iconLabel.TextSize = 14
        iconLabel.TextColor3 = self.settings.theme.inactive
        iconLabel.Parent = indicatorFrame
        
        -- Valor
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "Value"
        valueLabel.Size = UDim2.new(0, 50, 0, 20)
        valueLabel.Position = UDim2.new(1, 0, 0.5, 0)
        valueLabel.AnchorPoint = Vector2.new(1, 0.5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font.Code
        valueLabel.Text = indicator.getValue() or "-"
        valueLabel.TextSize = 14
        valueLabel.TextColor3 = self.settings.theme.text
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = indicatorFrame
        
        -- Armazenar função de atualização
        indicatorFrame:SetAttribute("updateFunc", indicator.name)
        indicatorFrame:SetAttribute("isActive", true)
        
        -- Pulsing animation for notification icon if it's the notification indicator
        if indicator.name == "Notif" then
            self.animator:pulse(iconLabel, "TextTransparency", 0.1, 0.5, 2)
        end
    end
    
    return indicators
end

-- Botões de controle da interface
function DragonHUB:createControlButtons(parent)
    -- Botões de controle na parte superior direita
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Name = "ControlsContainer"
    controlsContainer.Size = UDim2.new(0, 80, 0, 25)
    controlsContainer.Position = UDim2.new(0.98, 0, 0.15, 0)
    controlsContainer.AnchorPoint = Vector2.new(1, 0)
    controlsContainer.BackgroundTransparency = 1
    controlsContainer.Parent = parent
    
    -- Layout horizontal
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = controlsContainer
    
    -- Botão de minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 22, 0, 22)
    minimizeBtn.BackgroundColor3 = self.settings.theme.warning
    minimizeBtn.Text = "_"
    minimizeBtn.TextSize = 14
    minimizeBtn.Font = self.settings.fonts.title
    minimizeBtn.TextColor3 = Color3.fromRGB(70, 70, 70)
    minimizeBtn.LayoutOrder = 1
    minimizeBtn.Parent = controlsContainer
    
    -- Arredondar botão
    local minimizeCorner = Instance.new("UICorner", minimizeBtn)
    minimizeCorner.CornerRadius = UDim.new(0, 11)
    
    -- Botão de fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.BackgroundColor3 = self.settings.theme.danger
    closeBtn.Text = "×"
    closeBtn.TextSize = 18
    closeBtn.Font = self.settings.fonts.title
    closeBtn.TextColor3 = Color3.fromRGB(70, 70, 70)
    closeBtn.LayoutOrder = 2
    closeBtn.Parent = controlsContainer
    
    -- Arredondar botão
    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0, 11)
    
    -- Adicionar hover e efeitos de clique
    local function setupButtonEffects(button)
        button.MouseEnter:Connect(function()
            self.animator:tween(button, {BackgroundTransparency = 0.1}, 0.2)
            self.animator:tween(button, {TextTransparency = 0.1}, 0.2)
        end)
        
        button.MouseLeave:Connect(function()
            self.animator:tween(button, {BackgroundTransparency = 0}, 0.2)
            self.animator:tween(button, {TextTransparency = 0}, 0.2)
        end)
        
        button.MouseButton1Down:Connect(function()
            self.animator:tween(button, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
        end)
        
        button.MouseButton1Up:Connect(function()
            self.animator:tween(button, {Size = UDim2.new(0, 22, 0, 22)}, 0.1)
        end)
    end
    
    setupButtonEffects(minimizeBtn)
    setupButtonEffects(closeBtn)
    
    -- Funcionalidade
    minimizeBtn.MouseButton1Click:Connect(function()
        self:toggleMinimize()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:close()
    end)
    
    return controlsContainer
end

-- Métodos para funcionalidades da interface
function DragonHUB:toggleMinimize()
    local mainContainer = self.gui:FindFirstChild("MainContainer")
    local contentContainer = mainContainer:FindFirstChild("ContentContainer")
    
    if contentContainer.Visible then
        self.animator:tween(mainContainer, {Size = UDim2.new(0.8, 0, 0.12, 0)}, 0.3)
        contentContainer.Visible = false
    else
        self.animator:tween(mainContainer, {Size = UDim2.new(0.8, 0, 0.8, 0)}, 0.3)
        contentContainer.Visible = true
    end
end

function DragonHUB:close()
    -- Animação de fade out
    self.animator:tween(self.gui, {BackgroundTransparency = 1}, 0.5)
    
    local mainContainer = self.gui:FindFirstChild("MainContainer")
    self.animator:tween(mainContainer, {BackgroundTransparency = 1}, 0.5)
    
    -- Limpar recursos após a animação
    delay(0.5, function()
        self.animator:cleanup()
        self.gui:Destroy()
    end)
end

-- Atualizações em tempo real
function DragonHUB:startRealtimeUpdates()
    -- Atualizar indicadores de status
    local lastUpdateTime = 0
    
    local connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
        local currentTime = tick()
        
        -- Atualizar a cada 0.5 segundos
        if currentTime - lastUpdateTime >= 0.5 then
            lastUpdateTime = currentTime
            
            -- Encontrar o container de status
            local mainContainer = self.gui:FindFirstChild("MainContainer")
            if not mainContainer then return end
            
            local headerContainer = mainContainer:FindFirstChild("HeaderContainer")
            if not headerContainer then return end
            
            local statusContainer = headerContainer:FindFirstChild("StatusContainer")
            if not statusContainer then return end
            
            -- Atualizar cada indicador
            for _, child in pairs(statusContainer:GetChildren()) do
                if child:IsA("Frame") and child:GetAttribute("updateFunc") then
                    local updateFunc = child:GetAttribute("updateFunc")
                    local valueLabel = child:FindFirstChild("Value")
                    local iconLabel = child:FindFirstChild("Icon")
                    
                    if valueLabel and iconLabel then
                        if updateFunc == "Time" then
                            valueLabel.Text = os.date("%H:%M:%S")
                        elseif updateFunc == "FPS" then
                            local fps = math.floor(workspace:GetRealPhysicsFPS())
                            valueLabel.Text = tostring(fps)
                            
                            -- Mudar cor baseado no valor
                            if fps < 30 then
                                valueLabel.TextColor3 = self.settings.theme.danger
                            elseif fps < 60 then
                                valueLabel.TextColor3 = self.settings.theme.warning
                            else
                                valueLabel.TextColor3 = self.settings.theme.accent
                            end
                        elseif updateFunc == "Ping" then
                            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                            valueLabel.Text = tostring(ping)
                            
                            -- Mudar cor baseado no valor
                            if ping > 200 then
                                valueLabel.TextColor3 = self.settings.theme.danger
                            elseif ping > 100 then
                                valueLabel.TextColor3 = self.settings.theme.warning
                            else
                                valueLabel.TextColor3 = self.settings.theme.accent
                            end
                        end
                    end
                end
            end
        end
    end)
    
    table.insert(self.animator.connections, connection)
end

-- Inicialização
function DragonHUB:init()
    self:createInterface()
    return self
end

-- Iniciar a interface
local interface = DragonHUB:init()
