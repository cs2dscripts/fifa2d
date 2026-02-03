--[[
================================================================================
  REPOSITÓRIO DE JOGADORES - CS2D Football Game
  Responsabilidade: Gerenciar dados e identificação de jogadores
  
  Este módulo é responsável por:
  - Obter ID único do jogador (USGN, Steam ID ou IP)
  - Gerenciar informações dos jogadores ativos
================================================================================
--]]

local PlayerRepository = {}

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Obter identificador único do jogador
-- Prioridade: USGN > Steam ID > IP
function PlayerRepository:get_player_id(pid)
	local usgn = player(pid, "usgn")
	if usgn and usgn > 0 then
		return "U" .. usgn
	end
	
	local steamid = player(pid, "steamid")
	if steamid and steamid ~= "0" then
		return "S" .. steamid
	end
	
	-- Usar IP como fallback
	return "IP" .. player(pid, "ip")
end

-- Obter nome do jogador por ID armazenado
function PlayerRepository:get_player_name_by_id(stored_id, stats)
	-- Tentar encontrar jogador online
	for _, pid in ipairs(player(0, "table")) do
		if player(pid, "exists") then
			local current_id = self:get_player_id(pid)
			if current_id == stored_id then
				return player(pid, "name")
			end
		end
	end
	
	-- Se não estiver online, usar nome salvo nas estatísticas
	if stats[stored_id] and type(stats[stored_id]) == "table" then
		return stats[stored_id].name
	end
	
	return stored_id
end

-- Verificar se jogador existe e está vivo
function PlayerRepository:is_player_alive(pid)
	return player(pid, "exists") and player(pid, "health") > 0
end

-- Verificar se é bot
function PlayerRepository:is_bot(pid)
	return player(pid, "bot")
end

-- Obter posição do jogador
function PlayerRepository:get_player_position(pid)
	return player(pid, "x"), player(pid, "y")
end

-- Obter time do jogador
function PlayerRepository:get_player_team(pid)
	return player(pid, "team")
end

-- Obter nome do jogador
function PlayerRepository:get_player_name(pid)
	return player(pid, "name")
end

-- Obter lista de todos os jogadores
function PlayerRepository:get_all_players()
	return player(0, "table")
end

-- Retornar módulo
return PlayerRepository
