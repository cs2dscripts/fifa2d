--[[
================================================================================
  UTILITÁRIO MATEMÁTICO - CS2D Football Game
  Responsabilidade: Funções matemáticas reutilizáveis
  
  Funções auxiliares para cálculos geométricos e matemáticos.
================================================================================
--]]

local MathUtils = {}

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Calcular distância euclidiana entre dois pontos
function MathUtils:distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Calcular ângulo em graus entre dois pontos
function MathUtils:angle(x1, y1, x2, y2)
	return math.deg(math.atan2(x2 - x1, y2 - y1))
end

-- Converter tile para coordenada de pixel
function MathUtils:tile_to_pixel(tile)
	return (tile * 32) + 16
end

-- Converter pixel para tile
function MathUtils:pixel_to_tile(pixel)
	return math.floor(pixel / 32)
end

-- Normalizar ângulo para 0-360
function MathUtils:normalize_angle(angle)
	while angle > 360 do
		angle = angle - 360
	end
	while angle < 0 do
		angle = angle + 360
	end
	return angle
end

-- Clampar valor entre min e max
function MathUtils:clamp(value, min, max)
	if value < min then return min end
	if value > max then return max end
	return value
end

-- Linear interpolation
function MathUtils:lerp(a, b, t)
	return a + (b - a) * t
end

-- Retornar módulo
return MathUtils
