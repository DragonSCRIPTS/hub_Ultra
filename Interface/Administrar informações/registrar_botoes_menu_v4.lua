-- registrar_botoes_menu_v4.lua

-- Tabela de botões dentro do menu "Raças V4"
local botoes = {

    -- Botão "Ir ao Templo"
    {
        id = 1,
        nome = "Ir ao Templo",
        tamanho = "200x50",
        imagem_link = "",  -- Deixe vazio ou coloque um link se imagem estiver 'on'
        estado_imagem = "off",  -- 'on' ou 'off'
        link_imagem = "",  -- Coloque o link de imagem se 'on'
        logica_link = "loadstring(game:HttpGet('https://raw.githubusercontent.com/DragonSCRIPTS/DragonHUB/refs/heads/main/v4/modules/ir_ao_templo.lua'))()",  -- Link para carregar a lógica da função
        descricao = "Leva o jogador ao Templo do Tempo",
        ordem = 1
    },

    -- Botão "Puxar Alavanca"
    {
        id = 2,
        nome = "Puxar Alavanca",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        link_imagem = "",
        logica_link = "loadstring(game:HttpGet('https://raw.githubusercontent.com/DragonSCRIPTS/DragonHUB/refs/heads/main/v4/modules/puxar_alavanca.lua'))()",
        descricao = "Puxa a alavanca para o próximo evento no Templo do Tempo",
        ordem = 2
    },

    -- Botão "Acient One"
    {
        id = 3,
        nome = "Acient One",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        link_imagem = "",
        logica_link = "loadstring(game:HttpGet('https://raw.githubusercontent.com/DragonSCRIPTS/DragonHUB/refs/heads/main/v4/modules/acient_one.lua'))()",
        descricao = "Acessa a área do Acient One",
        ordem = 3
    },

    -- Botão "Porta da Raça"
    {
        id = 4,
        nome = "Porta da Raça",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        link_imagem = "",
        logica_link = "loadstring(game:HttpGet('https://raw.githubusercontent.com/DragonSCRIPTS/DragonHUB/refs/heads/main/v4/modules/porta_raca.lua'))()",
        descricao = "Abre a porta da raça com base no valor da raça do jogador",
        ordem = 4
    },

    -- Botão "Auto Human/Ghoul Trial"
    {
        id = 5,
        nome = "Auto Human/Ghoul Trial",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        link_imagem = "",
        logica_link = "loadstring(game:HttpGet('https://raw.githubusercontent.com/DragonSCRIPTS/DragonHUB/refs/heads/main/v4/modules/auto_human_ghoul_trial.lua'))()",
        descricao = "Ativa o Auto Trial para Human/Ghoul",
        ordem = 5
    },

    -- Botão "Auto Trial de Raça"
    {
        id = 6,
        nome = "Auto Trial de Raça",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        link_imagem = "",
        logica_link = "loadstring(game:HttpGet('https://raw.githubusercontent.com/DragonSCRIPTS/DragonHUB/refs/heads/main/v4/modules/auto_trial_raca.lua'))()",
        descricao = "Ativa o Auto Trial para a raça do jogador",
        ordem = 6
    }

}

return botoes
