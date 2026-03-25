class AppNumberFormat {
  static String formatNumber(num value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    String result = '';
    int count = 0;

    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result = ',$result';
      }
      result = '${intPart[i]}$result';
      count++;
    }

    return decPart == '00' ? result : '$result.$decPart';
  }
}
