--[[
================================================================================
  UTILITÁRIO DE IMAGEM - CS2D Football Game
  Responsabilidade: Gerenciar criação e manipulação de imagens
  
  Centraliza operações comuns com imagens do CS2D.
================================================================================
--]]

local ImageUtils = {}

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Liberar imagem com segurança
function ImageUtils:free(img)
	if img and img > 0 then
		freeimage(img)
	end
	return 0
end

-- Criar imagem
function ImageUtils:create(path, x, y, mode)
	return image(path, x or 0, y or 0, mode or 0)
end

-- Posicionar imagem
function ImageUtils:position(img, x, y, rot)
	if img and img > 0 then
		imagepos(img, x, y, rot or 0)
	end
end

-- Escalar imagem
function ImageUtils:scale(img, scale_x, scale_y)
	if img and img > 0 then
		imagescale(img, scale_x, scale_y or scale_x)
	end
end

-- Colorir imagem
function ImageUtils:color(img, r, g, b)
	if img and img > 0 then
		imagecolor(img, r, g, b)
	end
end

-- Definir transparência
function ImageUtils:alpha(img, alpha_value)
	if img and img > 0 then
		imagealpha(img, alpha_value)
	end
end

-- Definir blend mode
function ImageUtils:blend(img, mode)
	if img and img > 0 then
		imageblend(img, mode)
	end
end

-- Definir frame de spritesheet
function ImageUtils:frame(img, frame_number)
	if img and img > 0 then
		imageframe(img, frame_number)
	end
end

-- Retornar módulo
return ImageUtils
