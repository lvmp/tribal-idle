import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tribal_idle/domain/logic/fire_logic.dart';
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
    final loaded = await _saveService.loadOrCreate();
    // Guarda de migração: saves antigos (sem fireMaxFuel) podem ter fuel = 0.
    // Nesses casos iniciamos um novo jogo para garantir uma demo limpa.
    if (loaded.fireFuelSeconds <= 0 && loaded.wood > 0) {
      // Save legado detectado — reinicia preservando madeira acumulada
      state = GameState(wood: loaded.wood, food: loaded.food);
    } else {
      state = loaded;
    }
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

  /// Adiciona combustível ao fogo consumindo madeira.
  ///
  /// Retorna `false` se não houver madeira suficiente.
  bool addFuel(double fuelAmount) {
    final cost = FireLogic.woodCostForFuel(fuelAmount);
    if (state.wood < cost) return false;

    state = state.copyWith(
      wood: state.wood - cost,
      fireFuelSeconds: (state.fireFuelSeconds + fuelAmount)
          .clamp(0.0, state.fireMaxFuel),
    );
    return true;
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

// ── Fire State (Derivado) ─────────────────────────────────────────────────────

/// Snapshot imutável do estado do fogo para consumo rápido pela UI/Flame.
///
/// Derivado do [GameState] — nunca armazene lógica aqui.
class FireState {
  /// Combustível restante em segundos.
  final double fuelSeconds;

  /// Capacidade máxima em segundos.
  final double maxFuelSeconds;

  /// Percentagem [0.0 – 1.0].
  final double fuelPercent;

  /// `true` se o fogo está completamente apagado → penalidade de produção ativa.
  final bool isExtinguished;

  /// `true` se o fogo está abaixo de 20% → estado de crise (pulsar).
  final bool isCrisis;

  const FireState({
    required this.fuelSeconds,
    required this.maxFuelSeconds,
    required this.fuelPercent,
    required this.isExtinguished,
    required this.isCrisis,
  });

  factory FireState.fromGameState(GameState gs) => FireState(
        fuelSeconds: gs.fireFuelSeconds,
        maxFuelSeconds: gs.fireMaxFuel,
        fuelPercent: gs.fireFuelPercent,
        isExtinguished: gs.fireIsExtinguished,
        isCrisis: gs.fireIsCrisis,
      );

  static const FireState initial = FireState(
    fuelSeconds: 60,
    maxFuelSeconds: FireLogic.kDefaultMaxFuel,
    fuelPercent: 60 / FireLogic.kDefaultMaxFuel,
    isExtinguished: false,
    isCrisis: false,
  );
}

/// Provider derivado — re-emite sempre que [gameStateProvider] muda.
///
/// Consume exclusivamente valores derivados de [GameState]; não mantém
/// nenhum estado próprio de fogo — garantindo Single Source of Truth.
final fireStateProvider = Provider<FireState>((ref) {
  final gs = ref.watch(gameStateProvider);
  return FireState.fromGameState(gs);
});
