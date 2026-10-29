# Сценарий демонстрации (20–25 минут)

Цель: показать интерфейс, объяснить код интеграционного теста
и запустить проверки на iOS Simulator.

Перед занятием:

1. `flutter pub get`
2. В отдельном терминале (dart из Flutter SDK):
   `"$(dirname "$(which flutter)")/cache/dart-sdk/bin/dart" run tool/stub_server.dart`
3. `curl http://127.0.0.1:8080/health` — убедиться, что стаб жив
4. Запустить симулятор (например iPhone 16 Pro)

---

## 1. Вручную показать каталог, карточку и корзину (4–5 мин)

**Файл:** `lib/screens/catalog_screen.dart` (и соседние экраны)

**Команда:**

```bash
flutter run -d "iPhone 16 Pro" \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

**Показать студентам:**

- список из 5 товаров и цены;
- переход в карточку (название, описание, «Добавить в корзину»);
- корзину со счётчиком, изменением количества и итогом;
- оформление заказа и экран с номером `ORD-0001`.

**Ожидаемый результат:** приложение ходит к стабу, заказ успешен, корзина очищается.

---

## 2. Открыть один простой интеграционный тест (2 мин)

**Файл:** `integration_test/catalog_test.dart`

**Команда:** не запускать пока — только чтение кода.

**Показать студентам:**

- название теста;
- блоки «Подготовка / Действия / Проверки»;
- вызов `pumpStudyCatalogApp` и `waitForCatalog`.

**Ожидаемый результат:** студенты видят структуру одного короткого кейса.

---

## 3. Объяснить binding, tester, Finder, ожидание и expect (5–6 мин)

**Файлы:**

- `integration_test/catalog_test.dart`
- `integration_test/helpers/test_app.dart`
- `integration_test/helpers/wait_helpers.dart`
- `lib/keys.dart`

**Команда:** нет.

**Показать студентам:**

| Понятие | Где смотреть | Зачем |
|---------|--------------|-------|
| Binding | `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` | Связка тест ↔ устройство |
| tester | параметр `testWidgets` | pump, tap, widget |
| Finder | `find.byKey(AppKeys....)` | стабильный поиск UI |
| Ожидание | `waitFor` / `waitUntil` | HTTP без `pumpAndSettle` |
| expect | проверки после действий | фиксируем результат, не «не упало» |
| Очистка | `tearDown` → `app.dispose()` | изоляция тестов |

**Ожидаемый результат:** понятна разница между unit/widget и интеграционным тестом
(настоящий HTTP + UI на устройстве).

---

## 4. Запустить простой тест на симуляторе (3 мин)

**Файл:** `integration_test/catalog_test.dart`

**Команда:**

```bash
flutter test integration_test/catalog_test.dart \
  -d "iPhone 16 Pro" \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

**Показать студентам:** установку приложения на симулятор и зелёный отчёт в терминале.

**Ожидаемый результат:** `All tests passed!` (1 тест).

---

## 5. Показать тест ошибки и повтора (3–4 мин)

**Файл:** `integration_test/error_test.dart` (тест «Д»)

**Команда:**

```bash
flutter test integration_test/error_test.dart \
  -d "iPhone 16 Pro" \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080 \
  --name "Ошибка загрузки"
```

**Показать студентам:**

- сценарий `products_fail_once` в `tool/stub_server.dart`;
- ключи `catalog-error`, `retry-button`;
- что после «Повторить» товары появляются, ошибка исчезает.

**Ожидаемый результат:** тест «Д» зелёный; при желании сразу прогнать и «Е».

---

## 6. Управляемая задержка и helper ожидания (3 мин)

**Файлы:**

- `integration_test/delay_test.dart`
- `integration_test/helpers/wait_helpers.dart`

**Команда:**

```bash
flutter test integration_test/delay_test.dart \
  -d "iPhone 16 Pro" \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

**Показать студентам:**

- почему `pumpAndSettle` опасен при бесконечном лоадере;
- `waitFor` с `timeout` и понятным `message` при падении;
- индикатор `catalog-loading` до появления товаров.

**Ожидаемый результат:** тест «Ж» проходит за несколько секунд.

---

## 7. Запустить набор и объяснить изоляцию (3–4 мин)

**Файлы:** `integration_test/helpers/test_app.dart`, весь каталог `integration_test/`

**Команда:**

```bash
flutter test integration_test \
  -d "iPhone 16 Pro" \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

**Показать студентам:**

- перед каждым тестом `POST /test/reset` + новый `AppDependencies`;
- нет singleton, на который «надеется» следующий кейс;
- каждый тест проходит отдельно и в наборе.

**Ожидаемый результат:** все интеграционные тесты зелёные.

---

## Таблица: тест → что проверяет → какие зависимости настоящие

| Тест | Что проверяет | Настоящие зависимости |
|------|---------------|------------------------|
| А. Каталог и карточка | Загрузка списка, UI карточки | HTTP GET `/products`, UI |
| Б. Добавление в корзину | Товар, qty, сумма в корзине | HTTP + состояние корзины + UI |
| В. Количество и удаление | Пересчёт, empty, disabled checkout | UI + CartState (без нового HTTP) |
| Г. Успешный заказ | ORD-номер, сумма, очистка корзины | HTTP POST `/orders` + UI |
| Д. Ошибка и повтор | 500 → retry → успех | HTTP (сценарий fail_once) + UI |
| Е. Ошибка оформления | Ошибка, корзина жива, кнопка активна | HTTP (order_error) + UI |
| Ж. Задержка | Лоадер, затем каталог по timeout | HTTP (products_delay) + helper |
| Unit CartState | Логика корзины | Нет сети |
| Widget checkout disabled | Кнопка null при empty | Нет сети |

---

## Запасные команды

Unit/widget без устройства:

```bash
flutter test test/
flutter analyze
```
