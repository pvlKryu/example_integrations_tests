import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'api_exception.dart';
import 'logging_client.dart';

/// HTTP-клиент к учебному стабу.
/// Настоящие сетевые запросы — это то, что проверяют интеграционные тесты.
class ApiClient {
  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _httpClient = httpClient ?? LoggingClient(),
        _ownsClient = httpClient == null;

  final String baseUrl;
  final http.Client _httpClient;
  final bool _ownsClient;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<Product>> fetchProducts() async {
    final response = await _httpClient.get(_uri('/products'));
    if (response.statusCode != 200) {
      throw ApiException(
        'Не удалось загрузить каталог',
        statusCode: response.statusCode,
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>;
    return items
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderResult> createOrder({
    required List<Map<String, dynamic>> items,
    required int totalKopecks,
  }) async {
    final response = await _httpClient.post(
      _uri('/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'items': items,
        'totalKopecks': totalKopecks,
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        'Не удалось оформить заказ',
        statusCode: response.statusCode,
      );
    }
    return OrderResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Служебный вызов только для учебных тестов.
  Future<void> resetStub({
    String scenario = 'success',
    int? delayMs,
  }) async {
    final body = <String, dynamic>{'scenario': scenario};
    if (delayMs != null) {
      body['delayMs'] = delayMs;
    }
    final response = await _httpClient.post(
      _uri('/test/reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        'Не удалось сбросить стаб',
        statusCode: response.statusCode,
      );
    }
  }

  void close() {
    if (_ownsClient) {
      _httpClient.close();
    }
  }
}
