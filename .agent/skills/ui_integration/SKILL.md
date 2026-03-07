---
name: ui-integration
description: "Flame + Flutter bridge: overlays, reactive state, HUD, menus, responsive design for mobile games."
allowed-tools: Read, Write, Edit, Glob, Grep
---

# UI Integration — Flame + Flutter Bridge

> Gerenciar a fronteira entre componentes do Flame e Widgets do Flutter. Cada lado para o que faz melhor.

---

## 1. A Divisão Flame ↔ Flutter

### Onde Cada Coisa Vive

| Flame Canvas | Flutter Overlays |
|--------------|------------------|
| Mundo do jogo (mapa, NPCs) | Menus, painéis, modals |
| Animações de personagens | Tabelas de upgrade |
| Partículas e efeitos | Inventário e loja |
| Background parallax | HUD com contadores |
| Interações de toque no mundo | Botões e formulários |
| Feedback visual (screen shake) | Notificações e toasts |

### Regra de Ouro

> Se é **dinâmico e visual** → Flame. Se é **interativo e informativo** → Flutter.

---

## 2. Sistema de Overlays

### Registro

```dart
GameWidget<MyGame>(
  game: myGame,
  overlayBuilderMap: {
    'hud': (context, game) => HudOverlay(game: game),
    'upgrade_menu': (context, game) => UpgradeMenu(game: game),
    'shop': (context, game) => ShopOverlay(game: game),
    'pause': (context, game) => PauseMenu(game: game),
    'offline_earnings': (context, game) => OfflineDialog(game: game),
    'settings': (context, game) => SettingsMenu(game: game),
  },
  initialActiveOverlays: const ['hud'],
)
```

### Controle

```dart
// Dentro do game ou de componentes
game.overlays.add('shop');      // Abrir
game.overlays.remove('shop');   // Fechar
game.overlays.isActive('shop'); // Verificar

// Toggle
if (game.overlays.isActive('shop')) {
  game.overlays.remove('shop');
} else {
  game.overlays.add('shop');
}
```

### Múltiplos Overlays Simultâneos

| Overlay | Persistente? | Sobre outros? |
|---------|-------------|---------------|
| **HUD** | ✅ Sempre ativo | Base layer |
| **Upgrade Menu** | ❌ Toggle | Sobre HUD |
| **Shop** | ❌ Toggle | Sobre HUD |
| **Pause** | ❌ Toggle | Sobre tudo |
| **Settings** | ❌ Toggle | Sobre tudo |

---

## 3. Estado Compartilhado (Reactive Bridge)

### Com Riverpod

```dart
// Provider do estado
final gameStateProvider = ChangeNotifierProvider((ref) => GameState());

// No Flutter overlay
class HudOverlay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    return Row(
      children: [
        ResourceCounter(icon: Icons.forest, value: state.wood),
        ResourceCounter(icon: Icons.restaurant, value: state.food),
        ResourceCounter(icon: Icons.landscape, value: state.stone),
      ],
    );
  }
}

// No Flame component
class ZoneComponent extends SpriteComponent with HasGameRef<MyGame> {
  @override
  void update(double dt) {
    // Ler estado do domain (não do widget)
    final zone = gameRef.gameState.zones[zoneId];
    // Atualizar visual baseado no estado
  }
}
```

### Com ValueNotifier (Simples)

```dart
// Para UI que precisa rebuildar em mudanças específicas
class GameState {
  final ValueNotifier<double> woodNotifier = ValueNotifier(0);
  
  set wood(double value) {
    _wood = value;
    woodNotifier.value = value;
  }
}

// No overlay
ValueListenableBuilder<double>(
  valueListenable: gameState.woodNotifier,
  builder: (context, wood, child) {
    return Text('🪵 ${formatNumber(wood)}');
  },
)
```

---

## 4. HUD Design para Mobile

### Layout Recomendado

```
┌─────────────────────────────────┐
│  🪵 1.2K   🍖 850   ⛏️ 2.1K    │ ← Recursos (topo)
│  ████████████░░░░  🔥 67%       │ ← Barra de Fogo
├─────────────────────────────────┤
│                                 │
│        [FLAME CANVAS]           │ ← Mundo do jogo
│        Zonas de Trabalho        │
│        NPCs, Animações          │
│                                 │
├─────────────────────────────────┤
│  [⬆ Upgrade] [🛒 Shop] [⚙ Set] │ ← Ações (bottom)
└─────────────────────────────────┘
```

### Princípios de HUD

| Princípio | Implementação |
|-----------|---------------|
| **Mínimo visual** | Apenas info essencial |
| **Touch-friendly** | Botões ≥ 44x44 pts |
| **Sem oclusão** | HUD não cobre gameplay |
| **Feedback imediato** | Números animam ao mudar |
| **Responsive** | Adaptar a diferentes telas |

---

## 5. Animações de UI

### Feedback Visual em Upgrades

| Evento | Animação |
|--------|----------|
| **Comprar upgrade** | Botão faz "squash & stretch" |
| **Recurso ganho** | Número flutua para cima (+50) |
| **Nível up** | Flash dourado + particle burst |
| **Fogo baixo** | Barra pulsa em vermelho |
| **Fogo restaurado** | Screen glow + vibração |

### Implementação de Floating Text

```dart
class FloatingText extends TextComponent {
  FloatingText(String text, Vector2 position) 
    : super(text: text, position: position);
  
  double _elapsed = 0;
  
  @override
  void update(double dt) {
    _elapsed += dt;
    position.y -= 30 * dt; // Subir
    opacity = max(0, 1 - _elapsed); // Fade out
    if (_elapsed > 1) removeFromParent();
  }
}
```

---

## 6. Responsividade

### Estratégia por Tela

| Tamanho | Adaptação |
|---------|-----------|
| **Phone** (< 6") | HUD compacto, botões empilhados |
| **Phone+** (6-7") | HUD normal |
| **Tablet** (> 7") | HUD expandido, mais info visível |

### Implementação

```dart
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  
  return isTablet 
    ? TabletHudLayout(game: game)
    : PhoneHudLayout(game: game);
}
```

---

## 7. Anti-Patterns

| ❌ Don't | ✅ Do |
|----------|-------|
| UI complexa desenhada no Canvas | Flutter overlays |
| Rebuildar overlay a cada frame | `ValueListenableBuilder` |
| Lógica de negócio em widgets | Widgets apenas observam/disparam |
| Ignorar safe area | `SafeArea` + `MediaQuery` |
| HUD cobrindo gameplay | Layout com áreas definidas |
| Botões pequenos | Mínimo 44x44 pts |

---

> **Remember:** Flutter é excelente para UI. Flame é excelente para canvas. Use a ponte (overlays) para combinar o melhor dos dois.