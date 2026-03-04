## ADR 001: State Management
- **Status:** Aceito
- **Decisão:** Riverpod.
- **Contexto:** Precisamos de um sistema reativo que funcione tanto dentro da árvore de widgets quanto fora dela (para o Game Loop). Riverpod permite "ref providers" que são ideais para injetar dependências no Flame.

**Justificativa:** No estágio inicial do projeto, precisamos de uma "Single Source of Truth" que opere fora da árvore de Widgets do Flutter. O Flame roda seu próprio game loop e não entende o BuildContext. Riverpod, através do ProviderContainer, permite acessar estados de maneira global e tipada, servindo como uma ponte (DI container) perfeita para injetar dados do domínio diretamente nas entidades do jogo. Evitamos ChangeNotifier ou Provider clássicos para prevenir erros de rebuild desnecessários no loop de renderização.

## Consequências
### Positivas
- **Desacoplamento:** A lógica de negócio reside fora da árvore de widgets, facilitando testes unitários.
- **Performance:** Evita rebuilds desnecessários na árvore de widgets, algo crítico quando o Flame está rodando.
- **Injeção de Dependência:** Facilita muito a passagem de serviços (como o Hive ou Logger) para dentro do Game Engine.

### Negativas
- **Complexidade Inicial:** Existe uma curva de aprendizado para entender `ref`, `Provider`, `StateNotifier` vs `Notifier`.
- **Complexidade em Provedores Aninhados:** Se não houver cuidado, a árvore de provedores pode se tornar difícil de rastrear (o chamado "provider hell").