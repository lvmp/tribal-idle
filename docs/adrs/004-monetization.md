## ADR 004: Monetization
- **Status:** Aceito
- **Decisão:** Google Mobile Ads + AdMob Mediation.
- **Contexto:** Prioridade para simplicidade. Futuramente avaliar AppLovin MAX se o volume de tráfego justificar o aumento de complexidade no código.

**Justificativa:** O modelo de negócio do jogo depende de Rewarded Ads para acelerar a economia do Idle. Escolhemos a integração via Google Mobile Ads desde o início porque precisamos de um plugin que seja mantido ativamente pela comunidade Flutter. A decisão de usar Mediation desde o dia um (em vez de AdMob puro) é estratégica: ela prepara a infraestrutura para maximizar o eCPM sem que precisemos alterar a arquitetura do código no futuro, quando o tráfego do jogo escalar.

## Consequências
### Positivas
- **Maximização de Receita:** A *mediation* permite que múltiplas redes disputem o inventário, aumentando o fill rate e o eCPM.
- **Robustez:** SDKs oficiais da Google possuem melhor suporte para testes (test ads) e conformidade com políticas.

### Negativas
- **Dependência:** O jogo fica dependente de SDKs externos proprietários, o que aumenta o tamanho do binário final (APK/IPA).
- **UX Risk:** Se a lógica de pausa do jogo ao exibir o Ad for mal implementada, pode causar bugs na lógica de progressão (ex: o tempo de idle parar de contar enquanto o Ad é exibido).