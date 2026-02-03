--[[
================================================================================
  MAIN.LUA - CS2D Football Game (Refatorado com Module Architecture)
  
  Este é o ponto de entrada do jogo. Ele orquestra todos os módulos e
  registra os hooks do CS2D para conectar os eventos do jogo aos use cases.
  
  ARQUITETURA:
  - core/: Configurações e estado do jogo
  - repositories/: Acesso a dados e persistência
  - services/: Lógica reutilizável e independente
  - use_cases/: Regras de negócio e fluxos principais
  - utils/: Funções auxiliares
  
  FLUXO:
  1. Carregar configurações
  2. Inicializar estado do jogo
  3. Configurar servidor
  4. Registrar hooks que conectam eventos aos use cases
================================================================================
--]]

-- ============================================================================
-- IMPORTAÇÃO DE MÓDULOS
-- ============================================================================

-- Core
local Config = require("src.modules.core.config")
local GameState = require("src.modules.core.game_state")

-- Use Cases
local PlayerHandler = require("src.modules.use_cases.player_handler")
local GoalHandler = require("src.modules.use_cases.goal_handler")
local GameLoop = require("src.modules.use_cases.game_loop")
local LeaderboardHandler = require("src.modules.use_cases.leaderboard_handler")

-- Services
local BallService = require("src.modules.services.ball_service")
local ScoreService = require("src.modules.services.score_service")

-- ============================================================================
-- INICIALIZAÇÃO DO SERVIDOR
-- ============================================================================

-- Executar comandos de configuração do servidor
for _, cmd in ipairs(Config.SERVER_COMMANDS) do
	parse(cmd)
end

-- Inicializar bola
BallService:initialize(GameState)

-- Atualizar display inicial do placar
ScoreService:update_display(GameState)

-- ============================================================================
-- HOOKS DO CS2D - CONECTAM EVENTOS AOS USE CASES
-- ============================================================================

-- Hook: Inicialização do mapa
function _map_start()
	-- Carregar estatísticas
	LeaderboardHandler:load_stats(GameState)
	
	-- Mostrar leaderboard inicial
	LeaderboardHandler:update_leaderboard(GameState)
end

-- Hook: Jogador entra no servidor
function _player_join(id)
	PlayerHandler:on_player_join(GameState, id)
	LeaderboardHandler:update_leaderboard(GameState)
end

-- Hook: Jogador spawna
function _player_spawn(id)
	PlayerHandler:on_player_spawn(GameState, id)
end

-- Hook: Jogador sai do servidor
function _player_leave(id)
	PlayerHandler:on_player_leave(GameState, id)
end

-- Hook: Ataque primário (chute fraco)
function _player_attack(id)
	PlayerHandler:on_player_attack(GameState, id)
end

-- Hook: Ataque secundário (chute forte)
function _player_attack2(id)
	PlayerHandler:on_player_attack2(GameState, id)
end

-- Hook: Tecla pressionada
function _player_key(id, key, state)
	PlayerHandler:on_player_key(GameState, id, key, state)
end

-- Hook: Comandos de chat
function _player_say(id, text)
	-- Comando: Resetar jogo manualmente
	if text == "!rb" then
		local PlayerRepository = require("src.modules.repositories.player_repository")
		GoalHandler:manual_reset(GameState, PlayerRepository:get_all_players())
		return 1
	end
	
	-- Comando: Som de reset
	if text == "!rs" then
		local SoundUtils = require("src.modules.utils.sound_utils")
		SoundUtils:play(Config.SOUNDS.reset)
		return 1
	end
	
	-- Comando: Recarregar estatísticas
	if text == "!reload" or text == "!recarregar" then
		LeaderboardHandler:load_stats(GameState)
		LeaderboardHandler:update_leaderboard(GameState)
		return 1
	end
	
	-- Comando: Ver estatísticas pessoais
	if text == "!rank" or text == "!stats" then
		local PlayerRepository = require("src.modules.repositories.player_repository")
		local player_id = PlayerRepository:get_player_id(id)
		local gols = 0
		
		if GameState.stats.player_stats[player_id] then
			if type(GameState.stats.player_stats[player_id]) == "table" then
				gols = GameState.stats.player_stats[player_id].gols
			else
				gols = GameState.stats.player_stats[player_id]
			end
		end
		
		msg2(id, "©255255000[RANK] Você tem " .. gols .. " gols marcados!")
		return 1
	end
	
	return 0
end

-- Hook: Loop principal (executado a cada frame)
function _always()
	GameLoop:update(GameState)
end

-- ============================================================================
-- REGISTRO DOS HOOKS
-- ============================================================================

addhook("startround", "_map_start")
addhook("join", "_player_join")
addhook("spawn", "_player_spawn")
addhook("leave", "_player_leave")
addhook("attack", "_player_attack")
addhook("attack2", "_player_attack2")
addhook("key", "_player_key")
addhook("say", "_player_say")
addhook("always", "_always")

-- ============================================================================
-- MENSAGEM DE INICIALIZAÇÃO
-- ============================================================================

print("================================================================================")
print("  CS2D Football Game - Módulos Carregados com Sucesso!")
print("  Arquitetura: Module Architecture")
print("  Versão: 2.0 (Refatorado)")
print("================================================================================")
