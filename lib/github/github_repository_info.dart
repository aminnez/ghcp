import '../exceptions.dart';

/// A class that represents and parses GitHub repository information from URLs.
///
/// This class extracts and stores components of a GitHub repository URL such as
/// owner, repository name, branch, target, and path for easier manipulation
/// and access to repository resources.

/// Contains parsed information from a GitHub repository URL.
class GitHubRepositoryInfo {
  /// Creates a new [GitHubRepositoryInfo] instance with the given parameters.
  ///
  /// - [owner]: The owner of the GitHub repository
  /// - [repo]: The name of the GitHub repository
  /// - [branch]: The branch name in the repository
  /// - [target]: The target file or directory name
  /// - [targetPath]: The path within the repository
  const GitHubRepositoryInfo({
    required this.owner,
    required this.repo,
    required this.branch,
    required this.target,
    required this.targetPath,
  });

  /// Parses a GitHub URL and creates a [GitHubRepositoryInfo] instance.
  ///
  /// The URL should be in the format:
  /// `https://github.com/owner/repo/tree/branch/path/to/target`
  ///
  /// - [githubUrl]: The GitHub URL to parse
  ///
  /// Returns a new [GitHubRepositoryInfo] instance with the parsed components.
  ///
  /// Throws [InvalidGitHubUrlException] if the URL is not a valid GitHub URL
  /// or doesn't match the expected format.
  factory GitHubRepositoryInfo.fromUrl(String githubUrl) {
    githubUrl = githubUrl.trim();
    if (!githubUrl.toLowerCase().startsWith('https://github.com/')) {
      throw InvalidGitHubUrlException('Not a valid GitHub URL');
    }

    final uri = Uri.parse(githubUrl);
    final parts = uri.path.split('/')..removeWhere((e) => e.isEmpty);

    if (parts.length < 4) {
      throw InvalidGitHubUrlException(
        'Invalid GitHub URL format. Expected format: https://github.com/owner/repo/tree/branch/path',
      );
    }

    // Extract components from the URL path
    // parts[0] = owner
    // parts[1] = repo
    // parts[2] = 'tree' (assuming standard GitHub URL format)
    // parts[3] = branch
    // parts[4...n-1] = path components
    // parts.last = target file/directory name
    final owner = parts[0];
    final repo = parts[1];
    final branch = parts[3];
    final target = parts.length > 4 ? parts.last : '';

    final targetPath = parts.length > 4
        ? parts.sublist(4, parts.length - 1).join('/')
        : '';

    return GitHubRepositoryInfo(
      owner: owner,
      repo: repo,
      branch: branch,
      target: target,
      targetPath: targetPath,
    );
  }

  /// The owner of the GitHub repository (username or organization name).
  final String owner;

  /// The name of the GitHub repository.
  final String repo;

  /// The branch name in the repository.
  final String branch;

  /// The target file or directory name at the end of the path.
  final String target;

  /// The path within the repository, excluding the target file/directory.
  final String targetPath;

  @override
  String toString() =>
      'GitHubRepositoryInfo(owner: $owner, repo: $repo, branch: $branch, target: $target, targetPath: $targetPath)';
}
