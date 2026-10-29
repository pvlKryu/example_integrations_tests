// Учебный HTTP-стаб для интеграционных тестов.
// Запуск: dart run tool/stub_server.dart
//
// Endpoints:
//   GET  /health
//   GET  /products
//   POST /orders
//   POST /test/reset   — сброс + выбор сценария (только для тестов)

import 'dart:convert';
import 'dart:io';

const int port = 8080;

/// Предсказуемый каталог из 5 товаров. Цены в копейках.
const List<Map<String, dynamic>> catalog = [
  {
    'id': 'p1',
    'name': 'Учебник Flutter',
    'description': 'Практическое введение в Flutter для начинающих.',
    'priceKopecks': 199900,
  },
  {
    'id': 'p2',
    'name': 'Блокнот для конспектов',
    'description': 'В клетку, 96 листов, твёрдая обложка.',
    'priceKopecks': 34900,
  },
  {
    'id': 'p3',
    'name': 'Набор стикеров',
    'description': 'Стикеры с терминальными командами.',
    'priceKopecks': 19900,
  },
  {
    'id': 'p4',
    'name': 'Термокружка OTUS',
    'description': 'Металлическая кружка 0.4 л.',
    'priceKopecks': 89900,
  },
  {
    'id': 'p5',
    'name': 'Футболка «Код работает»',
    'description': 'Хлопок, размер M.',
    'priceKopecks': 149900,
  },
];

String scenario = 'success';
int delayMs = 2500;
int productsRequestCount = 0;
int orderSequence = 0;
final List<Map<String, dynamic>> orders = [];

void resetState({String nextScenario = 'success', int? nextDelayMs}) {
  scenario = nextScenario;
  delayMs = nextDelayMs ?? 2500;
  productsRequestCount = 0;
  orderSequence = 0;
  orders.clear();
}

Future<void> main(List<String> args) async {
  final host = args.isNotEmpty ? args.first : '0.0.0.0';
  final server = await HttpServer.bind(host, port);
  stdout.writeln('Stub server listening on http://$host:$port');
  stdout.writeln('Scenarios: success, products_fail_once, products_delay, '
      'empty_catalog, order_error');

  await for (final request in server) {
    // CORS не нужен для мобильного приложения, но удобно для curl/браузера.
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set(
      'Access-Control-Allow-Methods',
      'GET, POST, OPTIONS',
    );
    request.response.headers.set(
      'Access-Control-Allow-Headers',
      'Content-Type',
    );

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    try {
      await _handle(request);
    } catch (e, st) {
      stderr.writeln('Error: $e\n$st');
      request.response.statusCode = HttpStatus.internalServerError;
      _json(request.response, {'error': 'internal'});
      await request.response.close();
    }
  }
}

Future<void> _handle(HttpRequest request) async {
  final path = request.uri.path;

  if (request.method == 'GET' && path == '/health') {
    _json(request.response, {
      'status': 'ok',
      'scenario': scenario,
      'productsRequestCount': productsRequestCount,
      'ordersCount': orders.length,
    });
    await request.response.close();
    return;
  }

  if (request.method == 'POST' && path == '/test/reset') {
    final body = await _readJson(request);
    final nextScenario = (body['scenario'] as String?) ?? 'success';
    final nextDelay = body['delayMs'] as int?;
    resetState(nextScenario: nextScenario, nextDelayMs: nextDelay);
    _json(request.response, {
      'ok': true,
      'scenario': scenario,
      'delayMs': delayMs,
    });
    await request.response.close();
    return;
  }

  if (request.method == 'GET' && path == '/products') {
    productsRequestCount += 1;

    if (scenario == 'products_fail_once' && productsRequestCount == 1) {
      request.response.statusCode = HttpStatus.internalServerError;
      _json(request.response, {'error': 'products_unavailable'});
      await request.response.close();
      return;
    }

    if (scenario == 'products_delay') {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }

    final items =
        scenario == 'empty_catalog' ? <Map<String, dynamic>>[] : catalog;
    _json(request.response, {'items': items});
    await request.response.close();
    return;
  }

  if (request.method == 'POST' && path == '/orders') {
    if (scenario == 'order_error') {
      request.response.statusCode = HttpStatus.internalServerError;
      _json(request.response, {'error': 'order_failed'});
      await request.response.close();
      return;
    }

    final body = await _readJson(request);
    orderSequence += 1;
    final orderNumber = 'ORD-${orderSequence.toString().padLeft(4, '0')}';
    final totalKopecks = body['totalKopecks'] as int? ?? 0;
    final order = {
      'orderNumber': orderNumber,
      'totalKopecks': totalKopecks,
      'items': body['items'] ?? [],
    };
    orders.add(order);
    request.response.statusCode = HttpStatus.created;
    _json(request.response, order);
    await request.response.close();
    return;
  }

  request.response.statusCode = HttpStatus.notFound;
  _json(request.response, {'error': 'not_found', 'path': path});
  await request.response.close();
}

Future<Map<String, dynamic>> _readJson(HttpRequest request) async {
  final raw = await utf8.decoder.bind(request).join();
  if (raw.isEmpty) return {};
  return jsonDecode(raw) as Map<String, dynamic>;
}

void _json(HttpResponse response, Object data) {
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(data));
}
