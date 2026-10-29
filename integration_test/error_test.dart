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

  testWidgets(
      'Д. Ошибка загрузки каталога и повтор: ошибка → Повторить → товары',
      (tester) async {
    // --- Подготовка: первый GET /products вернёт 500 ---
    app = await pumpStudyCatalogApp(tester, scenario: 'products_fail_once');

    // --- Проверка экрана ошибки ---
    await waitFor(
      tester,
      find.byKey(AppKeys.catalogError),
      message: 'Экран ошибки каталога не появился',
    );
    expect(find.byKey(AppKeys.retryButton), findsOneWidget);
    expect(find.byKey(AppKeys.productCard('p1')), findsNothing);

    // --- Действия: нажать «Повторить» ---
    await tester.tap(find.byKey(AppKeys.retryButton));
    await tester.pump();

    // --- Проверки: товары появились, ошибка исчезла ---
    await waitForCatalog(tester);
    await waitUntilGone(
      tester,
      find.byKey(AppKeys.catalogError),
      message: 'Сообщение об ошибке не исчезло после повтора',
    );
  });

  testWidgets(
      'Е. Ошибка оформления: сообщение, корзина сохранена, можно повторить',
      (tester) async {
    // --- Подготовка ---
    app = await pumpStudyCatalogApp(tester, scenario: 'order_error');
    await waitForCatalog(tester);
    await openProduct(tester, 'p4');
    await addCurrentProductToCart(tester, 'p4');
    await goBackToCatalog(tester);
    await openCart(tester);

    // --- Действия ---
    await tester.tap(find.byKey(AppKeys.checkoutButton));
    await tester.pump();

    await waitFor(
      tester,
      find.byKey(AppKeys.checkoutError),
      message: 'Сообщение об ошибке оформления не появилось',
    );

    // --- Проверки результата ---
    expect(find.text('Не удалось оформить заказ'), findsOneWidget);
    // Корзина сохранилась.
    expect(find.byKey(AppKeys.cartItem('p4')), findsOneWidget);
    expect(find.text('Итого: ${formatPrice(89900)}'), findsOneWidget);
    // Можно повторить действие — кнопка снова доступна.
    final checkout = tester.widget<FilledButton>(
      find.byKey(AppKeys.checkoutButton),
    );
    expect(checkout.onPressed, isNotNull);
  });
}
