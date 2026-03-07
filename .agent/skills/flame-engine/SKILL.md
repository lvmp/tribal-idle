---
name: flame-engine
description: Flame Engine (Flutter) game development. Components, game loop, overlays, performance, audio, and mobile optimization.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Flame Engine — Flutter Game Framework

> **Docs:** https://docs.flame-engine.org/
> **Repo:** https://github.com/flame-engine/flame (`packages/flame/lib/src/`)
> **Módulos no source:** cache, camera, collisions, components, effects, events, game, geometry, gestures, layers, layout, math, particles, post_process, rendering, text, widgets

---

## 1. FlameGame (Raiz)

### Código-fonte: `src/game/flame_game.dart`

`FlameGame<W extends World>` é a classe base recomendada. Herda de `ComponentTreeRoot` com mixin `Game`.

```dart
// World genérico tipado (do GitHub source)
class MyWorld extends World {
  int score = 0;
}

class TribalIdleGame extends FlameGame<MyWorld> {
  TribalIdleGame() : super(world: MyWorld());
  // game.world retorna MyWorld sem cast!
}
```

### Propriedades Chave

```dart
game.world;         // W (World tipado) — onde adicionar componentes do jogo
game.camera;         // CameraComponent — viewport, viewfinder, follow
game.size;           // Vector2 (tamanho lógico após viewport transform)
game.canvasSize;     // Vector2 (tamanho real do widget Flutter)
game.currentTime();  // double — tempo atual em segundos com precisão de microsegundos
```

### Métodos do Source

```dart
// Aguardar que TODA a árvore esteja carregada (útil em testes)
await game.ready();

// Lifecycle do app (do source — usa _pausedBecauseBackgrounded)
@override
void lifecycleStateChange(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.paused:
      saveService.save(gameState);
      pauseEngine();
      break;
    case AppLifecycleState.resumed:
      resumeEngine();
      break;
    default: break;
  }
}

// Pausar/resumir o engine
game.pauseEngine();
game.resumeEngine();
game.paused; // bool
```

### Overlay Control

```dart
game.overlays.add('shop');            // Abrir overlay
game.overlays.remove('shop');         // Fechar overlay
game.overlays.isActive('shop');       // Verificar se ativo
game.overlays.removeAll(['a', 'b']);  // Fechar vários
```

---

## 2. Component System (FCS)

### Source: `src/components/`

Todos os componentes herdam de `Component`. É um sistema hierárquico (árvore).

### Component Lifecycle (do source `component.dart`)

```
Constructor → onLoad() → onGameResize() → onMount() → update(dt)/render(canvas) → onRemove()
```

| Callback | Frequência | Uso |
|----------|-----------|-----|
| `onLoad()` | **1x** na vida | Inicialização async (carregar sprites, dados) |
| `onGameResize(Vector2)` | Cada resize + antes do mount | Adaptar ao tamanho de tela |
| `onParentResize(Vector2)` | Quando parent muda tamanho | Layout relativo |
| `onMount()` | **Cada vez** que é adicionado | Pode repetir! NÃO use `late final` aqui |
| `update(double dt)` | Cada frame | Lógica visual (NÃO economia) |
| `render(Canvas canvas)` | Cada frame | Desenho customizado |
| `onRemove()` | Quando removido | Cleanup (timers, subscriptions) |
| `onChildrenChanged(child, type)` | Quando filhos mudam | Detectar add/remove de filhos |

### State Checkers (do source)

```dart
component.isLoaded;   // bool
component.loaded;     // Future<void>
component.isMounted;  // bool
component.mounted;    // Future<void>
component.isRemoved;  // bool
component.removed;    // Future<void>
```

### Composição e Queries

