-- registrar_menu.lua

-- Tabela de menus com nome, tamanho, link da imagem, estado de ativação da imagem, e outras propriedades
local menus = {

    {
        id = 1,
        nome = "Farm",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        descricao = "Menu para atividades de farm",
        ordem = 1,
        estado = "ativo"
    },

    {
        id = 2,
        nome = "Missões e Itens",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        descricao = "Realizar missões e coletar itens como recompensa",
        ordem = 2,
        estado = "ativo"
    },

    {
        id = 3,
        nome = "Espadas",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        descricao = "Menu que lista todas as espadas disponíveis no jogo e controla a coleta de cada uma",
        ordem = 3,
        estado = "ativo"
    },

    {
        id = 4,
        nome = "Loja",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        descricao = "Comprar itens e equipamentos",
        ordem = 4,
        estado = "ativo"
    },

    {
        id = 5,
        nome = "V4",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        descricao = "Menu para iniciar trials, treinar a raça e pagar pelo desbloqueio de novos trials.",
        ordem = 5,
        estado = "ativo"
    },

    {
        id = 6,
        nome = "Configurações",
        tamanho = "200x50",
        imagem_link = "",
        estado_imagem = "off",
        descricao = "Ajustes do jogo e preferências",
        ordem = 6,
        estado = "ativo"
    }

}

return menus
