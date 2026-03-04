## ADR 003: Game engine
- **Status:** Aceito
- **Decisão:** Flame como Engine base.
- **Contexto:** Flame sobre Flutter permite aproveitar plugins nativos de Ads e monetização de forma muito mais estável do que engines externas portadas para mobile.

**Justificativa:** O objetivo é a entrega rápida (Time-to-Market) sem troca de contexto de linguagem. Como a equipe já domina Dart, usar Flame elimina a curva de aprendizado de engines externas (Unity/Godot). A escolha permite que o código de regras de negócio (Idle math) seja 100% compartilhado entre a UI Flutter e o Game Engine, reduzindo drasticamente o esforço de sincronização de dados. A performance de renderização 2D do Flame é mais do que suficiente para o gênero Idle.

## Consequências
### Positivas
- **Unificação de Stack:** Todo o código é em Dart, permitindo compartilhamento de modelos e lógica entre Flutter e Flame.
- **Plugins:** Acesso direto a quase todo o ecossistema de pacotes do Flutter (Firebase, Local Auth, Google Ads).

### Negativas
- **Ecossistema:** Embora crescente, o ecossistema de assets e ferramentas visuais é menor do que Unity ou Godot.
- **Performance Visual:** Jogos com altíssima densidade gráfica 2D ou 3D complexo podem encontrar limites de performance mais cedo do que em engines nativas (C++/C#).