```dart
// Adicionar filhos
component.add(child);
component.addAll([child1, child2]);
Component(children: [child1, child2]); // No constructor

// Queries
component.children;                          // ComponentSet
component.children.query<SpriteComponent>(); // Lista tipada
component.findParent<MyGame>();              // Buscar parent
game.componentsAtPoint(position);            // Hit testing

// Visibilidade (mixin HasVisibility)
component.isVisible = false; // Pula render() E update()

// Prioridade (menor = renderiza primeiro)
component.priority = 10; // Reordena na árvore

// Component Keys (busca por key)
Component(key: ComponentKey.named('fire'));
game.findByKey(ComponentKey.named('fire'));
```

---

## 3. Componentes Built-in (do repo `src/components/`)

### PositionComponent

```dart
// Base para qualquer coisa com posição, tamanho, escala, rotação
class MyZone extends PositionComponent {
  MyZone() : super(
    position: Vector2(100, 200),
    size: Vector2(128, 128),
    scale: Vector2.all(1.0),
    angle: 0,           // Radianos
    nativeAngle: 0,     // Ângulo do asset original
    anchor: Anchor.center,
  );
}
```

### SpriteComponent

```dart
final building = SpriteComponent(
  sprite: await Sprite.load('building.png'),
  size: Vector2(128, 128),
  position: Vector2(100, 200),
  anchor: Anchor.center,
);
world.add(building);
```

### SpriteAnimationComponent

```dart
// De sprite sheet (mais eficiente — 1 draw call)
final data = SpriteAnimationData.sequenced(
  textureSize: Vector2.all(64),
  amount: 6,       // 6 frames no sheet
  stepTime: 0.1,   // 100ms por frame
);
final npc = SpriteAnimationComponent.fromFrameData(
  await images.load('npc_walk.png'),
  data,
  size: Vector2.all(64),
  removeOnFinish: false, // true = remove ao acabar (se não loop)
);

// Callbacks do SpriteAnimationTicker (do source)
npc.animationTicker
  ..onStart = () { /* início do ciclo */ }
  ..onFrame = (index) { /* frame específico atingido */ }
  ..onComplete = () { /* fim — só se removeOnFinish ou não loop */ };

// Aguardar animação terminar
await npc.animationTicker.completed;
```

### SpriteAnimationGroupComponent (Múltiplos Estados)

```dart
enum NpcState { idle, walking, collecting, delivering }

class NpcComponent extends SpriteAnimationGroupComponent<NpcState> {
  @override
  Future<void> onLoad() async {
    animations = {
      NpcState.idle: await _loadAnim('idle.png', 4, 0.15),
      NpcState.walking: await _loadAnim('walk.png', 6, 0.1),
      NpcState.collecting: await _loadAnim('collect.png', 4, 0.12),
    };
    current = NpcState.idle;
  }

  void startWalking() => current = NpcState.walking;
}
```

### ParallaxComponent (Background)

```dart
final parallax = await loadParallaxComponent(
  [
    ParallaxImageData('sky.png'),
    ParallaxImageData('mountains.png'),
    ParallaxImageData('trees.png'),
  ],
  baseVelocity: Vector2(5, 0),
  velocityMultiplierDelta: Vector2(1.8, 1.0),
);
world.add(parallax);

// Ajustar dinamicamente
parallax.parallax!.baseVelocity = Vector2(20, 0);

// Opções por layer (do docs)
loadParallaxImage(
  'stars.jpg',
  repeat: ImageRepeat.repeat,       // repeat, repeatX, repeatY, noRepeat
  alignment: Alignment.center,      // Alinhamento da imagem
  fill: LayerFill.width,            // width, height, none
);
```

### IsometricTileMapComponent (Mapa Isométrico)

```dart
final tilesetImage = await images.load('tileset.png');
final tileset = SpriteSheet(
  image: tilesetImage,
  srcSize: Vector2.all(64),  // Cada tile
);

// -1 = vazio, 0+ = tile ID (sequencial: esquerda→direita, cima→baixo)
final matrix = [
  [0, 1, 0, -1],
  [1, 2, 1, 0],
  [0, 1, 0, 1],
];

final map = IsometricTileMapComponent(
  tileset, matrix,
  tileHeight: 32, // Altura da face frontal do cubóide
);
world.add(map);

// Converter touch → tile
final blockIndex = map.getBlock(touchPosition); // Retorna coordenada do tile
```

