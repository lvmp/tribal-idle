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
  /// Nível atual da fogueira (0 = apagada, 1-5 = estágios crescentes).
  int fireLevel;

  /// Combustível restante em segundos. Quando chega a 0, a fogueira apaga.
  double fireFuelSeconds;

  // ── Meta ──────────────────────────────────────────────────────────
  /// Timestamp do último save (usado para calcular ganhos offline).
  DateTime lastSavedAt;

  GameState({
    this.wood = 0.0,
    this.food = 0.0,
    this.fireLevel = 1,
    this.fireFuelSeconds = 60.0,
    DateTime? lastSavedAt,
  }) : lastSavedAt = lastSavedAt ?? DateTime.now();

  // ── Economy Tick ──────────────────────────────────────────────────

  /// Chamado pelo [TimerComponent] a cada 1 segundo.
  ///
  /// [deltaSeconds]: normalmente 1.0, mas pode ser maior para cálculo offline.
  /// Toda a matemática do Idle deve estar aqui ou delegada para [IdleMath].
  void processTick({double deltaSeconds = 1.0}) {
    // TODO: Implementar produção de recursos por NPC/zona
    // TODO: Implementar consumo de combustível da fogueira
    // TODO: Implementar penalidade se fogueira apagar

    // Exemplo placeholder: 1 madeira por segundo base
    wood += deltaSeconds;
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
        'fireLevel': fireLevel,
        'fireFuelSeconds': fireFuelSeconds,
        'lastSavedAt': lastSavedAt.toIso8601String(),
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        wood: (json['wood'] as num?)?.toDouble() ?? 0.0,
        food: (json['food'] as num?)?.toDouble() ?? 0.0,
        fireLevel: (json['fireLevel'] as int?) ?? 1,
        fireFuelSeconds: (json['fireFuelSeconds'] as num?)?.toDouble() ?? 60.0,
        lastSavedAt: json['lastSavedAt'] != null
            ? DateTime.parse(json['lastSavedAt'] as String)
            : DateTime.now(),
      );

  /// Cópia superficial — útil para Riverpod StateNotifier.
  GameState copyWith({
    double? wood,
    double? food,
    int? fireLevel,
    double? fireFuelSeconds,
    DateTime? lastSavedAt,
  }) =>
      GameState(
        wood: wood ?? this.wood,
        food: food ?? this.food,
        fireLevel: fireLevel ?? this.fireLevel,
        fireFuelSeconds: fireFuelSeconds ?? this.fireFuelSeconds,
        lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      );
}
