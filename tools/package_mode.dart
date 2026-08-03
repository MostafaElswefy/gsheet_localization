import 'dart:io';

enum PackageMode {
  local,
  git,
}

void main(List<String> args) async {
  if (args.isEmpty) {
    _printUsage();
    exit(1);
  }

  late final PackageMode mode;

  switch (args.first.toLowerCase()) {
    case 'local':
      mode = PackageMode.local;
      break;

    case 'git':
      mode = PackageMode.git;
      break;

    default:
      _printUsage();
      exit(1);
  }

  final packages = <String>[
    'gsheet_localization',
    'gsheet_localization_generator',
    'localization_builder',
    'template_string',
  ];

  for (final package in packages) {
    final file = File('$package/pubspec.yaml');

    if (!file.existsSync()) {
      stdout.writeln('⚠ pubspec not found: ${file.path}');
      continue;
    }

    stdout.writeln('Processing ${file.path} ...');

    final content = await file.readAsString();

    final updated = switchDependencies(
      content: content,
      mode: mode,
    );

    if (updated != content) {
      await file.writeAsString(updated);
      stdout.writeln('✔ Updated');
    } else {
      stdout.writeln('• No changes');
    }
  }

  stdout.writeln('');
  stdout.writeln('Done.');
}

void _printUsage() {
  stdout.writeln('');
  stdout.writeln('Usage:');
  stdout.writeln('');
  stdout.writeln('dart run tools/package_mode.dart local');
  stdout.writeln('dart run tools/package_mode.dart git');
  stdout.writeln('');
}

/// سيتم تنفيذها فى الجزء التالى
String switchDependencies({
  required String content,
  required PackageMode mode,
}) {
  return content;
}



