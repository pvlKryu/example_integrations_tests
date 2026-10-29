import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Обёртка над http.Client: пишет запросы и ответы в консоль.
class LoggingClient extends http.BaseClient {
  LoggingClient([http.Client? inner]) : _inner = inner ?? http.Client();

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final started = DateTime.now();
    debugPrint('→ ${request.method} ${request.url}');
    if (request is http.Request && request.body.isNotEmpty) {
      debugPrint('  body: ${_short(request.body)}');
    }

    try {
      final streamed = await _inner.send(request);
      final response = await http.Response.fromStream(streamed);
      final ms = DateTime.now().difference(started).inMilliseconds;
      debugPrint(
        '← ${response.statusCode} ${request.method} ${request.url} ($ms ms)',
      );
      if (response.body.isNotEmpty) {
        debugPrint('  body: ${_short(response.body)}');
      }
      // Возвращаем новый StreamedResponse — исходный поток уже прочитан.
      return http.StreamedResponse(
        Stream<List<int>>.value(response.bodyBytes),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e) {
      final ms = DateTime.now().difference(started).inMilliseconds;
      debugPrint('✖ ${request.method} ${request.url} ($ms ms): $e');
      rethrow;
    }
  }

  @override
  void close() => _inner.close();

  String _short(String body, {int max = 300}) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final pretty = encoder.convert(jsonDecode(body));
      if (pretty.length <= max) return pretty.replaceAll('\n', ' ');
      return '${pretty.replaceAll('\n', ' ').substring(0, max)}…';
    } catch (_) {
      if (body.length <= max) return body;
      return '${body.substring(0, max)}…';
    }
  }
}
