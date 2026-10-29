/// Цены хранятся в копейках (целые числа).
/// Форматирование для отображения: «1 999,00 ₽».
String formatPrice(int kopecks) {
  final rubles = kopecks ~/ 100;
  final remainder = (kopecks % 100).abs().toString().padLeft(2, '0');
  final rublesStr = _formatThousands(rubles.abs());
  final sign = kopecks < 0 ? '-' : '';
  return '$sign$rublesStr,$remainder ₽';
}

String _formatThousands(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final fromEnd = raw.length - i;
    buffer.write(raw[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) {
      buffer.write('\u00A0'); // неразрывный пробел
    }
  }
  return buffer.toString();
}
