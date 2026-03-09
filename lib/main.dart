import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tribal_idle/infrastructure/persistence/hive_save_service.dart';
import 'package:tribal_idle/presentation/game/tribal_idle_game.dart';
import 'package:tribal_idle/presentation/widgets/hud_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ADR 003: Inicializar Hive antes do runApp
  await HiveSaveService.init();

  runApp(
    // ADR 001: ProviderScope na raiz — habilita Riverpod em toda a árvore
    const ProviderScope(child: TribalIdleApp()),
  );
}

class TribalIdleApp extends ConsumerWidget {
  const TribalIdleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Tribal Idle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1208),
      ),
      home: const _GameScreen(),
    );
  }
}

class _GameScreen extends ConsumerStatefulWidget {
  const _GameScreen();

  @override
  ConsumerState<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<_GameScreen> {
  late final TribalIdleGame _game;

  @override
  void initState() {
    super.initState();
    // Passamos o ProviderContainer para que o FlameGame possa acessar providers
    // fora da árvore de widgets (no game loop).
    _game = TribalIdleGame(container: ProviderScope.containerOf(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<TribalIdleGame>(
        game: _game,
        // ADR 001: Overlays Flutter que reagem ao estado via Riverpod
        overlayBuilderMap: {
          'hud': (ctx, game) => HudOverlay(game: game),
          // TODO: Adicionar conforme o desenvolvimento avança:
          // 'upgrade_menu': (ctx, game) => UpgradeMenu(game: game),
          // 'shop':         (ctx, game) => ShopOverlay(game: game),
          // 'offline':      (ctx, game) => OfflineDialog(game: game),
          // 'rewarded_ad':  (ctx, game) => RewardedAdScreen(game: game),
        },
        initialActiveOverlays: const ['hud'],
        loadingBuilder: (ctx) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      ),
    );
  }
}
