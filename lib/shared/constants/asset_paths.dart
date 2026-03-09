/// Caminhos de assets centralizados.
///
/// Nunca use strings hardcoded para assets — referencie sempre esta classe.
/// Isso evita erros de digitação e facilita refatorações.
abstract final class AssetPaths {
  // ── Images ──────────────────────────────────────────────────────────
  static const String imagesDir = 'assets/images/';

  // ── Audio ────────────────────────────────────────────────────────────
  static const String audioDir = 'assets/audio/';

  // Exemplos (adicionar conforme os assets forem criados):
  // static const String fireSprite = '${imagesDir}fire_spritesheet.png';
  // static const String bgStage1   = '${imagesDir}background_stage1.png';
  // static const String sfxTick    = '${audioDir}tick.ogg';
}
