import 'dart:ui';

import 'package:flutter/foundation.dart';

final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('fr'));

void setLocale(Locale locale) {
  appLocale.value = locale;
}

bool get isFrench => appLocale.value.languageCode == 'fr';
bool get isEnglish => appLocale.value.languageCode == 'en';