### SpawnComponent (Spawner Periódico)

```dart
world.add(SpawnComponent(
  factory: (index) => GoldenMammothComponent(),
  period: 120.0,       // A cada 2 minutos
  selfPositioning: true,
));
```

### TextComponent

```dart
final label = TextComponent(
  text: 'Nível 5',
  textRenderer: TextPaint(
    style: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: 'PressStart2P',
    ),
  ),
  position: Vector2(50, 50),
);
world.add(label);

// Atualizar texto
label.text = 'Nível 6';
```

### NineTileBoxComponent (Painéis Escaláveis)

```dart
// Grid 3x3 que escala sem distorção — bom para diálogos no canvas
final spriteImg = await images.load('panel_9slice.png');
final nineTileBox = NineTileBox(Sprite(spriteImg));
world.add(NineTileBoxComponent(
  nineTileBox: nineTileBox,
  size: Vector2(200, 150),
  position: Vector2(50, 50),
));
```

### TimerComponent

```dart
// Tick periódico — útil para economy ticks
world.add(TimerComponent(
  period: 1.0,           // A cada 1 segundo
  repeat: true,
  onTick: () => gameState.processTick(),
));
```

---

## 4. Effects System

### Source: `src/effects/effect.dart`

Effects são Components que **alteram propriedades** de outros componentes gradualmente. Baseados em `EffectController` (progress 0.0 → 1.0).

### API do Effect (do source)

```dart
effect.isPaused;       // bool
effect.pause();        // Pausar efeito
effect.resume();       // Retomar
effect.reset();        // Reiniciar para o início
effect.resetToEnd();   // Pular para o final
effect.removeOnFinish; // bool (true por padrão) — remove ao completar
effect.completed;      // Future<void> — aguardar conclusão
effect.onComplete = () { /* callback */ };
```

### Effects Disponíveis

```dart
// ═══════════ MOVE ═══════════
component.add(MoveEffect.to(
  Vector2(200, 100),
  EffectController(duration: 0.5, curve: Curves.easeOut),
));

component.add(MoveEffect.by( // Relativo
  Vector2(0, -50),
  EffectController(duration: 0.3),
));

// ═══════════ SCALE (Squash & Stretch) ═══════════
component.add(ScaleEffect.to(
  Vector2(1.2, 0.8),
  EffectController(duration: 0.1, reverseDuration: 0.2),
));

component.add(ScaleEffect.by(
  Vector2.all(0.05), // Pulse sutil
  EffectController(duration: 0.5, reverseDuration: 0.5, infinite: true),
));

// ═══════════ OPACITY ═══════════
component.add(OpacityEffect.fadeOut(
  EffectController(duration: 1.0),
  onComplete: () => component.removeFromParent(),
));

component.add(OpacityEffect.fadeIn(
  EffectController(duration: 0.5),
));

component.add(OpacityEffect.to(
  0.5, // 50% opaco
  EffectController(duration: 0.3),
));

// ═══════════ ROTATE ═══════════
component.add(RotateEffect.by(
  tau, // 360° (import 'dart:math')
  EffectController(duration: 2.0, infinite: true),
));

component.add(RotateEffect.to(
  pi / 4, // 45°
  EffectController(duration: 0.5),
));

// ═══════════ COLOR ═══════════
component.add(ColorEffect(
  const Color(0xFFFFD700), // Dourado
  EffectController(duration: 0.3, reverseDuration: 0.3),
));

// ═══════════ SIZE ═══════════
component.add(SizeEffect.to(
  Vector2(200, 200),
  EffectController(duration: 0.5),
));

// ═══════════ SEQUÊNCIA ═══════════
component.add(SequenceEffect([
  ScaleEffect.to(Vector2(1.2, 0.8), EffectController(duration: 0.05)),
  ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.15)),
  // Adicione quantos quiser
]));

// ═══════════ REMOVE ═══════════
component.add(RemoveEffect(delay: 2.0)); // Remove após 2s
```

