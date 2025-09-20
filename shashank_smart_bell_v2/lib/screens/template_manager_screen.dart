import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'code_preview_screen.dart';

class TemplateManagerScreen extends StatefulWidget {
  const TemplateManagerScreen({super.key});

  @override
  State<TemplateManagerScreen> createState() => _TemplateManagerScreenState();
}

class _TemplateManagerScreenState extends State<TemplateManagerScreen> {
  List<String> templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync();

    final found = files
        .where((file) => file.path.endsWith(".json"))
        .map((file) => file.uri.pathSegments.last.replaceAll(".json", ""))
        .toList();

    setState(() {
      templates = found;
    });
  }

  void _deleteTemplate(String template) async {
    final dir = await getApplicationDocumentsDirectory();
    final jsonFile = File('${dir.path}/$template.json');
    final txtFile = File('${dir.path}/code_$template.txt');

    if (await jsonFile.exists()) await jsonFile.delete();
    if (await txtFile.exists()) await txtFile.delete();

    _loadTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Templates")),
      body: ListView.builder(
        itemCount: templates.length,
        itemBuilder: (_, index) {
          final template = templates[index];
          return ListTile(
            title: Text(template),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTemplate(template),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CodePreviewScreen(template: template),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
