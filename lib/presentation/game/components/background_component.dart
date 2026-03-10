import 'package:flame/components.dart';

/// Camada de background do mundo — renderiza o cenário da clareira.
///
/// Responsabilidades (SOMENTE):
///   - Carregar e exibir `background/background_clareira.png`
///   - Redimensionar para cobrir toda a tela em qualquer resolução
///
/// Prioridade 0 → renderizado antes de qualquer outro componente do World.
class BackgroundComponent extends SpriteComponent {
  BackgroundComponent() : super(priority: -1, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('background/background_clareira.png');
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    position = Vector2.zero();
  }
}
