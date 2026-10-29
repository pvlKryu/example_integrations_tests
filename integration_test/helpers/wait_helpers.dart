import 'package:flutter_test/flutter_test.dart';

/// Ожидание условия без pumpAndSettle.
///
/// pumpAndSettle не подходит как универсальное ожидание HTTP:
/// при бесконечном индикаторе загрузки он «зависнет» навсегда.
/// Здесь мы явно крутим кадры с шагом [step] до [timeout].
Future<void> waitUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 15),
  Duration step = const Duration(milliseconds: 100),
  String message = 'Условие не выполнено за отведённое время',
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (condition()) {
      return;
    }
  }
  fail(message);
}

/// Ожидание появления виджета по Finder.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
  String? message,
}) async {
  await waitUntil(
    tester,
    () => finder.evaluate().isNotEmpty,
    timeout: timeout,
    message: message ?? 'Виджет не найден: $finder',
  );
}

/// Ожидание исчезновения виджета по Finder.
Future<void> waitUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
  String? message,
}) async {
  await waitUntil(
    tester,
    () => finder.evaluate().isEmpty,
    timeout: timeout,
    message: message ?? 'Виджет всё ещё на экране: $finder',
  );
}
