--[[
================================================================================
  UTILITÁRIO DE SOM - CS2D Football Game
  Responsabilidade: Gerenciar reprodução de sons
  
  Centraliza a lógica de tocar sons no servidor.
================================================================================
--]]

local SoundUtils = {}

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Tocar som para todos os jogadores
function SoundUtils:play(sound_path)
	if sound_path and sound_path ~= "" then
		parse('sv_sound "' .. sound_path .. '"')
	end
end

-- Tocar som aleatório de uma lista
function SoundUtils:play_random(sound_list)
	if sound_list and #sound_list > 0 then
		local random_index = math.random(1, #sound_list)
		self:play(sound_list[random_index])
	end
end

-- Retornar módulo
return SoundUtils
