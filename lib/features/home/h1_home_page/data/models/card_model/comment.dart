/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: comment.dart
/// Purpose: Declares `Comments`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class Comments {
  Comments({
    this.commentCreator,
    this.comment,
    this.timestamp,
  });

  Comments.fromJson(dynamic json) {
    commentCreator = json['Comment_Creator'] != null
        ? json['Comment_Creator'].cast<String>()
        : [];
    comment = json['Comments'] != null ? json['Comments'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? commentCreator;
  List<String>? comment;
  List<Timestamp>? timestamp;
  Comments copyWith({
    List<String>? commentCreator,
    List<String>? comment,
    List<Timestamp>? timestamp,
  }) =>
      Comments(
        commentCreator: commentCreator ?? this.commentCreator,
        comment: comment ?? this.comment,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Comment_Creator'] = commentCreator;
    map['Comments'] = comment;
    map['Timestamp'] = timestamp;
    return map;
  }
}
