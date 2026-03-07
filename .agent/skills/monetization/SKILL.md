---
name: monetization
description: "Mobile game monetization: Rewarded Ads, IAP, AdMob Mediation, economy integration, retention loops."
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Monetization — Ads, IAP & Revenue

> Foco em `google_mobile_ads` e bibliotecas de mediation (ex: AppLovin MAX). O design dos Ads é parte da economia do jogo.

---

## 1. Modelos de Monetização

| Modelo | Best For | Revenue/User |
|--------|----------|--------------|
| **Free + Rewarded Ads** | Idle, casual | $0.01-0.05/day |
| **Free + IAP** | Progression-based | $0.10-2.00/payer |
| **Free + Ads + IAP** | Hybrid (melhor LTV) | Combinado |
| **Premium** | Niche, quality | One-time |
| **Subscription** | Live service | Recorrente |

### Para Tribal Idle → **Hybrid (Rewarded Ads + IAP de conveniência)**

---

## 2. Rewarded Ads (Core Revenue)

### Princípios de Design

| Princípio | Implementação |
|-----------|---------------|
| **Opt-in sempre** | Jogador escolhe assistir |
| **Recompensa valiosa** | O ad deve "valer a pena" |
| **Não bloquear progresso** | Ads aceleram, não desbloqueiam |
| **Cooldown natural** | Evitar spam de ads |

### Integração com Game Loop

```dart
class AdManager {
  // SEMPRE verifique se o ad está carregado antes de mostrar
  bool isRewardedAdReady = false;
  
  Future<void> showRewardedAd({
    required VoidCallback onReward,
    VoidCallback? onDismissed,
  }) async {
    if (!isRewardedAdReady) return;
    
    // 1. Pausar o game loop do Flame
    game.pauseEngine();
    
    // 2. Mostrar o ad
    await _rewardedAd.show(
      onUserEarnedReward: (ad, reward) {
        // 3. Aplicar recompensa APENAS no callback
        onReward();
      },
    );
    
    // 4. Retomar o game loop
    game.resumeEngine();
    
    // 5. Pré-carregar próximo ad
    _loadRewardedAd();
  }
}
```

### Oportunidades de Ad no Tribal Idle

| Momento | Recompensa | Trigger |
|---------|------------|---------|
| **Mammute de Ouro** | Fortuna instantânea | Aparece periodicamente |
| **Bênção do Relâmpago** | 100% fogo + 2x speed 1h | Botão no HUD |
| **Multiplicador Offline** | 3x ganhos offline | Ao retornar |
| **Resgate de Crise** | Restaurar fogo | Quando fogo apaga |
| **Upgrade Grátis** | 1 upgrade free | Tela de upgrade |

---

## 3. IAP (In-App Purchases)

### Tipos de IAP

| Tipo | Exemplo | Pricing |
|------|---------|---------|
| **Consumível** | Pacote de recursos | $0.99-4.99 |
| **Não-consumível** | Remover ads | $2.99-4.99 |
| **Subscription** | VIP mensal | $4.99/mês |

### Pacotes Sugeridos para Tribal Idle

| Pacote | Conteúdo | Preço |
|--------|----------|-------|
| **Fogo Eterno** | Remove ads obrigatórios + lenha infinita | $4.99 |
| **Saco de Recursos** | 10,000 de cada recurso | $0.99 |
| **Pacote Starter** | Recursos + gerente raro | $2.99 |
| **VIP Tribal** | 2x speed permanente + daily bonus | $4.99/mês |

---

## 4. AdMob Mediation

### Hierarquia de Mediation

```
1. AdMob (Google) — Base
2. AppLovin MAX — Fill rate alto
3. Unity Ads — Jogos mobile
4. Meta Audience Network — Segmentação
```

### Configuração

| Parâmetro | Recomendação |
|-----------|-------------|
| **Banner ads** | Evitar em idle games (atrapalha UX) |
| **Interstitial** | Apenas em transições naturais |
| **Rewarded** | Principal fonte de revenue |
| **Rewarded Interstitial** | Após longos períodos de jogo |

---

## 5. Métricas de Monetização

| Métrica | Target Saudável |
|---------|----------------|
| **ARPDAU** | $0.05-0.15 |
| **IAP Conversion** | 2-5% |
| **Ad Engagement** | 30-60% dos DAU |
| **Retention D1** | > 40% |
| **Retention D7** | > 15% |
| **LTV** | > CPI (custo por instalação) |

---

## 6. Anti-Patterns de Monetização

| ❌ Don't | ✅ Do |
|----------|-------|
| Forçar ads (sem opt-in) | Rewarded ads opt-in |
| Bloquear progresso sem $$ | Ads aceleram, não desbloqueiam |
| Aplicar recompensa sem callback | Esperar `onUserEarnedReward` |
| Ignorar pausa do game loop | Pausar Flame durante ad |
| Banner cobrindo gameplay | Posicionar ads fora do canvas |
| Quebrar fluxo do jogador | Integrar ads na economia |

---

> **Remember:** O jogador deve *querer* ver o anúncio. Se ele *precisa* ver, você perdeu ele.