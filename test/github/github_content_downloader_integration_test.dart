import 'dart:io';

import 'package:ghcp/github/github_api_client.dart';
import 'package:ghcp/github_content_downloader.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final testOutputDir = Directory.systemTemp.createTempSync('test_output');
  GitHubApiClient? apiClient;

  setUp(() {
    // Create test output directory if it doesn't exist
    if (!testOutputDir.existsSync()) {
      testOutputDir.createSync(recursive: true);
    }
    apiClient = GitHubApiClient();
  });

  tearDown(() {
    // Clean up test directory after each test
    if (testOutputDir.existsSync()) {
      testOutputDir.deleteSync(recursive: true);
    }
  });

  group('GitHubContentDownloader Integration Tests', () {
    test('downloads a single file from GitHub', () async {
      // Arrange
      final downloader = GitHubContentDownloader(apiClient: apiClient!);
      const url =
          'https://github.com/google/dart-basics/blob/master/lib/string_basics.dart';
      final outputPath = p.join(testOutputDir.path, 'string_basics.dart');

      // Act
      await downloader.downloadRepository(url, outputPath: testOutputDir.path);

      // Assert
      final file = File(outputPath);
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(0));

      // Verify file content
      final content = file.readAsStringSync();
      expect(content, contains('String'));
      expect(content, contains('extension'));
    });

    test('downloads a single file from GitHub to custom output file', () async {
      // Arrange
      final downloader = GitHubContentDownloader(apiClient: apiClient);
      const url =
          'https://github.com/google/dart-basics/blob/master/lib/string_basics.dart';
      final outputPath = p.join(testOutputDir.path, 'string_custom.dart');

      // Act
      await downloader.downloadRepository(url, outputPath: outputPath);

      // Assert
      final file = File(outputPath);
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(0));

      // Verify file content
      final content = file.readAsStringSync();
      expect(content, contains('String'));
      expect(content, contains('extension'));
    });

    test('downloads a directory from GitHub', () async {
      // Arrange
      final downloader = GitHubContentDownloader(apiClient: apiClient);
      const url = 'https://github.com/google/dart-basics/tree/master/lib';
      final outputDir = p.join(testOutputDir.path);

      // Act
      await downloader.downloadRepository(url, outputPath: outputDir);

      // Assert
      final dir = Directory(outputDir);
      expect(dir.existsSync(), isTrue);

      // Check if expected files exist
      final files = dir.listSync(recursive: true).whereType<File>();
      expect(files.isNotEmpty, isTrue);
      print(files.map((f) => f.path).toList());

      // Verify some expected files exist
      final expectedFiles = [
        p.join(outputDir, 'string_basics.dart'),
        p.join(outputDir, 'int_basics.dart'),
      ];

      for (final filePath in expectedFiles) {
        expect(
          File(filePath).existsSync(),
          isTrue,
          reason: 'Expected file $filePath to exist',
        );
      }
    });

    test('downloads to custom output directory', () async {
      // Arrange
      final downloader = GitHubContentDownloader(apiClient: apiClient);
      const url = 'https://github.com/google/dart-basics/tree/master/lib';
      final customOutputDir = p.join(testOutputDir.path, 'custom_output');

      // Act
      await downloader.downloadRepository(url, outputPath: customOutputDir);

      // Assert
      final dir = Directory(customOutputDir);
      expect(dir.existsSync(), isTrue);

      // Check if expected files exist
      final files = dir.listSync(recursive: true).whereType<File>();
      expect(files.isNotEmpty, isTrue);

      // Verify some expected files exist
      final expectedFile = p.join(customOutputDir, 'string_basics.dart');
      expect(File(expectedFile).existsSync(), isTrue);
    });
  });
}
