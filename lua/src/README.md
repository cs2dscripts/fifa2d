# CS2D Football Game - Versão Modular

## 🎮 Sobre

Script de futebol para CS2D completamente refatorado utilizando **Module Architecture**, com separação clara de responsabilidades e código organizado.

## 📦 Instalação

1. **Copie a pasta `src/` para** `sys/lua/`
2. **Configure o carregamento no servidor**:

### Método 1: Autorun (Recomendado)
Edite ou crie `sys/lua/autorun.lua`:
```lua
dofile("sys/lua/src/main.lua")
```

### Método 2: Server.lua
Se você tem um `server.lua` customizado, adicione no topo:
```lua
dofile("sys/lua/src/main.lua")
-- ... resto do seu código
```

## 🎯 Comandos do Jogo

- `!rb` - Resetar partida manualmente
- `!rs` - Tocar som de reset
- `!rank` ou `!stats` - Ver seus gols
- `!reload` ou `!recarregar` - Recarregar estatísticas

## 🏗️ Estrutura

```
src/
├── main.lua                    # Ponto de entrada
└── modules/
    ├── core/                   # Configurações e estado
    ├── repositories/           # Persistência de dados
    ├── services/               # Lógica reutilizável
    ├── use_cases/              # Regras de negócio
    └── utils/                  # Funções auxiliares
```

## 📖 Documentação

Consulte [ARCHITECTURE.md](ARCHITECTURE.md) para:
- Decisões arquiteturais detalhadas
- Como adicionar novos módulos
- Boas práticas de desenvolvimento
- Exemplos práticos

## ✨ Principais Funcionalidades

- ⚽ Sistema de física da bola realista
- 🤖 IA inteligente para bots (atacantes/defensores)
- 💨 Sistema de stamina e corrida
- 🎬 Replay automático após gols
- 💥 Efeitos visuais de explosão
- 🏆 Sistema de ranking de artilheiros
- 📊 Estatísticas persistentes
- 🎵 Efeitos sonoros e vinhetas dos times

## 🔧 Customização

Todas as configurações estão centralizadas em:
- `src/modules/core/config.lua` - Sons, gráficos, textos, parâmetros

Exemplos de ajustes:
```lua
-- Alterar velocidade da bola
Config.BALL.kickspeed = 15  -- padrão: 10

-- Alterar stamina máxima
Config.STAMINA.max = 150  -- padrão: 100

-- Alterar pontos para vitória
Config.SCORE.max_points = 10  -- padrão: 5
```

## 🛠️ Desenvolvimento

### Adicionar Novo Recurso

1. **Criar Service** (se for lógica reutilizável)
   - Pasta: `src/modules/services/`
   
2. **Criar Use Case** (se for fluxo de negócio)
   - Pasta: `src/modules/use_cases/`
   
3. **Integrar no GameLoop ou Main**
   - Editar: `src/modules/use_cases/game_loop.lua` ou `src/main.lua`

### Exemplo: Adicionar Power-Up
Veja exemplos detalhados em [ARCHITECTURE.md](ARCHITECTURE.md#como-adicionar-novos-módulos)

## 🐛 Debug

Para habilitar logs de debug, adicione em `main.lua`:
```lua
-- No início do arquivo
DEBUG_MODE = true

-- Nas funções
if DEBUG_MODE then
    print("Debug: Ball position", GameState.ball.x, GameState.ball.y)
end
```

## 📝 Notas de Versão

### v2.0 - Refatoração Modular
- ✅ Código completamente modularizado
- ✅ Separação de responsabilidades
- ✅ Arquitetura escalável
- ✅ Documentação completa
- ✅ Fácil manutenção e extensão

### v1.0 - Versão Original
- Script monolítico em arquivo único
- Funcionalidades básicas do jogo

## 🤝 Contribuindo

Para adicionar novos recursos:
1. Siga a estrutura modular existente
2. Documente suas mudanças
3. Mantenha baixo acoplamento entre módulos
4. Teste antes de integrar

## 📄 Licença

Projeto criado para CS2D - Use livremente e customize conforme necessário.

## 🙏 Agradecimentos

- Comunidade CS2D
- Desenvolvedores do jogo base original

---

**Dúvidas?** Consulte [ARCHITECTURE.md](ARCHITECTURE.md) para documentação detalhada.
