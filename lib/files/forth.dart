import 'package:flutter/material.dart';

class AppLanguage{static Locale currentLocale = const Locale('en');

  static final Map<String, Map<String, String>> translations = {
    "en": {
      "next": "Next",
      "title": "Choose your preferred language",
      "subtitle":
      "From the below languages, Please choose your native language.",
    },
    "hi": {
      "next": "आगे बढ़ें",
      "title": "अपनी पसंदीदा भाषा चुनें",
      "subtitle":
      "नीचे दी गई भाषाओं में से अपनी भाषा चुनें।",
    },
    "es": {
      "next": "Siguiente",
      "title": "Elige tu idioma",
      "subtitle":
      "Seleccione su idioma preferido.",
    },
  };

  static String text(String key) {
    return translations[currentLocale.languageCode]?[key] ?? key;
  }
}