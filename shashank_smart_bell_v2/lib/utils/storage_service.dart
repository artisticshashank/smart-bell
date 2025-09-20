// storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {

  static Future<void> saveText(String filename, String content) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename.txt');
    await file.writeAsString(content);
  }

  static Future<String?> loadText(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename.txt');
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  static Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _getFile(String filename) async {
    final path = await _getLocalPath();
    return File('$path/$filename.json');
  }

  static Future<void> saveJson(String key, dynamic value) async {
    final file = await _getFile(key);
    final jsonString = jsonEncode(value);
    await file.writeAsString(jsonString);
  }

  static Future<dynamic> loadJson(String key) async {
    try {
      final file = await _getFile(key);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return jsonDecode(jsonString);
      }
    } catch (e) {
      print("Error loading JSON: $e");
    }
    return null;
  }


  static Future<void> saveCode(String template, String code) async {
    final path = await _getLocalPath();
    final file = File('$path/code_$template.txt');
    await file.writeAsString(code);
  }


  static Future<String?> loadCode(String template) async {
    final path = await _getLocalPath();
    final file = File('$path/code_$template.txt');
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }
}
