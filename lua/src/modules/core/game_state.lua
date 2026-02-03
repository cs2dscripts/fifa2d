--[[
================================================================================
  MÓDULO DE ESTADO DO JOGO - CS2D Football Game
  Responsabilidade: Centralizar e gerenciar todo o estado mutável do jogo
  
  Este módulo mantém o estado compartilhado entre diferentes componentes.
  Utiliza tabelas aninhadas para organizar o estado por contexto.
================================================================================
--]]

local GameState = {}

-- ============================================================================
-- ESTADO DA BOLA
-- ============================================================================
GameState.ball = {
	rot = 0,
	rotspeed = 0,
	x = 0,
	y = 0,
	lastx = 0,
	lasty = 0,
	mx = 0,
	my = 0,
	xtile = 0,
	ytile = 0,
	img = 0
}

-- ============================================================================
-- ESTADO DO PLACAR
-- ============================================================================
GameState.points = {
	ct = 0,
	t = 0
}

GameState.score_images = {
	t = 0,
	ct = 0,
	bg = 0
}

-- ============================================================================
-- ESTADO DOS JOGADORES
-- ============================================================================
GameState.players = {
	charge = {},           -- Carga de chute de cada jogador
	charging = {},         -- Se está carregando chute
	attack_timer = {},     -- Timer de ataque
	last_attacked = {},    -- Último ataque
	stamina = {},          -- Stamina atual
	sprinting = {},        -- Se está correndo
	stamina_imgs = {},     -- Imagens da barra de stamina
	hats = {}              -- Chapéus dos times
}

-- ============================================================================
-- ESTADO DOS BOTS
-- ============================================================================
GameState.bots = {
	list = {},
	kick_cooldown = {},
	roles = {},            -- atacante/defensor
	role_timer = 0
}

-- ============================================================================
-- ESTADO DO SISTEMA DE GOL
-- ============================================================================
GameState.goal = {
	scored = false,
	last_ball_toucher = nil,
	ball_holder_indicator = 0,
	reset_countdown = 0,
	reset_team = ""
}

-- ============================================================================
-- ESTADO DO REPLAY
-- ============================================================================
GameState.replay = {
	recording = true,
	playing = false,
	data = {},
	frame_index = 1,
	ball_img = 0,
	text_img = 0
}

-- ============================================================================
-- ESTADO DAS ESTATÍSTICAS
-- ============================================================================
GameState.stats = {
	player_stats = {},
	leaderboard_update_timer = 0,
	leaderboard_hud = {}
}

-- ============================================================================
-- ESTADO DO SOM DE BACKGROUND
-- ============================================================================
GameState.background_sound = {
	timer = 0,
	index = 1
}

-- ============================================================================
-- ESTADO DA EXPLOSÃO
-- ============================================================================
GameState.explosion = {
	active = false,
	timer = 0,
	x = 0,
	y = 0,
	scoring_team = ""
}

-- Retornar módulo
return GameState
