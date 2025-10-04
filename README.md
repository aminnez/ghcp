# GitHub Content Downloader (ghcp)

[![License](https://img.shields.io/github/license/aminnez/ghcp?style=flat-square&label=License&color=green)](https://opensource.org/licenses/MIT) ![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?logo=dart&logoColor=white) ![CLI Tool](https://img.shields.io/badge/Type-CLI%20Tool-FF6B6B?style=flat-square&logo=terminal&logoColor=white)

[![Pub Version](https://img.shields.io/pub/v/ghcp.svg?style=flat-square&label=Pub%20Version)](https://pub.dev/packages/ghcp) [![Pub Publisher](https://img.shields.io/pub/publisher/ghcp?style=flat-square&label=Pub%20Publisher&color=blue)](https://pub.dev/publishers/aminnez.com) [![GitHub Release](https://img.shields.io/github/v/release/aminnez/ghcp?style=flat-square&label=Latest%20Release)](https://github.com/aminnez/ghcp/releases)

![Windows](https://custom-icon-badges.demolab.com/badge/Windows-0078D6?logo=windows11&logoColor=white) ![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=F0F0F0) ![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)

A powerful, lightweight command-line tool for downloading files and directories from GitHub repositories with ease. Built with Dart, ghcp provides a simple yet flexible way to fetch content from GitHub repositories without cloning the entire repository. Perfect for CI/CD pipelines, automation scripts, and selective downloads.

## Features

- **Fast & Lightweight**: Only downloads what you need, no repository cloning required
- **Directory Support**: Download entire directories with preserved structure and recursive processing
- **Flexible URLs**: Supports various GitHub URL formats (blob/tree, different branches)
- **Recursive Downloads**: Automatically handles nested directories with concurrent processing
- **Concurrent Downloads**: Parallel file downloads for improved performance
- **File Size Awareness**: Handles files up to GitHub's 100MB limit

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Configuration](#configuration)
- [Supported URL Formats](#supported-url-formats)
- [Output Behavior](#output-behavior)
- [Examples](#examples)
- [API Rate Limits](#api-rate-limits)
- [Development](#development)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Installation

### Option 1: Download Pre-built Binary (Recommended)

Download the latest pre-built binary for your platform from the [releases page](https://github.com/aminnez/ghcp/releases):

**Available Platforms:**

- macOS: x64 (Intel), arm64 (Apple Silicon)
- Linux: x64, arm64
- Windows: x64

**Linux/macOS:**

```bash
# Download the appropriate binary for your platform
# Replace {version} with the latest version (e.g., v1.0.0)
# Replace {platform} with: linux or macos
# Replace {arch} with: x64 or arm64

curl -L -o ghcp.tar.gz https://github.com/aminnez/ghcp/releases/download/{version}/ghcp-{version}-{platform}-{arch}.tar.gz

# Extract and install
tar -xzf ghcp.tar.gz
chmod +x ghcp
sudo mv ghcp /usr/local/bin/

# Verify installation
ghcp --help
```

**Windows:**

```powershell
# Download the binary
# Replace {version} with the latest version (e.g., v1.0.0)
Invoke-WebRequest -Uri "https://github.com/aminnez/ghcp/releases/download/{version}/ghcp-{version}-windows-x64.zip" -OutFile "ghcp.zip"

# Extract the zip file
Expand-Archive -Path "ghcp.zip" -DestinationPath "."

# Add to PATH or run directly
# You can move ghcp.exe to a directory in your PATH
```

### Option 2: Install from pub.dev

**Prerequisites:** Dart SDK Version 3.8.1 or higher ([Install Dart](https://dart.dev/get-dart))

```bash
# Install globally
dart pub global activate ghcp

# Update to latest version
dart pub global activate ghcp
```

### Option 3: Install from Source

**Prerequisites:** Dart SDK Version 3.8.1 or higher ([Install Dart](https://dart.dev/get-dart))

```bash
# Clone the repository
git clone https://github.com/aminnez/ghcp.git
cd ghcp

# Install dependencies
dart pub get

# Activate globally
dart pub global activate --source path .
```

### Verify Installation

```bash
ghcp --help
```

## Quick Start

```bash
# Download a single file
ghcp https://github.com/open-webui/open-webui/blob/main/docker-compose.yaml

# Download a single file with custom filename
ghcp https://github.com/open-webui/open-webui/blob/main/docker-compose.yaml compose.yml

# Download an entire directory
ghcp https://github.com/google/dart-basics/tree/master/lib

# Download directory contents directly into target folder
ghcp https://github.com/google/dart-basics/tree/master/lib ./dart-basics
```

## Usage

### Command Syntax

```bash
ghcp <github-url> [output-directory] [--token <token>] [--help]
```

### Options

- `<github-url>`: GitHub URL to download from (required)
  - Supports both `blob` (single files) and `tree` (directories) URLs
  - Must follow the format: `https://github.com/owner/repo/blob|tree/branch/path`
- `[output-directory]`: Output directory or filename (optional, defaults to current directory)
  - For single files: Can specify a custom filename (e.g., `config.yml`) or directory
  - For directories: Specifies where to extract the directory contents
- `--token <token>`: GitHub personal access token for authentication
- `-h, --help`: Show help message

### Authentication

For private repositories or higher rate limits, you can provide a GitHub Personal Access Token:

#### Using Environment Variable (Recommended)

```bash
export GITHUB_TOKEN=your_github_token
ghcp https://github.com/your-username/your-private-repo/blob/main/path/to/file
```

#### Using Command Line Flag

```bash
ghcp https://github.com/your-username/your-private-repo/blob/main/path/to/file --token your_github_token
```

> **Note**: Environment variable takes precedence over command line flag.

## Configuration

### Environment Variables

| Variable       | Description                                     | Default |
| -------------- | ----------------------------------------------- | ------- |
| `GITHUB_TOKEN` | GitHub Personal Access Token for authentication | `null`  |

### Creating a GitHub Token

1. Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token"
3. Select appropriate scopes (at minimum `repo` for private repositories)
4. Copy the token and set it as an environment variable

## Supported URL Formats

ghcp supports the following GitHub URL formats:

### Single Files

```txt
https://github.com/owner/repo/blob/branch/path/to/file.ext
```

### Directories

```txt
https://github.com/owner/repo/tree/branch/path/to/directory
```

### Root Directory

```txt
https://github.com/owner/repo/tree/branch
```

## Output Behavior

ghcp intelligently handles output paths based on the download type and specified output:

### Single File Downloads

- **Custom filename**: `ghcp <url> config.yml` → saves as `config.yml`
- **Directory target**: `ghcp <url> ./configs/` → saves as `./configs/filename.ext`
- **No output specified**: `ghcp <url>` → saves as `filename.ext` in current directory

### Directory Downloads  

- **Target directory**: `ghcp <url> ./output` → extracts contents directly into `./output/`
- **No output specified**: `ghcp <url>` → extracts contents into current directory

> **Note**: Directory contents are extracted directly into the target directory, not into a subdirectory named after the source directory.

### Examples of Supported URLs

- `https://github.com/microsoft/vscode/blob/main/README.md`
- `https://github.com/google/dart-basics/tree/master/lib`
- `https://github.com/facebook/react/tree/main/packages`
- `https://github.com/owner/repo/tree/feature-branch/src`

## Examples

### Basic File Download

```bash
# Download docker-compose from a repository
ghcp https://github.com/open-webui/open-webui/blob/main/docker-compose.yaml

# Download with custom filename
ghcp https://github.com/open-webui/open-webui/blob/main/docker-compose.yaml compose.yaml

# Download to specific directory (keeps original filename)
ghcp https://github.com/google/dart-basics/blob/master/pubspec.yaml ./config/
```

### Directory Downloads

```bash
# Download directory contents directly to current directory
ghcp https://github.com/google/dart-basics/tree/master/lib

# Download directory contents to specific folder
ghcp https://github.com/facebook/react/tree/main/src ./react-source

# Download documentation contents directly into docs folder
ghcp https://github.com/kubernetes/kubernetes/tree/master/docs ./k8s-docs
```

### Private Repository Access

```bash
# Using environment variable (recommended for security)
export GITHUB_TOKEN=ghp_your_token_here
ghcp https://github.com/your-org/private-repo/blob/main/config/app.yaml

# Using command line flag (less secure, visible in process list)
ghcp https://github.com/your-org/private-repo/tree/main/src --token ghp_your_token_here
```

### Advanced Examples

```bash
# Download specific branch content
ghcp https://github.com/flutter/flutter/tree/stable/packages/flutter/lib

# Download from a specific commit (use commit SHA as branch)
ghcp https://github.com/dart-lang/sdk/tree/abc123def456/pkg/analyzer

# Download nested directories
ghcp https://github.com/kubernetes/kubernetes/tree/master/cmd/kubectl/app

# Download to nested output directories
ghcp https://github.com/microsoft/vscode/tree/main/src/vs/editor ./editor-source

# Download large directories (will show progress for each file)
ghcp https://github.com/tensorflow/tensorflow/tree/master/tensorflow/python
```

### Batch Downloads

```bash
# Download multiple files (using shell scripting)
for url in \
  "https://github.com/owner/repo/blob/main/file1.txt" \
  "https://github.com/owner/repo/blob/main/file2.md"; do
  ghcp "$url"
done
```

## API Rate Limits

GitHub API has rate limits that affect ghcp:

- **Unauthenticated requests**: 60 requests per hour
- **Authenticated requests**: 5,000 requests per hour

### Rate Limit Headers

The tool automatically handles rate limit information and provides clear error messages:

```txt
❌ GitHub API Error: API rate limit exceeded
Rate limit remaining: 0/60 (resets at 2024-01-01T12:00:00Z)
```

### Avoiding Rate Limits

1. **Use authentication**: Authenticated requests have much higher limits (5,000 vs 60)
2. **Batch operations**: Download directories instead of individual files when possible
3. **Be mindful of large directories**: Each file in a directory requires a separate API call
4. **Use caching**: Avoid re-downloading the same content repeatedly

### Rate Limit Best Practices

```bash
# Good: Downloads entire directory in one API call (plus one per file)
ghcp https://github.com/owner/repo/tree/main/src

# Less efficient: Multiple separate commands for files in same directory
ghcp https://github.com/owner/repo/blob/main/src/file1.dart
ghcp https://github.com/owner/repo/blob/main/src/file2.dart
```

## Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/aminnez/ghcp.git
cd ghcp

# Install dependencies
dart pub get

# Run in development mode
dart run bin/ghcp.dart --help

# Build standalone executable
dart compile exe bin/ghcp.dart -o ghcp

# Run tests
dart test

# Run static analysis
dart analyze

# Format code
dart format .
```

## Troubleshooting

### Common Issues

#### "Invalid GitHub URL"

**Error**: `Invalid GitHub URL: Not a valid GitHub URL`

**Solutions**:

- Ensure URL starts with `https://github.com/`
- Check URL format: `https://github.com/owner/repo/tree/branch/path`
- Verify repository exists and is accessible

#### "API rate limit exceeded"

**Error**: `GitHub API Error: API rate limit exceeded`

**Solutions**:

- Wait until rate limit resets (1 hour for unauthenticated)
- Use authentication with GitHub token
- Reduce request frequency

#### "Repository not found"

**Error**: `GitHub API Error: Repository not found`

**Solutions**:

- Verify repository exists and is spelled correctly
- Check if repository is private (requires authentication)
- Ensure you have access to the repository

#### "No download URL available"

**Error**: `Error: No download URL available for path/to/file`

**Solutions**:

- Verify the file exists in the repository
- Check if it's a valid file (not a directory)
- Ensure you have the correct branch name

### Debug Mode

Enable verbose output for debugging:

```bash
# Set debug environment variable
export DEBUG=true
ghcp <url>
```

### Network Issues

If you encounter network-related errors:

```bash
# Check network connectivity
ping github.com

# Test API accessibility
curl -I https://api.github.com
```

## FAQ

### Can I specify a custom filename for downloads?

Yes! For single file downloads, you can specify a custom filename:

```bash
# Download with custom filename
ghcp https://github.com/owner/repo/blob/main/config.yaml my-config.yml

# Download Docker Compose file with shorter name
ghcp https://github.com/owner/repo/blob/main/docker/docker-compose.yml dc.yml
```

### Can I download from private repositories?

Yes! Use a GitHub Personal Access Token with appropriate permissions:

```bash
export GITHUB_TOKEN=your_token
ghcp https://github.com/your-org/private-repo/blob/main/file.txt
```

### Does ghcp clone the entire repository?

No! ghcp only downloads the specific files or directories you request, making it much faster and more efficient than cloning.

### Can I download multiple files at once?

Yes, by downloading a directory that contains multiple files:

```bash
ghcp https://github.com/owner/repo/tree/main/directory-with-multiple-files
```

### What's the difference between blob and tree URLs?

- **blob URLs**: Point to individual files
- **tree URLs**: Point to directories (which may contain multiple files)

### How do I know if a download succeeded?

ghcp provides visual feedback with progress spinners and completion messages. Successful downloads show:

```txt
Downloaded! filename.ext
```

### Can I use ghcp in scripts?

Absolutely! ghcp is designed for scripting and automation:

```bash
#!/bin/bash
ghcp https://github.com/owner/repo/blob/main/config.yaml ./config
echo "Config downloaded successfully!"
```

### Is there a size limit for downloads?

GitHub has specific file size limits:

- **Individual files**: 100MB maximum (GitHub limitation)
- **Directory size**: No specific limit, but consider:
  - API rate limits (60 calls/hour without auth, 5,000 with auth)
  - Each file requires a separate API call
  - Large directories may take significant time
  - Network and disk space constraints

### How can I monitor download progress?

ghcp provides real-time visual feedback:

```txt
# Single file download
⏳ Downloading string_basics.dart...
✔ Downloaded! string_basics.dart

# Directory download  
✔ Downloading 3 of 11 files...
⠋ Downloading basics.dart...
⠋ Downloading comparable_basics.dart...
✔ Done! date_time_basics.dart
⠋ Downloading int_basics.dart...
✔ Done! 11 of 11 files.
```

### Can I resume interrupted downloads?

Currently, ghcp does not support resume functionality. Interrupted downloads will need to be restarted. This is planned for a future release.

### Does ghcp support GitHub Enterprise?

Currently, ghcp only supports GitHub.com. GitHub Enterprise support may be added in future versions based on user demand.

## Contributing

Contributions are welcome! Here's how you can help:

### Development Setup

1. **Fork the repository**
2. **Clone your fork**

   ```bash
   git clone https://github.com/your-username/ghcp.git
   cd ghcp
   ```

3. **Install dependencies**

   ```bash
   dart pub get
   ```

4. **Create a feature branch**

   ```bash
   git checkout -b feature/amazing-feature
   ```

5. **Make your changes and ensure quality**

   ```bash
   # Run tests
   dart test
   
   # Run static analysis
   dart analyze
   
   # Format code
   dart format .
   
   # Check pub publish readiness
   dart pub publish --dry-run
   ```

6. **Commit your changes**

   ```bash
   git add .
   git commit -m "Add amazing feature"
   git push origin feature/amazing-feature
   ```

7. **Submit a pull request**

### Local Testing

```bash
# Test the CLI locally
dart run bin/ghcp.dart <github-url> [output-dir]

# Build and test native executable
dart compile exe bin/ghcp.dart -o ghcp-test
./ghcp-test <github-url> [output-dir]
```

### Code Style

This project follows Dart's official style guide with strict linting rules:

- **Type Safety**: All public APIs must have explicit type annotations
- **Documentation**: All public APIs should have comprehensive documentation
- **Error Handling**: Use custom exceptions with descriptive messages
- **Testing**: Maintain high test coverage for all new features

### Linting Rules

The project uses strict analysis options defined in `analysis_options.yaml`:

```bash
# Check for linting issues
dart analyze

# Fix auto-fixable issues
dart fix --apply
```

### Pull Request Guidelines

- **Small, focused changes**: Keep PRs small and focused on a single feature/fix
- **Tests required**: All new functionality must include tests
- **Documentation**: Update README and inline docs as needed
- **Code quality**: Ensure all lints pass and tests succeed
- **Backwards compatibility**: Avoid breaking changes without discussion

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Dart Team**: For the amazing Dart programming language
- **GitHub**: For providing excellent APIs and platform
- **Open Source Community**: For inspiration and tools
