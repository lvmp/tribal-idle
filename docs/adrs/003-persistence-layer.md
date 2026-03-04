## ADR 002: Persistence Layer
- **Status:** Aceito
- **Decisão:** Hive (NoSQL).
- **Contexto:** Jogos idle precisam de escrita/leitura frequente e muito rápida. SQLite (Sqflite) é muito verboso e pesado para um jogo simples. Hive é ideal para serialização rápida de objetos de estado.

**Justificativa:** Jogos Idle dependem de autosaves frequentes para garantir que o progresso do usuário não seja perdido em caso de encerramento abrupto do app. Bancos relacionais (como SQLite) adicionam overhead de escrita e serialização que não se justificam nesta fase. O Hive oferece performance de leitura/escrita em memória com persistência local em disco, funcionando como um cache persistente. Isso permite que a lógica de salvamento seja apenas uma chamada simples de box.put(), mantendo o código limpo e extremamente performático.

## Consequências
### Positivas
- **Performance:** Escrita e leitura extremamente rápidas, ideais para o "tick" de um jogo Idle.
- **Offline-First:** O estado local é a fonte da verdade, garantindo que o jogo funcione instantaneamente sem internet.

### Negativas
- **Limitação de Queries:** Não possui suporte a `JOINs` ou consultas SQL complexas. Se precisarmos de relatórios avançados de dados, teremos que processá-los na aplicação.
- **Schema Migration:** Migrar campos de objetos Hive (quando o jogo atualizar e o modelo mudar) exige cuidado manual com `TypeAdapters`.