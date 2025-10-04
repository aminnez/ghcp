import 'dart:io';

import '../exceptions.dart';
import '../github_content_downloader.dart';

/// Handles the command-line interface for the GitHub Content Downloader.
class CliRunner {
  /// Creates a new [CliRunner] instance.
  ///
  /// - [downloader]: The [GitHubContentDownloader] to use for downloading content
  /// - [output]: Function to use for normal output (defaults to [print])
  /// - [errorOutput]: Function to use for error output (defaults to [stderr.writeln])
  CliRunner({
    GitHubContentDownloader? downloader,
    void Function(String)? output,
    void Function(Object)? errorOutput,
  }) : _downloader = downloader ?? GitHubContentDownloader(),
       _output = output ?? stdout.writeln,
       _errorOutput = errorOutput ?? stderr.writeln;
  final GitHubContentDownloader _downloader;
  final void Function(String) _output;
  final void Function(Object) _errorOutput;

  /// Runs the CLI with the given arguments.
  ///
  /// Returns the exit code (0 for success, non-zero for failure).
  Future<int> run(List<String> args) async {
    try {
      if (_shouldShowHelp(args)) {
        _printUsage();
        return 0;
      }

      if (args.isEmpty) {
        _printUsage();
        return 64; // EX_USAGE
      }

      String? token;
      final githubUrl = args.firstWhere(
        (arg) => !arg.startsWith('--'),
        orElse: () {
          _printUsage();
          throw const FormatException('GitHub URL is required');
        },
      );

      // Parse token from --token argument
      final tokenIndex = args.indexOf('--token');
      if (tokenIndex != -1 && tokenIndex + 1 < args.length) {
        token = args[tokenIndex + 1];
        if (token.startsWith('--')) {
          _errorOutput('❌ Error: Missing token value after --token');
          _printUsage();
          return 64; // EX_USAGE
        }
      }

      // Get output dir (first non-flag argument after the URL)
      final outputPath =
          args
              .skip(1)
              .where((arg) => arg != '--token' && !arg.startsWith('--'))
              .firstOrNull ??
          '';

      // Create a new downloader with the token if provided
      final downloader = token != null
          ? GitHubContentDownloader(githubToken: token)
          : _downloader;

      await downloader.downloadRepository(githubUrl, outputPath: outputPath);
      return 0;
    } on InvalidGitHubUrlException catch (e) {
      _errorOutput('❌ Invalid GitHub URL: ${e.message}');
      _printUsage();
      return 64; // EX_USAGE
    } on GitHubApiException catch (e) {
      _errorOutput('❌ GitHub API Error: ${e.message}');
      return 69; // EX_UNAVAILABLE
    } catch (e) {
      _errorOutput('❌ Error: $e');
      return 1; // EX_SOFTWARE
    }
  }

  bool _shouldShowHelp(List<String> args) =>
      args.contains('--help') ||
      args.contains('-h') ||
      args.any((arg) => arg.isEmpty);

  void _printUsage() {
    _output(
      '''
GitHub Content Downloader (ghcp)

Usage: ghcp <github-url> [output-dir] [--token <token>]

Arguments:
  <github-url>  The GitHub URL to download from (e.g., 'https://github.com/owner/repo/tree/branch/path')
  [output-dir]  Optional output directory (defaults to current directory)

Options:
  --token <token>  GitHub personal access token for authentication
  -h, --help       Show this help message

Authentication:
  You can provide a GitHub token in one of these ways:
  1. Using --token flag: ghcp <url> --token your_github_token
  2. Via GITHUB_TOKEN environment variable
    '''
          .trim(),
    );
  }
}
