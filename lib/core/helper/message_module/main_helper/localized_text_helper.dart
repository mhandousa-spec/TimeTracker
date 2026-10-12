/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: localized_text_helper.dart
/// Purpose: Declares `LocalizedTextHelper`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/message_module/interface/controller/messaging_init_controller.dart';

import '../../main_helper/format_title.dart' as Constants;

//Youssef Ashraf
///Localization Helper Text To determine which word to use
abstract class LocalizedTextHelper {
  static String formatString({
    required String? secondaryLanguageText,
    required String primaryLanguageText,
  }) {
    bool isSecondaryLanguage = Get.find<MessagingInitController>()
        .messagingConfigurations
        .isSecondaryLanguage();

    String selectedText = isSecondaryLanguage && secondaryLanguageText != null
        ? secondaryLanguageText
        : primaryLanguageText;

    // Capitalize each word

    return capitalize(selectedText);
  }

  static String capitalize(String input) {
    input.toLowerCase();
    input = applyAbbreviation(input);

    if (input.isEmpty) {
      return "";
    }

    List<String> words = input.split(" ");
    words = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      } else {
        return "";
      }
    }).toList();
    // print('words: $words');
    return words.join(" ");
  }

  static String applyAbbreviation(String input) {
    for (String abbreviation in Constants.abbreviation) {
      RegExp regex = RegExp(r'\b' + abbreviation + r'\b', caseSensitive: false);
      if (regex.hasMatch(input)) {
        input = input.replaceAllMapped(
            regex, (match) => abbreviation.toUpperCase());
      }
    }
    return input;
  }
}