### EffectController — Opções

```dart
EffectController(
  duration: 1.0,          // Duração em segundos
  reverseDuration: 0.5,   // Duração da volta (ping-pong)
  curve: Curves.easeInOut, // Curva de animação (Flutter)
  infinite: true,          // Loop infinito
  alternate: true,         // Ida e volta
  repeatCount: 3,          // Repetir N vezes
  startDelay: 0.5,         // Delay antes de começar
  atMaxDuration: 0.2,      // Pausar no ponto máximo
  atMinDuration: 0.1,      // Pausar no ponto mínimo
);

// Controllers especiais
LinearEffectController(duration);
CurvedEffectController(duration, curve);
DelayedEffectController(child, delay);
NoiseEffectController(duration, frequency);
ZigzagEffectController(period: 1.0);
SineEffectController(period: 1.0);
```

---

## 5. Particles System

### Source: `src/particles/`

Particles têm `lifespan` e são gerenciadas por `ParticleSystemComponent`.

### Tipos Built-in

| Particle | Função |
|----------|--------|
| `TranslatedParticle` | Translada child por Vector2 |
| `MovingParticle` | Move de A→B com Curve |
| `AcceleratedParticle` | Física básica (gravidade, speed, aceleração) |
| `CircleParticle` | Renderiza círculo (cor, raio) |
| `SpriteParticle` | Renderiza Sprite como partícula |
| `ImageParticle` | Renderiza dart:ui Image |
| `ComponentParticle` | Renderiza Component como partícula |
| `ScalingParticle` | Escala child ao longo do lifespan |
| `SpriteAnimationParticle` | Animação de sprite como partícula |

### Exemplo: Faíscas da Fogueira

```dart
void spawnFireSparks(Vector2 firePosition) {
  final rnd = Random();

  for (int i = 0; i < 8; i++) {
    world.add(ParticleSystemComponent(
      particle: AcceleratedParticle(
        position: firePosition.clone(),
        speed: Vector2(
          rnd.nextDouble() * 40 - 20,  // X: -20..20
          -rnd.nextDouble() * 60 - 20, // Y: -80..-20 (para cima)
        ),
        acceleration: Vector2(0, 30), // Gravidade leve
        child: CircleParticle(
          radius: 1.5,
          paint: Paint()..color = Color.lerp(
            Colors.orange,
            Colors.yellow,
            rnd.nextDouble(),
          )!,
        ),
        lifespan: 0.8 + rnd.nextDouble() * 0.4,
      ),
    ));
  }
}
```

### Exemplo: Floating Resource

```dart
void spawnFloatingResource(Vector2 position, String text) {
  final textComponent = TextComponent(
    text: text,
    textRenderer: TextPaint(
      style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    position: position.clone(),
  );

  textComponent.add(MoveEffect.by(
    Vector2(0, -50),
    EffectController(duration: 1.2, curve: Curves.easeOut),
  ));
  textComponent.add(OpacityEffect.fadeOut(
    EffectController(duration: 1.2),
    onComplete: () => textComponent.removeFromParent(),
  ));

  world.add(textComponent);
}
```

---

## 6. Camera System

### Source: `src/camera/`

`CameraComponent` é um Component que contém `Viewport` e `Viewfinder`.

