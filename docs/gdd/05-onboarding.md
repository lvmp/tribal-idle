# 05 - Onboarding: "A Primeira Brasa"

## Objetivo
Transformar o jogador de "clicker manual" em "gestor de tribo" em menos de 60 segundos.

## Contexto Narrativo
A tribo acaba de chegar em uma clareira desconhecida. A noite cai, a temperatura está caindo e a fogueira está quase apagando. Sobreviver é a prioridade.

## Fluxo do Tutorial (Tutorial State Machine)

### Passo 1: O Alerta do Fogo
- **Cena:** Foco da câmera na Fogueira Central (pulsando vermelho).
- **Ação:** Ícone de mão apontando para a fogueira.
- **Instrução:** "Alimente o fogo ou a tribo congelará!"
- **Término:** Usuário clica na fogueira, consome 10 de madeira, fogo brilha.

### Passo 2: A Necessidade de Recursos
- **Cena:** HUD de Madeira aparece com destaque.
- **Ação:** Usuário precisa coletar madeira manualmente (clicar no bosque).
- **Instrução:** "Toque nas árvores para coletar madeira."
- **Término:** Coletar 20 de madeira.

### Passo 3: A Primeira Automação (A transição para Idle)
- **Cena:** Loja de Zonas (desbloqueia o "Posto de Coleta").
- **Ação:** Comprar a primeira zona com a madeira coletada.
- **Instrução:** "Construa um Posto de Coleta para trabalhar por você."
- **Término:** Construção concluída, NPC aparece, coleta automática inicia.

## Technical Constraints (Specs para o Agente)

- **Bloqueio de UI (Tutorial Gate):** Enquanto o tutorial estiver ativo, botões não essenciais (ex: Menus de Gerentes, Settings, Loja de IAP) devem estar `disabled` ou invisíveis.
- **Tutorial Persistence:** O progresso do tutorial deve ser salvo no Hive como `tutorialStep: int`. Se o jogador fechar o app no meio, ele deve retornar no mesmo passo.
- **Interruption Proof:** Se o jogador clicar em um lugar errado, o tutorial deve repetir a animação de "hand-tap" (o indicador de clique) em vez de travar o jogo.
- **Auto-Advance:** O tutorial avança via *Event Trigger* (ex: `onResourceCollected`), não via timer.

## Elementos Necessários (Assets)
- `tutorial_hand_icon`: Sprite de mão apontando para clique.
- `text_bubble`: Balão de fala tribal (estilo quadrinho).
- `focus_overlay`: Máscara escura que cobre a tela inteira, exceto o elemento focado (o "buraco" de luz).