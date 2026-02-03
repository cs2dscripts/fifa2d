--[[
================================================================================
  SERVIÇO DE EXPLOSÃO - CS2D Football Game
  Responsabilidade: Gerenciar efeito de explosão quando há gol
  
  Este serviço encapsula:
  - Iniciar explosão visual
  - Atualizar efeitos da explosão
  - Controlar delay antes do replay
================================================================================
--]]

local ExplosionService = {}

-- Dependências
local Config = require("src.modules.core.config")
local ImageUtils = require("src.modules.utils.image_utils")
local SoundUtils = require("src.modules.utils.sound_utils")

-- Configurações de efeitos
local EXPLOSION_CONFIG = {
	delay = 150,  -- 3 segundos (50 FPS * 3)
	goal_sound = "bombapatch/boom.ogg"
}

-- ============================================================================
-- FUNÇÕES PRIVADAS
-- ============================================================================

-- Obter cores do time
local function get_team_colors(team)
	if team == "t" then
		return 255, 0, 0  -- Flamengo: vermelho
	elseif team == "ct" then
		return 255, 255, 255  -- Corinthians: branco
	else
		return 255, 200, 0  -- Cor padrão (laranja)
	end
end

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Iniciar explosão
function ExplosionService:start(state, ball_x, ball_y, team)
	state.explosion.active = true
	state.explosion.timer = 0
	state.explosion.x = ball_x
	state.explosion.y = ball_y
	state.explosion.scoring_team = team
	
	-- Tocar som de explosão
	SoundUtils:play(EXPLOSION_CONFIG.goal_sound)
end

-- Resetar explosão
function ExplosionService:reset(state)
	state.explosion.active = false
	state.explosion.timer = 0
	state.explosion.x = 0
	state.explosion.y = 0
	state.explosion.scoring_team = ""
end

-- Atualizar explosão e efeitos visuais
function ExplosionService:update(state)
	if not state.explosion.active then
		return false
	end
	
	state.explosion.timer = state.explosion.timer + 1
	
	-- Fazer a bola pulsar durante a explosão
	if state.ball.img and state.ball.img > 0 then
		local pulse_scale = 1.0 + math.sin(state.explosion.timer * 0.3) * 0.5
		ImageUtils:scale(state.ball.img, pulse_scale, pulse_scale)
		ImageUtils:position(state.ball.img, state.explosion.x, state.explosion.y, state.explosion.timer * 5)
		
		local r, g, b = get_team_colors(state.explosion.scoring_team)
		ImageUtils:color(state.ball.img, r, g, b)
	end
	
	-- Spawnar efeitos de partículas
	if state.explosion.timer % 5 == 0 then
		local angle = math.random(0, 360)
		local distance = math.random(10, 50)
		local fx = state.explosion.x + math.cos(math.rad(angle)) * distance
		local fy = state.explosion.y + math.sin(math.rad(angle)) * distance
		local r, g, b = get_team_colors(state.explosion.scoring_team)
		parse('effect "colorsmoke" ' .. fx .. ' ' .. fy .. ' 32 32 ' .. r .. ' ' .. g .. ' ' .. b)
	end
	
	-- Verificar se o delay terminou
	if state.explosion.timer >= EXPLOSION_CONFIG.delay then
		return true  -- Explosão terminada
	end
	
	return false
end

-- Retornar módulo
return ExplosionService
