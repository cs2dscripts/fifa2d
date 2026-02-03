--[[
================================================================================
  CASO DE USO: Gerenciador de Gols - CS2D Football Game
  Responsabilidade: Gerenciar detecção e processamento de gols
  
  Este use case coordena:
  - Detecção de gol
  - Atualização de pontuação e estatísticas
  - Trigger de explosões e replay
  - Sistema de reset automático
================================================================================
--]]

local GoalHandler = {}

-- Dependências
local Config = require("src.modules.core.config")
local PlayerRepository = require("src.modules.repositories.player_repository")
local StatsRepository = require("src.modules.repositories.stats_repository")
local ScoreService = require("src.modules.services.score_service")
local ExplosionService = require("src.modules.services.explosion_service")
local BallService = require("src.modules.services.ball_service")
local SoundUtils = require("src.modules.utils.sound_utils")
local StaminaService = require("src.modules.services.stamina_service")

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Verificar e processar gols
function GoalHandler:check_goals(state)
	if state.goal.scored then
		return
	end
	
	local entity_name = entity(state.ball.xtile, state.ball.ytile, "name")
	
	-- Gol do time T (Flamengo)
	if entity_name == "twin" then
		self:process_goal(state, "t", "Flamengo", Config.TEXTS.goal_flamengo, Config.SOUNDS.vinheta_flamengo)
	-- Gol do time CT (Corinthians)
	elseif entity_name == "ctwin" then
		self:process_goal(state, "ct", "Corinthians", Config.TEXTS.goal_corinthians, Config.SOUNDS.vinheta_corinthians)
	end
end

-- Processar um gol
function GoalHandler:process_goal(state, team, team_name, goal_text, anthem)
	state.goal.scored = true
	
	-- Sons
	SoundUtils:play(Config.SOUNDS.crowd)
	SoundUtils:play_random({Config.SOUNDS.gol_1, Config.SOUNDS.gol_2})
	SoundUtils:play(anthem)
	
	-- Mensagens
	msg(goal_text)
	if state.goal.last_ball_toucher and player(state.goal.last_ball_toucher, "exists") then
		local scorer_name = PlayerRepository:get_player_name(state.goal.last_ball_toucher)
		msg(string.format(Config.TEXTS.scorer_format, scorer_name))
		
		-- Adicionar gol às estatísticas
		if not PlayerRepository:is_bot(state.goal.last_ball_toucher) then
			local player_id = PlayerRepository:get_player_id(state.goal.last_ball_toucher)
			state.stats.player_stats = StatsRepository:increment_goals(
				player_id, 
				scorer_name, 
				state.stats.player_stats
			)
			StatsRepository:save(state.stats.player_stats)
		end
	end
	
	-- Atualizar pontuação
	ScoreService:add_point(state, team)
	
	-- Verificar condição de vitória
	local winning_team, winning_team_name = ScoreService:check_win_condition(state)
	if winning_team then
		state.goal.reset_countdown = 150  -- 3 segundos
		state.goal.reset_team = winning_team_name
	end
	
	-- Iniciar explosão
	ExplosionService:start(state, state.ball.x, state.ball.y, team)
	BallService:freeze(state)
end

-- Atualizar contagem regressiva de reset
function GoalHandler:update_reset_countdown(state, player_list)
	if state.goal.reset_countdown > 0 then
		state.goal.reset_countdown = state.goal.reset_countdown - 1
		
		-- Exibir mensagens
		if state.goal.reset_countdown == 100 then
			msg(string.format(Config.TEXTS.reset_countdown_3, state.goal.reset_team))
		elseif state.goal.reset_countdown == 50 then
			msg(Config.TEXTS.reset_countdown_2)
		elseif state.goal.reset_countdown == 1 then
			msg(Config.TEXTS.reset_countdown_1)
		elseif state.goal.reset_countdown == 0 then
			self:execute_reset(state, player_list)
		end
	end
end

-- Executar reset completo do jogo
function GoalHandler:execute_reset(state, player_list)
	-- Resetar pontos
	ScoreService:reset(state)
	
	-- Reposicionar jogadores
	for _, pid in ipairs(player_list) do
		if player(pid, "exists") and player(pid, "health") > 0 then
			local team = PlayerRepository:get_player_team(pid)
			local new_x = (team == 2) and (45 * 32) or (65 * 32)
			parse('setpos ' .. pid .. ' ' .. new_x .. ' ' .. player(pid, "y"))
		end
	end
	
	-- Resetar bola
	BallService:restart(state)
	
	-- Resetar estados
	for _, pid in ipairs(player_list) do
		if state.players.charge[pid] then
			state.players.charge[pid] = 0
			state.players.charging[pid] = false
		end
		if state.players.stamina[pid] and not PlayerRepository:is_bot(pid) then
			state.players.stamina[pid] = Config.STAMINA.max
			state.players.sprinting[pid] = false
			StaminaService:update_bar(state, pid)
		end
	end
	
	-- Sons e mensagens
	SoundUtils:play(Config.SOUNDS.resetado)
	msg(Config.TEXTS.reset_complete)
	
	-- Resetar variáveis
	state.goal.reset_team = ""
end

-- Reset manual via comando
function GoalHandler:manual_reset(state, player_list)
	self:execute_reset(state, player_list)
end

-- Retornar módulo
return GoalHandler
