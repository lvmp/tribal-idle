## ADR 001: State Management
- **Status:** Aceito
- **Decisão:** Riverpod 3.0 (Notifier API).
- **Contexto:** Precisamos de um sistema reativo que funcione tanto dentro da árvore de widgets quanto fora dela (para o Game Loop). Riverpod permite "ref providers" que são ideais para injetar dependências no Flame.

**Justificativa:** No estágio inicial do projeto, precisamos de uma "Single Source of Truth" que opere fora da árvore de Widgets do Flutter. O Flame roda seu próprio game loop e não entende o BuildContext. Riverpod 3.0, através do `Notifier` e do `ProviderContainer`, permite acessar estados de maneira global e tipada, servindo como uma ponte (DI container) perfeita para injetar dados do domínio diretamente nas entidades do jogo. A migração para a API de `Notifier` reduz o boilerplate e garante compatibilidade total com as novas diretrizes do Dart 3.11+.

## Consequências
### Positivas
- **Desacoplamento:** A lógica de negócio reside fora da árvore de widgets, facilitando testes unitários.
- **Performance:** Evita rebuilds desnecessários na árvore de widgets, algo crítico quando o Flame está rodando.
- **Injeção de Dependência:** Facilita muito a passagem de serviços (como o Hive ou Logger) para dentro do Game Engine via `ref`.

### Negativas
- **Complexidade Inicial:** Existe uma curva de aprendizado para entender `ref`, `Provider` e a nova API de `Notifier`.
- **Complexidade em Provedores Aninhados:** Se não houver cuidado, a árvore de provedores pode se tornar difícil de rastrear.