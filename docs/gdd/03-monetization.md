# 03 - Monetização

## Estratégia de Rewarded Ads
- **Mammute de Ouro:** Gatilho randômico, recompensa fortuna instantânea.
- **Bênção do Relâmpago:** Multiplicador temporário de produção + Fogo cheio.
- **Produção Offline:** Triplicar ganho offline via Ad.

## 2. Technical Implementation Logic

Esta seção detalha o mapeamento matemático e as estratégias sistêmicas para a exibição de Anúncios Recompensados (Rewarded Ads), bem como as fórmulas para a concessão de bônus, evitando a interrupção abusiva do gameplay.

### A. Pontos de Ancoragem de Ads (Ad Placements) e Status de Bônus

No backend, cada tipo de bônus é tratado como um *BoostEffect* com tempo de início, tempo de duração e multiplicador associado.

#### 1. Incremento de Produção Offline (Welcome Back Bonus)
Quando o jogador retorna após `$timeOfflineSeconds` > `60` segundos, a tela de "Lucro Offline" é apresentada.
- **Ação Padrão:** O jogador coleta `1x` do valor processado (`OfflineProduction`).
- **Ação Secundária (Assistir AD):** O jogador assiste a um vídeo (Rewarded Ad). Após a confirmação (`onAdWatchedSuccess`), o ganho é multiplicado.
- **Fórmula de Recompensa (Soft Cap por Nível):**
  Para balancear a economia e impedir que um jogador fique trilionário num único clique inicial limitamos o acúmulo máximo de offline multiplicável:
  ```math
  MaxOfflineTimeToMultiply = 43200 \times (1.0 + (playerLevel \times 0.05))
  ```
  *(Equivale a 12 horas base, adicionando 5% ao teto a cada nível alcançado)*
  Ao assistir, o ganho passa a ser: `OfflineProduction \times AdMultiplier` (ex: 2x ou 3x).

#### 2. Recompensas Diárias Baseadas em Nível (Daily Ad Rewards)
Uma roleta ou lista de "Missões de Anúncio Diárias" fica acessível num menu. Existe um *Daily Limits Cap* (ex: 5 ADs por dia).
- **Escalabilidade (Scaling Revenue):** O valor resgatado **não** pode ser fixo (ex: 100 Moedas/Ossos sempre), senão perde o apelo no *Late Game*.
- **Fórmula de Carga Diária:**
  ```math
  DailyAdRewardAmount = BaseDailyReward \times (RevenueMultiplier^{playerLevel - 1})
  ```
  Se o jogador está no Nível 50, ele pode ganhar 5.000 Moedas, valor que seria um game breaker no Nível 1, mas uma gota d'água útil no Nível 50.
- Caso encerre os 5 ADs (`dailyAdsWatched >= maxDailyAds`), o botão entra em *Cooldown* até a meia-noite (Server Time).

#### 3. Manager Boost (Boost Passivo Temporário)
Um botão constante na Interface de cada Zona de Trabalho que permite dobrar a eficiência daquele gerente/construção.
- **Funcionamento:** Assista um Ad para ativar um *Status Effect*.
- **Fórmula e Duração:** Adiciona uma varíavel na classe da Zona:
  ```math
  activeManagerAdBoostEndTime = currentTimestamp + 3600
  ```
  Isso gera `1h` de efeito ativo. A fórmula de produção da zona (conforme Documento 02) recebe este boost temporário:
  ```math
  FinalProductionRate = (BaseRate \times ManagerBonus) \times AdBoostMultiplier
  ```
  *(Onde AdBoostMultiplier vale `2.0` se dentro da janela de 1 hora, ou `1.0` normalmente)*.

#### 4. Evento do Mamute de Ouro (Random Event Trigger)
Para manter o jogador focado com os olhos ativos em movimento constante sobre a base:
- **Gatilho (RNG):** A cada `Tick Update` de 10 segundos, um número entre `0` e `100` é rolado.
- **Chance:** Se `Random < 2` (2% de chance) **E** `lastMammothAppearanceTime > 300` (min. 5 minutos de cooldown), o Mamute atravessa a tela.
- **Matemática do Susto e Prêmio (Instant Cash):** Recompensa instantânea equivalente a `15 a 30 minutos` da produção global da base inteira **caso** confira o Ad.
  ```math
  MammothReward = (\sum FinalZoneProductionRate) \times RandomRange(900, 1800)
  ```

### B. Integração do AdManager (Callbacks)

Todo acionamento de um Ad depende do recebimento do callback `AdRewardGranted()` ou semelhante de um provedor (AdMob, Unity Ads, Applovin).

**Casos de Borda (Edge Cases):**
- **Sinal de Internet Caindo:** Se o AD for interrompido, cai no `onAdFailed()`. Nenhuma recompensa é fornecida e nenhuma mensagem técnica deve quebrar o decoro do jogo ("Conexão com os Deuses Tribais Perdida").
- **Excesso de Boosts Temporários Acumulados:** Se o jogador clicar 4x no botão de Boost de 1 hora (consumindo 4 Ads seguidos), o tempo não multiplica, e sim a duração acumula até um limite máximo (`Caps` de 4h ou 12h, por exemplo: `endTime = min(endTime + 3600, maxBoostDuration)`). Isso aumenta suas métricas diárias sem destruir o equilíbrio de multiplicadores de economia (o multiplicador se mantém em 2x, apenas seu tempo se estende).