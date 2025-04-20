-- Script de Criação de Botões (Button Factory)
-- Responsável por construir os botões da interface com base nas configurações

local HttpService = game:GetService("HttpService")

local ButtonFactory = {}
ButtonFactory.__index = ButtonFactory

function ButtonFactory.new(parent)
    local self = setmetatable({}, ButtonFactory)
    
    self.parent = parent
    self.buttonSize = Vector2.new(80, 80)
    self.buttonSpacing = 10
    self.buttonsPerRow = 4
    self.currentButtons = {}
    
    -- Container para os botões
    self.container = Instance.new("ScrollingFrame")
    self.container.Name = "ButtonsContainer"
    self.container.Size = UDim2.new(1, 0, 1, 0)
    self.container.BackgroundTransparency = 1
    self.container.BorderSizePixel = 0
    self.container.ScrollBarThickness = 6
    self.container.Parent = parent
    
    -- Grid layout para os botões
    self.gridLayout = Instance.new("UIGridLayout")
    self.gridLayout.CellSize = UDim2.new(0, self.buttonSize.X, 0, self.buttonSize.Y)
    self.gridLayout.CellPadding = UDim2.new(0, self.buttonSpacing, 0, self.buttonSpacing)
    self.gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.gridLayout.Parent = self.container
    
    -- Padding para o grid
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = self.container
    
    return self
end

function ButtonFactory:clearButtons()
    -- Limpar botões existentes
    for _, button in pairs(self.currentButtons) do
        button:Destroy()
    end
    self.currentButtons = {}
end

function ButtonFactory:createButtons(buttonData)
    -- Limpar botões existentes
    self:clearButtons()
    
    -- Ordenar botões pela ordem definida
    table.sort(buttonData, function(a, b)
        return (a.ordem or 999) < (b.ordem or 999)
    end)
    
    -- Criar novos botões
    for i, btnInfo in ipairs(buttonData) do
        local button = Instance.new("Frame")
        button.Name = "Button_" .. btnInfo.id
        button.Size = UDim2.new(0, btnInfo.tamanho and btnInfo.tamanho[1] or self.buttonSize.X, 
                                0, btnInfo.tamanho and btnInfo.tamanho[2] or self.buttonSize.Y)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        button.BorderColor3 = Color3.fromRGB(60, 60, 60)
        button.BorderSizePixel = 1
        button.LayoutOrder = btnInfo.ordem or i
        button.Parent = self.container
        
        -- Arredondar os cantos
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button
        
        -- Imagem do botão
        local image = Instance.new("ImageLabel")
        image.Name = "ButtonImage"
        image.Size = UDim2.new(0.7, 0, 0.7, 0)
        image.Position = UDim2.new(0.15, 0, 0.05, 0)
        image.BackgroundTransparency = 1
        image.Image = btnInfo.imagem_link or "rbxassetid://0"
        image.ImageTransparency = btnInfo.estado_imagem == false and 0.5 or 0
        image.Parent = button
        
        -- Texto do botão
        local text = Instance.new("TextLabel")
        text.Name = "ButtonText"
        text.Size = UDim2.new(1, 0, 0.25, 0)
        text.Position = UDim2.new(0, 0, 0.75, 0)
        text.BackgroundTransparency = 1
        text.Text = btnInfo.nome or "Botão"
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.Font = Enum.Font.SourceSans
        text.TextSize = 14
        text.Parent = button
        
        -- Área clicável
        local clickArea = Instance.new("TextButton")
        clickArea.Name = "ClickArea"
        clickArea.Size = UDim2.new(1, 0, 1, 0)
        clickArea.BackgroundTransparency = 1
        clickArea.Text = ""
        clickArea.Parent = button
        
        -- Efeito de hover
        clickArea.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
        
        clickArea.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end)
        
        -- Efeito de clique
        clickArea.MouseButton1Down:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        end)
        
        clickArea.MouseButton1Up:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
        
        -- Execução da lógica ao clicar
        clickArea.MouseButton1Click:Connect(function()
            if btnInfo.logica_link then
                pcall(function()
                    -- Carrega e executa o script de lógica
                    local success, result = pcall(function()
                        return loadstring(game:HttpGet(btnInfo.logica_link))()
                    end)
                    
                    if not success then
                        warn("Erro ao executar a lógica do botão " .. btnInfo.nome .. ": " .. tostring(result))
                    end
                end)
            end
        end)
        
        -- Tooltip para descrição
        if btnInfo.descricao then
            local tooltip = Instance.new("Frame")
            tooltip.Name = "Tooltip"
            tooltip.Size = UDim2.new(0, 200, 0, 50)
            tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            tooltip.BorderColor3 = Color3.fromRGB(60, 60, 60)
            tooltip.BorderSizePixel = 1
            tooltip.Visible = false
            tooltip.ZIndex = 10
            tooltip.Parent = button
            
            local tipCorner = Instance.new("UICorner")
            tipCorner.CornerRadius = UDim.new(0, 4)
            tipCorner.Parent = tooltip
            
            local tipText = Instance.new("TextLabel")
            tipText.Name = "TooltipText"
            tipText.Size = UDim2.new(1, -10, 1, -10)
            tipText.Position = UDim2.new(0, 5, 0, 5)
            tipText.BackgroundTransparency = 1
            tipText.Text = btnInfo.descricao
            tipText.TextColor3 = Color3.fromRGB(255, 255, 255)
            tipText.Font = Enum.Font.SourceSans
            tipText.TextSize = 14
            tipText.TextWrapped = true
            tipText.TextXAlignment = Enum.TextXAlignment.Left
            tipText.TextYAlignment = Enum.TextYAlignment.Top
            tipText.ZIndex = 11
            tipText.Parent = tooltip
            
            clickArea.MouseEnter:Connect(function()
                tooltip.Position = UDim2.new(1, 10, 0, 0)
                tooltip.Visible = true
            end)
            
            clickArea.MouseLeave:Connect(function()
                tooltip.Visible = false
            end)
        end
        
        -- Adicionar o botão à lista de botões atuais
        table.insert(self.currentButtons, button)
    end
