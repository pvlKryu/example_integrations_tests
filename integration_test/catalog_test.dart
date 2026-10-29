import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study_catalog/keys.dart';
import 'package:study_catalog/utils/money.dart';

import 'helpers/test_app.dart';

void main() {
  // Инициализация binding для интеграционных тестов.
  // Должна быть до любых вызовов tester / pumpWidget.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  TestAppHandle? app;

  tearDown(() {
    // Очистка состояния и закрытие HTTP-клиента после каждого теста.
    app?.dispose();
    app = null;
  });

  testWidgets('А. Каталог загружается, карточка показывает название и цену',
      (tester) async {
    // --- Подготовка ---
    app = await pumpStudyCatalogApp(tester, scenario: 'success');

    // --- Действия ---
    // Дождаться загрузки каталога (настоящий HTTP к стабу).
    await waitForCatalog(tester);
    await openProduct(tester, 'p1');

    // --- Проверки результата ---
    // Поиск по стабильному ValueKey, а не по тексту вслепую.
    expect(find.byKey(AppKeys.productDetailName), findsOneWidget);
    expect(find.text('Учебник Flutter'), findsWidgets);
    expect(
      find.text(formatPrice(199900)),
      findsWidgets,
    );
  });
}
