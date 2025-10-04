import 'package:ghcp/github/models/github_content.dart';
import 'package:test/test.dart';

void main() {
  group('GitHubContent', () {
    const mockJson = {
      'name': 'example.txt',
      'path': 'path/to/example.txt',
      'size': 1024,
      'url': 'https://api.github.com/repos/example/repo/contents/example.txt',
      'download_url':
          'https://raw.githubusercontent.com/example/repo/main/example.txt',
      'type': 'file',
    };

    test('fromJson creates correct GitHubContent instance', () {
      final content = GitHubContent.fromJson(mockJson);

      expect(content.name, equals('example.txt'));
      expect(content.path, equals('path/to/example.txt'));
      expect(content.size, equals(1024));
      expect(
        content.url,
        equals(
          'https://api.github.com/repos/example/repo/contents/example.txt',
        ),
      );
      expect(
        content.downloadUrl,
        equals(
          'https://raw.githubusercontent.com/example/repo/main/example.txt',
        ),
      );
      expect(content.type, equals('file'));
    });

    test('fromJson handles null download_url', () {
      final json = Map<String, dynamic>.from(mockJson)..remove('download_url');
      final content = GitHubContent.fromJson(json);

      expect(content.downloadUrl, isNull);
    });

    test('toJson returns correct map', () {
      final content = GitHubContent.fromJson(mockJson);
      final json = content.toJson();

      expect(json['name'], equals('example.txt'));
      expect(json['path'], equals('path/to/example.txt'));
      expect(json['size'], equals(1024));
      expect(
        json['url'],
        equals(
          'https://api.github.com/repos/example/repo/contents/example.txt',
        ),
      );
      expect(
        json['download_url'],
        equals(
          'https://raw.githubusercontent.com/example/repo/main/example.txt',
        ),
      );
      expect(json['type'], equals('file'));
    });

    test('copyWith creates new instance with updated fields', () {
      final original = GitHubContent.fromJson(mockJson);
      final copy = original.copyWith(name: 'new_name.txt', size: 2048);

      expect(copy.name, equals('new_name.txt'));
      expect(copy.path, equals(original.path));
      expect(copy.size, equals(2048));
      expect(copy.url, equals(original.url));
      expect(copy.downloadUrl, equals(original.downloadUrl));
      expect(copy.type, equals(original.type));
    });

    test('toString returns correct string representation', () {
      final content = GitHubContent.fromJson(mockJson);
      final str = content.toString();

      expect(str, contains('GitHubContent'));
      expect(str, contains('name: example.txt'));
      expect(str, contains('path: path/to/example.txt'));
      expect(str, contains('size: 1024'));
      expect(str, contains('type: file'));
      expect(str, contains(content.url));
      expect(str, contains(content.downloadUrl));
    });
  });
}
