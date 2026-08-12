import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:csv/csv.dart';
import 'package:gsheet_localization/gsheet_localization.dart';
import 'package:http/http.dart' as http;
import 'package:localization_builder/localization_builder.dart';
import 'package:source_gen/source_gen.dart';

class GSheetLocalizationGenerator
    extends GeneratorForAnnotation<GSheetLocalization> {
  const GSheetLocalizationGenerator();

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element,
      ConstantReader annotation,
      BuildStep buildStep,
      ) async {

    if (element is! ClassElement) {
      final name = element.name;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$name`.',
        todo: 'Remove the GSheetLocalization annotation from `$name`.',
        element: element,
      );
    }

    if (element.name != null && !element.name!.endsWith('Delegate')) {
      final name = element.name!;
      throw InvalidGenerationSourceError(
        'Generator for target `$name` should have a name ending with `Delegate`.',
        todo:
        'Rename `$name` to something ending with `Delegate` (example: ${name}Delegate).',
        element: element,
      );
    }

    final localizationClassName =
        '${element.name!.replaceAll('Delegate', '')}Data';

    final localizations = await _loadLocalization(
      annotation: annotation,
      buildStep: buildStep,
      name: localizationClassName,
    );

    return DartLocalizationBuilder().build(localizations);
  }

  Future<Localizations> _loadLocalization({
    required ConstantReader annotation,
    required BuildStep buildStep,
    required String name,
  }) async {
    final sourceType = annotation.read('sourceType').objectValue;
    final sourceIndex = sourceType.getField('index')!.toIntValue()!;

    switch (LocalizationSourceType.values[sourceIndex]) {
      case LocalizationSourceType.googleSheet:
        return _downloadGoogleSheet(
          documentId: annotation.read('docId').stringValue,
          sheetId: annotation.read('sheetId').stringValue,
          name: name,
        );

      case LocalizationSourceType.assets:
        return _loadFromAssets(
          buildStep: buildStep,
          assetPath: annotation.read('assetsPath').stringValue,
          name: name,
        );
    }
  }

  Future<Localizations> _downloadGoogleSheet({
    required String documentId,
    required String sheetId,
    required String name,
  }) async {
    final url =
        'https://docs.google.com/spreadsheets/d/$documentId/export'
        '?format=csv&id=$documentId&gid=$sheetId';

    log.info('Downloading localization from Google Sheet');
    log.fine(url);

    final response = await http.get(
      Uri.parse(url),
      headers: const {
        'accept': 'text/csv;charset=UTF-8',
      },
    );

    return _parseCsv(
      body: utf8.decode(response.bodyBytes),
      name: name,
    );
  }

  Future<Localizations> _loadFromAssets({
    required BuildStep buildStep,
    required String assetPath,
    required String name,
  }) async {
    log.info('Loading localization from asset: $assetPath');

    final asset = AssetId(
      buildStep.inputId.package,
      assetPath,
    );

    if (!await buildStep.canRead(asset)) {
      throw InvalidGenerationSourceError(
        'Localization asset not found: $assetPath',
      );
    }

    final body = await buildStep.readAsString(asset);

    return _parseCsv(
      body: body,
      name: name,
    );
  }

  Localizations _parseCsv({
    required String body,
    required String name,
  }) {
    final rows = Csv(
      dynamicTyping: false,
    ).decode(body);

    final parser = CsvLocalizationParser();

    final result = parser.parse(
      input: rows,
      name: name,
    );

    return result.result;
  }
}


