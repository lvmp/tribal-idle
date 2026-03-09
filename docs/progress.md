# Progress Log — Tribal Idle

> Histórico de implementação por sprint. Atualizado a cada commit.

---

## Sprint 1 — FlameGame Bootstrap
**Commit:** `feat: FlameGame básico com WoodLabelComponent`
**Data:** 2026-03-09

### Entregável
- `TribalIdleGame` (FlameGame com game loop, economy tick 1s, autosave 30s)
- `WoodLabelComponent` — `TextComponent` no `camera.viewport` que lê `gameStateProvider`
- Fix: `ProviderScope.containerOf` movido de `initState` → `didChangeDependencies`

### Arquivos
| Arquivo | Tipo |
|---------|------|
| `lib/presentation/game/tribal_idle_game.dart` | MODIFY |
| `lib/presentation/game/components/wood_label_component.dart` | NEW |
| `lib/main.dart` | MODIFY (bugfix) |

---

## Sprint 2 — Sistema de Fogo (FireSystem)
**Commit:** `f46cf23` — `feat: Sistema de Fogo (FireSystem) — sobrevivência core loop`
**Data:** 2026-03-09

### Entregável
- **Domain:** `FireLogic` (cálculos puros: consumo, penalidade 90%, crise 20%)
- **Domain:** `GameState.processTick()` consome combustível e aplica penalidade
- **State:** `addFuel()` em `GameStateNotifier`; `FireState` + `fireStateProvider` (derivados)
- **Presentation:** `FireBarComponent` no `camera.viewport` — gradiente 🔴→🟠→🟢, ScaleEffect em crise

### Arquivos
| Arquivo | Tipo |
|---------|------|
| `lib/domain/logic/fire_logic.dart` | NEW |
| `lib/domain/models/game_state.dart` | MODIFY |
| `lib/shared/state/providers.dart` | MODIFY |
| `lib/presentation/game/components/fire_bar_component.dart` | NEW |
| `lib/presentation/game/tribal_idle_game.dart` | MODIFY |
| `lib/presentation/widgets/hud_overlay.dart` | MODIFY |

### Constantes do FireSystem
| Constante | Valor | Significado |
|-----------|-------|-------------|
| `kDefaultMaxFuel` | 300s | 5 minutos de combustível máximo |
| `kDefaultConsumptionRate` | 1.0/s | 1 unidade consumida por segundo |
| `kCrisisThreshold` | 0.20 | Abaixo de 20% → barra pulsa |
| `kPenaltyFactor` | 0.10 | Fogo apagado → 10% de produção |

---

## Próximos Passos (Backlog)
- [ ] ZoneSystem — zonas de trabalho com nível e custo exponencial
- [ ] NpcComponent — homens das cavernas com animação de coleta
- [ ] FireComponent — sprite pulsante da fogueira central
- [ ] ParallaxComponent — background com camadas (céu, montanhas, floresta)
- [ ] ManagerSystem — gerentes com bônus passivos
- [ ] PrestigeSystem — soft reset com moeda de prestígio
- [ ] OfflineEarnings — cap de 8h e cenário de fogo apagado offline
- [ ] AdManager — Rewarded Ads (mammute, bênção, offline)
