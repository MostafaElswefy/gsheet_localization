import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:gsheet_localization_generator/gsheet_localization_generator.dart';

Builder gsheetLocalization(BuilderOptions options) => SharedPartBuilder(
  [GSheetLocalizationGenerator()],
  'gsheet_localization',
);