# 01 - Economia e Matemática

## A Equação do Equilíbrio
O motor do jogo se baseia na produção líquida constante:

$$ProduçãoLíquida = \sum(Ganhos) - \sum(CustoManutenção)$$

## Estado de Crise
- **Condição:** Se `EstoqueMadeira <= 0`.
- **Penalidade:** Eficiência global cai para $0.1$ ($10\%$ da produtividade).

## Recursos
- Madeira (Combustível), Pedra (Construção), Comida (População).

## 4. Technical Implementation Logic

Esta seção detalha a lógica backend necessária para implementar o sistema de economia e sobrevivência (FireBar), abordando variáveis, estados, fórmulas de progressão e mitigação de casos de borda.

### A. Variáveis de Estado (State Variables)
- `currentWood` (float/double): Quantidade atual de madeira no estoque.
- `maxWoodCapacity` (float/double): Limite máximo de madeira que pode ser estocada.
- `woodConsumptionRate` (float/double): Taxa de consumo de lenha por segundo (ex: `1.5/s`).
- `fireBarPercentage` (float): Nível visual da barra térmica (de `0.0` a `1.0`).
- `globalEfficiency` (float): Multiplicador atual de eficiência de todas as outras zonas (`1.0` ou `0.1`).
- `lastLoginTimestamp` (long): Timestamp da última sessão salva para cálculo de progressão offline.
- `baseProduction` (Map ou Object): Taxa de produção base de cada recurso por segundo.

### B. Estados Possíveis da FireBar
A interface e a mecânica respondem diretamente ao estado restritivo do fogo:
1. **Aceso (Normal):** `currentWood` > `20%` da capacidade (ou de tempo restante de segurança).
   - **Efeito:** Jogabilidade fluida, `globalEfficiency = 1.0`.
2. **Crítico (Pulsando):** `currentWood` <= `20%`.
   - **Efeito:** `globalEfficiency = 1.0`, mas a UI pulsa em vermelho ou laranja forte, indicando perigo, ícone tremendo implorando por cliques.
3. **Apagado (Crise):** `currentWood <= 0`.
   - **Efeito:** Fogo extinto. A tela escurece e entra em modo "Crise", garantindo que `currentWood = 0` e ativando a penalidade global `globalEfficiency = 0.1` (redução drástica na linha de produção).

### C. Fórmulas Matemáticas Exatas

**1. Consumo Ativo (Tick Update / Per Second)**
```math
currentWood = currentWood - (woodConsumptionRate \times deltaTime)
```

**2. Status da Barra Visual (FireBar)**
```math
fireBarPercentage = clamp(currentWood / maxWoodCapacity, 0.0, 1.0)
```

**3. Produção de Recursos Ativa**
Para cada recurso autônomo coletado no mesmo frame/tick:
```math
ResourceGenerated = (baseProduction + \sum GerentesBuffs) \times globalEfficiency \times deltaTime
```

**4. Matemática de Produção Offline (Idle Progress)**
Ao relogar, calculamos o desenrolar das ações simuladas durante a ausência:
```math
timeOfflineSeconds = currentTimestamp - lastLoginTimestamp
```
```math
woodConsumedOffline = woodConsumptionRate \times timeOfflineSeconds
```

**Cenário 4.1: Sobreviveu (sempre teve lenha no período)**
Se `woodConsumedOffline <= currentWood`:
```math
OfflineProduction = baseProduction \times 1.0 \times timeOfflineSeconds
currentWood = currentWood - woodConsumedOffline
```

**Cenário 4.2: Fogo apagou enquanto estava offline**
Se `woodConsumedOffline > currentWood`:
Calcula o tempo exato em que a lenha acabou:
```math
timeWithFire = currentWood / woodConsumptionRate
timeWithoutFire = timeOfflineSeconds - timeWithFire
```
Divide-se o lucro offline de maneira segmentada e zera-se a lenha:
```math
OfflineProduction = (baseProduction \times 1.0 \times timeWithFire) + (baseProduction \times 0.1 \times timeWithoutFire)
currentWood = 0
```

### D. Tratamento de Casos de Borda (Edge Cases)

- **O que acontece se o jogador fechar o app com o fogo quase apagado?**
  Ao processar o *Idle Progress*, nossa fórmula (Cenário 4.2) é à prova de cheat/falhas. O jogo simulará exatamente os poucos segundos em que a lenha restante o sustentou e concederá `100%` da produção por este pequeno sub-período (`timeWithFire`). No resto inteiro do período offline (às vezes horas ou dias), o jogador receberá um fluxo ínfimo equivalente à punição (`globalEfficiency = 0.1`), penalidade matemática justificada pela falta de prevenção.
- **Buffs por tempo limitado expirando enquanto Offline (Ex: Boost de Ad de 1h)**
  A mesma lógica proporcional de segmentação do fogo se aplica aos buffs. O tick offline divide a matemática: computa os minutos cobertos por um multiplicador `buffMultiplier = 2.0` que estão dentro de `timeOfflineSeconds` e volta o ganho normal no tempo restante após a expiração.
- **Geração de lenha excedendo o consumo (Auto-Susto)**
  Se automatizadores passarem a coletar taxa de madeira mais rápida do que é consumida (ex: `woodProductionRate` > `woodConsumptionRate`), o saldo final do *offline production loop* de `currentWood` excederia logicamente e ficaria infinito. Por isso o valor gerado offline precisa ao final receber um `currentWood = min(currentWood, maxWoodCapacity)`.