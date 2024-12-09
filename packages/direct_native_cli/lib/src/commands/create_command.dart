import 'package:args/command_runner.dart';
import '../templates/project_template.dart';

class CreateCommand extends Command {
  @override
  final name = 'create';

  @override
  final description = 'Create a new Direct Native project';

  CreateCommand() {
    argParser.addOption(
        'project-name',
        abbr: 'n',
        help: 'Name of the project to create',
        mandatory: true
    );

    argParser.addFlag(
      'ios',
      help: 'Generate iOS project',
      defaultsTo: true,
    );

    argParser.addFlag(
      'android',
      help: 'Generate Android project',
      defaultsTo: true,
    );
  }

  @override
  Future<void> run() async {
    final projectName = argResults!['project-name'];
    print('Creating Direct Native project: $projectName');

    // Create project directory structure
    final creator = ProjectCreator(projectName);
    await creator.createProject(
      includeIos: argResults!['ios'],
      includeAndroid: argResults!['android'],
    );
  }
}