import 'file_helper_stub.dart'
    if (dart.library.io) 'file_helper_io.dart';

class FileHelper {
  static Future<bool> saveString(String path, String content) {
    return saveStringToFile(path, content);
  }

  static Future<bool> saveBytes(String path, List<int> bytes) {
    return saveBytesToFile(path, bytes);
  }

  static Future<bool> directoryExists(String path) {
    return checkPathExists(path);
  }

  static Future<bool> fileExists(String path) {
    return checkFileExists(path);
  }

  static Future<String?> readFile(String path) {
    return readFileString(path);
  }
}
