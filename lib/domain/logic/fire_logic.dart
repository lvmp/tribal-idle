/// Lógica pura do Sistema de Fogo — sem dependências de Flutter ou Flame.
///
/// Todas as constantes e cálculos relacionados ao fogo vivem aqui,
/// permitindo testes unitários isolados e reutilização em cálculos offline.
class FireLogic {
  // ── Constantes ────────────────────────────────────────────────────────────

  /// Combustível máximo padrão em segundos (5 minutos).
  static const double kDefaultMaxFuel = 300.0;

  /// Taxa de consumo padrão: 1 unidade de combustível por segundo.
  static const double kDefaultConsumptionRate = 1.0;

  /// Limiar de crise: abaixo de 20% → pulsa e emite alerta.
  static const double kCrisisThreshold = 0.20;

  /// Penalidade de produção quando o fogo está apagado (10% da taxa normal).
  static const double kPenaltyFactor = 0.10;

  // ── Cálculos ────────────────────────────────────────────────────────────

  /// Retorna o novo nível de combustível após [dt] segundos de consumo.
  ///
  /// Clampado em 0 — nunca fica negativo.
  static double computeNewFuel({
    required double currentFuel,
    required double dt,
    double consumptionRate = kDefaultConsumptionRate,
  }) {
    return (currentFuel - consumptionRate * dt).clamp(0.0, double.infinity);
  }

  /// Retorna `true` se o fogo está apagado (combustível esgotado).
  static bool isExtinguished(double fuel) => fuel <= 0;

  /// Retorna `true` se o fogo está em estado de crise (< 20% do máximo).
  static bool isCrisis(double fuel, double maxFuel) {
    if (maxFuel <= 0) return true;
    return (fuel / maxFuel) < kCrisisThreshold;
  }

  /// Retorna o multiplicador de produção com base no nível de combustível.
  ///
  /// - Fogo apagado → [kPenaltyFactor] (10%)
  /// - Fogo aceso   → 1.0 (produção normal)
  static double productionMultiplier(double fuel) =>
      isExtinguished(fuel) ? kPenaltyFactor : 1.0;

  /// Quantidade de madeira necessária para adicionar [fuelAmount] de combustível.
  ///
  /// Relação 1:1 por enquanto (1 madeira = 1 segundo de combustível).
  /// Pode ser ajustado por upgrades futuros.
  static double woodCostForFuel(double fuelAmount) => fuelAmount;
}
