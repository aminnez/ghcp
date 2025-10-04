import 'dart:io';

import 'package:ghcp/cli/cli_runner.dart';

/// The entry point for the GitHub Content Downloader (ghcp) command-line tool.
///
/// This function initializes the CLI runner and executes it with the provided arguments.
/// It handles any uncaught errors and ensures the process exits with the appropriate status code.
Future<void> main(List<String> args) async {
  final cli = CliRunner();
  final exitCode = await cli.run(args);
  exit(exitCode);
}
