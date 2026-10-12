/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: name_case.dart
/// Purpose: Declares `NameCase` — the ONE helper the whole module uses to
///          show a person's name, job title or department in proper case.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (owner finding, 14:17 — "salma fathy" /
///            "service center coordinator" on the employee dashboard)
///
/// The Active Directory upload stores some fields in lower case (known
/// bug), and the module read names from different sources (the employee
/// directory vs the signed-in identity), so the same person showed as
/// "Salma Fathy" on one card and "salma fathy" on another.
///
/// Rules (Latin text only — Arabic is returned untouched):
/// - a word stored entirely in lower case gets a capital first letter;
/// - small connector words (of, and, the, for, in, on, at, to, a, an) stay
///   lower case unless they start the text ("Director of Administrative
///   Affairs");
/// - words with any capital (HR, IT, McDonald, e-mail-like text) are kept as
///   stored;
/// - text that is ENTIRELY upper case ("SALMA FATHY") becomes Title Case,
///   except short acronyms (≤ 3 letters: HR, IT, QA).
/// Hyphenated words are cased per part ("Al-Sayed"). Pure Dart.

abstract final class NameCase {
  static const Set<String> _small = <String>{'of', 'and', 'the', 'for', 'in', 'on', 'at', 'to', 'a', 'an'};

  static final RegExp _latin = RegExp(r'[A-Za-z]');
  static final RegExp _arabic = RegExp(r'[؀-ۿ]');

  /// Function Name: [proper]
  ///
  /// Purpose: [text] in proper case (see the file header); '' stays ''.
  ///
  /// Return type: [String]
  static String proper(String text) {
    final String t = text.trim();
    if (t.isEmpty || !_latin.hasMatch(t) || _arabic.hasMatch(t) || t.contains('@')) return t;
    final bool allUpper = t == t.toUpperCase() && t != t.toLowerCase();
    final List<String> words = t.split(RegExp(r'\s+'));
    return <String>[
      for (int i = 0; i < words.length; i++) _word(words[i], first: i == 0, allUpper: allUpper),
    ].join(' ');
  }

  static String _word(String word, {required bool first, required bool allUpper}) {
    if (word.contains('-')) {
      return word.split('-').map((String p) => _word(p, first: true, allUpper: allUpper)).join('-');
    }
    if (word.isEmpty) return word;
    final String lower = word.toLowerCase();
    if (allUpper) {
      if (word.length <= 3 && !_small.contains(lower)) return word;
    } else if (word != lower) {
      return word; // has a capital already → as stored
    }
    if (!first && _small.contains(lower)) return lower;
    return lower[0].toUpperCase() + lower.substring(1);
  }
}
