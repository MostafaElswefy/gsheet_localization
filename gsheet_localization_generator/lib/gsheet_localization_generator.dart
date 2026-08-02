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
      final name = element.name;
      throw InvalidGenerationSourceError(
        'Generator for target `$name` should have a name ending with `Delegate`.',
        todo:
        'Rename `$name` to something ending with `Delegate` (example: `${name}Delegate`).',
        element: element,
      );
    }

    final localizationClassName =
        '${element.name!.replaceAll('Delegate', '')}Data';

    final docId =
    annotation.objectValue.getField('docId')!.toStringValue()!;

    final sheetId =
    annotation.objectValue.getField('sheetId')!.toStringValue()!;

    final localizations = await _downloadGoogleSheet(
      documentId: docId,
      sheetId: sheetId,
      name: localizationClassName,
    );

    final builder = DartLocalizationBuilder();

    return builder.build(localizations);
  }

  Future<Localizations> _downloadGoogleSheet({
    required String documentId,
    required String sheetId,
    required String name,
  }) async {
    final url =
        'https://docs.google.com/spreadsheets/d/$documentId/export'
        '?format=csv&id=$documentId&gid=$sheetId';

    log.info('Downloading csv from Google Sheet: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: const {
        'accept': 'text/csv;charset=UTF-8',
      },
    );

    final body = utf8.decode(response.bodyBytes);

    log.fine(body);

    final rows = Csv(dynamicTyping: false).decode(body);

    final parser = CsvLocalizationParser();
    final result = parser.parse(
      input: rows,
      name: name,
    );

    return result.result;
  }
}