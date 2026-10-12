/// Module: messaging / chat / data/models/sub_models/pin_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// ****************** FILE INFO ****************************
/// File Name : pin_model.dart
/// Purpose: it holds the data of the pin acation
/// Author : Mohamed Elrashidy
/// Created at: 4/3/2025

class PinModel {
  List<bool> isPinned;
  List<String> userId;
  List<Timestamp> pinnedAt;
  PinModel({
    required this.isPinned,
    required this.userId,
    required this.pinnedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'Pinned_Messages': isPinned,
      'UserId': userId,
      'Pinned_At': pinnedAt,
    };
  }

  factory PinModel.fromMap(Map<String, dynamic> map) {
    return PinModel(
      isPinned: List<bool>.from(map['Pinned_Messages']),
      userId: List<String>.from(map['UserId']),
      pinnedAt: List<Timestamp>.from(map['Pinned_At']),
    );
  }
}