-- Agregador de todos os módulos de botões
-- Este arquivo unifica o carregamento de todas as tabelas de botões usando HttpGet

local botoes_por_menu = {}

-- Registro do menu V4
botoes_por_menu["v4"] = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_v4.lua"))()

-- Registro do menu Farm
botoes_por_menu["farm"] = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_farm.lua"))()

-- Outros menus podem ser adicionados aqui seguindo o mesmo padrão:
-- botoes_por_menu["nome_do_menu"] = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_nome_do_menu.lua"))()

-- Exemplos de outros menus (links fictícios para demonstração):
botoes_por_menu["teleport"] = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_teleport.lua"))()

botoes_por_menu["config"] = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_config.lua"))()

botoes_por_menu["visual"] = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/Interface/Administrar%20informa%C3%A7%C3%B5es/registrar_botoes_menu_visual.lua"))()

-- Se algum link não estiver disponível, o script vai ignorar o erro e seguir para o próximo
-- O sistema vai funcionar com os menus que tiverem links válidos

return botoes_por_menu