```dart
class TribalIdleGame extends FlameGame<TribalWorld> {
  TribalIdleGame() : super(
    world: TribalWorld(),
    camera: CameraComponent(), // Criado por padrão se não passado
  );

  @override
  Future<void> onLoad() async {
    // Follow: câmera segue um componente
    camera.follow(someComponent);

    // Ou: moveTo para posição específica
    camera.moveTo(Vector2(500, 300));

    // Zoom
    camera.viewfinder.zoom = 1.5;
    camera.viewfinder.anchor = Anchor.center;

    // Zoom animado
    camera.viewfinder.add(ScaleEffect.to(
      Vector2.all(2.0),
      EffectController(duration: 0.5, curve: Curves.easeInOut),
    ));

    // Bounds da câmera (limites de movimento)
    camera.setBounds(Rectangle.fromLTWH(0, 0, worldWidth, worldHeight));
  }
}
```

### Viewports

```dart
// FixedResolutionViewport — resolve diferenças de aspect ratio
camera.viewport = FixedResolutionViewport(
  resolution: Vector2(1080, 1920), // Portrait phone
);

// MaxViewport — usa todo o espaço (padrão)
camera.viewport = MaxViewport();

// FixedAspectRatioViewport
camera.viewport = FixedAspectRatioViewport(aspectRatio: 9 / 16);
```

---

## 7. Input System

### Source: `src/events/` e `src/gestures/`

### Para Componentes (Recomendado)

```dart
// Tap
class ZoneComponent extends SpriteComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) { /* feedback visual */ }

  @override
  void onTapUp(TapUpEvent event) { /* ação: abrir overlay, coletar */ }

  @override
  void onTapCancel(TapCancelEvent event) { /* cancelar feedback */ }

  @override
  void onLongTapDown(TapDownEvent event) { /* long press */ }
}

// Drag
class DraggableItem extends SpriteComponent with DragCallbacks {
  @override void onDragStart(DragStartEvent event) { /* início do drag */ }
  @override void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }
  @override void onDragEnd(DragEndEvent event) { /* fim do drag */ }
}

// Double Tap
class DoubleTapZone extends SpriteComponent with DoubleTapCallbacks {
  @override void onDoubleTapDown(DoubleTapDownEvent event) { /* ação */ }
}

// Scale (pinch zoom)
class ZoomableWorld extends Component with ScaleCallbacks {
  @override void onScaleUpdate(ScaleUpdateEvent event) { /* zoom */ }
}
```

### Hitboxes

```dart
// IMPORTANTE: componentes com TapCallbacks precisam de hitbox
class ZoneComponent extends SpriteComponent with TapCallbacks {
  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()); // Retângulo (padrão, usa size do component)

    // Ou customizado
    // add(RectangleHitbox(
    //   size: Vector2(48, 48),     // Mínimo 44x44 para mobile!
    //   position: Vector2(-4, -4), // Pode ser maior que o sprite
    // ));

    // add(CircleHitbox(radius: 32));
    // add(PolygonHitbox([...Vector2 points]));
  }
}
```

### Para Game (Legacy, 13 Detector Mixins)

```dart
// Disponíveis mas NÃO recomendados (use callbacks nos components)
// TapDetector, SecondaryTapDetector, DoubleTapDetector,
// LongPressDetector, VerticalDragDetector, HorizontalDragDetector,
// ForcePressDetector, PanDetector, ScaleDetector,
// MultiTouchTapDetector, MultiTouchDragDetector,
// MouseMovementDetector, ScrollDetector
```

---

## 8. GameWidget (Bridge Flutter)

