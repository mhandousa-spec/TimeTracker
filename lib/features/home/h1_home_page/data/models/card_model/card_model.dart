/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: card_model.dart
/// Purpose: Declares `CardModel`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Moved here from the top-level `features/task_management`
///          module, which was deleted. That module held nothing but these 27
///          model files — no controller, no domain layer, no UI — because the
///          real tasks/todo module was stripped from this copy of the app
///          (see `home/main_controller/helper/todo_new_module/tasks_stub.dart`).
///          The models outlived it because `ScheduleController` and
///          `upcoming_schedule_listview` still read boards and cards, so they
///          now live with their only consumers instead of in a feature folder
///          with no feature in it.
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_attachments.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_checklists.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_creator.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_description.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_image.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_members.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_name.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_priority.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_progress.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_progress_color.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_status.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/comment.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/end_date.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/end_time.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/last_update.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/start_date.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/start_time.dart';

class CardModel {
  String? cardId;
  CardCreator? cardCreator;
  CardName? cardName;
  CardDescription? cardDescription;
  StartDate? startDate;
  EndDate? endDate;
  StartTime? startTime;
  EndTime? endTime;
  CardImage? cardImage;
  CardMember? cardMembers;
  List<Comments>? comments;
  CardAttachments? cardAttachments;
  List<CardCheckLists>? cardCheckLists;
  CardStatus? cardStatus;
  CardPriority? cardPriority;
  CardProgress? cardProgress;
  LastUpdate? lastUpdate;
  CardProgressIndicator? progressIndicator;

  CardModel(
      {this.cardId,
      this.cardCreator,
      this.cardName,
      this.cardDescription,
      this.startDate,
      this.endDate,
      this.startTime,
      this.endTime,
      this.cardImage,
      this.cardMembers,
      this.comments,
      this.cardAttachments,
      this.cardCheckLists,
      this.cardStatus,
      this.cardPriority,
      this.cardProgress,
      this.lastUpdate,
      this.progressIndicator});

  CardModel.fromMap(dynamic json, String id) {
    cardName =
        json['Card_Name'] != null ? CardName.fromJson(json['Card_Name']) : null;
    cardDescription = json['Card_Description'] != null
        ? CardDescription.fromJson(json['Card_Description'])
        : null;
    startDate = json['Start_Date'] != null
        ? StartDate.fromJson(json['Start_Date'])
        : null;
    endDate =
        json['End_Date'] != null ? EndDate.fromJson(json['End_Date']) : null;
    startTime = json['Start_Time'] != null
        ? StartTime.fromJson(json['Start_Time'])
        : null;
    endTime =
        json['End_Time'] != null ? EndTime.fromJson(json['End_Time']) : null;
    cardImage = json['Card_Image'] != null
        ? CardImage.fromJson(json['Card_Image'])
        : null;
    cardMembers = json['Card_Members'] != null
        ? CardMember.fromJson(json['Card_Members'])
        : null;
    comments =
        /* json['Comments'] != null ? Comments.fromJson(json['Comments']) : null;*/
        json['Comments'] != null
            ? (json['Comments'] as List<dynamic>)
                .map((item) => Comments.fromJson(item))
                .toList()
            : [];
    cardAttachments = json['Card_Attachments'] != null
        ? CardAttachments.fromJson(json['Card_Attachments'])
        : null;
    cardCheckLists = json['Card_Checklists'] != null
        ? (json['Card_Checklists'] as List<dynamic>)
            .map(
                (item) => CardCheckLists.fromJson(item as Map<String, dynamic>))
            .toList()
        : [];

    // json['Card_Checklists'] != null
    //     ? (json['Card_Checklists'] as List<dynamic>)
    //         .map((item) => CardCheckLists.fromJson(item))
    //         .toList()
    //     : [];

    cardCreator = json['Card_Creator'] != null
        ? CardCreator.fromJson(json['Card_Creator'])
        : null;
    cardStatus = json['Card_Status'] != null
        ? CardStatus.fromJson(json['Card_Status'])
        : null;
    cardPriority = json['Card_Priority'] != null
        ? CardPriority.fromJson(json['Card_Priority'])
        : null;
    cardProgress = json['Card_Progress'] != null
        ? CardProgress.fromJson(json['Card_Progress'])
        : null;
    lastUpdate = json['Last_Update'] != null
        ? LastUpdate.fromJson(json['Last_Update'])
        : null;
    progressIndicator = json['Progress_Indicator'] != null
        ? CardProgressIndicator.fromJson(json['Progress_Indicator'])
        : null;

    cardId = id;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (cardName != null) {
      map['Card_Name'] = cardName?.toJson();
    }
    if (cardDescription != null) {
      map['Card_Description'] = cardDescription?.toJson();
    }
    if (startDate != null) {
      map['Start_Date'] = startDate?.toJson();
    }
    if (endDate != null) {
      map['End_Date'] = endDate?.toJson();
    }
    if (startTime != null) {
      map['Start_Time'] = startTime?.toJson();
    }
    if (endTime != null) {
      map['End_Time'] = endTime?.toJson();
    }
    if (cardImage != null) {
      map['Card_Image'] = cardImage?.toJson();
    }
    if (cardMembers != null) {
      map['Card_Members'] = cardMembers?.toJson();
    }
    if (comments != null) {
      // map['Comments'] = comments?.toJson();
      map['Comments'] = comments!.map((e) => e.toJson()).toList();
    }
    if (cardAttachments != null) {
      map['Card_Attachments'] = cardAttachments?.toJson();
    }
    if (cardCheckLists != null) {
      map['Card_Checklists'] = cardCheckLists?.map((e) => e.toJson()).toList();
    }

    if (cardCreator != null) {
      map['Card_Creator'] = cardCreator?.toJson();
    }
    if (cardStatus != null) {
      map['Card_Status'] = cardStatus?.toJson();
    }
    if (cardPriority != null) {
      map['Card_Priority'] = cardPriority?.toJson();
    }
    if (cardProgress != null) {
      map['Card_Progress'] = cardProgress?.toJson();
    }
    if (lastUpdate != null) {
      map['Last_Update'] = lastUpdate?.toJson();
    }
    if (progressIndicator != null) {
      map['Progress_Indicator'] = progressIndicator?.toJson();
    }
    return map;
  }
}
