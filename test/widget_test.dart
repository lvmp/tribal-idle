import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tribal_idle/main.dart';

void main() {
  testWidgets('App smoke test — mounts without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TribalIdleApp()));

    // Verifica que o MaterialApp foi renderizado.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
