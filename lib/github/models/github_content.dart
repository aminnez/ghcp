/// Represents a content item in a GitHub repository.
///
/// This could be a file, directory, or submodule.
class GitHubContent {
  /// Creates a new [GitHubContent] instance.
  GitHubContent({
    required this.name,
    required this.path,
    required this.size,
    required this.url,
    required this.type,
    this.downloadUrl,
  });

  /// Creates a [GitHubContent] from JSON data.
  factory GitHubContent.fromJson(Map<String, dynamic> json) => GitHubContent(
    name: json['name'] as String,
    path: json['path'] as String,
    size: json['size'] as int,
    url: json['url'] as String,
    downloadUrl: json['download_url'] as String?,
    type: json['type'] as String,
  );

  /// The name of the content item
  final String name;

  /// The path of the content item
  final String path;

  /// The size of the file in bytes
  final int size;

  /// The API URL for this content item
  final String url;

  /// The download URL for this content item (only for files)
  final String? downloadUrl;

  /// The type of the content (file, dir, or symlink)
  final String type;

  /// Converts this [GitHubContent] to a JSON object.
  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'size': size,
    'url': url,
    'download_url': downloadUrl,
    'type': type,
  };

  GitHubContent copyWith({
    String? name,
    String? path,
    int? size,
    String? url,
    String? downloadUrl,
    String? type,
  }) => GitHubContent(
    name: name ?? this.name,
    path: path ?? this.path,
    size: size ?? this.size,
    url: url ?? this.url,
    downloadUrl: downloadUrl ?? this.downloadUrl,
    type: type ?? this.type,
  );

  @override
  String toString() =>
      'GitHubContent(name: $name, path: $path, size: $size, url: $url, downloadUrl: $downloadUrl, type: $type)';
}
