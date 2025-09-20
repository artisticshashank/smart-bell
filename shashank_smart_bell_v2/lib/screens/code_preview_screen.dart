import 'package:flutter/material.dart';
import '../utils/storage_service.dart';
import '../utils/esp32_api.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CodePreviewScreen extends StatefulWidget {
  final String template;

  const CodePreviewScreen({super.key, required this.template});

  @override
  State<CodePreviewScreen> createState() => _CodePreviewScreenState();
}

class _CodePreviewScreenState extends State<CodePreviewScreen> {
  bool isSending = false;
  bool isSaving = false;

  Future<void> _saveToFile(BuildContext context, String code) async {
    setState(() => isSaving = true);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${widget.template}.ino');
    await file.writeAsString(code);

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Saved to ${file.path}')),
    );
  }

  Future<void> _sendToESP32(BuildContext context, String code) async {
    setState(() => isSending = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚀 Sending code to ESP32...')),
    );

    try {
      await ESP32Api.sendCodeToESP32(code);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📡 Code sent to ESP32!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to send code: $e')),
      );
    }

    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Bell Logic'),
      ),
      body: FutureBuilder<String?>(
        future: StorageService.loadCode(widget.template),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final code = snapshot.data ?? '';
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SelectableText(
              code.isNotEmpty
                  ? code
                  : '// No schedule found for this template.\n// Use the Schedule screen and click "Generate Code".',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<String?>(
        future: StorageService.loadCode(widget.template),
        builder: (context, snapshot) {
          final code = snapshot.data ?? '';

          if (snapshot.connectionState == ConnectionState.done && code.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: isSaving
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.save),
                      label: const Text('Save Template'),
                      onPressed: isSaving ? null : () => _saveToFile(context, code),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: isSending
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.send),
                      label: const Text('Send to ESP32'),
                      onPressed: isSending ? null : () => _sendToESP32(context, code),
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done && code.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('No saved code found'),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
