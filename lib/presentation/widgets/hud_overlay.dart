import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tribal_idle/presentation/game/tribal_idle_game.dart';
import 'package:tribal_idle/shared/state/providers.dart';

/// HUD principal do jogo — sempre visível (initialActiveOverlays: ['hud']).
///
/// Exibe recursos básicos: madeira e comida.
/// Futuramente: FireBar, botões de upgrade, status de NPCs.
class HudOverlay extends ConsumerWidget {
  final TribalIdleGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ResourceChip(icon: '🪵', label: 'Madeira', value: state.wood),
            _ResourceChip(icon: '🍖', label: 'Comida', value: state.food),
            _ResourceChip(
              icon: '🔥',
              label: 'Fogo',
              value: state.fireFuelPercent * 100,
              suffix: '%',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widget ────────────────────────────────────────────────────────────────

class _ResourceChip extends StatelessWidget {
  final String icon;
  final String label;
  final double value;
  final String? suffix;

  const _ResourceChip({
    required this.icon,
    required this.label,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final raw = value >= 1000
        ? '${(value / 1000).toStringAsFixed(1)}k'
        : value.toStringAsFixed(1);
    final displayValue = suffix != null ? '$raw$suffix' : raw;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          Text(
            displayValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
