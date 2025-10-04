/// Exception thrown when an error occurs while communicating with the GitHub API.
///
/// This exception includes the error message and optionally the HTTP status code
/// returned by the GitHub API.
class GitHubApiException implements Exception {
  GitHubApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'GitHubApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when an invalid GitHub URL is provided.
///
/// This exception is typically thrown when the provided URL doesn't match
/// the expected GitHub repository URL format.
class InvalidGitHubUrlException implements Exception {
  InvalidGitHubUrlException(this.message);
  final String message;

  @override
  String toString() => 'InvalidGitHubUrlException: $message';
}

/// Exception thrown when an error occurs while downloading files.
class DownloadException implements Exception {
  DownloadException(this.message);
  final String message;

  @override
  String toString() => 'DownloadException: $message';
}
