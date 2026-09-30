import 'file_helper_stub.dart'
    if (dart.library.io) 'file_helper_io.dart';

class FileHelper {
  static Future<bool> saveString(String path, String content) {
    return saveStringToFile(path, content);
  }

  static Future<bool> directoryExists(String path) {
    return checkPathExists(path);
  }
}
