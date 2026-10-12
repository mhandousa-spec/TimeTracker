import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/page_model.dart';

// Date: 21/2/2025
// By: Fouad
// Last update: 21/2/2025
// Objectives: Implementation of response model
class ResponseModel {
  final String submittedBy;
  final List<Timestamp> timestamps;
  final List<Timestamp> reminder;
  final List<PageModel>? pages;
  final String? id;

  ResponseModel({
    required this.submittedBy,
    required this.timestamps,
    required this.reminder,
    required this.pages,
    this.id,
  });
  static const String submittedByField = 'Submitted_By';
  static const String timestampsField = 'Timestamps';
  static const String reminderField = 'Reminder';
  static const String pagesField = 'Pages';

  factory ResponseModel.fromMap(Map<String, dynamic> map, String id) {
    return ResponseModel(
      id: id,
      submittedBy: map[submittedByField],
      timestamps:List<Timestamp>.from( map[timestampsField]),
      reminder:List<Timestamp>.from( map[reminderField]),
      pages: map[pagesField]==null?null:   List<PageModel>.from((map[pagesField] as List<dynamic>)
          .map<PageModel>((x) => PageModel.fromMap(x as Map<String, dynamic>))),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      submittedByField: submittedBy,
      timestampsField: timestamps,
      reminderField: reminder,
      pagesField: pages?.map((e) => e.toMap()).toList(),
    };
  }

  ResponseModel copyWith({
    String? submittedBy,
    List<Timestamp>? timestamps,
    List<Timestamp>? reminder,
    List<PageModel>? pages,
    String? id,
  }) {
    return ResponseModel(
      submittedBy: submittedBy ?? this.submittedBy,
      timestamps: timestamps ?? this.timestamps,
      reminder: reminder ?? this.reminder,
      pages: pages ?? this.pages,
      id: id ?? this.id,
    );
  }
}
