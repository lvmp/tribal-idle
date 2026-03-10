import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tribal_idle/presentation/game/components/background_component.dart';
import 'package:tribal_idle/presentation/game/components/fire_bar_component.dart';
import 'package:tribal_idle/presentation/game/components/fire_component.dart';
import 'package:tribal_idle/presentation/game/components/wood_label_component.dart';
import 'package:tribal_idle/shared/state/providers.dart';

// ── World ─────────────────────────────────────────────────────────────────────

/// O "mundo" do jogo — contém todos os componentes visuais do Flame.
///
/// Adicione aqui: background, fogueira, NPCs, zonas de coleta.
/// NÃO adicione componentes de HUD aqui — eles vão para camera.viewport.
class TribalWorld extends World {
  final ProviderContainer container;

  TribalWorld({required this.container});

  // World is intentionally empty for now.
  // Visual components live in camera.viewport for correct Z-ordering.
  // Future: ZoneComponents, NpcComponents will be added here.
}

// ── Game ──────────────────────────────────────────────────────────────────────

/// Ponto de entrada do Flame Engine.
///
/// Responsabilidades:
/// - Iniciar o game loop
/// - Conectar o [GameStateNotifier] ao tick de economia (1s via [TimerComponent])
/// - Gerenciar autosave (30s via [TimerComponent])
/// - Tratar lifecycle (pause/resume → save)
///
/// NÃO coloque lógica de negócio aqui. Delegue para [GameStateNotifier].
class TribalIdleGame extends FlameGame<TribalWorld> {
  final ProviderContainer _container;

  TribalIdleGame({required ProviderContainer container})
    : _container = container,
      super(world: TribalWorld(container: container));

  GameStateNotifier get _notifier =>
      _container.read(gameStateProvider.notifier);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Carregar estado salvo (inclui ganhos offline)
    await _notifier.initialize();

    // ── Camadas visuais no viewport (screen-space — não se movem com a câmera) ─
    // priority -1 → background da clareira (camada base)
    // priority  5 → fogueira (sobre o background, abaixo do HUD)
    // priority 10 → WoodLabel
    // priority 20 → FireBar
    await camera.viewport.addAll([
      BackgroundComponent(),
      FireComponent(container: _container),
      WoodLabelComponent(container: _container),
      FireBarComponent(container: _container),
    ]);

    // Economy tick: a cada 1 segundo
    add(
      TimerComponent(period: 1.0, repeat: true, onTick: () => _notifier.tick()),
    );

    // Autosave: a cada 30 segundos
    add(
      TimerComponent(
        period: 30.0,
        repeat: true,
        onTick: () => _notifier.save(),
      ),
    );

    // HUD Flutter sempre visível
    overlays.add('hud');
  }

  /// Gerencia ciclo de vida do app (fundo ↔ frente).
  /// ADR 003: Salvar ao sair para garantir consistência do progresso.
  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _notifier.save();
        pauseEngine();
      case AppLifecycleState.resumed:
        resumeEngine();
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF1A1208); // Marrom escuro de noite
}
