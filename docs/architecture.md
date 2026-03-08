# Arquitetura do Projeto

## Visão Geral
O projeto utiliza uma separação clara entre a Camada de Jogo (Flame) e a Camada de UI (Flutter Widgets).

## Estrutura de Pastas
```
lib/
├── domain/
│   ├── models/           # Entidades (ex: Resource, Manager, FireState)
│   ├── logic/            # Regras de negócio (Idle math, tick logic)
│   └── repositories/     # Interfaces de repositório
├── infrastructure/
│   ├── persistence/      # Hive Adapters, Data Sources
│   └── services/         # AdMobService, FirebaseService
├── presentation/
│   ├── game/             # FlameGame, Componentes, GameLoop
│   └── widgets/          # Flutter UI Widgets, Overlays, HUD
└── shared/
    ├── state/            # Riverpod Providers, Notifiers
    └── constants/        # Cores, Sprites, Configurações
```

# Fluxo de Dados (The Bridge)
1. **Source of Truth:** O estado do jogo reside em `lib/domain/`.
2. **Game Loop:** O Flame lê o estado de `domain` para renderizar o canvas.
3. **UI Interaction:** Flutter Widgets disparam eventos que atualizam o estado em `domain`.
4. **Reactive UI:** Componentes do Flame e Widgets do Flutter observam o estado (via StateNotifier/ChangeNotifier) e reagem automaticamente às mudanças.

## Regra de Ouro
NUNCA instancie lógica de jogo pesada dentro de um Widget do Flutter. Widgets devem apenas disparar métodos do `Domain` ou ouvir mudanças de estado.