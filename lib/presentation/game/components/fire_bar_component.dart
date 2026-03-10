import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' show Color, LinearGradient;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tribal_idle/presentation/game/components/fire_component.dart';
import 'package:tribal_idle/shared/state/providers.dart';

/// Barra de fogo do Flame — exibe o nível de combustível diretamente no canvas.
///
/// Responsabilidades (SOMENTE):
///   - Ler o [FireState] via [ProviderContainer] a cada frame
///   - Desenhar a barra com gradiente de cor (vermelho → âmbar → verde)
///   - Exibir sprite mini da fogueira à esquerda (sem texto numérico bruto)
///   - Ativar/desativar efeito de pulsação quando em estado de crise (< 20%)
///
/// Lógica de negócio → [FireLogic] + [GameStateNotifier]. NUNCA aqui.
class FireBarComponent extends PositionComponent {
  final ProviderContainer _container;

  // ─── Layout ──────────────────────────────────────────────────────────────
  static const double _barHeight = 14.0;
  static const double _borderRadius = 7.0;
  static const double _paddingH = 24.0;
  static const double _bottomOffset = 20.0;

  /// Largura reservada para o ícone sprite à esquerda da barra.
  static const double _iconSize = 20.0;
  static const double _iconGap = 6.0;

  // ─── Estado interno de renderização ──────────────────────────────────────
  double _pct = 1.0;
  FireLevel _currentLevel = FireLevel.high;
  bool _wasCrisis = false;
  bool _pulseActive = false;

  /// Sprites das 4 versões da fogueira — carregados em onLoad().
  final Map<FireLevel, Sprite> _fireSprites = {};

  FireBarComponent({required ProviderContainer container})
      : _container = container,
        super(priority: 20);

  @override
  Future<void> onLoad() async {
    _fireSprites[FireLevel.veryLow] =
        await Sprite.load('fogueira/fire_very_low.png');
    _fireSprites[FireLevel.low] = await Sprite.load('fogueira/fire_low.png');
    _fireSprites[FireLevel.medium] =
        await Sprite.load('fogueira/fire_medium.png');
    _fireSprites[FireLevel.high] = await Sprite.load('fogueira/fire_high.png');
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final totalWidth = size.x - _paddingH * 2;
    this.size = Vector2(totalWidth, _barHeight);
    position = Vector2(_paddingH, size.y - _barHeight - _bottomOffset);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final fire = _container.read(fireStateProvider);
    _pct = fire.fuelPercent;
    _currentLevel = fireLevelFromPercent(_pct);

    final nowCrisis = fire.isCrisis;
    if (nowCrisis && !_wasCrisis) {
      _startPulse();
    } else if (!nowCrisis && _wasCrisis) {
      _stopPulse();
    }
    _wasCrisis = nowCrisis;
  }

  void _startPulse() {
    if (_pulseActive) return;
    _pulseActive = true;
    add(
      ScaleEffect.by(
        Vector2.all(1.06),
        EffectController(
          duration: 0.45,
          reverseDuration: 0.45,
          infinite: true,
        ),
      ),
    );
  }

  void _stopPulse() {
    if (!_pulseActive) return;
    _pulseActive = false;
    removeWhere((c) => c is ScaleEffect);
    scale = Vector2.all(1.0);
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // ── Ícone sprite (lado esquerdo da barra) ─────────────────────────────
    final sprite = _fireSprites[_currentLevel];
    if (sprite != null) {
      sprite.render(
        canvas,
        position: Vector2(0, (h - _iconSize) / 2),
        size: Vector2.all(_iconSize),
      );
    }

    // ── Barra de combustível (deslocada para direita do ícone) ────────────
    final barX = _iconSize + _iconGap;
    final barW = w - barX;
    final fillW = (barW * _pct).clamp(0.0, barW);

    canvas.save();
    canvas.translate(barX, 0);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, barW, h),
      const Radius.circular(_borderRadius),
    );
    final fillRrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillW, h),
      const Radius.circular(_borderRadius),
    );

    // Trilha (fundo visível)
    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0x55FF8F00),
    );

    // Preenchimento com gradiente
    if (fillW > 0) {
      final fillColor = _colorForPercent(_pct);
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            fillColor.withValues(alpha: 0.7),
            fillColor,
          ],
        ).createShader(Rect.fromLTWH(0, 0, fillW, h));
      canvas.drawRRect(fillRrect, gradientPaint);
    }

    // Borda
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xAAFF8F00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    canvas.restore();
  }

  /// Interpola a cor da barra: 0% → vermelho · 50% → âmbar · 100% → verde
  Color _colorForPercent(double pct) {
    if (pct < 0.5) {
      return Color.lerp(
        const Color(0xFFE53935),
        const Color(0xFFFF8F00),
        pct * 2,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFFF8F00),
        const Color(0xFF43A047),
        (pct - 0.5) * 2,
      )!;
    }
  }
}
