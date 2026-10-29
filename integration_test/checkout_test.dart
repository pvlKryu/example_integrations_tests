import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study_catalog/keys.dart';
import 'package:study_catalog/utils/money.dart';

import 'helpers/test_app.dart';
import 'helpers/wait_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  TestAppHandle? app;

  tearDown(() {
    app?.dispose();
    app = null;
  });

  testWidgets('Г. Успешное оформление: номер, сумма, корзина очищена',
      (tester) async {
    // --- Подготовка ---
    app = await pumpStudyCatalogApp(tester, scenario: 'success');
    await waitForCatalog(tester);
    await openProduct(tester, 'p1');
    await addCurrentProductToCart(tester, 'p1');
    await goBackToCatalog(tester);
    await openCart(tester);

    // --- Действия ---
    await tester.tap(find.byKey(AppKeys.checkoutButton));
    await tester.pump();

    // Ожидание экрана успеха (HTTP POST /orders).
    await waitFor(
      tester,
      find.byKey(AppKeys.orderSuccess),
      message: 'Экран успешного заказа не появился',
    );

    // --- Проверки результата ---
    expect(find.byKey(AppKeys.orderNumber), findsOneWidget);
    expect(find.textContaining('ORD-0001'), findsOneWidget);
    final orderTotal = tester.widget<Text>(find.byKey(AppKeys.orderTotal));
    expect(orderTotal.data, contains(formatPrice(199900)));

    // Возврат в каталог и проверка, что корзина пуста.
    await tester.tap(find.byKey(AppKeys.backToCatalog));
    await tester.pump();
    await waitForCatalog(tester);
    await openCart(tester);
    expect(find.byKey(AppKeys.cartEmpty), findsOneWidget);
  });
}
