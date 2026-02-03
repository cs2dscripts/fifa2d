--[[
================================================================================
  M©DULO DE CONFIGURA©©O - CS2D Football Game
  Responsabilidade: Centralizar todas as configura©©es do jogo
  
  Este m©dulo cont©m todas as constantes de configura©©o:
  - Caminhos de sons e gr©ficos
  - Textos e mensagens do jogo
  - Par©metros de gameplay (velocidades, limites, etc.)
================================================================================
--]]

local Config = {}

-- ============================================================================
-- CONFIGURA©©ES DE ©UDIO
-- ============================================================================
Config.SOUNDS = {
	apito = "bombapatch/apito.ogg",
	bem_vindo = "bombapatch/bem-vindo.ogg",
	batida = "bombapatch/batida.ogg",
	crowd = "bombapatch/crowd.ogg",
	gol_1 = "bombapatch/gol.ogg",
	gol_2 = "bombapatch/gol-1.ogg",
	resetado = "bombapatch/resetado.ogg",
	kick_1 = "bombapatch/kick-1.ogg",
	kick_2 = "bombapatch/kick-2.ogg",
	reset = "bombapatch/rs.ogg",
	vinheta_flamengo = "bombapatch/flamengo-eco.ogg",
	vinheta_corinthians = "bombapatch/corinthians-eco.ogg",
	bg = {
		"bombapatch/bg.ogg",
		"bombapatch/bg-2.ogg",
		"bombapatch/bg-3.ogg"
	}
}

-- ============================================================================
-- CONFIGURA©©ES DE GR©FICOS
-- ============================================================================
Config.GRAPHICS = {
	ball = "gfx/bombapatch/ball.png",
	placar = "gfx/bombapatch/placar.bmp",
	numeros = "gfx/bombapatch/numeros.bmp",
	flamengo_hat = "gfx/bombapatch/flamengo.bmp<m>",
	corinthians_hat = "gfx/bombapatch/corinthians.bmp<m>",
	stamina_bar = "gfx/bombapatch/bar.bmp",
	block = "gfx/bombapatch/block.bmp",
	replay_text = "gfx/bombapatch/replay.png"
}

-- ============================================================================
-- TEXTOS DO JOGO
-- ============================================================================
Config.TEXTS = {
	stamina_warning = "©255000000Aguarde a stamina recarregar completamente!",
	leaderboard_title = "©255255255Top Artilheiros FIFA2D",
	leaderboard_empty = "©255255255Nenhum gol marcado ainda!",
	goal_flamengo = "GOOOOOL DO FLAMENGO! ?",
	goal_corinthians = "GOOOOOL DO CORINTHIANS! ?",
	scorer_format = "©255255000%s@C",  -- %s = nome do jogador
	reset_countdown_3 = "©255000000A partida vai resetar em 3... %s ganhou! @C",  -- %s = nome do time
	reset_countdown_2 = "©255000000A partida vai resetar em 2... @C",
	reset_countdown_1 = "©255000000A partida vai resetar em 1... @C",
	reset_complete = "©000255000[RESET] Jogo resetado! @C"
}

-- ============================================================================
-- CONFIGURA©©ES DE GAMEPLAY
-- ============================================================================
Config.BALL = {
	friction = 0.2,
	kickspeed = 10,
	kickrotspeed = 10,
	xstart = (55 * 32) + 16,
	ystart = (47 * 32) + 16
}

Config.STAMINA = {
	max = 100,
	drain_rate = 1.5,
	regen_rate = 0.2
}

Config.SCORE = {
	max_points = 5
}

Config.REPLAY = {
	max_frames = 200,  -- 4 segundos a 50 FPS
	delay = 150  -- 3 segundos antes de iniciar
}

Config.GOALS = {
	t = {tilex = 71, tiley = 47},
	ct = {tilex = 39, tiley = 47}
}

Config.BOT = {
	kick_cooldown_attacker = 22,
	kick_cooldown_defender = 28,
	kick_power_attacker = 1.0,
	kick_power_defender = 0.7,
	speed = 3
}

Config.LEADERBOARD = {
	update_interval = 50,  -- Atualizar a cada 1 segundo (50 FPS)
	top_count = 3
}

Config.BACKGROUND_SOUND = {
	interval = 500  -- 10 segundos (50 FPS * 10)
}

-- ============================================================================
-- INICIALIZA©©O DO SERVER
-- ============================================================================
Config.SERVER_COMMANDS = {
	'mp_damagefactor 0',
	'mp_hud 0',
	'mp_radar 0',
	'transfer_speed 500'
}

-- Retornar m©dulo
return Config

