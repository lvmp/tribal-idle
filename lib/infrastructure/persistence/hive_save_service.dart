import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:tribal_idle/domain/models/game_state.dart';
import 'package:tribal_idle/domain/repositories/i_save_repository.dart';

/// Implementação de [ISaveRepository] usando Hive (ADR 003).
///
/// O estado do jogo é serializado como JSON e armazenado em uma [Box] do Hive.
/// Isso permite escrita em O(1) e leitura instantânea na inicialização.
class HiveSaveService implements ISaveRepository<GameState> {
  static const String _boxName = 'game_save';
  static const String _saveKey = 'state';

  final Logger _log = Logger();

  Box? _box;

  /// Inicializa o Hive e abre a box de salvamento.
  /// Deve ser chamado em [main()] antes de [runApp()].
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Box get _openBox {
    _box ??= Hive.box(_boxName);
    return _box!;
  }

  @override
  Future<GameState?> load() async {
    try {
      final raw = _openBox.get(_saveKey) as String?;
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _log.i('[SaveService] Estado carregado com sucesso.');
      return GameState.fromJson(json);
    } catch (e, st) {
      _log.e(
        '[SaveService] Erro ao carregar estado.',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  @override
  Future<void> save(GameState state) async {
    try {
      state.lastSavedAt = DateTime.now();
      final raw = jsonEncode(state.toJson());
      await _openBox.put(_saveKey, raw);
      _log.d(
        '[SaveService] Estado salvo: wood=${state.wood.toStringAsFixed(1)}',
      );
    } catch (e, st) {
      _log.e('[SaveService] Erro ao salvar estado.', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> clear() async {
    await _openBox.clear();
    _log.w('[SaveService] Save deletado (reset/prestige).');
  }

  /// Carrega o estado salvo ou cria um novo estado inicial.
  Future<GameState> loadOrCreate() async {
    final saved = await load();
    if (saved == null) {
      _log.i('[SaveService] Nenhum save encontrado. Iniciando novo jogo.');
      return GameState();
    }
    // Aplica ganhos offline automaticamente
    saved.applyOfflineEarnings(DateTime.now());
    return saved;
  }
}
