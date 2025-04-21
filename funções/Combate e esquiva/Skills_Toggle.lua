-- Arquivo para alternar o uso de habilidades

-- Verificar se o módulo principal está carregado
if not KillAuraModule then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/funções/Combate e esquiva/Main_Module.lua"))()
    wait(0.1)
end

-- Alternar o uso de habilidades
local status = KillAuraModule.ToggleSkills()

return status
