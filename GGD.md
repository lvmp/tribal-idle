# Tribal Idle: Dawn of Fire

> **Status:** Versão Final para Implementação (V1.0)
> **Engine:** Flame Engine (Flutter) — https://flame-engine.org/
> **Inspiração de UI:** *Idle Bank Tycoon: Money Empire*
> **Modelo de Negócio:** F2P com foco em Rewarded Ads e IAP de conveniência.

---

## 1. Visão Geral e "Pitch"

**Tribal Idle: Dawn of Fire** é um simulador de gestão de tribo onde o jogador luta contra a extinção enquanto evolui tecnologicamente. O "gancho" emocional (endorfina) vem da satisfação visual de ver uma vila primitiva crescer, da coleta rítmica de recursos e da gestão de risco do **Custo de Sobrevivência (Fogo)**.

---

## 2. Core Loop (O Ciclo de Dopamina)

1. **Extração:** Tocar e automatizar a coleta de Pedras, Comida e Madeira.
2. **Manutenção:** Alimentar a Fogueira Central para evitar o colapso da produção.
3. **Expansão:** Desbloquear novas "Zonas de Trabalho" (estilo as salas do Idle Bank).
4. **Otimização:** Alocar Gerentes (Xamãs/Guerreiros) para aumentar o lucro líquido.
5. **Evolução:** Realizar o "Salto Evolutivo" (Prestige) para a próxima Era.

---

## 3. Mecânicas de Sobrevivência (Lógica de Backend)

Diferente de tycoons comuns, o lucro pode ser negativo. O jogador precisa equilibrar o consumo das construções com a produção de lenha.

- **A Equação do Equilíbrio:**

    $$ProduçãoLíquida = \sum(Ganhos) - \sum(CustoManutenção)$$

- **Estado de Crise (Fogo Apagado):** Se o estoque de Madeira chegar a zero, a produção de todos os outros recursos é penalizada em **90%**.
- **Endorfina Trigger:** Ao restaurar o fogo (via cliques ou AD), a tela brilha e a música acelera, gerando alívio imediato.

---

## 4. Design de Interface (UI/UX) — Estilo "Stone Empire"

O layout segue o padrão isométrico do *Idle Bank Tycoon*:

### A. Estrutura da Tela (HUD)

```
┌─────────────────────────────────┐
│  🪵 Wood   🍖 Food   ⛏️ Stone   │ ← Contadores táteis
│  ████████████░░░░  🔥 67%       │ ← Barra de Fogo (pulsa)
├─────────────────────────────────┤
│                                 │
│     [FLAME CANVAS]              │ ← Mundo isométrico
│     Zonas de Trabalho           │
│     NPCs com cestas             │
│     Fogueira Central            │
│                                 │
├─────────────────────────────────┤
│  [⬆ Upgrade] [👤 Gerentes] [⚙] │ ← Ações (bottom)
└─────────────────────────────────┘
```

- **Topo:** Contadores de recursos com ícones grandes e táteis (osso, couro, madeira)
- **Barra de Fogo (Vital):** Uma barra térmica no topo que pulsa conforme o combustível diminui
- **Zonas de Trabalho:** Áreas delimitadas no mapa (Ex: Posto de Coleta de Berries, Pedreira, Ateliê de Lanças)

### B. Feedback Visual e Sonoro

- **"Juicy" Buttons:** Botões de upgrade que "esmagam" e tremem ao serem clicados (squash & stretch)
- **Fluxo de NPCs:** Pequenos homens das cavernas carregando cestas. Quando o nível da zona sobe, eles ficam mais rápidos e as cestas maiores
- **Floating Numbers:** Números que flutuam para cima ao coletar recursos (+50 🪵)
- **Screen Glow:** Efeito de brilho ao restaurar o fogo
- **Sons:** Som seco de pedra batendo em pedra, fogo estalando e um grito tribal festivo quando um upgrade importante ocorre

---

## 5. Art Direction

### Estilo Visual

| Atributo | Decisão |
|----------|---------|
| **Estilo** | Vector/Flat com texturas tribais |
| **Paleta** | Tons quentes (terra, laranja, ocre) + verde floresta |
| **Personagens** | 64-128px, silhuetas distintas |
| **Background** | Parallax com camadas (céu, montanhas, floresta) |
| **Animações** | 8-12 FPS para NPCs, squash & stretch em UI |

### Hierarquia Visual

1. **Fogueira Central** — elemento mais proeminente (pulsante, brilhante)
2. **Zonas Ativas** — cores vivas e NPCs em movimento
3. **Recursos (HUD)** — ícones grandes e legíveis
4. **Background** — sutil, não compete com gameplay

### Asset Pipeline

```
Concept → Aseprite/Procreate → Spritesheet → Flame SpriteComponent
```

