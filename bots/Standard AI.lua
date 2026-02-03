--------------------------------------------------
-- CS2D Football Bot AI - Customizado           --
-- Otimizado para scripts de futebol            --
-- by Paulo & Smoker - Bomba Patch              --
--------------------------------------------------
---
dofile("bots/includes/settings.lua")
dofile("bots/includes/general.lua")

vai_destx={}; vai_desty={}				-- destination x|y
vai_aimx={}; vai_aimy={}				-- aim at x|y
vai_px={}; vai_py={}					-- previous x|y


-- Desabilitar comportamentos padrão da IA
function ai_onspawn(id)
    -- Resetar variáveis ao spawnar
end

function ai_update_living(id)
    -- IA customizada desabilitada - controlada pelo server.lua
    -- Não fazer nada aqui para evitar conflitos
end

function ai_gotohostage(id)
    -- Desabilitar resgate de reféns
    return false
end

function ai_goto(id, x, y, aim)
    -- Movimento customizado desabilitado
    return false
end

function ai_iattack(id)
    -- Ataque customizado desabilitado
    return false
end

function ai_update_dead(id)
	-- Try to respawn (if not in normal gamemode)
	fai_update_settings()
	if vai_set_gm~=0 then
		ai_respawn(id)
	end
end

function ai_move(id, x, y)
    -- Movimento controlado pelo script de futebol
    return false
end

function ai_attack(id)
    -- Ataque controlado pelo script de futebol
    return false
end

function ai_buy(id)
    -- Desabilitar compras
    return false
end

function ai_radio(id, msg)
    -- Desabilitar mensagens de rádio
    return false
end

-- Retornar true para indicar que este arquivo foi carregado
return true
