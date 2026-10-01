import 'dart:io';

Future<bool> saveStringToFile(String path, String content) async {
  try {
    final file = File(path);
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    await file.writeAsString(content);
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> saveBytesToFile(String path, List<int> bytes) async {
  try {
    final file = File(path);
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    await file.writeAsBytes(bytes);
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> checkPathExists(String path) async {
  try {
    return await Directory(path).exists();
  } catch (_) {
    return false;
  }
}

Future<bool> checkFileExists(String path) async {
  try {
    return await File(path).exists();
  } catch (_) {
    return false;
  }
}

Future<String?> readFileString(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsString();
    }
  } catch (_) {}
  return null;
}
