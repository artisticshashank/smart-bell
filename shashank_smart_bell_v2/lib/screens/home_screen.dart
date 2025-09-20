import 'package:flutter/material.dart';

import 'code_editor_screen.dart';
import 'schedule_screen.dart';
import 'template_manager_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String defaultTemplate = 'Normal Week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Bell System")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.amber),
              child: Text(
                '📚 Menu',
                style: TextStyle(fontSize: 50, color: Colors.black),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.schedule_sharp),
              title: const Text('Manage Schedule'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ScheduleScreen(initialTemplate: defaultTemplate),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Template Manager'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TemplateManagerScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Code Editor'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CodeEditorScreen(template: defaultTemplate),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.notifications_active),
          label: const Text("Ring Bell Now"),
          onPressed: () {
            // TODO: Trigger ESP32 bell instantly
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "🔔 Bell would ring now! (ESP32 trigger here and rings the bell aprt from the schedule)",
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
