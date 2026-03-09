import 'package:tribal_idle/domain/logic/fire_logic.dart';

/// Modelo central do estado do jogo.
///
/// Esta é a "Single Source of Truth" de todo o progresso do jogador.
/// Esta classe é 100% Dart puro — SEM dependências do Flutter ou do Flame.
/// Pode ser testada em isolamento.
class GameState {
  // ── Recursos ──────────────────────────────────────────────────────
  double wood;
  double food;

  // ── Fogueira ──────────────────────────────────────────────────────
  /// Combustível restante em segundos. Quando chega a 0, a fogueira apaga.
  double fireFuelSeconds;

  /// Capacidade máxima de combustível (em segundos).
  double fireMaxFuel;

  /// Taxa de consumo de combustível por segundo (upgradável no futuro).
  double fireConsumptionRate;

  // ── Meta ──────────────────────────────────────────────────────────
  /// Timestamp do último save (usado para calcular ganhos offline).
  DateTime lastSavedAt;

  GameState({
    this.wood = 0.0,
    this.food = 0.0,
    this.fireFuelSeconds = 180.0, // 60% de 300s — fogo aceso ao iniciar
    this.fireMaxFuel = FireLogic.kDefaultMaxFuel,
    this.fireConsumptionRate = FireLogic.kDefaultConsumptionRate,
    DateTime? lastSavedAt,
  }) : lastSavedAt = lastSavedAt ?? DateTime.now();

  // ── Computed Properties ────────────────────────────────────────────

  /// Percentagem de combustível restante [0.0 – 1.0].
  double get fireFuelPercent =>
      fireMaxFuel > 0 ? (fireFuelSeconds / fireMaxFuel).clamp(0.0, 1.0) : 0.0;

  /// `true` se o fogo está apagado → produção penalizada.
  bool get fireIsExtinguished => FireLogic.isExtinguished(fireFuelSeconds);

  /// `true` se o fogo está em modo de crise (< 20%).
  bool get fireIsCrisis => FireLogic.isCrisis(fireFuelSeconds, fireMaxFuel);

  // ── Economy Tick ──────────────────────────────────────────────────

  /// Chamado pelo [TimerComponent] a cada 1 segundo.
  ///
  /// [deltaSeconds]: normalmente 1.0, mas pode ser maior para cálculo offline.
  void processTick({double deltaSeconds = 1.0}) {
    // 1. Consumir combustível
    fireFuelSeconds = FireLogic.computeNewFuel(
      currentFuel: fireFuelSeconds,
      dt: deltaSeconds,
      consumptionRate: fireConsumptionRate,
    );

    // 2. Aplicar multiplicador de produção (penalidade se fogo apagado)
    final multiplier = FireLogic.productionMultiplier(fireFuelSeconds);

    // 3. Produção de recursos base
    //    TODO: multiplicar pela produção de cada NPC/zona quando implementado
    wood += 1.0 * deltaSeconds * multiplier;
  }

  /// Calcula ganhos offline e aplica ao estado.
  void applyOfflineEarnings(DateTime now) {
    final offlineSeconds = now.difference(lastSavedAt).inSeconds.toDouble();
    if (offlineSeconds > 0) {
      processTick(deltaSeconds: offlineSeconds);
    }
    lastSavedAt = now;
  }

  // ── Serialization ─────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'wood': wood,
        'food': food,
        'fireFuelSeconds': fireFuelSeconds,
        'fireMaxFuel': fireMaxFuel,
        'fireConsumptionRate': fireConsumptionRate,
        'lastSavedAt': lastSavedAt.toIso8601String(),
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        wood: (json['wood'] as num?)?.toDouble() ?? 0.0,
        food: (json['food'] as num?)?.toDouble() ?? 0.0,
        fireFuelSeconds:
            (json['fireFuelSeconds'] as num?)?.toDouble() ?? 60.0,
        fireMaxFuel: (json['fireMaxFuel'] as num?)?.toDouble() ??
            FireLogic.kDefaultMaxFuel,
        fireConsumptionRate:
            (json['fireConsumptionRate'] as num?)?.toDouble() ??
                FireLogic.kDefaultConsumptionRate,
        lastSavedAt: json['lastSavedAt'] != null
            ? DateTime.parse(json['lastSavedAt'] as String)
            : DateTime.now(),
      );

  /// Cópia superficial — útil para Riverpod Notifier emitir nova referência.
  GameState copyWith({
    double? wood,
    double? food,
    double? fireFuelSeconds,
    double? fireMaxFuel,
    double? fireConsumptionRate,
    DateTime? lastSavedAt,
  }) =>
      GameState(
        wood: wood ?? this.wood,
        food: food ?? this.food,
        fireFuelSeconds: fireFuelSeconds ?? this.fireFuelSeconds,
        fireMaxFuel: fireMaxFuel ?? this.fireMaxFuel,
        fireConsumptionRate: fireConsumptionRate ?? this.fireConsumptionRate,
        lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      );
}
