import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' show Color, LinearGradient, TextStyle, FontWeight, Shadow, Offset;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tribal_idle/shared/state/providers.dart';

/// Barra de fogo do Flame — exibe o nível de combustível diretamente no canvas.
///
/// Responsabilidades (SOMENTE):
///   - Ler o [FireState] via [ProviderContainer] a cada frame
///   - Desenhar a barra com gradiente de cor (verde → amarelo → laranja → vermelho)
///   - Ativar/desativar efeito de pulsação quando em estado de crise (< 20%)
///
/// Lógica de negócio → [FireLogic] + [GameStateNotifier]. NUNCA aqui.
class FireBarComponent extends PositionComponent {
  final ProviderContainer _container;

  // ─── Layout ──────────────────────────────────────────────────────────────
  static const double _barHeight = 14.0;
  static const double _borderRadius = 7.0;
  static const double _labelFontSize = 11.0;
  static const double _paddingH = 24.0;
  static const double _bottomOffset = 20.0;

  // ─── Estado interno de renderização ──────────────────────────────────────
  double _pct = 1.0;
  bool _wasCrisis = false;
  bool _pulseActive = false;
  late TextPaint _labelPaint;

  FireBarComponent({required ProviderContainer container})
      : _container = container,
        super(priority: 20);

  @override
  Future<void> onLoad() async {
    _labelPaint = TextPaint(
      style: TextStyle(
        color: const Color(0xFFFFFFFF),
        fontSize: _labelFontSize,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(
            color: Color(0xAA000000),
            offset: Offset(0.5, 0.5),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final barWidth = size.x - _paddingH * 2;
    this.size = Vector2(barWidth, _barHeight);
    position = Vector2(_paddingH, size.y - _barHeight - _bottomOffset);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final fire = _container.read(fireStateProvider);
    _pct = fire.fuelPercent;

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
    final fillW = (w * _pct).clamp(0.0, w);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(_borderRadius),
    );
    final fillRrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillW, h),
      const Radius.circular(_borderRadius),
    );

    // Trilha (fundo visível)
    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0x55FF8F00), // âmbar escuro translúcido
    );

    // Preenchimento com gradiente de cor
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
        ..color = const Color(0xAAFF8F00) // âmbar
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Label centrado
    final label = '🔥 ${(_pct * 100).toStringAsFixed(0)}%';
    _labelPaint.render(
      canvas,
      label,
      Vector2(w / 2, h / 2),
      anchor: Anchor.center,
    );
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
