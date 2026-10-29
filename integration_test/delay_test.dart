import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study_catalog/keys.dart';

import 'helpers/test_app.dart';
import 'helpers/wait_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  TestAppHandle? app;

  tearDown(() {
    app?.dispose();
    app = null;
  });

  testWidgets(
      'Ж. Задержка ответа: индикатор загрузки, затем каталог в пределах тайм-аута',
      (tester) async {
    // --- Подготовка: управляемая задержка 1.5 с ---
    app = await pumpStudyCatalogApp(
      tester,
      scenario: 'products_delay',
      delayMs: 1500,
    );

    // --- Проверка индикатора (не используем pumpAndSettle) ---
    expect(find.byKey(AppKeys.catalogLoading), findsOneWidget);

    // --- Ожидание каталога helper'ом с ограничением времени ---
    await waitFor(
      tester,
      find.byKey(AppKeys.productCard('p1')),
      timeout: const Duration(seconds: 10),
      message: 'Каталог не появился после управляемой задержки',
    );

    await waitUntilGone(
      tester,
      find.byKey(AppKeys.catalogLoading),
      message: 'Индикатор загрузки не исчез',
    );
  });
}
