## ADR 003: Persistence Layer
- **Status:** Aceito
- **Decisão:** Hive (NoSQL) com Serialização JSON.
- **Contexto:** Jogos idle precisam de escrita/leitura frequente e muito rápida. A escolha do Hive visa performance, enquanto a serialização JSON (via `toJson` e `fromJson`) evita conflitos de geração de código entre múltiplos pacotes.

**Justificativa:** Jogos Idle dependem de autosaves frequentes. O Hive oferece performance de leitura/escrita em memória com persistência local em disco. Optamos por usar serialização manual (JSON) em vez de `hive_generator` para garantir que o projeto não sofra com conflitos de versão entre o `source_gen` do Hive e do Riverpod (problema comum no ecossistema Dart 3.x). Isso mantém o ciclo de build simples e a base de código mais flexível para mudanças estruturais no `GameState`.

## Consequências
### Positivas
- **Performance:** Escrita e leitura extremamente rápidas, ideais para o "tick" de um jogo Idle.
- **Offline-First:** O estado local é a fonte da verdade, garantindo que o jogo funcione instantaneamente sem internet.
- **Ciclo de Build Estável:** Sem dependência de `hive_generator` e comandos extras de geração de código para a camada de persistência.

### Negativas
- **Serialização Manual:** Exige a manutenção dos métodos `toJson` e `fromJson` no `GameState`.
- **Schema Migration:** Migrar campos de objetos JSON exige lógica manual de validação durante o `fromJson`.