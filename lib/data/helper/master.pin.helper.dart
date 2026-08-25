class MasterPinHelper {
  MasterPinHelper._();

  /// Generates a dynamic developer master PIN based on the current date.
  /// Formula: [DD][MM]38
  /// e.g. 25th August -> "250838", 2nd May -> "020538"
  static String generateTodayPin() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$day$month${38}';
  }

  /// Checks if the given PIN matches today's master PIN.
  static bool verify(String pin) {
    return pin == generateTodayPin();
  }
}
