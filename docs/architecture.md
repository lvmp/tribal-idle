# Arquitetura do Projeto

## Visão Geral
O projeto utiliza uma separação clara entre a Camada de Jogo (Flame) e a Camada de UI (Flutter Widgets).

## Estrutura de Pastas
- `lib/domain/`: Regras de negócio, cálculos matemáticos (Idle Logic), modelos.
- `lib/infrastructure/`: Repositórios, persistência (Hive/Isar), serviços (Ads).
- `lib/presentation/`:
  - `game/`: Componentes do Flame, Game Loop, Entidades.
  - `widgets/`: UI do Flutter, Menus, Hud, Overlays.
- `lib/shared/`: Gerenciamento de estado (Riverpod/Bloc), constantes.

## Fluxo de Dados (The Bridge)
1. **Source of Truth:** O estado do jogo reside em `lib/domain/`.
2. **Game Loop:** O Flame lê o estado de `domain` para renderizar o canvas.
3. **UI Interaction:** Flutter Widgets disparam eventos que atualizam o estado em `domain`.
4. **Reactive UI:** Componentes do Flame e Widgets do Flutter observam o estado (via StateNotifier/ChangeNotifier) e reagem automaticamente às mudanças.

## Regra de Ouro
NUNCA instancie lógica de jogo pesada dentro de um Widget do Flutter. Widgets devem apenas disparar métodos do `Domain` ou ouvir mudanças de estado.