--[[
================================================================================
  CASO DE USO: Gerenciador de Jogadores - CS2D Football Game
  Responsabilidade: Gerenciar lifecycle e ações dos jogadores
  
  Este use case coordena:
  - Join, spawn e leave de jogadores
  - Ações de ataque e chute
  - Sistema de chapéus dos times
================================================================================
--]]

local PlayerHandler = {}

-- Dependências
local Config = require("src.modules.core.config")
local PlayerRepository = require("src.modules.repositories.player_repository")
local StatsRepository = require("src.modules.repositories.stats_repository")
local StaminaService = require("src.modules.services.stamina_service")
local BallService = require("src.modules.services.ball_service")
local ImageUtils = require("src.modules.utils.image_utils")
local SoundUtils = require("src.modules.utils.sound_utils")

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Handler de quando jogador entra no servidor
function PlayerHandler:on_player_join(state, pid)
	-- Inicializar estados do jogador
	state.players.charge[pid] = 0
	state.players.charging[pid] = false
	state.players.attack_timer[pid] = 0
	state.players.last_attacked[pid] = 0
	
	-- Inicializar stamina
	StaminaService:initialize_player(state, pid)
	
	-- Carregar estatísticas
	state.stats.player_stats = StatsRepository:load()
	
	-- Tocar som de boas-vindas
	SoundUtils:play(Config.SOUNDS.bem_vindo)
end

-- Handler de quando jogador spawna
function PlayerHandler:on_player_spawn(state, pid)
	addbind("e")
	
	-- Inicializar stamina
	StaminaService:initialize_player(state, pid)
	StaminaService:update_bar(state, pid)
	
	-- Remover chapéu anterior
	if state.players.hats[pid] then
		ImageUtils:free(state.players.hats[pid])
		state.players.hats[pid] = nil
	end
	
	-- Adicionar chapéu baseado no time
	local team = PlayerRepository:get_player_team(pid)
	if team == 1 then -- Time T (Flamengo)
		state.players.hats[pid] = ImageUtils:create(Config.GRAPHICS.flamengo_hat, 0, 0, 200 + pid)
	elseif team == 2 then -- Time CT (Corinthians)
		state.players.hats[pid] = ImageUtils:create(Config.GRAPHICS.corinthians_hat, 0, 0, 200 + pid)
	end
end

-- Handler de quando jogador sai
function PlayerHandler:on_player_leave(state, pid)
	-- Limpar estados
	state.players.charge[pid] = nil
	state.players.charging[pid] = nil
	state.players.attack_timer[pid] = nil
	state.players.last_attacked[pid] = nil
	
	-- Limpar stamina
	StaminaService:cleanup_player(state, pid)
	
	-- Remover chapéu
	if state.players.hats[pid] then
		ImageUtils:free(state.players.hats[pid])
		state.players.hats[pid] = nil
	end
end

-- Handler de ataque primário (chute fraco)
function PlayerHandler:on_player_attack(state, pid)
	-- Bots usam comportamento diferente
	if PlayerRepository:is_bot(pid) then
		local x, y = PlayerRepository:get_player_position(pid)
		if BallService:kick(state, x, y, 1.0) then
			state.goal.last_ball_toucher = pid
		end
		return
	end
	
	-- Jogadores humanos - chute fraco
	local x, y = PlayerRepository:get_player_position(pid)
	if BallService:kick(state, x, y, 0.6) then
		SoundUtils:play(Config.SOUNDS.kick_1)
		state.goal.last_ball_toucher = pid
	end
end

-- Handler de ataque secundário (chute forte)
function PlayerHandler:on_player_attack2(state, pid)
	-- Apenas para jogadores humanos
	if PlayerRepository:is_bot(pid) then
		return
	end
	
	local x, y = PlayerRepository:get_player_position(pid)
	if BallService:kick(state, x, y, 1.3) then
		SoundUtils:play(Config.SOUNDS.kick_2)
		state.goal.last_ball_toucher = pid
	end
end

-- Handler de tecla pressionada
function PlayerHandler:on_player_key(state, pid, key, key_state)
	if not player(pid, "exists") or PlayerRepository:is_bot(pid) then 
		return 
	end
	
	-- key "E" para sprint
	if key == "E" then
		if key_state == 0 then  -- Pressionou
			if not StaminaService:start_sprint(state, pid) then
				msg2(pid, Config.TEXTS.stamina_warning)
			end
		end
	end
end

-- Atualizar chapéus dos jogadores
function PlayerHandler:update_hats(state, player_list)
	for _, id in ipairs(player_list) do
		if player(id, "exists") and state.players.hats[id] then
			local px, py = PlayerRepository:get_player_position(id)
			ImageUtils:position(state.players.hats[id], px, py - 20, 0)
		end
	end
end

-- Retornar módulo
return PlayerHandler
