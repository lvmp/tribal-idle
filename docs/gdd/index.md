# Índice de Decisões de Arquitetura (ADR Index)

Este documento serve como o índice central para todas as decisões arquiteturais do projeto **Tribal Idle**. Toda mudança fundamental que impacte a tecnologia, estrutura ou estratégia do jogo deve ser registrada aqui.

## Registros de Decisão

| ID | Título | Status | Data |
| :--- | :--- | :--- | :--- |
| [001](001-state-management.md) | Gerenciamento de Estado (Riverpod) | Aceito | 2026-03-03 |
| [002](002-game-engine.md) | Engine de Jogo (Flame) | Aceito | 2026-03-03 |
| [003](003-persistence-layer.md) | Persistência de Dados (Hive) | Aceito | 2026-03-03 |
| [004](004-monetization.md) | Monetização (AdMob + Mediation) | Aceito | 2026-03-03 |

---

## Protocolo de Consulta para o Agente

> **LEIA-ME PRIMEIRO:**
> Como IA colaboradora, você deve tratar estes documentos como a **"lei"** do projeto. Antes de propor qualquer solução:
> 
> 1. **Consulte este Índice:** Identifique quais ADRs se aplicam à tarefa atual.
> 2. **Leia o ADR Específico:** Acesse o arquivo vinculado para entender o contexto, a justificativa e, principalmente, as **Consequências Negativas**.
> 3. **Validação de Risco:** Verifique se a sua solução proposta fere alguma das consequências negativas listadas. Se ferir, você deve alertar o usuário e sugerir uma alternativa que mitigue esse risco.
> 4. **Evolução:** Se uma tarefa exigir uma nova decisão tecnológica, proponha a criação de um novo ADR neste formato padrão antes de implementar a mudança.

---

## Como Adicionar um Novo ADR
Para manter a consistência, todos os novos ADRs devem seguir o template:

1. **Título e Status**
2. **Contexto/Justificativa** (O porquê agora?)
3. **Consequências Positivas**
4. **Consequências Negativas** (Risco técnico)