# 🎮 Design Doc: Idle Mobile Game Development com Flame Engine

> **Documento compilado para agentes de IA** — Todas as diretrizes, padrões e referências para criar jogos idle mobile usando Flame Engine + Flutter.
>
> **Projeto de Referência:** Tribal Idle: Dawn of Fire
> **Engine:** Flame Engine (https://docs.flame-engine.org/)
> **Plataforma:** Mobile-first (Android + iOS)

---

## PARTE 1: FUNDAMENTOS

---

### 1.1 Filosofia de Desenvolvimento

```
Games are about experience, not technology.
Choose tools that serve the game, not the trend.
```

| Princípio | Aplicação |
|-----------|-----------|
| **Gameplay first** | Tecnologia serve a experiência |
| **Performance is a feature** | 30 FPS é o baseline para idle |
| **Iterate fast** | Prototipar antes de polir |
| **Profile before optimize** | Medir, não adivinhar |
| **Platform-aware** | Mobile tem constraints únicos |
| **Decoupling é lei** | Domain, Engine e UI separados |

---

### 1.2 Por Que Flame Engine?

| Fator | Flame | Unity | Godot |
|-------|-------|-------|-------|
| **Ideal para** | Idle/casual mobile 2D | Cross-platform | Indies, 2D |
| **Linguagem** | Dart (mesmo do Flutter) | C# | GDScript/C# |
| **UI complexa** | Flutter nativo (overlays!) | UGUI/UIToolkit | Godot UI |
| **Mobile perf** | Excelente (nativo) | Boa | Boa |
| **Isometric** | IsometricTileMapComponent | Plugin | TileMap |
| **Custo** | Free, open source | Revenue share | Free |
| **Ecosystem** | pub.dev (Dart/Flutter) | Asset Store | Asset Library |

**Flame é ideal quando:** jogo 2D, mobile-first, UI complexa (menus, inventário, HUD), equipe que já conhece Flutter/Dart.

---

### 1.3 Stack Tecnológico Recomendado

| Camada | Tecnologia | Pacote |
|--------|-----------|--------|
| **Engine** | Flame | `flame` |
| **Audio** | FlameAudio | `flame_audio` |
| **State** | Riverpod | `flutter_riverpod` + `flame_riverpod` |
| **Persistence** | Hive + JSON | `hive` + `hive_flutter` |
| **Ads** | Google AdMob | `google_mobile_ads` |
| **Analytics** | Firebase | `firebase_analytics` |
| **Cloud Sync** | Firestore | `cloud_firestore` |
| **Auth** | Firebase Auth | `firebase_auth` |

---

## PARTE 2: ARQUITETURA

---

### 2.1 Separação de Camadas

```
┌─────────────────────────────────────────────┐
│  PRESENTATION LAYER                         │
│  ┌──────────────┐  ┌─────────────────────┐  │
│  │ Flame Canvas  │  │  Flutter Overlays   │  │
│  │ (Components)  │  │  (Widgets)          │  │
│  │ - NPCs        │  │  - HUD              │  │
│  │ - Zonas       │  │  - Menus            │  │
│  │ - Efeitos     │  │  - Shop             │  │
│  │ - Background  │  │  - Notificações     │  │
│  └──────┬───────┘  └──────────┬──────────┘  │
│         │    OBSERVAM / DISPARAM    │        │
│  ┌──────┴───────────────────────────┴──────┐ │
│  │         DOMAIN LAYER (State)            │ │
│  │  GameState, ResourceManager,            │ │
│  │  EconomyEngine, PrestigeSystem          │ │
│  └───────────────────┬─────────────────────┘ │
│                      │ PERSISTE               │
│  ┌───────────────────┴─────────────────────┐ │
│  │       INFRASTRUCTURE LAYER              │ │
│  │  SaveService, AdService, AudioService   │ │
│  └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### 2.2 Estrutura de Pastas

```
lib/
├── core/
│   ├── game.dart              // FlameGame principal
│   ├── game_state.dart        // Estado central (ChangeNotifier)
│   └── constants.dart         // Constantes de balanceamento
├── domain/
│   ├── economy/
│   │   ├── resource_manager.dart
│   │   ├── production_calculator.dart
│   │   └── prestige_system.dart
│   ├── models/
│   │   ├── resource_model.dart
│   │   ├── zone_model.dart
│   │   └── manager_model.dart
│   └── events/
│       └── game_events.dart
├── components/                // Flame FCS
│   ├── world/
│   │   ├── tribal_world.dart
│   │   ├── zone_component.dart
│   │   ├── fire_component.dart
│   │   └── npc_component.dart
│   ├── effects/
│   │   ├── floating_text.dart
│   │   ├── screen_flash.dart
│   │   └── pulse_effect.dart
│   └── background/
│       └── parallax_bg.dart
├── overlays/                  // Flutter widgets
│   ├── hud/
│   │   ├── hud_overlay.dart
│   │   ├── resource_counter.dart
│   │   └── fire_bar.dart
│   ├── menus/
│   │   ├── upgrade_menu.dart
│   │   ├── manager_menu.dart
│   │   └── settings_menu.dart
│   ├── shop/
│   │   └── shop_overlay.dart
│   └── dialogs/
│       ├── offline_dialog.dart
│       └── prestige_dialog.dart
├── services/
│   ├── save_service.dart
│   ├── ad_service.dart
│   └── audio_service.dart
└── main.dart
```

### 2.3 Regras Arquiteturais

| Regra | Justificativa |
|-------|--------------|
| Domain Layer **NUNCA** importa Flame | Testabilidade e portabilidade |
| Components **NUNCA** calculam economia | Separação de responsabilidades |
| Overlays **NUNCA** instanciam lógica pesada | Apenas observam e disparam |
| `update(dt)` só para **animações visuais** | Economia via tick/timer |
| Todo estado em `GameState` | Single source of truth |

---

## PARTE 3: FLAME ENGINE — REFERÊNCIA RÁPIDA

---

### 3.1 Component Lifecycle

```
onLoad()        → Inicialização async (1x na vida)
onGameResize()  → Quando tela redimensiona
onMount()       → Quando adicionado à árvore (pode repetir)
update(dt)      → A cada frame (lógica visual)
render(canvas)  → A cada frame (desenho)
onRemove()      → Cleanup ao remover
```

### 3.2 Componentes para Idle Games

| Componente | Uso no Idle |
|------------|-------------|
| `SpriteComponent` | Buildings, items estáticos |
| `SpriteAnimationComponent` | NPCs idle/walk, fogueira |
| `SpriteAnimationGroupComponent` | NPCs com múltiplos estados |
| `ParallaxComponent` | Background céu/montanhas |
| `IsometricTileMapComponent` | Layout isométrico de zonas |
| `TextComponent` | Labels no mundo |
| `ParticleSystemComponent` | Faíscas, poeira, brilho |
| `SpawnComponent` | Mammute de ouro (periódico) |
| `NineTileBoxComponent` | Painéis escaláveis |
| `TimerComponent` | Ticks periódicos |

### 3.3 Effects System (Juice)

```dart
// Squash & Stretch (botão de upgrade)
button.add(SequenceEffect([
  ScaleEffect.to(Vector2(1.2, 0.8), EffectController(duration: 0.05)),
  ScaleEffect.to(Vector2(1.0, 1.0), EffectController(duration: 0.15)),
]));

// Floating text (+50)
text.add(MoveEffect.by(Vector2(0, -40), EffectController(duration: 1.0)));
text.add(OpacityEffect.fadeOut(EffectController(duration: 1.0)));

// Screen flash (restaurar fogo)
flash.add(OpacityEffect.fadeOut(EffectController(duration: 0.4)));

// Pulsating (fogo crítico)
bar.add(ScaleEffect.by(Vector2.all(0.05),
  EffectController(duration: 0.5, reverseDuration: 0.5, infinite: true)));

// Gold sparkle
component.add(ColorEffect(Color(0xFFFFD700),
  EffectController(duration: 0.3, reverseDuration: 0.3)));
```

### 3.4 Overlays (Flutter Bridge)

```dart
// Registro
GameWidget(
  game: game,
  overlayBuilderMap: {
    'hud': (ctx, g) => Hud(game: g),
    'shop': (ctx, g) => Shop(game: g),
  },
  initialActiveOverlays: ['hud'],
)

// Controle
game.overlays.add('shop');
game.overlays.remove('shop');
```

### 3.5 Input Mobile

```dart
// Mixin TapCallbacks para toque
class Zone extends SpriteComponent with TapCallbacks {
  @override void onTapUp(TapUpEvent e) { /* ação */ }
}

// Hitbox para área de toque ≥ 44x44
add(RectangleHitbox(size: Vector2(48, 48)));
```

---

## PARTE 4: ECONOMIA IDLE

---

### 4.1 Fórmulas Core

#### Custo de Upgrade (Exponencial)

$$Cost_n = BaseCost \times Multiplier^{level}$$

- **Multiplier:** 1.07-1.25 (mais alto = mais lento)
- **Breakpoints:** A cada 25 níveis (desbloqueio especial)

#### Produção por Segundo

$$G/s = \sum_{i=1}^{n} (BaseProduction_i \times Level_i \times Multiplier_i)$$

#### Produção Líquida (Sobrevivência)

$$ProduçãoLíquida = \sum(Ganhos) - \sum(CustoManutenção)$$

- Se `wood = 0`: efficiency = 0.1 (90% penalidade)

#### Prestige

$$Prestige_{moeda} = \lfloor \sqrt{\frac{TotalEarnings}{Threshold}} \rfloor$$

$$GlobalMultiplier = 1 + (PrestigeMoeda \times 0.02)$$

### 4.2 Offline Earnings

```dart
Duration elapsed = now.difference(lastSaveTime);
int cappedSeconds = min(elapsed.inSeconds, 8 * 3600); // Cap 8h
double earnings = earningsPerSecond * cappedSeconds * 0.5; // 50% eficiência

// Opção: triplicar com rewarded ad
```

### 4.3 Formatação de Números

```dart
String format(double v) {
  if (v >= 1e15) return '${(v/1e15).toStringAsFixed(2)}Q';
  if (v >= 1e12) return '${(v/1e12).toStringAsFixed(2)}T';
  if (v >= 1e9)  return '${(v/1e9).toStringAsFixed(2)}B';
  if (v >= 1e6)  return '${(v/1e6).toStringAsFixed(2)}M';
  if (v >= 1e3)  return '${(v/1e3).toStringAsFixed(2)}K';
  return v.toStringAsFixed(0);
}
```

---

## PARTE 5: UI/UX MOBILE

---

### 5.1 Layout HUD

```
┌─────────────────────────────────┐
│  🪵 1.2K   🍖 850   ⛏️ 2.1K    │ ← Recursos (topo)
│  ████████████░░░░  🔥 67%       │ ← Barra de Fogo
├─────────────────────────────────┤
│                                 │
│     [FLAME CANVAS - Isométrico] │ ← Zonas + NPCs + Fogueira
│                                 │
├─────────────────────────────────┤
│  [⬆ Upgrade] [👤 Gerentes] [⚙] │ ← Nav Bar (bottom)
└─────────────────────────────────┘
```

### 5.2 Feedback Visual ("Juice")

| Evento | Feedback |
|--------|----------|
| Tap em upgrade | Botão squash & stretch |
| Recurso coletado | Floating number (+50 🪵) |
| Nível up | Flash dourado + partículas |
| Fogo < 20% | Barra pulsa vermelha + screen tint |
| Fogo restaurado | Screen flash + som tribal |
| Prestige | Trovão + transição épica |

### 5.3 Touch Targets

- **Mínimo 44x44 points** em todos os botões
- Visual feedback imediato no tap (scale 0.95)
- Haptic feedback em ações importantes
- Safe area respeitada (notch/camera)

---

## PARTE 6: PERSISTÊNCIA

---

### 6.1 Estratégia de Save

| Evento | Ação |
|--------|------|
| A cada 30s | Autosave silencioso |
| App → background | Save imediato |
| Após compra IAP | Save imediato |
| Após prestige | Save imediato |
| App → foreground | Calcular offline earnings |

### 6.2 Estrutura de Save

```dart
class GameData {
  Map<String, double> resources;
  Map<String, int> zoneLevels;
  List<String> unlockedManagers;
  int prestigeCount;
  double prestigeCurrency;
  DateTime lastSaveTime;
  int version; // Para migrações

  Map<String, dynamic> toJson() => { /* ... */ };
  factory GameData.fromJson(Map<String, dynamic> json) => /* ... */;
}
```

### 6.3 Versionamento e Migração

```dart
if (version < 2) json = _migrateV1toV2(json);
if (version < 3) json = _migrateV2toV3(json);
```

---

## PARTE 7: MONETIZAÇÃO

---

### 7.1 Modelo: Hybrid (Rewarded Ads + IAP)

| Rewarded Ad | Recompensa | Trigger |
|-------------|------------|---------|
| Mammute de Ouro | Fortuna instantânea | Aparece periodicamente |
| Bênção do Relâmpago | 100% fogo + 2x speed | Botão HUD |
| Multiplicador Offline | 3x ganhos offline | Ao retornar |
| Resgate de Crise | Restaurar fogo | Fogo apaga |

| IAP | Conteúdo | Preço |
|-----|----------|-------|
| Fogo Eterno | Remove ads + lenha infinita | $4.99 |
| Starter Pack | Recursos + gerente raro | $2.99 |
| VIP Tribal | 2x speed permanente | $4.99/mês |

### 7.2 Regra de Ouro

> O jogador deve **querer** ver o ad. Se ele **precisa** ver, você perdeu ele.
> Ads **aceleram**, nunca **desbloqueiam** conteúdo.

---

## PARTE 8: ART & AUDIO

---

### 8.1 Art Direction para Idle Mobile

| Atributo | Decisão |
|----------|---------|
| Estilo | Vector/Flat com texturas tribais |
| Paleta | Tons quentes (terra, laranja, ocre) |
| Personagens | 64-128px, silhuetas distintas |
| Background | Parallax (céu → montanhas → floresta) |
| Animações | 8-12 FPS para NPCs |

### 8.2 Asset Pipeline

```
Concept (Procreate) → Sprites (Aseprite) → Spritesheet → Flame
```

### 8.3 Naming Convention

```
spr_npc_walk_01.png
spr_building_quarry_lv3.png
bg_parallax_sky.png
sfx_upgrade_tribal.mp3
bgm_tribal_drums.mp3
```

### 8.4 Audio

| Tipo | Exemplo | FlameAudio |
|------|---------|------------|
| BGM | Tambores tribais | `bgm.play('tribal.mp3')` |
| SFX | Click, upgrade | `play('click.mp3')` |
| Ambient | Fogo crepitando | `play('fire.mp3')` em loop |

---

## PARTE 9: PERFORMANCE MOBILE

---

### 9.1 Targets

| Métrica | Target |
|---------|--------|
| FPS | 30 (suficiente para idle) |
| Frame budget | 33ms |
| Memory | < 200MB RAM |
| Battery | Mínimo impacto |
| App size | < 100MB |

### 9.2 Otimizações

| Técnica | Quando |
|---------|--------|
| 30 FPS | Sempre (idle não precisa de 60) |
| SpriteBatch | Muitos sprites similares |
| Object pooling | Spawn/destroy frequente |
| `isVisible = false` | Componentes fora de tela |
| Pausar engine em background | Sempre |
| Image cache | Padrão do Flame |
| Thermal throttling | Quando device esquenta |

---

## PARTE 10: ANTI-PATTERNS (COMPILADO)

| ❌ Don't | ✅ Do |
|----------|-------|
| Economia no `update(dt)` | Timer ticks isolados |
| Lógica de negócio em Components | Domain layer separado |
| UI complexa no Canvas | Flutter overlays |
| `late final` no `onMount()` | Inicializar no `onLoad()` |
| Save apenas ao fechar | Autosave periódico |
| Ads que bloqueiam progresso | Rewarded ads opt-in |
| Botões < 44x44 pts | Touch targets generosos |
| Ignorar lifecycle | Salvar e pausar em background |
| Linear scaling de custos | Exponential scaling |
| Desktop controls | Design for touch |
| Mix art styles | Style guide consistente |
| Esquecer `super` callbacks | Sempre chamar super |
| Sem formatação de números | K, M, B, T, Q |
| Offline earnings ilimitados | Cap 8h + 50% eficiência |

---

## REFERÊNCIAS

| Recurso | Link |
|---------|------|
| **Flame Docs** | https://docs.flame-engine.org/ |
| **Flame GitHub** | https://github.com/flame-engine/flame |
| **Flame Examples** | https://examples.flame-engine.org/ |
| **GDD do Projeto** | `GGD.md` |
| **Definições Técnicas** | `definicoes.md` |
| **Arquitetura** | `docs/architecture.md` |
| **ADRs** | `docs/adrs/` |
| **Skills do Agente** | `.agent/skills/` |

---

> **Para o agente de IA:** Este documento é sua referência central. Antes de implementar qualquer feature, consulte a seção relevante. Se algo contradiz uma ADR, pare e avise o usuário.
