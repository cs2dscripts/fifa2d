--[[
================================================================================
  SERVIÇO DE PLACAR - CS2D Football Game
  Responsabilidade: Gerenciar pontuação e display visual do placar
  
  Este serviço encapsula:
  - Incrementar pontos dos times
  - Atualizar display visual do placar
  - Verificar condições de vitória
================================================================================
--]]

local ScoreService = {}

-- Dependências
local Config = require("src.modules.core.config")
local ImageUtils = require("src.modules.utils.image_utils")

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Incrementar pontos de um time
function ScoreService:add_point(state, team)
	if team == "t" then
		state.points.t = state.points.t + 1
	elseif team == "ct" then
		state.points.ct = state.points.ct + 1
	end
	
	self:update_display(state)
end

-- Resetar pontos
function ScoreService:reset(state)
	state.points.t = 0
	state.points.ct = 0
	self:update_display(state)
end

-- Atualizar display visual do placar
function ScoreService:update_display(state)
	-- Remover imagens antigas
	state.score_images.t = ImageUtils:free(state.score_images.t)
	state.score_images.ct = ImageUtils:free(state.score_images.ct)
	state.score_images.bg = ImageUtils:free(state.score_images.bg)
	
	-- Criar imagem de fundo do placar
	state.score_images.bg = ImageUtils:create(Config.GRAPHICS.placar, 120, 50, 2)
	
	-- Criar imagens dos números com spritesheet
	local bg_left = 120 - 100
	state.score_images.t = ImageUtils:create(
		"<spritesheet:" .. Config.GRAPHICS.numeros .. ":26:42>", 
		bg_left + 70, 50, 2
	)
	state.score_images.ct = ImageUtils:create(
		"<spritesheet:" .. Config.GRAPHICS.numeros .. ":26:42>", 
		bg_left + 64 + 68, 50, 2
	)
	
	-- Selecionar o frame correto (número do placar)
	ImageUtils:frame(state.score_images.t, state.points.t + 1)
	ImageUtils:frame(state.score_images.ct, state.points.ct + 1)
	
	-- Ajustar tamanho
	ImageUtils:scale(state.score_images.t, 1.0, 1.0)
	ImageUtils:scale(state.score_images.ct, 1.0, 1.0)
end

-- Verificar se um time atingiu a pontuação máxima
function ScoreService:check_win_condition(state)
	if state.points.t >= Config.SCORE.max_points then
		return "t", "Flamengo"
	elseif state.points.ct >= Config.SCORE.max_points then
		return "ct", "Corinthians"
	end
	return nil, nil
end

-- Retornar módulo
return ScoreService
