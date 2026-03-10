import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tribal_idle/shared/state/providers.dart';

/// Nível visual da fogueira — derivado do percentual de combustível.
enum FireLevel { veryLow, low, medium, high }

/// Converte [fuelPercent] ∈ [0.0, 1.0] → [FireLevel].
///
/// Limites conforme a diretriz técnica do GDD:
///   0 – 20%  → very low
///  21 – 45%  → low
///  46 – 70%  → medium
///  71 – 100% → high
FireLevel fireLevelFromPercent(double pct) {
  if (pct <= 0.20) return FireLevel.veryLow;
  if (pct <= 0.45) return FireLevel.low;
  if (pct <= 0.70) return FireLevel.medium;
  return FireLevel.high;
}

/// Componente Flame que exibe a fogueira no mundo com 4 sprites estáticos.
///
/// Responsabilidades (SOMENTE):
///   - Ler [FireState] via [ProviderContainer] a cada frame
///   - Alternar o sprite ativo conforme o [FireLevel]
///   - Adicionar / remover efeito de pulsação em estado de crise
///
/// Lógica de negócio → [FireLogic] + [GameStateNotifier]. NUNCA aqui.
class FireComponent extends SpriteAnimationGroupComponent<FireLevel> {
  final ProviderContainer _container;

  // ─── State tracking ───────────────────────────────────────────────────────
  FireLevel? _lastLevel;
  bool _wasCrisis = false;
  bool _pulseActive = false;

  // ─── Layout ───────────────────────────────────────────────────────────────
  static const double _fireWidth = 128.0;
  static const double _fireHeight = 128.0;

  FireComponent({required ProviderContainer container})
      : _container = container,
        super(
          priority: 5,
          anchor: Anchor.bottomCenter,
          size: Vector2(_fireWidth, _fireHeight),
        );

  @override
  Future<void> onLoad() async {
    animations = {
      FireLevel.veryLow: await _staticAnim('fogueira/fire_very_low.png'),
      FireLevel.low: await _staticAnim('fogueira/fire_low.png'),
      FireLevel.medium: await _staticAnim('fogueira/fire_medium.png'),
      FireLevel.high: await _staticAnim('fogueira/fire_high.png'),
    };
    current = FireLevel.medium; // Estado inicial (60% de fuel)
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Centro horizontal, ~67% vertical — centro da área de terra batida da clareira
    position = Vector2(size.x / 2, size.y * 0.67);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final fire = _container.read(fireStateProvider);
    final newLevel = fireLevelFromPercent(fire.fuelPercent);

    // Só troca o sprite quando o nível muda — evita rebuild a cada frame
    if (newLevel != _lastLevel) {
      current = newLevel;
      _lastLevel = newLevel;
    }

    // Gerencia efeito de pulsação na crise
    final nowCrisis = fire.isCrisis;
    if (nowCrisis && !_wasCrisis) {
      _startPulse();
    } else if (!nowCrisis && _wasCrisis) {
      _stopPulse();
    }
    _wasCrisis = nowCrisis;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<SpriteAnimation> _staticAnim(String path) async {
    final sprite = await Sprite.load(path);
    return SpriteAnimation.spriteList([sprite], stepTime: 1.0, loop: true);
  }

  void _startPulse() {
    if (_pulseActive) return;
    _pulseActive = true;
    add(
      ScaleEffect.by(
        Vector2.all(1.08),
        EffectController(duration: 0.5, reverseDuration: 0.5, infinite: true),
      ),
    );
  }

  void _stopPulse() {
    if (!_pulseActive) return;
    _pulseActive = false;
    removeWhere((c) => c is ScaleEffect);
    scale = Vector2.all(1.0);
  }
}
