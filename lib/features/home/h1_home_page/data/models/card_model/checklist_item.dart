/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: checklist_item.dart
/// Purpose: Declares `CheckListItems`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class CheckListItems {
  List<String>? itemTitle;
  List<String>? itemMembers;
  List<String>? itemStartDate;
  List<String>? itemEndDate;
  List<String>? itemStartTime;
  List<String>? itemEndTime;
  List<String>? itemStatus;
  List<Timestamp>? timestamp;

  CheckListItems({
    this.itemTitle,
    this.itemMembers,
    this.itemStartDate,
    this.itemEndDate,
    this.itemStartTime,
    this.itemEndTime,
    this.itemStatus,
    this.timestamp,
  });

  CheckListItems.fromJson(dynamic json) {
    itemTitle =
        json['Item_Title'] != null ? json['Item_Title'].cast<String>() : [];
    itemMembers = 
        json['Item_Members'] != null ? json['Item_Members'].cast<String>() : [];
    itemStartDate =
        json['Item_Start_Date'] != null ? json['Item_Start_Date'].cast<String>() : [];
    itemEndDate =
        json['Item_End_Date'] != null ? json['Item_End_Date'].cast<String>() : [];
    itemStartTime =
        json['Item_Start_Time'] != null ? json['Item_Start_Time'].cast<String>() : [];
    itemEndTime =
        json['Item_End_Time'] != null ? json['Item_End_Time'].cast<String>() : [];
    itemStatus =
        json['Item_Status'] != null ? json['Item_Status'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Item_Title'] = itemTitle;
    map['Item_Members'] = itemMembers;
    map['Item_Start_Date'] = itemStartDate;
    map['Item_End_Date'] = itemEndDate;
    map['Item_Start_Time'] = itemStartTime;
    map['Item_End_Time'] = itemEndTime;
    map['Item_Status'] = itemStatus;
    map['Timestamp'] = timestamp;
    return map;
  }
}