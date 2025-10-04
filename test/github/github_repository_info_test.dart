import 'package:ghcp/exceptions.dart';
import 'package:ghcp/github/github_repository_info.dart';
import 'package:test/test.dart';

void main() {
  group('GitHubRepositoryInfo', () {
    group('fromUrl', () {
      test('parses a standard GitHub URL with path', () {
        const url = 'https://github.com/owner/repo/tree/main/path/to/target';
        final info = GitHubRepositoryInfo.fromUrl(url);

        expect(info.owner, equals('owner'));
        expect(info.repo, equals('repo'));
        expect(info.branch, equals('main'));
        expect(info.target, equals('target'));
        expect(info.targetPath, equals('path/to'));
      });

      test('parses a GitHub URL with just owner and repo', () {
        const url = 'https://github.com/owner/repo/tree/main';
        final info = GitHubRepositoryInfo.fromUrl(url);

        expect(info.owner, equals('owner'));
        expect(info.repo, equals('repo'));
        expect(info.branch, equals('main'));
        expect(info.target, isEmpty);
        expect(info.targetPath, isEmpty);
      });

      test('trims whitespace from URL', () {
        const url = '  https://github.com/owner/repo/tree/main/path  ';
        final info = GitHubRepositoryInfo.fromUrl(url);

        expect(info.owner, equals('owner'));
        expect(info.repo, equals('repo'));
        expect(info.branch, equals('main'));
        expect(info.target, equals('path'));
        expect(info.targetPath, isEmpty);
      });

      test('throws for non-GitHub URLs', () {
        const url = 'https://gitlab.com/owner/repo/tree/main/path';

        expect(
          () => GitHubRepositoryInfo.fromUrl(url),
          throwsA(
            isA<InvalidGitHubUrlException>().having(
              (e) => e.message,
              'message',
              'Not a valid GitHub URL',
            ),
          ),
        );
      });

      test('throws for invalid GitHub URL format', () {
        const url = 'https://github.com/owner';

        expect(
          () => GitHubRepositoryInfo.fromUrl(url),
          throwsA(
            isA<InvalidGitHubUrlException>().having(
              (e) => e.message,
              'message',
              'Invalid GitHub URL format. Expected format: https://github.com/owner/repo/tree/branch/path',
            ),
          ),
        );
      });
    });
  });
}