---

## 6. Audio Design

### Soundscape Tribal

| Tipo | Descrição | Trigger |
|------|-----------|---------|
| **BGM** | Tambores tribais + flauta de osso | Sempre (loop) |
| **SFX: Pedra** | Batida seca de pedra | Coleta de pedra |
| **SFX: Madeira** | Machado em tronco | Coleta de madeira |
| **SFX: Fogo** | Estalidos constantes | Background (fogueira) |
| **SFX: Upgrade** | Grito tribal festivo | Ao comprar upgrade |
| **SFX: Crise** | Tambor de alarme | Fogo < 20% |
| **SFX: Prestige** | Trovão + coro tribal | Ao evoluir de era |

### Volume Adaptativo

- BGM reduz durante pausas e menus
- SFX de fogo escala com nível da barra
- Respeitar configurações do sistema (silent mode)

---

## 7. Sistema de Gerentes (Personagens)

Inspirado nas cartas do *Idle Bank*, os gerentes são o coração da retenção e monetização.

| **Gerente** | **Tipo** | **Habilidade Passiva** | **Estética** |
| --- | --- | --- | --- |
| **Ugh, o Forte** | Mineração | +25% de Velocidade de Pedra | Brutamontes com clava de osso. |
| **Zola, a Ágil** | Coleta | -15% no Custo de Comida | Caçadora com pele de leopardo. |
| **Xamã Ignis** | Fogo | Dobra a duração da Madeira | Velho com máscara de madeira e cajado. |

---

## 8. Estratégia de Monetização (Ads & IAP)

O jogo é desenhado para o jogador *querer* ver o anúncio para evitar a perda de progresso ou acelerar o ganho.

- **O Mammute de Ouro (Rewarded AD):** Um mamute passa na borda da tela. Se o jogador clicar e ver o AD, ele "caça" o mamute e ganha uma fortuna instantânea.
- **Bênção do Relâmpago:** Assista um vídeo para encher 100% da barra de fogo e ganhar 2x de velocidade por 1 hora.
- **Multiplicador de Ausência:** "Sua tribo trabalhou enquanto você dormia. Assista para triplicar a produção offline!"
- **IAP:** Pacote "Fogo Eterno" (Remove Ads obrigatórios e garante manutenção infinita de lenha).

---

## 9. Referência Técnica

### Stack Tecnológico

| Camada | Tecnologia |
|--------|-----------|
| **Engine** | Flame Engine (Flutter) |
| **State Management** | Riverpod |
| **Persistence** | Hive + JSON Serialization |
| **Ads** | Google AdMob + Mediation |
| **Cloud** | Firebase Firestore |
| **Audio** | FlameAudio |

### Arquitetura

```
lib/
├── domain/     → Regras de negócio, economia, progressão
├── infrastructure/ → Repositórios, persistência, ads
├── presentation/
│   ├── game/   → Flame Components, Game Loop
│   └── widgets/ → Flutter Overlays, HUD
└── shared/     → State management, constantes
```

> Consulte `docs/architecture.md` e `definicoes.md` para detalhes técnicos.

---

## 10. Roadmap de Implementação

### Fase 1: Core Loop (MVP)

| Módulo | Descrição |
|--------|-----------|
| `ResourceManager` | Controla Wood, Food, Stone com `UpdateTick()`. Aplica efficiency=0.1 se wood=0 |
| `FireSystem` | Barra de fogo com consumo por segundo. Visual pulse no HUD |
| `ZoneSystem` | Zonas de trabalho com nível e custo exponencial |

### Fase 2: Meta Systems

| Módulo | Descrição |
|--------|-----------|
| `ManagerSystem` | Gerentes com bônus passivos. Cards estilo Idle Bank |
| `PrestigeSystem` | Soft reset com moeda de prestígio. Fórmula sqrt(TotalEarnings/Threshold) |
| `OfflineEarnings` | Cálculo timestamp-based com cap de 8h e 50% eficiência |

### Fase 3: Monetização & Polish

| Módulo | Descrição |
|--------|-----------|
| `AdManager` | Rewarded ads integrados à economia (mammute, bênção, offline) |
| `IAPManager` | Pacotes de compra (Fogo Eterno, Starter Pack) |
| `AudioManager` | BGM tribal + SFX contextuais |

---

## 11. Elementos de Retenção

- **Missões Diárias:** "Cace 50 javalis", "Mantenha o fogo aceso por 1 hora".
- **Árvore de Tecnologia:** Uma pedra gigante com gravuras que o jogador vai "limpando" para desbloquear novas eras.
- **Eventos Sazonais:** Tempestade (mais consumo de lenha), Caça ao Mamute (evento temporário).
- **Achievements:** Marcos de progresso com recompensas.