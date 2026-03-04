# 02 - Progressão e Zonas

## Zonas de Trabalho (Work Zones)
- Estilo: Idle Bank Tycoon (isométrico).
- Mecânica: Cada zona tem custo incremental e slots para gerentes.

## Sistema de Gerentes
- Ugh (Pedra), Zola (Comida), Xamã (Fogo).
- Devem ser implementados como objetos (ScriptableObjects ou Data Classes Dart) para fácil balanceamento.

## 3. Technical Implementation Logic

Esta seção detalha as fórmulas matemáticas e o design de progressão para as Zonas de Trabalho (Work Zones) e para os Gerentes (Managers), definindo os cálculos de custo, ganho e alcance de marcos (milestones).

### A. Progressão de Zonas de Trabalho (Buildings)

Cada Zona de Trabalho possui uma curva de custo exponencial e um ganho de produção linear ou em degraus (step-based).

**1. Variáveis de Estado da Zona**
- `currentLevel` (int): Nível atual da construção (inicia em 1).
- `baseUpgradeCost` (float/double): Custo base para subir do nível 1 para o 2.
- `costMultiplier` (float/double): Coeficiente de crescimento do custo (ex: `1.15` para `+15%` por nível).
- `baseProduction` (float/double): Valor base gerado no nível 1.
- `productionMultiplier` (float/double): Mult. de crescimento da produção base.
- `milestoneMultiplier` (float/double): Multiplicador de bônus acumulado em níveis-chave.

**2. Cálculo de Custo para o Próximo Nível**
A fórmula de encarecimento segue uma progressão geométrica padrão em jogos *Idle*:
```math
NextLevelCost = baseUpgradeCost \times (costMultiplier ^ {currentLevel - 1})
```
*Exemplo:* O jogador está no nível 10 com `costMultiplier` de `1.15` e `baseUpgradeCost` de `100`. O custo para o nível 11 será: `100 * (1.15 ^ 9) = ~351`.

Para comprar `N` níveis de uma vez (botões `MAX` ou `x10`), é prudente utilizar a fórmula da soma finita de progressão geométrica para evitar loops exaustivos na CPU:
```math
CostForNLevels = baseUpgradeCost \times (costMultiplier^{currentLevel - 1}) \times \frac{(costMultiplier^N - 1)}{(costMultiplier - 1)}
```

**3. Progresso de Produção e Marcos (Milestones)**
A produção base cresce de forma controlada conforme o nível, mas recebe grandes trancos multiplicativos ao atingir marcos (ex: níveis 10, 25, 50, 100).
```math
CurrentProduction = (baseProduction \times currentLevel) \times MilestonesAchieved
```
Onde `MilestonesAchieved` é um fator multiplicativo cumulativo. Exemplo:
- Ao atingir o nível 25: `MilestonesAchieved = MilestonesAchieved * 2` (produção passiva agora entra num "novo patamar" permanentemente).
- Marcos também são úteis para reduzir o *Cycle Time* (ex: cair de `3s` para `1.5s`), dobrando a vazão efetiva de coletas por segundo.

### B. Progressão de Gerentes (Managers)

Os gerentes requerem "Fragmentos" (Cartas/Shards) e moedas "Premium/Secundárias" (Ex: Ossos ou Tribal Gold) para evoluírem, introduzindo mecânicas de *gacha drop* e coleta específica.

**1. Variáveis de Estado do Gerente**
- `managerLevel` (int): Nível atual (inicia em 1).
- `rarity` (Enum: Comum, Raro, Épico): Define pesos de custo diferentes em cada equação.
- `baseCardCost` (int): Fragmentos base requeridos.
- `baseCurrencyCost` (double): Moeda requerida base para upar do Lvl 1->2.
- `bonusValue` (float): Percentual / Multiplicador base.
- `bonusIncrementPerLevel` (float): Ganho fixo ou escalar de bônus por LVL.

**2. Cálculo de Custo de Upgrade do Gerente**
O custo de *cards* em gachas/idles usualmente escala em degraus matemáticos mais contidos, enquanto moedas escalam exponencialmente:
```math
CardsRequiredNextLevel = baseCardCost \times (managerLevel \times 1.5)
```
```math
CurrencyRequiredNextLevel = baseCurrencyCost \times (currencyCostMultiplier ^ {managerLevel - 1})
```

**3. Progressão de Status (Buff do Gerente)**
A eficácia do Gerente sobre a Zona adiciona fatores percentuais (Boosts):
```math
CurrentBonus = baseBonus + (bonusIncrementPerLevel \times (managerLevel - 1))
```
*Exemplo:* "Zola" LVL 1 reduz custo de Comida em `15%` (`0.15`). Bônus fixo é `+2%` por lvl. No Lvl 3, a redução total será: `15% + (2 * 2%) = 19%` (`0.19`).

### C. Integração Final: Zona + Gerente = Gameplay
Se o Gerente em questão provê Bônus de Produção Massiva:
```math
FinalZoneProductionRate = CurrentProduction \times (1.0 + CurrentBonus)
```
Caso proveja aumento de Velocidade da Animação de Colheita / Caminhada:
```math
FinalZoneCycleTime = BaseCycleTime \times (1.0 - SpeedBonus)
```

### D. Casos de Borda (Edge Cases) e Balanceamento

- **Max Level Teto (Cap):** A classe matemática deve observar constantes inibidoras (`maxZoneLevel`, `maxManagerLevel`). Atingindo-o, a matemática é suprimida visualmente (exibe botão opaco "MAX") para impedir a contagem negativa ou descarte inválido de recursos se o jogador rodar macro-clicks.
- **Floating Point Scale / Overflow:** Zonas maiores que o Lvl 500 começam a estourar a casa dos quadrilhões. A base inteira de cálculo precisa repousar sobre bibliotecas de **Big Numbers** ou **BigDouble** nativa que segure formatação de string (Ex: `100a`, `1M`, `450B`, `2aa`), e garantindo que contas na casa flutuante do sistema evitem `Infinity` em double de 64-bits.
- **Substituição Agressiva de Gerentes (Hot-Swapping):** Trocar ou retirar o Gerente em pleno "cast" de produção do recurso na UI. Se for hot-swapped no frame *N* do Unity/Flutter, o `FinalZoneCycleTime` atual deve ser invalidado e forçar o cancelamento ou a rescale instantânea do FillAmount (Timer) no mesmo tick. Do contrário, o timer finaliza com tempo velho entregando loot adulterado.