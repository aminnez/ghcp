import 'dart:io';
import 'dart:typed_data';

import 'exceptions.dart';

class FileSystemHelper {
  Future<void> saveFile(String path, Uint8List bytes) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
    } on FileSystemException catch (e) {
      throw DownloadException('Failed to save file $path: ${e.message}');
    }
  }

  bool fileExists(String path) => File(path).existsSync();

  Future<Directory> createDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
