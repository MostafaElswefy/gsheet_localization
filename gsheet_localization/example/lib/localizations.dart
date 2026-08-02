import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gsheet_localization/gsheet_localization.dart';

part 'localizations.g.dart';

@GSheetLocalization(
  "1hmC0Hm4QROPmy0uOAhSAPZNAam-SAiJm",
  "655639681",
  1,
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

