-- Script Principal da Interface
-- Orquestra todos os módulos e disponibiliza a interface completa do DragonHUB

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Carregar módulos
local menus = require("registrar_menu")
local MenuBar = require("menu_bar")
local ButtonFactory = require("button_factory")
local botoesPorMenu = require("registrar_botoes")

-- Classe principal da interface
local DragonHUB = {}
DragonHUB.__index = DragonHUB

function DragonHUB.new()
    local self = setmetatable({}, DragonHUB)
    
    -- Criar a interface principal
    self:createMainUI()
    
    -- Inicializar componentes
    self:initComponents()
    
    -- Configurar eventos
    self:setupEvents()
    
    return self
end

function DragonHUB:createMainUI()
    -- Criar o ScreenGui principal
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "DragonHUB"
    self.gui.ResetOnSpawn = false
    self.gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Frame principal
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 600, 0, 400)
    self.mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.gui
    
    -- Arredondar os cantos
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.mainFrame
    
    -- Sombra
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://4996891970"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(20, 20, 280, 280)
    shadow.ZIndex = -1
    shadow.Parent = self.mainFrame
    
    -- Título
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Size = UDim2.new(1, 0, 0, 30)
    self.titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.titleBar
    
    -- Reparar cantos
    local titleFix = Instance.new("Frame")
    titleFix.Name = "TitleFix"
    titleFix.Size = UDim2.new(1, 0, 0.5, 0)
    titleFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleFix.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleFix.BorderSizePixel = 0
    titleFix.ZIndex = 0
    titleFix.Parent = self.titleBar
    
    -- Texto do título
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "DragonHUB"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = self.titleBar
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Position = UDim2.new(1, -30, 0, 3)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeButton.Text = ""
    closeButton.Parent = self.titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self.gui:Destroy()
    end)
    
    -- Botão de minimizar
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 24, 0, 24)
    minimizeButton.Position = UDim2.new(1, -60, 0, 3)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    minimizeButton.Text = ""
    minimizeButton.Parent = self.titleBar
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 12)
    minimizeCorner.Parent = minimizeButton
    
    -- Área para a barra de menus
    self.menuArea = Instance.new("Frame")
    self.menuArea.Name = "MenuArea"
    self.menuArea.Size = UDim2.new(1, 0, 0, 40)
    self.menuArea.Position = UDim2.new(0, 0, 0, 30)
    self.menuArea.BackgroundTransparency = 1
    self.menuArea.Parent = self.mainFrame
    
    -- Área para os botões
    self.contentArea = Instance.new("Frame")
    self.contentArea.Name = "ContentArea"
    self.contentArea.Size = UDim2.new(1, 0, 1, -70)
    self.contentArea.Position = UDim2.new(0, 0, 0, 70)
    self.contentArea.BackgroundTransparency = 1
    self.contentArea.Parent = self.mainFrame
    
    -- Tornar draggable
    self:makeDraggable(self.titleBar)
end

function DragonHUB:initComponents()
    -- Criar a barra de menus
    self.menuBar = MenuBar.new(self.menuArea)
    
    -- Criar a fábrica de botões
    self.buttonFactory = ButtonFactory.new(self.contentArea)
    
    -- Configurar callback para seleção de menu
    self.menuBar:setMenuSelectedCallback(function(menuId)
        self:loadMenuButtons(menuId)
    end)
end

function DragonHUB:loadMenuButtons(menuId)
    -- Carregar os botões correspondentes ao menu selecionado
    local botoes = botoesPorMenu[menuId]
    
    if botoes then
        self.buttonFactory:createButtons(botoes)
    else
        warn("Botões não encontrados para o menu: " .. menuId)
        self.buttonFactory:clearButtons()
    end
end

function DragonHUB:setupEvents()
    -- Eventos adicionais podem ser configurados aqui
    
    -- Configurar o evento de redimensionamento
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            self.gui.Enabled = not self.gui.Enabled
        end
    end)
    
    -- Atualizar tamanho do ScrollingFrame ao redimensionar
    self.mainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        self.buttonFactory:updateContainerSize()
    end)
end

function DragonHUB:makeDraggable(dragObject)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        self.mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    dragObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Iniciar a interface
local dragonHUB = DragonHUB.new()

return dragonHUB
