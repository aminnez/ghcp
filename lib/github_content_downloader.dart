import 'package:interact_cli/interact_cli.dart';
import 'package:path/path.dart' as p;

import 'file_system_helper.dart';
import 'github/github_api_client.dart';
import 'github/github_repository_info.dart';
import 'github/models/github_content.dart';

/// A class that handles downloading content from GitHub repositories.
///
/// This class provides functionality to download single files or entire directories
/// from GitHub repositories with progress tracking and error handling.

/// A service class for downloading content from GitHub repositories.
///
/// Handles both single file and directory downloads with progress visualization.
class GitHubContentDownloader {
  /// Creates a new [GitHubContentDownloader] instance.
  ///
  /// All parameters are optional and will be initialized with default values if not provided.
  ///
  /// - [spinner]: Optional spinner for progress visualization
  /// - [apiClient]: Optional GitHub API client
  /// - [fileSystem]: Optional file system helper
  /// - [githubToken]: Optional GitHub personal access token for authentication.
  ///   If not provided, falls back to GITHUB_TOKEN environment variable.
  GitHubContentDownloader({
    MultiSpinner? spinner,
    GitHubApiClient? apiClient,
    FileSystemHelper? fileSystem,
    String? githubToken,
  }) : _apiClient = apiClient ?? GitHubApiClient(token: githubToken),
       _fileSystem = fileSystem ?? FileSystemHelper(),
       _spinner = spinner ?? MultiSpinner();

  /// The GitHub API client used for making requests to GitHub's API.
  final GitHubApiClient _apiClient;

  /// The file system helper for file operations.
  final FileSystemHelper _fileSystem;

  /// The spinner for showing download progress in the console.
  final MultiSpinner _spinner;

  /// Downloads content from a GitHub repository.
  ///
  /// The method can handle both single files and entire directories.
  /// For directories, it will recursively download all files.
  ///
  /// [githubUrl] The GitHub URL to download from (e.g., 'https://github.com/owner/repo/tree/branch/path')
  /// [outputPath] The output path where to save the downloaded files (defaults to current directory)
  ///
  /// Throws [InvalidGitHubUrlException] if the URL is invalid
  /// Throws [GitHubApiException] if there's an error with the GitHub API
  /// Throws [DownloadException] if there's an error downloading or saving files
  Future<void> downloadRepository(
    String githubUrl, {
    String outputPath = '',
  }) async {
    try {
      final repoInfo = GitHubRepositoryInfo.fromUrl(githubUrl);
      final contentPath = repoInfo.targetPath.isNotEmpty
          ? '${repoInfo.targetPath}/${repoInfo.target}'
          : repoInfo.target;
      final contentUrl =
          'https://api.github.com/repos/${repoInfo.owner}/${repoInfo.repo}/contents/$contentPath?ref=${repoInfo.branch}';

      final contents = await _apiClient.getContents(contentUrl);

      if (contents.length == 1) {
        // For single files, determine if outputPath is a filename or directory
        final path = _getSingleFileOutputPath(outputPath, repoInfo.target);
        await _downloadSingleFile(
          content: contents.first,
          outputPath: path,
          repoName: repoInfo.repo,
        );
      } else {
        // For directories, use the output directory directly to extract contents
        await _downloadMultipleFiles(
          contents: contents,
          outputPath: outputPath,
        );
      }
    } finally {
      reset();
      _apiClient.dispose();
    }
  }

  /// Downloads a single file from GitHub.
  ///
  /// - [content]: A [GitHubContent] object containing file information from GitHub API
  /// - [outputPath]: The local path where the file should be saved
  /// - [repoName]: The name of the repository (used for display purposes)
  ///
  /// Throws [Exception] if the download fails.
  Future<void> _downloadSingleFile({
    required GitHubContent content,
    required String outputPath,
    required String repoName,
  }) async {
    final spinner = _spinner.add(
      Spinner.withTheme(
        theme: Theme.colorfulTheme,
        icon: '⏳',
        rightPrompt: (state) => switch (state) {
          SpinnerStateType.inProgress => 'Downloading ${content.name}...',
          SpinnerStateType.done => 'Downloaded! ${content.name}',
          SpinnerStateType.failed => 'Failed!',
        },
      ),
    );

    try {
      if (content.downloadUrl == null) {
        throw Exception('No download URL available for ${content.path}');
      }
      final fileContent = await _apiClient.downloadFile(content.downloadUrl!);
      await _fileSystem.saveFile(outputPath, fileContent);
      spinner.done();
    } catch (e) {
      spinner.failed();
      rethrow;
    }
  }

