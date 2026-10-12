/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: card_checklists.dart
/// Purpose: Declares `CardCheckLists`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/checklist_item.dart';

class CardCheckLists {
  List<String>? checkListTitle;
  List<CheckListItems>? checkListItems;
  List<String>? checkListStatus;
  List<Timestamp>? timestamp;

  CardCheckLists({
    this.checkListTitle,
    this.checkListItems,
    this.checkListStatus,
    this.timestamp,
  });

  CardCheckLists.fromJson(dynamic json) {
    checkListTitle = json['CheckList_Title'] != null
        ? json['CheckList_Title'].cast<String>()
        : [];
    checkListItems = json['CheckList_Items'] != null
        ? (json['CheckList_Items'] as List<dynamic>)
            .map((item) => CheckListItems.fromJson(item))
            .toList()
        : [];
    /*checkListItems = (json['CheckList_Items'] != null ? CheckListItems.fromJson(json['CheckList_Items']) : []) as List<CheckListItems>?;*/
    checkListStatus = json['CheckList_Status'] != null
        ? json['CheckList_Status'].cast<String>()
        : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CheckList_Title'] = checkListTitle;
    map['CheckList_Items'] = checkListItems?.map((e) => e.toJson()).toList();
    map['CheckList_Status'] = checkListStatus;
    map['Timestamp'] = timestamp;
    return map;
  }
}
