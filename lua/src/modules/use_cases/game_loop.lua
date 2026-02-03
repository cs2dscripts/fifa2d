--[[
================================================================================
  CASO DE USO: Loop Principal do Jogo - CS2D Football Game
  Responsabilidade: Orquestrar todas as atualizações do jogo a cada frame
  
  Este use case coordena:
  - Atualização da bola
  - Atualização de jogadores (stamina, chapéus)
  - IA dos bots
  - Sistema de explosão e replay
  - Detecção de gols
================================================================================
--]]

local GameLoop = {}

-- Dependências
local Config = require("src.modules.core.config")
local PlayerRepository = require("src.modules.repositories.player_repository")
local BallService = require("src.modules.services.ball_service")
local StaminaService = require("src.modules.services.stamina_service")
local BotService = require("src.modules.services.bot_service")
local ExplosionService = require("src.modules.services.explosion_service")
local SoundUtils = require("src.modules.utils.sound_utils")
local ReplayHandler = require("src.modules.use_cases.replay_handler")
local LeaderboardHandler = require("src.modules.use_cases.leaderboard_handler")
local PlayerHandler = require("src.modules.use_cases.player_handler")
local GoalHandler = require("src.modules.use_cases.goal_handler")

-- ============================================================================
-- FUNÇÕES PRIVADAS
-- ============================================================================

-- Atualizar sons de background
local function update_background_sound(state)
	state.background_sound.timer = state.background_sound.timer + 1
	
	if state.background_sound.timer >= Config.BACKGROUND_SOUND.interval then
		SoundUtils:play_random(Config.SOUNDS.bg)
		state.background_sound.timer = 0
	end
end

-- Atualizar indicador de quem está com a bola
local function update_ball_holder_indicator(state)
	local ImageUtils = require("src.modules.utils.image_utils")
	local MathUtils = require("src.modules.utils.math_utils")
	
	-- Limpar indicador anterior
	if state.goal.ball_holder_indicator and state.goal.ball_holder_indicator > 0 then
		ImageUtils:free(state.goal.ball_holder_indicator)
		state.goal.ball_holder_indicator = 0
	end
	
	-- Verificar se existe jogador com a bola
	if state.goal.last_ball_toucher and player(state.goal.last_ball_toucher, "exists") then
		local px = player(state.goal.last_ball_toucher, "x")
		local py = player(state.goal.last_ball_toucher, "y")
		local dist = MathUtils:distance(state.ball.x, state.ball.y, px, py)
		
		if dist <= 60 then
			-- Criar indicador amarelo acima da cabeça
			state.goal.ball_holder_indicator = ImageUtils:create(Config.GRAPHICS.block, px, py - 30, 0)
			ImageUtils:color(state.goal.ball_holder_indicator, 255, 255, 0)
			ImageUtils:scale(state.goal.ball_holder_indicator, 5 / 32, 5 / 32)
			ImageUtils:alpha(state.goal.ball_holder_indicator, 1.0)
		end
	end
end

-- Gravar trajetória para replay
local function record_replay(state)
	if state.replay.recording and not state.replay.playing then
		table.insert(state.replay.data, {
			x = state.ball.x, 
			y = state.ball.y, 
			rot = state.ball.rot
		})
		
		-- Limitar tamanho do buffer
		if #state.replay.data > Config.REPLAY.max_frames then
			table.remove(state.replay.data, 1)
		end
	end
end

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Atualização principal (chamada no hook "always")
function GameLoop:update(state)
	local player_list = PlayerRepository:get_all_players()
	
	-- Se explosão está ativa, processar explosão
	if state.explosion.active then
		-- Parar gravação durante explosão
		state.replay.recording = false
		
		local finished = ExplosionService:update(state)
		if finished then
			-- Salvar scoring_team antes de resetar
			local scoring_team = state.explosion.scoring_team
			-- Resetar explosão primeiro
			ExplosionService:reset(state)
			-- Após explosão, iniciar replay
			ReplayHandler:start_replay(state, scoring_team)
		end
		return
	end
	
	-- Se replay está ativo, processar replay
	if state.replay.playing then
		ReplayHandler:update_replay(state, player_list)
		return
	end
	
	-- Sons de background
	update_background_sound(state)
	
	-- Atualizar leaderboard periodicamente
	state.stats.leaderboard_update_timer = state.stats.leaderboard_update_timer + 1
	if state.stats.leaderboard_update_timer >= Config.LEADERBOARD.update_interval then
		LeaderboardHandler:update_leaderboard(state)
		state.stats.leaderboard_update_timer = 0
	end
	
	-- Atualizar chapéus dos jogadores
	PlayerHandler:update_hats(state, player_list)
	
	-- Sistema de stamina
	StaminaService:update_all(state, player_list)
	
	-- Atualizar barra de stamina periodicamente (a cada 5 frames)
	if state.stats.leaderboard_update_timer % 5 == 0 then
		for _, id in ipairs(player_list) do
			if player(id, "exists") and not PlayerRepository:is_bot(id) then
				StaminaService:update_bar(state, id)
			end
		end
	end
	
	-- IA dos bots
	BotService:update_all(state, player_list)
	
	-- Verificar colisões
	BallService:check_player_collision(state, player_list)
	
	-- Atualizar física da bola
	BallService:update_physics(state)
	
	-- Gravar replay
	record_replay(state)
	
	-- Verificar gols
	GoalHandler:check_goals(state)
	
	-- Atualizar indicador da bola
	update_ball_holder_indicator(state)
	
	-- Sistema de reset automático
	GoalHandler:update_reset_countdown(state, player_list)
end

-- Retornar módulo
return GameLoop