  /// Downloads multiple files from GitHub with progress tracking.
  ///
  /// - [contents]: A list of [GitHubContent] objects containing file information from GitHub API
  /// - [outputPath]: The local directory where files should be saved
  ///
  /// Shows a progress spinner for the overall operation and individual spinners for each file.
  Future<void> _downloadMultipleFiles({
    required List<GitHubContent> contents,
    required String outputPath,
  }) async {
    final total = contents.length;
    var completedCount = 0;

    final headSpinner = _spinner.add(
      Spinner.withTheme(
        theme: Theme.basicTheme,
        icon: '✔',
        failedIcon: '✘',
        rightPrompt: (state) => switch (state) {
          SpinnerStateType.inProgress =>
            'Downloading $completedCount of $total files...',
          SpinnerStateType.done => 'Done! $completedCount of $total files.',
          SpinnerStateType.failed => 'Failed!',
        },
      ),
    );

    final spinnerStates = <String, SpinnerState>{};
    final downloadTasks = <Future<void>>[];

    for (final content in contents) {
      if (content.type != 'file' || content.downloadUrl == null) continue;

      final spinner = _spinner.add(
        Spinner.withTheme(
          theme: Theme.colorfulTheme,
          icon: '✔',
          failedIcon: '✘',
          rightPrompt: (state) => switch (state) {
            SpinnerStateType.inProgress => 'Downloading ${content.name}...',
            SpinnerStateType.done => 'Done! ${content.name}',
            SpinnerStateType.failed => 'Failed!',
          },
        ),
      );

      spinnerStates[content.name] = spinner;

      downloadTasks.add(
        _downloadFile(
          downloadUrl: content.downloadUrl!,
          outputPath: p.join(outputPath, content.name),
          onSuccess: () {
            spinner.done();
            completedCount++;
          },
          onFailed: () => spinner.failed(),
        ),
      );
    }

    await Future.wait(downloadTasks);
    headSpinner.done();
  }

  /// Determines the correct output path for a single file download.
  ///
  /// If [outputPath] looks like a filename (has an extension), use it directly.
  /// If [outputPath] looks like a directory, join it with [targetFileName].
  /// If [outputPath] is empty, use [targetFileName] in current directory.
  String _getSingleFileOutputPath(String outputPath, String targetFileName) {
    if (outputPath.isEmpty) {
      return targetFileName;
    }

    // Check if outputPath looks like a filename by checking if it has an extension
    // and doesn't end with a path separator
    final hasExtension = p.extension(outputPath).isNotEmpty;
    final endsWithSeparator =
        outputPath.endsWith('/') || outputPath.endsWith('\\');

    if (hasExtension && !endsWithSeparator) {
      // outputPath looks like a filename, use it directly
      return outputPath;
    } else {
      // outputPath looks like a directory, join with target filename
      return p.join(outputPath, targetFileName);
    }
  }

  /// Downloads a single file and updates the UI with progress.
  ///
  /// - [downloadUrl]: The URL to download the file from
  /// - [outputPath]: The local path where the file should be saved
  /// - [onSuccess]: Callback function to execute on successful download
  /// - [onFailed]: Callback function to execute if the download fails
  ///
  /// This is an internal helper method used by [_downloadMultipleFiles].
  Future<void> _downloadFile({
    required String downloadUrl,
    required String outputPath,
    required void Function() onSuccess,
    required void Function() onFailed,
  }) async {
    try {
      final content = await _apiClient.downloadFile(downloadUrl);
      await _fileSystem.saveFile(outputPath, content);
      onSuccess();
    } catch (e) {
      onFailed();
    }
  }
}
