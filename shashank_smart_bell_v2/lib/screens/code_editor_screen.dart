import 'package:flutter/material.dart';
import '../utils/storage_service.dart';
import 'package:http/http.dart' as http;

class CodeEditorScreen extends StatefulWidget {
  final String template;
  const CodeEditorScreen({super.key, required this.template});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    final code = await StorageService.loadText('code_${widget.template}');
    setState(() {
      codeController.text = code ?? '// No code saved for ${widget.template}';
    });
  }

  Future<void> _saveCode() async {
    await StorageService.saveText('code_${widget.template}', codeController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Code saved locally")),
    );
  }

  Future<void> _sendCode() async {
    const esp32Ip = "http://192.168.1.100"; // Replace with real IP
    try {
      final response = await http.post(
        Uri.parse('$esp32Ip/upload'),
        headers: {"Content-Type": "text/plain"},
        body: codeController.text,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Code sent to ESP32")),
        );
      } else {
        throw Exception("Status ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Code - ${widget.template}"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveCode),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendCode),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: codeController,
          maxLines: null,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'C++ Code',
          ),
        ),
      ),
    );
  }
}
