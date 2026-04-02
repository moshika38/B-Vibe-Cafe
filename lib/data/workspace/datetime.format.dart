class DatetimeFormat {
  static String date([DateTime? dateTime]) {
    final dt = dateTime ?? DateTime.now();
    return "${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}";
  }

  static String time([DateTime? dateTime]) {
    final dt = dateTime ?? DateTime.now();
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return "${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period";
  }
}
