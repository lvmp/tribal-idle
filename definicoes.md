# Definições Técnicas — Tribal Idle

> Referência rápida para padrões arquiteturais e boas práticas do projeto.
> Engine: **Flame Engine** (https://flame-engine.org/)

---

# 1. Separação de Responsabilidades (Arquitetura)

Não tente colocar a lógica do seu jogo dentro dos componentes do Flame (`PositionComponent`, etc.). Mantenha o que chamamos de **Domain Layer** isolado.

| Camada | Responsabilidade |
|--------|------------------|
| **Game Engine (Flame)** | Desenhar na tela, processar inputs de toque, executar animações |
| **Game State (Domain)** | O "cérebro" do jogo — gerencia recursos, multiplicadores, progressão |
| **Persistence Layer** | Serializar o estado para JSON e salvar no dispositivo/nuvem |
| **UI Layer (Flutter)** | Menus, overlays, HUDs, shop — via Flutter widgets sobre o canvas |

### Regra de Ouro
> NUNCA instancie lógica de jogo pesada dentro de um Widget do Flutter ou Component do Flame. Ambos devem apenas **disparar métodos** do Domain ou **observar mudanças** de estado.

---

# 2. O Loop de Cálculo (Tick-Based vs. Time-Based)

Diferente de um jogo de ação, onde tudo acontece no `update(dt)`, no idle, a progressão muitas vezes precisa acontecer mesmo quando o app está fechado (**offline earnings**).

| Abordagem | Uso | Onde Fica |
|-----------|-----|-----------|
| **Frame-based** (`update(dt)`) | Animações, movimentos visuais | Flame Components |
| **Tick-based** (timer periódico) | Cálculos de recursos, progressão | Domain Layer |
| **Timestamp** (offline) | Ganhos offline ao retornar | Persistence Layer |

**Evite:** Calcular grandes progressões apenas dentro do `update` do Flame.

**Adote:** Uma lógica de "timestamp". Quando o jogador retorna, você calcula o tempo decorrido:

$$\Delta T = T_{atual} - T_{último\_save}$$

E então aplica os ganhos acumulados multiplicados por $\Delta T$.

---

# 3. Integração Flutter + Flame (Overlays)

O Flame possui um sistema de **overlays** que é perfeito para jogos idle. Ele permite que você construa menus, lojas e telas de status usando Widgets nativos do Flutter (que são muito melhores para interfaces complexas do que desenhar tudo na Canvas do Flame).

| Use Flame para... | Use Flutter Overlays para... |
|--------------------|-------------------------------|
| Mundo do jogo (canvas) | Menus e painéis complexos |
| Animações de NPCs e sprites | Tabelas de upgrade e inventário |
| Partículas e efeitos visuais | Loja e monetização |
| Background parallax | HUD com contadores de recursos |
| Interações de toque no mundo | Botões e formulários |

### Como Registrar Overlays

```dart
GameWidget(
  game: myGame,
  overlayBuilderMap: {
    'hud': (context, game) => HudOverlay(game: game),
    'shop': (context, game) => ShopOverlay(game: game),
    'pause': (context, game) => PauseMenu(game: game),
  },
  initialActiveOverlays: const ['hud'],
)
```

### Mostrar/Esconder Overlays

```dart
overlays.add('shop');    // Abre a loja
overlays.remove('shop'); // Fecha a loja
```

---

# 4. Estrutura de Pastas

Para manter a escalabilidade, recomendamos uma estrutura modular:

```
lib/
├── core/
│   ├── game.dart          // Classe principal que estende FlameGame
│   └── game_state.dart    // Singleton ou DI para o estado do jogo
├── components/            // Componentes visuais do Flame
│   ├── fire_component.dart
│   ├── npc_component.dart
│   └── zone_component.dart
├── overlays/              // Widgets do Flutter (menus, hud)
│   ├── hud_overlay.dart
│   ├── upgrade_menu.dart
│   └── shop_overlay.dart
├── models/                // Entidades de domínio
│   ├── resource_model.dart
│   └── upgrade_model.dart
├── services/              // Persistência, Som, IAP
│   ├── save_service.dart
│   ├── ad_service.dart
│   └── audio_service.dart
└── main.dart
```

---

# 5. Persistência de Dados (Save/Load)

Em um jogo idle, o save é **sagrado**. Utilize a serialização de dados de forma rigorosa.

### Princípios

- Crie uma classe `GameData` que contenha todos os seus estados
- Implemente métodos `toJson()` e `fromJson()`
- **Autosave** periódico (a cada 30s) + ao ir para background
- **Cloud sync** via Firebase/Play Games Services para backup
- **Validação** de dados ao carregar (proteger contra corrupção)

### Lifecycle do App

```dart
@override
void lifecycleStateChange(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.paused:
      saveGame();      // Salvar ao sair
      pauseEngine();   // Pausar game loop
      break;
    case AppLifecycleState.resumed:
      calculateOfflineEarnings();  // Ganhos offline
      resumeEngine();              // Retomar game loop
      break;
  }
}
```

---

# 6. Flame Components — Ciclo de Vida

### Principais Métodos

| Método | Quando |
|--------|--------|
| `onLoad()` | Inicialização async (carregar sprites) |
| `update(dt)` | A cada frame (lógica visual) |
| `render(canvas)` | A cada frame (desenho) |
| `onMount()` | Quando adicionado à árvore |
| `onRemove()` | Quando removido (cleanup) |

### Componentes Essenciais

| Componente | Uso |
|------------|-----|
| `SpriteComponent` | Imagem estática |
| `SpriteAnimationComponent` | Animação por frames |
| `ParallaxComponent` | Background scrolling |
| `TextComponent` | Texto renderizado no canvas |
| `ParticleSystemComponent` | Efeitos de partículas |
| `TimerComponent` | Timers in-game |

---

# 7. Performance Mobile

### Targets

| Métrica | Target |
|---------|--------|
| **FPS** | 30 FPS (suficiente para idle) |
| **Frame budget** | 33ms por frame |
| **Memory** | < 200MB RAM |
| **Battery** | Mínimo impacto (sleep when paused) |

### Otimizações

| Técnica | Impacto |
|---------|---------|
| `SpriteBatch` | Reduz draw calls |
| Object pooling | Evita GC pressure |
| Limitar FPS a 30 | Economiza bateria |
| Desabilitar `update` em componentes estáticos | Menos processamento |
| Touch target mínimo 44x44 | Usabilidade mobile |

---

# 8. Audio

### FlameAudio

```dart
FlameAudio.play('click.mp3');           // Efeito sonoro
FlameAudio.bgm.play('tribal_theme.mp3'); // Música de fundo
FlameAudio.bgm.stop();                  // Parar música
```

### Boas Práticas

- Formatos leves (OGG/MP3)
- Sons curtos para feedback (< 1s)
- Pausar áudio ao ir para background
- Volume adaptativo (respeitar config do sistema)

---

> **Referência oficial do Flame Engine:** https://flame-engine.org/