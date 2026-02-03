--[[
================================================================================
  SERVIÇO DE STAMINA - CS2D Football Game
  Responsabilidade: Gerenciar sistema de stamina/corrida dos jogadores
  
  Este serviço encapsula:
  - Inicialização de stamina
  - Consumo e regeneração de stamina
  - Display visual da barra de stamina
================================================================================
--]]

local StaminaService = {}

-- Dependências
local Config = require("src.modules.core.config")
local ImageUtils = require("src.modules.utils.image_utils")

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Inicializar stamina de um jogador
function StaminaService:initialize_player(state, pid)
	state.players.stamina[pid] = Config.STAMINA.max
	state.players.sprinting[pid] = false
	state.players.stamina_imgs[pid] = {}
end

-- Limpar stamina de um jogador
function StaminaService:cleanup_player(state, pid)
	state.players.stamina[pid] = nil
	state.players.sprinting[pid] = nil
	
	if state.players.stamina_imgs[pid] then
		if state.players.stamina_imgs[pid].bg then
			ImageUtils:free(state.players.stamina_imgs[pid].bg)
		end
		if state.players.stamina_imgs[pid].bar then
			ImageUtils:free(state.players.stamina_imgs[pid].bar)
		end
		state.players.stamina_imgs[pid] = nil
	end
end

-- Iniciar sprint
function StaminaService:start_sprint(state, pid)
	if state.players.stamina[pid] >= Config.STAMINA.max then
		state.players.sprinting[pid] = true
		return true
	end
	return false
end

-- Parar sprint
function StaminaService:stop_sprint(state, pid)
	state.players.sprinting[pid] = false
	parse('speedmod ' .. pid .. ' 0')
end

-- Atualizar stamina de todos os jogadores
function StaminaService:update_all(state, player_list)
	for _, id in ipairs(player_list) do
		if player(id, "exists") and not player(id, "bot") and player(id, "health") > 0 then
			self:update_player(state, id)
		end
	end
end

-- Atualizar stamina de um jogador
function StaminaService:update_player(state, pid)
	-- Verificar se deve parar o sprint
	if state.players.sprinting[pid] then
		if state.players.stamina[pid] <= 0 then
			self:stop_sprint(state, pid)
		end
	end
	
	if state.players.sprinting[pid] and state.players.stamina[pid] > 0 then
		-- Gastando stamina
		state.players.stamina[pid] = state.players.stamina[pid] - Config.STAMINA.drain_rate
		if state.players.stamina[pid] < 0 then
			state.players.stamina[pid] = 0
			self:stop_sprint(state, pid)
		end
		
		-- Aplicar speedmod
		parse('speedmod ' .. pid .. ' 10')
	else
		-- Recuperando stamina
		if state.players.stamina[pid] < Config.STAMINA.max then
			state.players.stamina[pid] = state.players.stamina[pid] + Config.STAMINA.regen_rate
			if state.players.stamina[pid] > Config.STAMINA.max then
				state.players.stamina[pid] = Config.STAMINA.max
			end
		end
		
		-- Speedmod normal
		if not state.players.sprinting[pid] then
			parse('speedmod ' .. pid .. ' 0')
		end
	end
end

-- Atualizar barra visual de stamina
function StaminaService:update_bar(state, pid)
	if not player(pid, "exists") or player(pid, "bot") then
		return
	end
	
	local stamina = state.players.stamina[pid] or Config.STAMINA.max
	local percentage = stamina / Config.STAMINA.max
	
	-- Parâmetros da barra
	local bar_max_width = 100
	local bar_height = 10
	
	-- Criar imagens se não existirem
	if not state.players.stamina_imgs[pid] or not state.players.stamina_imgs[pid].bar then
		-- Limpar antigas
		if state.players.stamina_imgs[pid] and state.players.stamina_imgs[pid].bg then
			ImageUtils:free(state.players.stamina_imgs[pid].bg)
		end
		if state.players.stamina_imgs[pid] and state.players.stamina_imgs[pid].bar then
			ImageUtils:free(state.players.stamina_imgs[pid].bar)
		end
		
		state.players.stamina_imgs[pid] = {}
		
		-- Criar fundo (cinza escuro)
		state.players.stamina_imgs[pid].bg = ImageUtils:create(Config.GRAPHICS.stamina_bar, 0, 0, 200 + pid)
		ImageUtils:color(state.players.stamina_imgs[pid].bg, 50, 50, 50)
		ImageUtils:scale(state.players.stamina_imgs[pid].bg, bar_max_width / 32, bar_height / 12)
		ImageUtils:alpha(state.players.stamina_imgs[pid].bg, 0.8)
		
		-- Criar barra de progresso (azul)
		state.players.stamina_imgs[pid].bar = ImageUtils:create(Config.GRAPHICS.stamina_bar, 0, 10, 200 + pid)
		ImageUtils:color(state.players.stamina_imgs[pid].bar, 0, 150, 255)
		ImageUtils:alpha(state.players.stamina_imgs[pid].bar, 0.9)
	end
	
	-- Atualizar scale da barra
	local current_width = bar_max_width * percentage
	ImageUtils:scale(state.players.stamina_imgs[pid].bar, math.max(0.01, current_width / 32), bar_height / 12)
	
end

-- Retornar módulo
return StaminaService
