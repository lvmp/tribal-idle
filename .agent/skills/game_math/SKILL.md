---
name: game-math
description: "Idle game math: progression curves, BigInt, economy balancing, offline earnings, prestige formulas."
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Game Math — Idle Economy & Progression

> Foco total na lógica de progressão. Estruturas de dados que suportem BigInt para evitar overflow. Cálculo de G/s independente do framerate.

---

## 1. Progressão de Custos (Exponential Scaling)

### Fórmula Base

$$Cost_n = BaseCost \times Multiplier^{level}$$

| Exemplo | Base | Multiplier | Nível 10 | Nível 50 |
|---------|------|------------|----------|----------|
| Mineração | 10 | 1.15 | ~40 | ~10,837 |
| Fogueira | 25 | 1.20 | ~155 | ~237,376 |
| Templo | 100 | 1.25 | ~931 | ~8,881,784 |

### Princípios de Balanceamento

| Regra | Motivo |
|-------|--------|
| Multiplier entre 1.07 e 1.25 | Crescimento percebido sem frustração |
| Diminishing returns suaves | Jogador sempre sente progresso |
| Breakpoints a cada 25 níveis | Momentos de "wow" ao desbloquear |

---

## 2. Produção por Segundo (G/s)

### Fórmula

$$G/s = \sum_{i=1}^{n} (BaseProduction_i \times Level_i \times Multiplier_i)$$

### Implementação

```dart
double calculateTotalProduction() {
  return zones.fold(0.0, (total, zone) {
    return total + zone.baseProduction * zone.level * zone.multiplier;
  });
}
```

### Regra de Independência

> O cálculo de G/s NUNCA deve depender do framerate. Use `dt` do game loop apenas para animações. Para economia, use ticks ou timestamps.

---

## 3. BigInt / Decimal para Grandes Números

### Quando Usar

| Faixa de Valor | Tipo |
|----------------|------|
| < 10^15 | `double` (ok para early game) |
| 10^15 - 10^308 | `double` com formatação (K, M, B, T) |
| > 10^308 | `BigInt` ou lib especializada |

### Formatação de Números Grandes

```dart
String formatNumber(double value) {
  if (value >= 1e15) return '${(value / 1e15).toStringAsFixed(2)}Q';
  if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
  if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
  if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
  if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
  return value.toStringAsFixed(0);
}
```

---

## 4. Offline Earnings (Timestamps)

### Cálculo Offline

```dart
Duration elapsed = DateTime.now().difference(lastSaveTime);
double offlineGain = earningsPerSecond * elapsed.inSeconds;

// Cap para evitar exploits
offlineGain = min(offlineGain, maxOfflineGain);
```

### Princípios

| Regra | Motivo |
|-------|--------|
| Cap de tempo offline (ex: 8h) | Evitar exploits de data/hora |
| Eficiência offline < 100% (50-75%) | Incentivar jogo ativo |
| Opção de multiplicar via ad | Monetização natural |

---

## 5. Prestige (Soft Reset)

### Fórmula de Moeda de Prestígio

$$Prestige_{currency} = \lfloor \sqrt{\frac{TotalEarnings}{PrestigeThreshold}} \rfloor$$

### Bônus de Prestígio

$$GlobalMultiplier = 1 + (PrestigeCurrency \times 0.02)$$

### Princípios

| Elemento | Guideline |
|----------|-----------|
| **Primeiro prestige** | ~4-8 horas de jogo |
| **Incentivo mínimo** | 2x mais rápido após prestige |
| **Progressão sentida** | Cada prestige desbloqueia novos sistemas |

---

## 6. Custo de Sobrevivência (Tribal Idle Specific)

### Equação do Equilíbrio

$$ProduçãoLíquida = \sum(Ganhos) - \sum(CustoManutenção)$$

### Estado de Crise (Fogo Apagado)

```dart
double efficiency = currentWood > 0 ? 1.0 : 0.1; // 90% penalty
double netProduction = totalGains * efficiency - maintenanceCost;
```

### Regras

- Se `CurrentWood <= 0`: efficiency = 0.1 (penalidade de 90%)
- Custo de manutenção escala com número de zonas ativas
- Trigger de endorfina: restaurar fogo = feedback visual + sonoro

---

## 7. Anti-Patterns de Economia Idle

| ❌ Don't | ✅ Do |
|----------|-------|
| Calcular economia no `update(dt)` | Usar ticks independentes |
| Usar `int` para moedas | Usar `double` ou `BigInt` |
| Linear scaling de custos | Exponential scaling |
| Prestige sem incentivo claro | 2x+ ganho mínimo pós-prestige |
| Permitir earnings offline ilimitados | Cap de tempo + eficiência reduzida |

---

> **Remember:** A economia é o coração do idle game. Se a progressão não for satisfatória, nenhuma gráfico bonito salva o jogo.