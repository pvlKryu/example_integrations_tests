import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study_catalog/keys.dart';
import 'package:study_catalog/utils/money.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  TestAppHandle? app;

  tearDown(() {
    app?.dispose();
    app = null;
  });

  testWidgets('Б. Добавление товара в корзину: товар, количество и сумма',
      (tester) async {
    // --- Подготовка ---
    app = await pumpStudyCatalogApp(tester, scenario: 'success');
    await waitForCatalog(tester);

    // --- Действия ---
    await openProduct(tester, 'p2');
    await addCurrentProductToCart(tester, 'p2');
    await goBackToCatalog(tester);
    await openCart(tester);

    // --- Проверки результата ---
    expect(find.byKey(AppKeys.cartItem('p2')), findsOneWidget);
    // Имя может ещё мелькать в SnackBar — проверяем внутри строки корзины.
    expect(
      find.descendant(
        of: find.byKey(AppKeys.cartItem('p2')),
        matching: find.text('Блокнот для конспектов'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(AppKeys.cartTotal), findsOneWidget);
    expect(find.text('Итого: ${formatPrice(34900)}'), findsOneWidget);
  });

  testWidgets(
      'В. Количество, удаление: пересчёт, пустая корзина, оформление недоступно',
      (tester) async {
    // --- Подготовка ---
    app = await pumpStudyCatalogApp(tester, scenario: 'success');
    await waitForCatalog(tester);
    await openProduct(tester, 'p3');
    await addCurrentProductToCart(tester, 'p3');
    await goBackToCatalog(tester);
    await openCart(tester);

    // --- Действия: увеличить количество ---
    await tester.tap(find.byKey(AppKeys.increase('p3')));
    await tester.pump();

    // --- Проверка пересчёта ---
    expect(find.text('Итого: ${formatPrice(19900 * 2)}'), findsOneWidget);

    // --- Действия: уменьшить и удалить ---
    await tester.tap(find.byKey(AppKeys.decrease('p3')));
    await tester.pump();
    expect(find.text('Итого: ${formatPrice(19900)}'), findsOneWidget);

    await tester.tap(find.byKey(AppKeys.remove('p3')));
    await tester.pump();

    // --- Проверки результата ---
    expect(find.byKey(AppKeys.cartEmpty), findsOneWidget);
    final checkout = tester.widget<FilledButton>(
      find.byKey(AppKeys.checkoutButton),
    );
    expect(checkout.onPressed, isNull);
  });
}
