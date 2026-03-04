# Tribal Idle: Dawn of Fire

Aqui está a versão consolidada e final do seu **Game Design Document (GDD)**, formatada especificamente para ser copiada e colada no **Notion**.

Este documento une a mecânica de sobrevivência, o sistema de progressão por eras e a interface polida inspirada no *Idle Bank Tycoon*.

---

# 🗿 GDD: Tribal Idle - Dawn of Fire

> **Status:** Versão Final para Implementação (V1.0)
> 
> 
> **Inspiração de UI:** *Idle Bank Tycoon: Money Empire*
> 
> **Modelo de Negócio:** F2P com foco em Rewarded Ads e IAP de conveniência.
> 

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

## 4. Design de Interface (UI/UX) - Estilo "Stone Empire"

O layout segue o padrão isométrico do *Idle Bank Tycoon*:

### A. Estrutura da Tela (HUD)

- **Topo:** Contadores de recursos com ícones grandes e táteis (osso, couro, madeira).
- **Barra de Fogo (Vital):** Uma barra térmica no topo que pulsa conforme o combustível diminui.
- **Zonas de Trabalho:** Áreas delimitadas no mapa (Ex: Posto de Coleta de Berries, Pedreira, Ateliê de Lanças).

### B. Feedback Visual e Sonoro

- **"Juicy" Buttons:** Botões de upgrade que "esmagam" e tremem ao serem clicados.
- **Fluxo de NPCs:** Pequenos homens das cavernas carregando cestas. Quando o nível da zona sobe, eles ficam mais rápidos e os cestas maiores.
- **Sons:** Som seco de pedra batendo em pedra, fogo estalando e um grito tribal festivo quando um upgrade importante ocorre.

---

## 5. Sistema de Gerentes (Personagens)

Inspirado nas cartas do *Idle Bank*, os gerentes são o coração da retenção e monetização.

| **Gerente** | **Tipo** | **Habilidade Passiva** | **Estética** |
| --- | --- | --- | --- |
| **Ugh, o Forte** | Mineração | +25% de Velocidade de Pedra | Brutamontes com clava de osso. |
| **Zola, a Ágil** | Coleta | -15% no Custo de Comida | Caçadora com pele de leopardo. |
| **Xamã Ignis** | Fogo | Dobra a duração da Madeira | Velho com máscara de madeira e cajado. |

---

## 6. Estratégia de Monetização (Ads & IAP)

O jogo é desenhado para o jogador *querer* ver o anúncio para evitar a perda de progresso ou acelerar o ganho.

- **O Mammute de Ouro (Rewarded AD):** Um mamute passa na borda da tela. Se o jogador clicar e ver o AD, ele "caça" o mamute e ganha uma fortuna instantânea.
- **Bênção do Relâmpago:** Assista um vídeo para encher 100% da barra de fogo e ganhar 2x de velocidade por 1 hora.
- **Multiplicador de Ausência:** "Sua tribo trabalhou enquanto você dormia. Assista para triplicar a produção offline!"
- **IAP:** Pacote "Fogo Eterno" (Remove Ads obrigatórios e garante manutenção infinita de lenha).

---

## 7. Roadmap de Implementação (Para IDE de IA)

Para transformar isso em código em ferramentas como Cursor ou Windsurf, use os seguintes módulos:

### Módulo 1: Manager de Recursos (Backend)

> "Crie uma classe `ResourceManager` que controle 'Wood', 'Food' e 'Stone'. Implemente uma função `UpdateTick()` que subtraia `woodConsumption` por segundo. Se `CurrentWood <= 0`, aplique um modificador de `efficiency = 0.1f` globalmente."
> 

### Módulo 2: Sistema de Zonas (Frontend/UI)

> "Desenvolva um sistema de 'WorkZone' inspirado em Idle Bank Tycoon. Cada zona deve ter um nível, um custo de upgrade incremental e um slot para um Gerente que aplique bônus multiplicadores."
> 

### Módulo 3: Integração de Ads

> "Implemente um `AdManager` que dispare um evento de `DoubleProduction` por 60 segundos após a conclusão de um Rewarded Video."
> 

---

## 8. Elementos de Retenção

- **Missões Diárias:** "Cace 50 javalis", "Mantenha o fogo aceso por 1 hora".
- **Árvore de Tecnologia:** Uma pedra gigante com gravuras que o jogador vai "limpando" para desbloquear novas eras.