/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: card_progress_color.dart
/// Purpose: Declares `CardProgressIndicator`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

class CardProgressIndicator {
  CardProgressIndicator({
    this.progressPercentage,
    this.colors,
  });

  CardProgressIndicator.fromJson(dynamic json) {
    progressPercentage = json['Progress_Percentage'] != null
        ? json['Progress_Percentage'].cast<String>()
        : [];
    colors = json['Colors'] != null ? json['Colors'].cast<String>() : [];
  }

  List<String>? progressPercentage;
  List<String>? colors;

  CardProgressIndicator copyWith({
    List<String>? progressPercentage,
    List<String>? colors,
  }) =>
      CardProgressIndicator(
        progressPercentage: progressPercentage ?? this.progressPercentage,
        colors: colors ?? this.colors,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Progress_Percentage'] = progressPercentage;
    map['Colors'] = colors;
    return map;
  }
}
