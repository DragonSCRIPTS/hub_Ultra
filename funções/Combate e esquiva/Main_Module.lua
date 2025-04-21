-- Módulo KillAura Otimizado para Raids - Versão 4.0
-- Módulo Principal - Configurações e Funções Básicas

KillAuraModule = {}

-- Configurações principais
KillAuraModule.active = false
KillAuraModule.attackRange = 60
KillAuraModule.targetEnemy = nil
KillAuraModule.enemies = {}
KillAuraModule.normalAttackCooldown = false
KillAuraModule.skillKeys = {"Z", "X", "C"}
KillAuraModule.evading = false

-- Configurações avançadas
KillAuraModule.skillsActive = true
KillAuraModule.comboModeActive = true
KillAuraModule.prioritizeLowHealth = true
KillAuraModule.safeDistance = 15
KillAuraModule.clickDelay = 0.08
KillAuraModule.comboHitCount = 0
KillAuraModule.maxComboHits = 4
KillAuraModule.maxEnemyGroupSize = 3

-- Sistema de cooldown para habilidades
KillAuraModule.skillCooldowns = {
    Z = {active = false, cooldown = 2.5},
    X = {active = false, cooldown = 4},
    C = {active = false, cooldown = 6}
}

-- Callback padrão de status
KillAuraModule.statusCallback = function(message)
    print(message)
end

-- Função para definir callback de status
function KillAuraModule.SetStatusCallback(callback)
    if type(callback) == "function" then
        KillAuraModule.statusCallback = callback
        return true
    end
    return false
end

-- Funções utilitárias
function KillAuraModule.IsLowHealth(humanoid)
    return humanoid and humanoid.Health <= humanoid.MaxHealth * 0.4
end

function KillAuraModule.GetAvailableSkills()
    local available = {}
    for key, data in pairs(KillAuraModule.skillCooldowns) do
        if not data.active then
            table.insert(available, key)
        end
    end
    return available
end

-- Função para iniciar o KillAura
function KillAuraModule.Start()
    if KillAuraModule.active then return end
    
    KillAuraModule.active = true
    KillAuraModule.statusCallback("✅ KillAura Anti-Raid ativado")
    
    -- Carregar subsistemas necessários
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/funções/Combate e esquiva/Enemy_Detection.lua"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCRIPTS/hub_Ultra/refs/heads/main/funções/Combate e esquiva/Combat_Logic.lua"))()
    
    -- Loop principal
    spawn(function()
        while KillAuraModule.active and wait(0.15) do
            pcall(KillAuraModule.PerformKillAura)
        end
    end)
end

-- Função para parar o KillAura
function KillAuraModule.Stop()
    KillAuraModule.active = false
    KillAuraModule.statusCallback("❌ KillAura desativado")
    KillAuraModule.comboHitCount = 0
    KillAuraModule.enemies = {}
end

-- Função para alternar o KillAura
function KillAuraModule.Toggle()
    if KillAuraModule.active then
        KillAuraModule.Stop()
    else
        KillAuraModule.Start()
    end
    return KillAuraModule.active
end

-- Funções auxiliares mantidas para compatibilidade
KillAuraModule.ToggleKillAura = KillAuraModule.Toggle
KillAuraModule.StartKillAura = KillAuraModule.Start
KillAuraModule.StopKillAura = KillAuraModule.Stop
KillAuraModule.killAuraActive = KillAuraModule.active

-- Função para alternar o uso de habilidades
function KillAuraModule.ToggleSkills()
    KillAuraModule.skillsActive = not KillAuraModule.skillsActive
    KillAuraModule.statusCallback(KillAuraModule.skillsActive and "Skills ✅" or "Skills ❌")
    return KillAuraModule.skillsActive
end

-- Função para alternar o modo combo
function KillAuraModule.ToggleComboMode()
    KillAuraModule.comboModeActive = not KillAuraModule.comboModeActive
    KillAuraModule.comboHitCount = 0
    KillAuraModule.statusCallback(KillAuraModule.comboModeActive and "Combo ✅" or "Combo ❌")
    return KillAuraModule.comboModeActive
end

-- Função para definir o alcance
function KillAuraModule.SetRange(range)
    if tonumber(range) and tonumber(range) > 0 then
        KillAuraModule.attackRange = tonumber(range)
        KillAuraModule.statusCallback("Alcance: " .. KillAuraModule.attackRange)
        return true
    end
    return false
end

print("Módulo KillAura Anti-Raid v4.0 carregado!")
return KillAuraModule
