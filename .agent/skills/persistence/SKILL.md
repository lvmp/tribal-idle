---
name: persistence
description: "Game save/load: JSON serialization, autosave, offline earnings, cloud sync, data integrity."
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Persistence — Save/Load System

> Em um jogo idle, o save é **sagrado**. Se o save corromper, o jogador perde tudo e nunca mais volta.

---

## 1. Princípios Fundamentais

| Princípio | Motivo |
|-----------|--------|
| **Autosave periódico** | Proteger contra crash e battery die |
| **Save ao sair** | Capturar último estado no `AppLifecycleState.paused` |
| **Serialização rigorosa** | JSON com validação de schema |
| **Backup local** | Manter versão anterior antes de sobrescrever |
| **Cloud sync** | Firebase/Play Games Services para backup cross-device |

---

## 2. Arquitetura de Persistência

### Separação de Responsabilidades

```
Domain Layer         →  GameState (dados puros)
                          ↓
Serialization Layer  →  GameData.toJson() / fromJson()
                          ↓
Storage Layer        →  Hive / SharedPreferences / File
                          ↓
Cloud Layer          →  Firebase Firestore / Play Games
```

### Classe GameData

```dart
class GameData {
  final Map<String, double> resources;
  final Map<String, int> zoneLevels;
  final List<String> unlockedManagers;
  final int prestigeCount;
  final double prestigeCurrency;
  final DateTime lastSaveTime;
  final int version; // Para migrações futuras

  Map<String, dynamic> toJson() => {
    'resources': resources,
    'zoneLevels': zoneLevels,
    'unlockedManagers': unlockedManagers,
    'prestigeCount': prestigeCount,
    'prestigeCurrency': prestigeCurrency,
    'lastSaveTime': lastSaveTime.toIso8601String(),
    'version': version,
  };

  factory GameData.fromJson(Map<String, dynamic> json) {
    // Validação + migração de versão
    final version = json['version'] as int? ?? 1;
    return GameData(
      resources: Map<String, double>.from(json['resources'] ?? {}),
      zoneLevels: Map<String, int>.from(json['zoneLevels'] ?? {}),
      // ... com valores default para campos faltantes
      version: version,
    );
  }
}
```

---

## 3. Estratégia de Autosave

### Intervalos

| Evento | Ação |
|--------|------|
| **A cada 30 segundos** | Autosave silencioso |
| **Ao ir para background** | Save imediato (`AppLifecycleState.paused`) |
| **Após compra IAP** | Save imediato (proteger transação) |
| **Após prestige** | Save imediato |
| **Ao ver rewarded ad** | Save antes e depois |

### Implementação

```dart
class SaveService {
  Timer? _autosaveTimer;
  
  void startAutosave(GameState state) {
    _autosaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => save(state),
    );
  }
  
  Future<void> save(GameState state) async {
    final data = state.toGameData();
    final json = jsonEncode(data.toJson());
    
    // 1. Backup do save anterior
    await _backupPreviousSave();
    
    // 2. Salvar novo estado
    await _storage.write('game_save', json);
    
    // 3. Atualizar timestamp
    state.lastSaveTime = DateTime.now();
  }
}
```

---

## 4. Offline Earnings

### Cálculo ao Retornar

```dart
void calculateOfflineEarnings(GameData savedData) {
  final now = DateTime.now();
  final elapsed = now.difference(savedData.lastSaveTime);
  
  // Cap máximo de 8 horas
  final cappedSeconds = min(elapsed.inSeconds, 8 * 3600);
  
  // Eficiência offline: 50% do normal
  final offlineEfficiency = 0.5;
  
  final earnings = savedData.earningsPerSecond 
      * cappedSeconds 
      * offlineEfficiency;
  
  // Opção de triplicar com ad
  showOfflineEarningsDialog(
    baseEarnings: earnings,
    onWatchAd: () => applyEarnings(earnings * 3),
    onSkip: () => applyEarnings(earnings),
  );
}
```

---

## 5. Cloud Sync

### Estratégia de Conflito

| Cenário | Resolução |
|---------|-----------|
| Local mais recente | Usar local |
| Cloud mais recente | Usar cloud |
| Ambos recentes | Perguntar ao jogador |
| Sem internet | Usar local, sync depois |

### Princípios

- **Sync assíncrono** (não bloquear gameplay)
- **Retry com backoff** em caso de falha
- **Timestamp de cada save** para resolver conflitos
- **Compressão** dos dados antes de enviar

---

## 6. Migração de Dados

### Versionamento

```dart
GameData migrateData(Map<String, dynamic> json) {
  int version = json['version'] as int? ?? 1;
  
  // Migração incremental
  if (version < 2) json = _migrateV1toV2(json);
  if (version < 3) json = _migrateV2toV3(json);
  
  return GameData.fromJson(json);
}
```

### Regras

- Nunca deletar campos — apenas deprecate
- Valores default para campos novos
- Testar migração com saves antigos
- Log de versão do save para debugging

---

## 7. Anti-Patterns

| ❌ Don't | ✅ Do |
|----------|-------|
| Salvar apenas ao fechar app | Autosave periódico |
| Sem backup do save anterior | Manter backup antes de sobrescrever |
| Ignorar versão dos dados | Versionamento + migração |
| Confiar em `DateTime.now()` para offline | Validar contra server time |
| Save síncrono que trava UI | Save assíncrono em isolate |
| Guardar estado derivado | Salvar apenas dados base |

---

> **Remember:** O save é a promessa mais importante que você faz ao jogador. Quebre-a e ele nunca volta.