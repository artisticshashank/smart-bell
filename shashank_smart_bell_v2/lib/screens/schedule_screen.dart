import 'package:flutter/material.dart';
import 'code_preview_screen.dart';
import '../utils/storage_service.dart';

class ScheduleScreen extends StatefulWidget {
  final String initialTemplate;

  const ScheduleScreen({super.key, required this.initialTemplate});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> templates = ['Normal Week', 'Exam', 'Special'];

  late String selectedTemplate;
  Map<String, List<Map<String, String>>> schedule = {};

  @override
  void initState() {
    super.initState();
    selectedTemplate = widget.initialTemplate;
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final data = await StorageService.loadJson('schedule_$selectedTemplate');
    if (data != null) {
      schedule = Map<String, List<Map<String, String>>>.from(
        data.map((day, periods) => MapEntry(
          day,
          List<Map<String, String>>.from(
            (periods as List).map((p) => Map<String, String>.from(p)),
          ),
        )),
      );
    } else {
      for (var day in days) {
        schedule[day] = [];
      }
    }
    setState(() {});
  }

  Future<void> _saveSchedule() async {
    await StorageService.saveJson('schedule_$selectedTemplate', schedule);
  }

  void _addPeriod(String day) {
    final titleController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Period for $day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time'),
              readOnly: true,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  timeController.text = picked.format(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && timeController.text.isNotEmpty) {
                setState(() {
                  schedule[day]?.add({
                    'title': titleController.text,
                    'time': timeController.text,
                  });
                });
                _saveSchedule();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  List<int>? _parseTimeOfDay(String time) {
    final parts = time.split(' ');
    if (parts.length != 2) return null;

    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);

    final isPM = parts[1].toUpperCase() == 'PM';
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return [hour, minute];
  }

  String _generateCppCode(Map<String, List<Map<String, String>>> schedule) {
    final buffer = StringBuffer();

    buffer.writeln('// Auto-generated bell schedule for ESP32');
    buffer.writeln('#include <WiFi.h>');
    buffer.writeln('#include <NTPClient.h>');
    buffer.writeln('#include <WiFiUdp.h>');
    buffer.writeln('');
    buffer.writeln('const char* ssid = "YOUR_WIFI_SSID";');
    buffer.writeln('const char* password = "YOUR_WIFI_PASSWORD";');
    buffer.writeln('');
    buffer.writeln('WiFiUDP ntpUDP;');
    buffer.writeln('NTPClient timeClient(ntpUDP, "pool.ntp.org", 0, 60000);');
    buffer.writeln('');
    buffer.writeln('const int relayPin = 5;');
    buffer.writeln('');
    buffer.writeln('struct BellEvent {');
    buffer.writeln('  int hour;');
    buffer.writeln('  int minute;');
    buffer.writeln('};');
    buffer.writeln('');
    buffer.writeln('BellEvent events[] = {');

    for (var day in schedule.keys) {
      for (var period in schedule[day]!) {
        final time = period['time']!;
        final parsed = _parseTimeOfDay(time);
        if (parsed != null) {
          buffer.writeln('  {${parsed[0]}, ${parsed[1]}}, // $day - ${period['title']} at $time');
        }
      }
    }

    buffer.writeln('};');
    buffer.writeln('int numEvents = sizeof(events) / sizeof(events[0]);');
    buffer.writeln('');
    buffer.writeln('void ringBell() {');
    buffer.writeln('  digitalWrite(relayPin, HIGH);');
    buffer.writeln('  delay(1000);');
    buffer.writeln('  digitalWrite(relayPin, LOW);');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('void setup() {');
    buffer.writeln('  pinMode(relayPin, OUTPUT);');
    buffer.writeln('  Serial.begin(115200);');
    buffer.writeln('  WiFi.begin(ssid, password);');
    buffer.writeln('  while (WiFi.status() != WL_CONNECTED) {');
    buffer.writeln('    delay(500);');
    buffer.writeln('    Serial.print(".");');
    buffer.writeln('  }');
    buffer.writeln('  timeClient.begin();');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('void loop() {');
    buffer.writeln('  timeClient.update();');
    buffer.writeln('  int currentHour = timeClient.getHours();');
    buffer.writeln('  int currentMinute = timeClient.getMinutes();');
    buffer.writeln('');
    buffer.writeln('  for (int i = 0; i < numEvents; i++) {');
    buffer.writeln('    if (events[i].hour == currentHour && events[i].minute == currentMinute) {');
    buffer.writeln('      ringBell();');
    buffer.writeln('      delay(60000); // wait 1 min to prevent repeated rings');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln('  delay(1000);');
    buffer.writeln('}');
    return buffer.toString();
  }

  Future<void> _applyTemplate(String template) async {
    selectedTemplate = template;
    final data = await StorageService.loadJson('schedule_$template');

    if (data != null) {
      schedule = Map<String, List<Map<String, String>>>.from(
        data.map((day, periods) => MapEntry(
          day,
          List<Map<String, String>>.from(
            (periods as List).map((p) => Map<String, String>.from(p)),
          ),
        )),
      );
    } else {
      schedule.clear();
      for (var day in days) {
        schedule[day] = [];
      }

      if (template == 'Normal Week') {
        schedule['Monday']?.add({'title': 'Math', 'time': '08:00 AM'});
        schedule['Tuesday']?.add({'title': 'Science', 'time': '08:45 AM'});
      } else if (template == 'Exam') {
        schedule['Monday']?.add({'title': 'Physics Exam', 'time': '09:00 AM'});
      } else if (template == 'Special') {
        schedule['Friday']?.add({'title': 'Sports Meet', 'time': '10:00 AM'});
      }

      await _saveSchedule();
    }

    setState(() {});
  }

  void _showCreateTemplateDialog() {
    final templateController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create New Template"),
        content: TextField(
          controller: templateController,
          decoration: const InputDecoration(hintText: 'Enter template name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final name = templateController.text.trim();
              if (name.isNotEmpty && !templates.contains(name)) {
                setState(() {
                  templates.add(name);
                  selectedTemplate = name;
                  schedule = {for (var day in days) day: []};
                });
                _saveSchedule();
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule: $selectedTemplate'),
        actions: [
          DropdownButton<String>(
            value: templates.contains(selectedTemplate) ? selectedTemplate : null,
            onChanged: (value) {
              if (value != null) {
                _applyTemplate(value);
              }
            },
            items: templates.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text(t),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Template',
            onPressed: _showCreateTemplateDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: days.length,
        itemBuilder: (_, index) {
          String day = days[index];
          return ExpansionTile(
            title: Text(day),
            children: [
              ...schedule[day]!.map((period) => ListTile(
                title: Text(period['title']!),
                subtitle: Text(period['time']!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      schedule[day]!.remove(period);
                    });
                    _saveSchedule();
                  },
                ),
              )),
              ListTile(
                title: const Text('+ Add Period'),
                onTap: () => _addPeriod(day),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final code = _generateCppCode(schedule);
          await StorageService.saveCode(selectedTemplate, code);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CodePreviewScreen(template: selectedTemplate),
            ),
          );
        },
        icon: const Icon(Icons.code),
        label: const Text('Generate Code'),
      ),
    );
  }
}
