String formatDuration(DateTime start, DateTime end) {
  final difference = end.difference(start);
  final mins = difference.inMinutes;
  if (mins < 60) {
    return mins.toString() + 'm';
  }
  final hours = difference.inHours;
  if (hours < 24) {
    return hours.toString() + 'h';
  }
  final days = difference.inDays;
  return days.toString() + 'd';
}
