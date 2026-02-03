--[[
================================================================================
  REPOSITÓRIO DE ESTATÍSTICAS - CS2D Football Game
  Responsabilidade: Gerenciar persistência de estatísticas dos jogadores
  
  Este módulo é responsável por:
  - Carregar estatísticas do arquivo
  - Salvar estatísticas no arquivo
  - Operações CRUD sobre dados de jogadores
================================================================================
--]]

local StatsRepository = {}

-- Arquivo de persistência
local STATS_FILE = "sys/lua/stats.txt"

-- ============================================================================
-- FUNÇÕES PRIVADAS
-- ============================================================================

-- Parsear linha do arquivo
local function parse_line(line)
	-- Formato novo: id,nome,gols
	local id, name, gols = line:match("([^,]+),([^,]+),(%d+)")
	if id and name and gols then
		return id, {name = name, gols = tonumber(gols) or 0}
	end
	
	-- Compatibilidade com formato antigo: id,gols
	local old_id, old_gols = line:match("([^,]+),(%d+)")
	if old_id and old_gols then
		return old_id, {name = old_id, gols = tonumber(old_gols) or 0}
	end
	
	return nil, nil
end

-- ============================================================================
-- FUNÇÕES PÚBLICAS
-- ============================================================================

-- Carregar todas as estatísticas do arquivo
function StatsRepository:load()
	local stats = {}
	local file = io.open(STATS_FILE, "r")
	
	if file then
		for line in file:lines() do
			local id, data = parse_line(line)
			if id and data then
				stats[id] = data
			end
		end
		file:close()
	else
		-- Se arquivo não existe, criar vazio
		self:save({})
	end
	
	return stats
end

-- Salvar todas as estatísticas no arquivo
function StatsRepository:save(stats)
	local file = io.open(STATS_FILE, "w")
	
	if file then
		for id, data in pairs(stats) do
			if type(data) == "table" then
				file:write(id .. "," .. data.name .. "," .. data.gols .. "\n")
			else
				-- Compatibilidade com formato antigo
				file:write(id .. "," .. id .. "," .. data .. "\n")
			end
		end
		file:close()
		return true
	end
	
	return false
end

-- Obter estatísticas de um jogador específico
function StatsRepository:get_player_stats(player_id, stats)
	return stats[player_id]
end

-- Atualizar estatísticas de um jogador
function StatsRepository:update_player_stats(player_id, player_name, gols, stats)
	if not stats[player_id] then
		stats[player_id] = {name = player_name, gols = 0}
	end
	
	stats[player_id].name = player_name
	stats[player_id].gols = gols
	
	return stats
end

-- Incrementar gols de um jogador
function StatsRepository:increment_goals(player_id, player_name, stats)
	if not stats[player_id] then
		stats[player_id] = {name = player_name, gols = 0}
	end
	
	stats[player_id].name = player_name
	stats[player_id].gols = stats[player_id].gols + 1
	
	return stats
end

-- Obter top N jogadores ordenados por gols
function StatsRepository:get_top_players(stats, limit)
	local sorted = {}
	
	for id, data in pairs(stats) do
		if type(data) == "table" then
			table.insert(sorted, {id = id, name = data.name, gols = data.gols})
		else
			-- Compatibilidade com formato antigo
			table.insert(sorted, {id = id, name = id, gols = data})
		end
	end
	
	-- Ordenar por gols (decrescente)
	table.sort(sorted, function(a, b) return a.gols > b.gols end)
	
	-- Limitar ao número solicitado
	local result = {}
	for i = 1, math.min(limit, #sorted) do
		table.insert(result, sorted[i])
	end
	
	return result
end

-- Retornar módulo
return StatsRepository
