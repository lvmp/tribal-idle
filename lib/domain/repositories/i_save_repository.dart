/// Interface do repositório de persistência.
///
/// Define o contrato que qualquer implementação de save/load deve seguir.
/// Seguindo o Princípio da Inversão de Dependência (DIP):
/// a camada de domínio depende desta abstração, NÃO do Hive diretamente.
abstract interface class ISaveRepository<T> {
  /// Carrega o estado salvo. Retorna `null` se não houver save.
  Future<T?> load();

  /// Persiste o estado atual.
  Future<void> save(T state);

  /// Remove todos os dados salvos (útil para reset/prestige).
  Future<void> clear();
}
