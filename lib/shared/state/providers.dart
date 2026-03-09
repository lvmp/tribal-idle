import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tribal_idle/domain/models/game_state.dart';
import 'package:tribal_idle/infrastructure/persistence/hive_save_service.dart';

// ── Save Service ──────────────────────────────────────────────────────────────

/// Provider do serviço de persistência (singleton).
final saveServiceProvider = Provider<HiveSaveService>((ref) {
  return HiveSaveService();
});

// ── Game State ────────────────────────────────────────────────────────────────

/// [Notifier] que gerencia o [GameState] — Single Source of Truth.
///
/// Riverpod 3.x usa [Notifier] em vez de [StateNotifier].
/// Tanto os Widgets Flutter quanto os Componentes do Flame devem ler e
/// escrever o estado exclusivamente através deste notifier.
class GameStateNotifier extends Notifier<GameState> {
  @override
  GameState build() => GameState();

  HiveSaveService get _saveService => ref.read(saveServiceProvider);

  /// Inicializa o estado a partir do save (ou cria novo).
  Future<void> initialize() async {
    state = await _saveService.loadOrCreate();
  }

  /// Processa um tick da economia (chamado pelo TimerComponent a cada 1s).
  void tick() {
    state.processTick();
    // Emite uma nova referência para acionar rebuilds reativos.
    state = state.copyWith();
  }

  /// Persiste o estado atual no Hive.
  Future<void> save() async {
    await _saveService.save(state);
  }

  /// Adiciona recursos manualmente (ex: tap, recompensa de Ad).
  void addWood(double amount) {
    state = state.copyWith(wood: state.wood + amount);
  }

  void addFood(double amount) {
    state = state.copyWith(food: state.food + amount);
  }

  /// Reseta o jogo (ex: prestige).
  Future<void> reset() async {
    await _saveService.clear();
    state = GameState();
  }
}

/// Provider do [GameStateNotifier] — use este provider em toda a aplicação.
///
/// Acesse o valor: `ref.watch(gameStateProvider)` → [GameState]
/// Acesse o notifier: `ref.read(gameStateProvider.notifier).tick()`
final gameStateProvider = NotifierProvider<GameStateNotifier, GameState>(
  GameStateNotifier.new,
);
