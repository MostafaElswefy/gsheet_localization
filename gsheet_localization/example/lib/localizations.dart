import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gsheet_localization/gsheet_localization.dart';

part 'localizations.g.dart';




/// To Generate Files
/// dart run build_runner build --delete-conflicting-outputs


// @GSheetLocalization.assets(
//   "assets/localization/app.csv",
// )

@GSheetLocalization.googleSheet(
  "1hmC0Hm4QROPmy0uOAhSAPZNAam-SAiJm",
  "655639681",
  2,
)

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizationsData> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => localizedLabels.containsKey(locale);

  @override
  Future<AppLocalizationsData> load(Locale locale) =>
      SynchronousFuture(localizedLabels[locale]!);

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}

extension AppLocalizationX on BuildContext {
  AppLocalizationsData get labels =>
      Localizations.of<AppLocalizationsData>(
        this,
        AppLocalizationsData,
      )!;
}