### Source: `src/widgets/`

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GameWidget<TribalIdleGame>(
          game: TribalIdleGame(),
          overlayBuilderMap: {
            'hud': (ctx, game) => HudOverlay(game: game),
            'upgrade_menu': (ctx, game) => UpgradeMenu(game: game),
            'shop': (ctx, game) => ShopOverlay(game: game),
            'manager_menu': (ctx, game) => ManagerMenu(game: game),
            'pause': (ctx, game) => PauseScreen(game: game),
            'settings': (ctx, game) => SettingsScreen(game: game),
            'offline': (ctx, game) => OfflineDialog(game: game),
          },
          initialActiveOverlays: const ['hud'],
          loadingBuilder: (ctx) => const LoadingScreen(),
          errorBuilder: (ctx, error) => ErrorScreen(error: error),
          // backgroundBuilder: (ctx) => Container(color: Colors.black),
        ),
      ),
    );
  }
}
```

### Princípios de Overlay

| Regra | Motivo |
|-------|--------|
| HUD como `initialActiveOverlays` | Sempre visível |
| Flutter para UI complexa | Listas, formulários, tabelas |
| Flame para visual dinâmico | NPCs, partículas, animações |
| Fechar outros modais antes de abrir novo | Evitar sobreposição |
| Compartilhar estado via Riverpod | Single source of truth |
| Não rebuildar overlays frequentemente | Use `ValueListenableBuilder` |

---

## 9. Collision System

### Source: `src/collisions/`

```dart
// Mixin no game
class MyGame extends FlameGame with HasCollisionDetection {
  // HasCollisionDetection ativa o broadphase
}

// Mixin nos componentes
class BulletComponent extends SpriteComponent with CollisionCallbacks {
  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    if (other is EnemyComponent) {
      other.takeDamage(10);
      removeFromParent();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // Quando colisão termina
  }
}
```

---

## 10. Cache & Images

### Source: `src/cache/`

```dart
// Flame cacheia imagens automaticamente
final sprite = await Sprite.load('player.png'); // Cacheia na 1ª vez

// Pre-load batch (evita lag)
await images.loadAll([
  'npc_idle.png',
  'npc_walk.png',
  'building.png',
  'tileset.png',
]);

// SpriteBatch para performance (muitos sprites iguais)
final batch = await SpriteBatch.load('particles.png');
batch.add(source: Rect.fromLTWH(0, 0, 16, 16), offset: Vector2(x, y));
batch.render(canvas);

// SpriteSheet (sprite sheet → animações)
final sheet = SpriteSheet(
  image: await images.load('npc_sheet.png'),
  srcSize: Vector2(64, 64),
);
final animation = sheet.createAnimation(row: 0, stepTime: 0.1, to: 6);
```

---

## 11. Arquitetura para Idle Games

### Separação de Responsabilidades

```
FlameGame (raiz)
├── World (componentes visuais)
│   ├── ParallaxComponent (background)
│   ├── IsometricTileMapComponent (terreno)
│   ├── ZoneComponent (x N) → SpriteAnimationComponent (NPC)
│   ├── FireComponent → ParticleSystemComponent (faíscas)
│   └── SpawnComponent (mammute periódico)
├── CameraComponent → Viewport
└── TimerComponent (economy tick: 1s)
    └── gameState.processTick() // Domain layer
```

### Game Loop Pattern

```dart
class TribalIdleGame extends FlameGame<TribalWorld> {
  late GameState state;

  @override
  Future<void> onLoad() async {
    state = await SaveService.loadOrCreate();

    // Economy tick separado do render (1x por segundo)
    add(TimerComponent(
      period: 1.0,
      repeat: true,
      onTick: () => state.processTick(),
    ));

    // Autosave a cada 30s
    add(TimerComponent(
      period: 30.0,
      repeat: true,
      onTick: () => SaveService.save(state),
    ));
  }

  @override
  void lifecycleStateChange(AppLifecycleState lifecycle) {
    switch (lifecycle) {
      case AppLifecycleState.paused:
        SaveService.save(state);
        pauseEngine();
        break;
      case AppLifecycleState.resumed:
        final earnings = state.calculateOfflineEarnings();
        if (earnings.isNotEmpty) overlays.add('offline');
        resumeEngine();
        break;
      default: break;
    }
  }
}
```

---

## 12. Performance Mobile

| Técnica | Como | Source |
|---------|------|--------|
| **Object Pooling** | Reusar componentes, não criar/destruir | `ComponentKey` para lookup |
| **SpriteBatch** | Agrupar sprites similares | `src/sprite_batch.dart` |
| **isVisible** | Pular render/update | `HasVisibility` mixin |
| **removeFromParent()** | Liberar componentes fora de tela | Lifecycle automático |
| **30 FPS** | Suficiente para idle | Timer-based throttle |
| **Image cache** | Não recarregar | `src/cache/images.dart` |
| **ready()** | Aguardar árvore completa | Útil em loading screens |
| **Pausar em background** | Economizar bateria | `lifecycleStateChange` |

---

## 13. Audio

### Pacote: `flame_audio`

```dart
// SFX (curtos, fire-and-forget)
FlameAudio.play('click.mp3');
FlameAudio.play('upgrade.mp3', volume: 0.8);

