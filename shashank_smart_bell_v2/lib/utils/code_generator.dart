String generateCppCode(Map<String, List<Map<String, String>>> schedule) {
  final buffer = StringBuffer();
  buffer.writeln("void checkAndRing(String day, String time) {");

  schedule.forEach((day, periods) {
    for (final period in periods) {
      final time = period['time'] ?? '';
      buffer.writeln('  if (day == "$day" && time == "$time") ringBell();');
    }
  });

  buffer.writeln("}");
  return buffer.toString();
}
