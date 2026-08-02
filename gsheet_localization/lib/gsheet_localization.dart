library flutter_sheet_localization;

export 'package:template_string/template_string.dart';

class GSheetLocalization  {
  final String docId;
  final String sheetId;
  final int version;
  final bool jsonSerializers;
  const GSheetLocalization  (
    this.docId,
    this.sheetId,
    this.version, {
    this.jsonSerializers = true,
  });
}
