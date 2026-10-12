// ignore_for_file: unnecessary_this

/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: email_model.dart
/// Purpose: Declares `Email`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Email {
  List<String?>? emails;

  List<Timestamp?>? timestamps;
  Email({
    this.emails,
    this.timestamps,
  });

  Email copyWith({
    List<String?>? emails,
    List<String?>? isSecondEmail,
    List<Timestamp?>? timestamps,
  }) {
    return Email(
      emails: emails ?? this.emails,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Email': emails,
      'Timestamp': timestamps,
    };
  }

  factory Email.fromMap(Map<String, dynamic> map) {
    return Email(
      emails: map['Email'] != null
          ? List<String?>.from(
              (map['Email']),
            )
          : null,
      timestamps: map['Timestamp'] != null
          ? List<Timestamp?>.from(
              (map['Timestamp']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Email.fromJson(String source) =>
      Email.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Email(Email: $emails, Timestamp: $timestamps,)';

  @override
  bool operator ==(covariant Email other) {
    if (identical(this, other)) return true;

    return listEquals(other.emails, emails) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => emails.hashCode ^ timestamps.hashCode;
}
