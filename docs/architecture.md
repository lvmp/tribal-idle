# Arquitetura do Projeto

## Visão Geral
O projeto utiliza uma separação clara entre a Camada de Jogo (Flame) e a Camada de UI (Flutter Widgets).

## Estrutura de Pastas
```
lib/
├── domain/
│   ├── models/           # Entidades (GameState)
│   ├── logic/            # Regras de negócio puras (FireLogic)
│   └── repositories/     # Interfaces de repositório
├── infrastructure/
│   ├── persistence/      # HiveSaveService
│   └── services/         # AdMobService, FirebaseService (futuro)
├── presentation/
│   ├── game/
│   │   ├── tribal_idle_game.dart   # FlameGame + GameLoop
│   │   └── components/             # Componentes Flame (WoodLabel, FireBar)
│   └── widgets/          # Flutter UI Overlays (HudOverlay)
└── shared/
    ├── state/            # Riverpod Providers + Notifiers + FireState
    └── constants/        # AssetPaths, Configurações
```

## Fluxo de Dados (The Bridge)

```
TimerComponent (1s, Flame)
    └─▶ GameStateNotifier.tick()        [shared/state]
          └─▶ GameState.processTick()   [domain/models]
                ├─▶ FireLogic           [domain/logic]
                └─▶ state = copyWith()  → rebuild reativo

fireStateProvider (derivado)
    └─▶ FireBarComponent.update()       [presentation/game]  ← só lê

gameStateProvider
    └─▶ HudOverlay (Flutter widget)     [presentation/widgets] ← só lê
    └─▶ WoodLabelComponent.update()     [presentation/game]    ← só lê
```

## HUD: Dois Planos de Renderização

| Plano | Tecnologia | Conteúdo |
|-------|-----------|----------|
| **camera.viewport** (Flame) | `PositionComponent` | `WoodLabelComponent`, `FireBarComponent` |
| **GameWidget overlay** (Flutter) | `ConsumerWidget` | `HudOverlay` (chips de recurso) |

Componentes em `camera.viewport` ficam **fixos na tela** independentemente da posição da câmera no mundo.

## Regra de Ouro
> NUNCA coloque lógica de negócio em componentes Flame ou widgets Flutter.
> Ambos devem apenas **disparar métodos** do Domain ou **observar** mudanças de estado.
> Toda lógica de tick e economia reside em `GameState` e `FireLogic`.