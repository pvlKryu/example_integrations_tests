import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_catalog/api/api_client.dart';
import 'package:study_catalog/app.dart';
import 'package:study_catalog/config.dart';
import 'package:study_catalog/keys.dart';
import 'package:study_catalog/state/cart_state.dart';

import 'wait_helpers.dart';

/// Подготовка приложения для одного интеграционного теста.
///
/// Важно: не полагаемся на повторный вызов main() для очистки singleton.
/// На каждый тест создаём новые ApiClient и CartState, сбрасываем стаб.
class TestAppHandle {
  TestAppHandle({
    required this.dependencies,
  });

  final AppDependencies dependencies;

  ApiClient get apiClient => dependencies.apiClient;
  CartState get cartState => dependencies.cartState;

  /// Освобождение ресурсов после теста.
  void dispose() {
    dependencies.dispose();
  }
}

Future<TestAppHandle> pumpStudyCatalogApp(
  WidgetTester tester, {
  String scenario = 'success',
  int? delayMs,
}) async {
  // 1. Сбрасываем учебный стаб и выбираем сценарий.
  final setupClient = ApiClient(baseUrl: AppConfig.apiBaseUrl);
  try {
    await setupClient.resetStub(scenario: scenario, delayMs: delayMs);
  } finally {
    setupClient.close();
  }

  // 2. Новое состояние приложения и корзины на каждый тест.
  // Сохранённых данных нет (корзина только в памяти) — очищать нечего.
  final dependencies = AppDependencies(
    apiClient: ApiClient(baseUrl: AppConfig.apiBaseUrl),
    cartState: CartState(),
  );

  await tester.pumpWidget(
    StudyCatalogApp(dependencies: dependencies),
  );
  // Первый кадр после запуска.
  await tester.pump();

  return TestAppHandle(dependencies: dependencies);
}

Finder catalogLoadedFinder() => find.byKey(AppKeys.productCard('p1'));

Future<void> waitForCatalog(WidgetTester tester) async {
  await waitFor(
    tester,
    catalogLoadedFinder(),
    message: 'Каталог не загрузился: товар p1 не появился',
  );
}

Future<void> openProduct(WidgetTester tester, String productId) async {
  await tester.tap(find.byKey(AppKeys.productCard(productId)));
  await tester.pump();
  await waitFor(
    tester,
    find.byKey(AppKeys.productDetailScreen),
    message: 'Экран карточки товара не открылся',
  );
}

Future<void> addCurrentProductToCart(
  WidgetTester tester,
  String productId,
) async {
  await tester.tap(find.byKey(AppKeys.addToCart(productId)));
  await tester.pump();
  await waitFor(
    tester,
    find.byKey(AppKeys.addConfirmation),
    message: 'Подтверждение добавления в корзину не появилось',
  );
  // SnackBar внизу перекрывает кнопки корзины/оформления — ждём исчезновения.
  await waitUntilGone(
    tester,
    find.byKey(AppKeys.addConfirmation),
    timeout: const Duration(seconds: 5),
    message: 'SnackBar подтверждения не исчез',
  );
}

/// Возврат с карточки в каталог.
///
/// Нельзя тапать `cart-button` «вслепую»: Finder находит кнопку на
/// предыдущем маршруте (offstage), а hit-test не проходит.
/// Дождаться завершения анимации маршрута.
/// Это не замена waitFor для HTTP — только короткий «дожим» перехода.
Future<void> settleRouteTransition(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> goBackToCatalog(WidgetTester tester) async {
  final back = find.byType(BackButton);
  expect(back, findsOneWidget, reason: 'На карточке товара нет кнопки «Назад»');
  await tester.tap(back);
  await tester.pump();
  await waitUntilGone(
    tester,
    find.byKey(AppKeys.productDetailScreen),
    message: 'Экран карточки не закрылся после возврата',
  );
  await waitFor(
    tester,
    find.byKey(AppKeys.catalogScreen),
    message: 'Каталог не стал верхним экраном',
  );
  await settleRouteTransition(tester);
}

Future<void> openCart(WidgetTester tester) async {
  // Только hit-testable виджет — иначе тап попадёт в offstage-кнопку под маршрутом.
  final cartButton = find.byKey(AppKeys.cartButton).hitTestable();
  await waitFor(
    tester,
    cartButton,
    message: 'Кнопка корзины недоступна для нажатия (экран перекрыт?)',
  );
  await tester.tap(cartButton);
  await tester.pump();
  await waitFor(
    tester,
    find.byKey(AppKeys.cartScreen),
    message: 'Экран корзины не открылся',
  );
  await settleRouteTransition(tester);
}
