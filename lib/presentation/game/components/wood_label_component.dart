import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tribal_idle/shared/state/providers.dart';

/// Componente Flame que exibe o valor atual de madeira diretamente no canvas.
///
/// Lê o [GameState.wood] via [ProviderContainer] (passado pelo [TribalIdleGame])
/// a cada frame em [update], mantendo o texto sempre em sincronia com o estado.
///
/// Posicionado no canto superior esquerdo da câmera (HUD de canvas).
class WoodLabelComponent extends TextComponent {
  final ProviderContainer _container;

  WoodLabelComponent({required ProviderContainer container})
      : _container = container,
        super(
          text: '🪵 Madeira: 0',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black87,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          // Espaço confortável a partir do canto superior esquerdo
          position: Vector2(12, 12),
          // Prioridade alta: renderiza acima de outros componentes do world
          priority: 10,
        );

  @override
  void update(double dt) {
    super.update(dt);

    // Lê o estado atual sem usar ref.watch (fora da árvore Flutter).
    // _container.read() é síncrono e seguro dentro do game loop.
    final wood = _container.read(gameStateProvider).wood;
    final display = wood >= 1000
        ? '🪵 Madeira: ${(wood / 1000).toStringAsFixed(1)}k'
        : '🪵 Madeira: ${wood.toStringAsFixed(1)}';

    // Só atualiza o texto se mudou (evita re-layout desnecessário a cada frame)
    if (text != display) {
      text = display;
    }
  }
}
