# Учебный каталог — интеграционные тесты

Небольшой Flutter-магазин для занятия «Интеграционные тесты».
Приложение ходит настоящими HTTP-запросами к локальному Dart-стабу.

Основная платформа демонстрации: **iOS Simulator**.

## Требования

- Flutter SDK (проверено на 3.38.x)
- Xcode + iOS Simulator
- macOS

## Установка зависимостей

```bash
flutter pub get
```

## HTTP-стаб

Стаб слушает `0.0.0.0:8080` (доступен с симулятора и с эмулятора).

```bash
# Важно: используйте dart из Flutter SDK (не Homebrew dart 3.4).
"$(dirname "$(which flutter)")/cache/dart-sdk/bin/dart" run tool/stub_server.dart
```

Если настроен FVM:

```bash
fvm dart run tool/stub_server.dart
```

Проверка здоровья:

```bash
curl http://127.0.0.1:8080/health
```

Ожидаемый ответ содержит `"status":"ok"`.

### Endpoints

| Метод | Путь | Назначение |
|-------|------|------------|
| GET | `/health` | Статус стаба |
| GET | `/products` | Каталог |
| POST | `/orders` | Оформление заказа |
| POST | `/test/reset` | Сброс + выбор сценария (только тесты) |

Сценарии: `success`, `products_fail_once`, `products_delay`, `empty_catalog`, `order_error`.

Пример сброса:

```bash
curl -X POST http://127.0.0.1:8080/test/reset \
  -H 'Content-Type: application/json' \
  -d '{"scenario":"success"}'
```

## Адрес API (`API_BASE_URL`)

Передаётся через `--dart-define=API_BASE_URL=...`.

| Среда | Адрес | Комментарий |
|-------|-------|-------------|
| iOS Simulator | `http://127.0.0.1:8080` | localhost симулятора = хост Mac |
| macOS desktop | `http://127.0.0.1:8080` | тот же хост |
| Android Emulator | `http://10.0.2.2:8080` | спец. адрес хост-машины |
| Реальный телефон | `http://<IP_Mac>:8080` | телефон и Mac в одной Wi‑Fi сети |

Узнать IP Mac:

```bash
ipconfig getifaddr en0
```

На реальном телефоне **не** используйте `localhost` / `127.0.0.1` —
это адрес самого телефона, а не компьютера со стабом.

Стаб по умолчанию биндится на `0.0.0.0`, чтобы принимать запросы
с эмулятора и с устройства в локальной сети.

Cleartext HTTP разрешён для учебной debug-сборки (iOS ATS local networking,
Android `usesCleartextTraffic` в debug).

## Запуск приложения

Список устройств:

```bash
flutter devices
```

iOS Simulator (типичный демо-запуск):

```bash
flutter run -d "iPhone 16 Pro" \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

Android Emulator (если доступен):

```bash
flutter run -d emulator-5554 \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Реальный iPhone (подставьте IP Mac):

```bash
flutter run -d <device_id> \
  --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

## Интеграционные тесты

Стаб должен быть запущен в отдельном терминале.

Один тест (пример — каталог и карточка):

```bash
flutter test integration_test/catalog_test.dart \
  -d "iPhone 16 Pro" \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

Весь набор:

```bash
flutter test integration_test \
  -d "iPhone 16 Pro" \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

Файлы:

| Файл | Сценарии |
|------|----------|
| `integration_test/catalog_test.dart` | А. Каталог и карточка |
| `integration_test/cart_test.dart` | Б. Добавление; В. Количество и удаление |
| `integration_test/checkout_test.dart` | Г. Успешное оформление |
| `integration_test/error_test.dart` | Д. Ошибка загрузки; Е. Ошибка оформления |
| `integration_test/delay_test.dart` | Ж. Задержка ответа |

Helpers: `integration_test/helpers/`.

## Unit / widget-тесты

```bash
flutter test test/
```

## Анализ

```bash
flutter analyze
```

## Структура `lib/`

```
lib/
  main.dart              — точка входа
  app.dart               — StudyCatalogApp + AppDependencies
  config.dart            — API_BASE_URL
  keys.dart              — ValueKey для тестов
  api/                   — HTTP-клиент
  models/                — Product, CartItem, Order
  state/cart_state.dart  — корзина
  screens/               — каталог, карточка, корзина, результат
  utils/money.dart       — формат цен (копейки → рубли)
```

## Первый файл на занятии

Откройте `integration_test/catalog_test.dart` — самый короткий сквозной пример.
