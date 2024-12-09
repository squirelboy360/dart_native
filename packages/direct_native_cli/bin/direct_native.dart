import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import '../lib/src/commands/create_command.dart';

void main(List<String> args) {
  final runner = CommandRunner('direct_native', 'Direct Native framework CLI')
    ..addCommand(CreateCommand());

  runner.run(args).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64);
  });
}