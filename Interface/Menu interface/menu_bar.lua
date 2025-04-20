-- Agregador de todos os módulos de botões
-- Este arquivo unifica o carregamento de todas as tabelas de botões

local botoes_por_menu = {
    ["v4"] = require("registrar_botoes_menu_v4"),
    ["farm"] = require("registrar_botoes_menu_farm"),
    -- Adicione novos menus aqui seguindo o padrão:
    -- ["id_do_menu"] = require("registrar_botoes_menu_id_do_menu"),
}

return botoes_por_menu
