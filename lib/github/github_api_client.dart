import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../exceptions.dart';
import 'models/github_content.dart';

/// A client for interacting with the GitHub REST API.
///
/// This class provides methods to fetch repository contents and download files
/// from GitHub repositories using the GitHub REST API v3.
class GitHubApiClient {
  /// Creates a new [GitHubApiClient] instance.
  ///
  /// - [httpClient]: Optional client for testing or custom HTTP handling.
  /// - [token]: Optional GitHub personal access token for authentication.
  ///   If not provided, falls back to GITHUB_TOKEN environment variable.
  GitHubApiClient({http.Client? httpClient, String? token})
    : _httpClient = httpClient ?? http.Client(),
      _token = token;

  /// The underlying HTTP client used for making requests.
  final http.Client _httpClient;
  final String? _token;

  /// Fetches contents from the GitHub API at the specified path.
  ///
  /// The [path] should be a valid GitHub API endpoint path (e.g., '/repos/username/repo/contents').
  ///
  /// Returns a [Future] that completes with a list of [GitHubContent] objects.
  ///
  /// Throws a [GitHubApiException] if:
  /// - The request fails (non-200 status code)
  /// - The response format is invalid
  /// - The response cannot be parsed
  Future<List<GitHubContent>> getContents(String path) async {
    final token = _token ?? Platform.environment['GITHUB_TOKEN'];
    try {
      final response = await _httpClient.get(
        Uri.parse(path),
        headers: {
          'Accept': 'application/vnd.github+json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw GitHubApiException(
          'Failed to fetch contents from $path. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final jsonBody = jsonDecode(response.body) as dynamic;

      if (jsonBody is Map<String, dynamic>) {
        return [GitHubContent.fromJson(jsonBody)];
      }

      if (jsonBody is List) {
        final contents = await _processContentList(
          jsonBody.cast<Map<String, dynamic>>(),
        );
        return contents;
      }

      throw const FormatException(
        'Unexpected response format: Expected Map or List',
      );
    } on FormatException catch (e) {
      throw GitHubApiException('Failed to parse response: ${e.message}');
    } on http.ClientException catch (e) {
      throw GitHubApiException(
        'Network error while fetching contents: ${e.message}',
      );
    }
  }

  /// Processes a list of content items from the GitHub API.
  ///
  /// Handles both files and directories, recursively processing directory contents.
  /// For directories, fetches their contents and updates paths accordingly.
  Future<List<GitHubContent>> _processContentList(
    List<Map<String, dynamic>> items,
  ) async {
    final contents = <GitHubContent>[];

    for (final item in items) {
      try {
        final content = GitHubContent.fromJson(item);

        if (content.type == 'dir') {
          final subContents = await getContents(content.url);
          final updatedContents = subContents.map(
            (sub) => sub.copyWith(name: '${content.name}/${sub.name}'),
          );
          contents.addAll(updatedContents);
        } else {
          contents.add(content);
        }
      } catch (e) {
        // Log error but continue processing other items
        stderr.writeln('Error processing content item: $e');
      }
    }

    return contents;
  }

  /// Downloads a file from the specified URL as a list of bytes.
  ///
  /// The [url] should be a direct download URL (e.g., a raw GitHub URL).
  /// Returns a [Uint8List] containing the file's binary data.
  ///
  /// Throws a [GitHubApiException] if the download fails.
  Future<Uint8List> downloadFile(String url) async {
    final token = _token ?? Platform.environment['GITHUB_TOKEN'];
    final response = await _httpClient.get(
      Uri.parse(url),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw GitHubApiException(
        'Failed to download file from $url',
        statusCode: response.statusCode,
      );
    }

    return response.bodyBytes;
  }

  /// Closes the underlying HTTP client and releases any resources.
  ///
  /// This should be called when the client is no longer needed to avoid
  /// memory leaks.
  void dispose() {
    _httpClient.close();
  }
}
