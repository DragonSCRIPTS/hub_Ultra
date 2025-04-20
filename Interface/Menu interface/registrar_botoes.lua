-- Agregador de todos os módulos de botões
-- Este arquivo unifica o carregamento de todas as tabelas de botões usando HttpGet

local botoes_por_menu = {}

-- Função para carregar botões de um menu com tratamento de erro
local function carregarBotoesMenu(menuId, url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        botoes_por_menu[menuId] = result
    else
        warn("Erro ao carregar botões do menu " .. menuId .. ": " .. tostring(result))
        -- Criar uma entrada vazia para não quebrar referências
        botoes_por_menu[menuId] = {}
    end
end

-- Registro do menu V4
carregarBotoesMenu("v4", "https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_v4.lua")

-- Registro do menu Farm
carregarBotoesMenu("farm", "https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_farm.lua")

-- Exemplos de outros menus (completar com URLs reais quando disponíveis)
carregarBotoesMenu("teleport", "https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_teleport.lua")

carregarBotoesMenu("config", "https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_config.lua")

carregarBotoesMenu("visual", "https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_visual.lua")

return botoes_por_menu
