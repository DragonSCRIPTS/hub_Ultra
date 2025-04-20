-- Script da Barra de Menus (Menu Bar)
-- Responsável pela criação e renderização da barra horizontal de menus

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local menus = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_menu.lua"))()

local MenuBar = {}
MenuBar.__index = MenuBar

function MenuBar.new(parent)
    local self = setmetatable({}, MenuBar)
    
    -- Configurações da barra de menus
    self.menuBarHeight = 40
    self.menuSpacing = 5
    self.parent = parent
    self.menus = menus
    self.menuInstances = {}
    self.selectedMenu = nil
    self.onMenuSelected = nil  -- Callback para quando um menu é selecionado
    
    -- Criar o container da barra de menus
    self.container = Instance.new("Frame")
    self.container.Name = "MenuBarContainer"
    self.container.Size = UDim2.new(1, 0, 0, self.menuBarHeight)
    self.container.Position = UDim2.new(0, 0, 0, 0)
    self.container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.container.BorderSizePixel = 0
    self.container.Parent = parent
    
    -- Criar o layout horizontal
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, self.menuSpacing)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = self.container
    
    -- Padding para os menus
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 5)
    padding.Parent = self.container
    
    -- Criar os menus
    self:createMenus()
    
    -- Configurar o drag-and-drop
    self:setupDragDrop()
    
    return self
end

function MenuBar:createMenus()
    -- Ordenar menus pela ordem definida
    table.sort(self.menus, function(a, b)
        return (a.ordem or 999) < (b.ordem or 999)
    end)
    
    -- Criar botões de menu
    for _, menuInfo in ipairs(self.menus) do
        local menuButton = Instance.new("TextButton")
        menuButton.Name = "Menu_" .. menuInfo.id
        menuButton.Size = UDim2.new(0, menuInfo.tamanho and menuInfo.tamanho[1] or 80, 0, self.menuBarHeight - 10)
        menuButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        menuButton.Text = menuInfo.nome
        menuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        menuButton.Font = Enum.Font.SourceSansBold
        menuButton.TextSize = 14
        menuButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
        menuButton.BorderSizePixel = 1
        menuButton.LayoutOrder = menuInfo.ordem or 999
        menuButton.Parent = self.container
        
        -- Arredondar os cantos
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = menuButton
        
        -- Efeito de hover
        menuButton.MouseEnter:Connect(function()
            if self.selectedMenu ~= menuInfo.id then
                menuButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end
        end)
        
        menuButton.MouseLeave:Connect(function()
            if self.selectedMenu ~= menuInfo.id then
                menuButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
        end)
        
        -- Selecionar menu ao clicar
        menuButton.MouseButton1Click:Connect(function()
            self:selectMenu(menuInfo.id)
        end)
        
        -- Armazenar a instância do botão
        self.menuInstances[menuInfo.id] = {
            button = menuButton,
            info = menuInfo
        }
    end
    
    -- Selecionar o primeiro menu por padrão
    if #self.menus > 0 then
        self:selectMenu(self.menus[1].id)
    end
end

function MenuBar:selectMenu(menuId)
    -- Desselecionar o menu atual
    if self.selectedMenu and self.menuInstances[self.selectedMenu] then
        self.menuInstances[self.selectedMenu].button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    
    -- Selecionar o novo menu
    self.selectedMenu = menuId
    if self.menuInstances[menuId] then
        self.menuInstances[menuId].button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    end
    
    -- Chamar o callback se existir
    if self.onMenuSelected then
        self.onMenuSelected(menuId)
    end
end

function MenuBar:setupDragDrop()
    local isDragging = false
    local dragMenu = nil
    local dragStartPos = nil
    local originalLayouts = {}
    
    -- Guardar posições originais
    for id, instance in pairs(self.menuInstances) do
        originalLayouts[id] = instance.button.LayoutOrder
    end
    
    -- Função auxiliar para troca de ordem
    local function swapMenuLayouts(menu1, menu2)
        local temp = menu1.button.LayoutOrder
        menu1.button.LayoutOrder = menu2.button.LayoutOrder
        menu2.button.LayoutOrder = temp
    end
    
    -- Iniciar drag
    self.container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            
            -- Verificar se clicou em algum menu
            for id, instance in pairs(self.menuInstances) do
                local buttonPos = instance.button.AbsolutePosition
                local buttonSize = instance.button.AbsoluteSize
                
                if mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                   mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y then
                    isDragging = true
                    dragMenu = instance
                    dragStartPos = mousePos
                    
                    -- Efeito visual ao iniciar drag
                    instance.button.BackgroundTransparency = 0.3
                    break
                end
            end
        end
    end)
    
    -- Arrastar
    self.container.InputChanged:Connect(function(input)
        if isDragging and dragMenu and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            
            -- Verificar se está sobre outro menu
            for id, instance in pairs(self.menuInstances) do
                if instance ~= dragMenu then
                    local buttonPos = instance.button.AbsolutePosition
                    local buttonSize = instance.button.AbsoluteSize
                    
                    if mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                       mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y then
                        -- Trocar posições
                        swapMenuLayouts(dragMenu, instance)
                        break
                    end
                end
            end
        end
    end)
    
    -- Terminar drag
    self.container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            if dragMenu then
                dragMenu.button.BackgroundTransparency = 0
                dragMenu = nil
            end
        end
    end)
end

function MenuBar:setMenuSelectedCallback(callback)
    self.onMenuSelected = callback
end

return MenuBar
