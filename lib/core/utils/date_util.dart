String formatDate(dynamic dateInput, {bool short = false}) {
  if (dateInput == null) return '';
  DateTime? dateTime;

  if (dateInput is DateTime) {
    dateTime = dateInput;
  } else if (dateInput is String) {
    try {
      dateTime = DateTime.parse(dateInput);
    } catch (_) {
      return dateInput;
    }
  } else {
    return dateInput.toString();
  }

  final day = dateTime.day;
  final year = dateTime.year;

  const longMonths = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  const shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  final month = short ? shortMonths[dateTime.month - 1] : longMonths[dateTime.month - 1];

  return '$day $month $year';
}
