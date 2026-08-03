library gsheet_localization;

export 'package:template_string/template_string.dart';

enum LocalizationSourceType {
  googleSheet,
  assets,
}

class GSheetLocalization {
  final LocalizationSourceType sourceType;

  // Google Sheet
  final String? docId;
  final String? sheetId;
  final int? version;

  // Assets
  final String? assetsPath;

  final bool jsonSerializers;

  /// Google Sheet Source
  const GSheetLocalization.googleSheet(
      this.docId,
      this.sheetId,
      this.version, {
        this.jsonSerializers = true,
      })  : sourceType = LocalizationSourceType.googleSheet,
        assetsPath = null;

  /// Assets Source
  const GSheetLocalization.assets(
      this.assetsPath, {
        this.jsonSerializers = true,
      })  : sourceType = LocalizationSourceType.assets,
        docId = null,
        sheetId = null,
        version = null;
}