// BGM (loop)
FlameAudio.bgm.play('tribal_drums.mp3');
FlameAudio.bgm.stop();
FlameAudio.bgm.pause();
FlameAudio.bgm.resume();

// Pre-load (evitar lag no 1º play)
await FlameAudio.audioCache.loadAll([
  'click.mp3', 'upgrade.mp3', 'fire.mp3', 'tribal_drums.mp3',
]);
```

### Formatos

- **Android:** OGG (preferido), MP3
- **iOS:** M4A (preferido), MP3, CAF
- **Assets em:** `assets/audio/` (registrar no `pubspec.yaml`)

---

## 14. Ecossistema de Pacotes

| Pacote | Import | Uso para Idle |
|--------|--------|-------------|
| `flame` | Core | ⭐ Engine base |
| `flame_audio` | Áudio | ⭐ BGM + SFX |
| `flame_tiled` | Tiled Editor | 🟡 Mapas complexos |
| `flame_forge2d` | Box2D physics | 🔴 Desnecessário |
| `flame_rive` | Rive animations | 🟡 UI animada premium |
| `flame_svg` | SVG render | 🔴 Opcional |
| `flame_riverpod` | Estado reativo | ⭐ Bridge Flame↔Flutter |
| `flame_bloc` | Bloc pattern | 🟡 Alternativa Riverpod |
| `flame_lottie` | Lottie animations | 🟡 Onboarding |
| `flame_noise` | Noise generation | 🔴 Terreno procedural |

---

## 15. Anti-Patterns (Validados pelo Source)

| ❌ Don't | ✅ Do | Evidência |
|----------|-------|-----------|
| `late final` no `onMount()` | Inicializar no `onLoad()` | `onMount` pode rodar múltiplas vezes (source) |
| Economia no `update(dt)` | `TimerComponent` com period fixo | `dt` varia com framerate |
| Ignorar `super` callbacks | Sempre chamar `super.onLoad()` etc | `@mustCallSuper` no source |
| Overlays rebuildam a cada frame | `ValueListenableBuilder` | Overlays são Flutter widgets |
| Esquecer hitbox com TapCallbacks | Sempre adicionar hitbox | Source verifica hit testing via hitbox |
| Não pausar em background | `lifecycleStateChange` + `pauseEngine()` | `_pausedBecauseBackgrounded` no source |
| Misturar effects com update logic | Effects system do Flame | `EffectController` com progress 0→1 |
| Criar sprites sem cache | `Sprite.load()` / `images.load()` | Cache automático em `src/cache/` |
| Usar game-level detectors | Usar `TapCallbacks` nos components | Detectors são legacy/deprecated |

---

> **Referências do Source:**
> - `packages/flame/lib/src/game/flame_game.dart` — FlameGame com World genérico
> - `packages/flame/lib/src/effects/effect.dart` — Effect base com controller pattern
> - `packages/flame/lib/src/components/` — Todos os componentes
> - `packages/flame/lib/src/particles/` — Sistema de partículas
> - `packages/flame/lib/src/camera/` — Camera + Viewport
> - `packages/flame/lib/src/collisions/` — Collision detection
> - **Docs:** https://docs.flame-engine.org/
> - **Exemplos:** https://examples.flame-engine.org/
