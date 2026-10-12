/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_display.dart
/// Purpose: How the three feedback kinds, the three statuses, the four
///          priorities and the seven "More Options" taxonomies are named and
///          coloured on screen.
/// Author: Knowticed Plus team
/// Created at: 1/9/2026
/// Updated: 2/9/2026 - Added a label helper per enum in
///          `feedback_details.dart`, so the form's dropdowns never hardcode an
///          option string and the request card can name the same values later.
///
/// Kept in ONE place because the request card, the status chips and the new
/// request form all name the same values. When "Comments And Feedback" became
/// "Improvements To Existing Feature" the label had to change in exactly one
/// spot, which is the point.
///
/// Nothing here touches the wire values — see the note on [FeedbackKind].

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/generated/l10n.dart';

abstract final class FeedbackDisplay {
  const FeedbackDisplay._();

  /// The label above each box in the form, and the title on each request card.
  static String kindLabel(BuildContext context, FeedbackKind kind) {
    switch (kind) {
      case FeedbackKind.bug:
        return S.of(context).reportBugs;
      case FeedbackKind.comment:
        // Figma (MESBAH 7628:7681) renamed this from "Comments And Feedback"
        // on 1/9/2026. The stored value is still `'comment'`.
        return S.of(context).improvementsToExistingFeature;
      case FeedbackKind.featureRequest:
        return S.of(context).requestNewFeature;
    }
  }

  /// The 30×30 glyph on a request card and beside each box in the form.
  static String kindIcon(FeedbackKind kind) {
    switch (kind) {
      case FeedbackKind.bug:
        return 'assets/icons_assets/main_icons_assets/warning_exclamation_circle.svg';
      case FeedbackKind.comment:
        return 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg';
      case FeedbackKind.featureRequest:
        return 'assets/icons_assets/main_icons_assets/vectors_add.svg';
    }
  }

  /// Status names.
  ///
  /// NOT `S.of(context).fixed`: that key is the salary sense of the word and
  /// translates to "ثابت" (constant), which is wrong for a bug that has been
  /// fixed. [feedbackFixed] and [feedbackClosed] were added for this screen.
  static String statusLabel(BuildContext context, FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.open:
        return S.of(context).open;
      case FeedbackStatus.fixed:
        return S.of(context).feedbackFixed;
      case FeedbackStatus.closed:
        return S.of(context).feedbackClosed;
    }
  }

  /// Matches the Figma card: Open amber, Fixed green, Closed red.
  static Color statusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.open:
        return AppColors.orange;
      case FeedbackStatus.fixed:
        return AppColors.green;
      case FeedbackStatus.closed:
        return AppColors.red;
    }
  }

  static String priorityLabel(BuildContext context, FeedbackPriority priority) {
    switch (priority) {
      case FeedbackPriority.low:
        return S.of(context).low;
      case FeedbackPriority.medium:
        return S.of(context).medium;
      case FeedbackPriority.high:
        return S.of(context).high;
      case FeedbackPriority.critical:
        return S.of(context).critical;
    }
  }

  // ── "More Options" panel (2/9/2026) ───────────────────────────────────────
  //
  // One helper per enum in `feedback_details.dart`. They are here rather than
  // on the enums themselves for the reason this whole file exists: an enum in
  // the domain layer must not import `S`, and the request card will want these
  // same labels the moment it starts showing what a report was filed against.
  //
  // Every switch is exhaustive and returns from each arm, so adding a value to
  // one of those enums is a COMPILE error here rather than a blank cell in the
  // UI. That is deliberate — do not add a `default`.

  /// Which part of the app the report is about.
  static String moduleLabel(BuildContext context, FeedbackModule module) {
    switch (module) {
      case FeedbackModule.requests:
        return S.of(context).requests;
      case FeedbackModule.home:
        return S.of(context).home;
      case FeedbackModule.hr:
        return S.of(context).hr;
      case FeedbackModule.knowledgeHub:
        return S.of(context).knowledgeHub;
      case FeedbackModule.services:
        return S.of(context).services;
      case FeedbackModule.formBuilder:
        return S.of(context).formBuilder;
      case FeedbackModule.messages:
        return S.of(context).messages;
      case FeedbackModule.database:
        return S.of(context).database;
      case FeedbackModule.notifications:
        return S.of(context).notifications;
      case FeedbackModule.calendar:
        return S.of(context).calendar;
      case FeedbackModule.roleManagement:
        return S.of(context).roleManagement;
      case FeedbackModule.settings:
        return S.of(context).settings;
    }
  }

  /// The specific screen or flow inside the module.
  static String screenSectionLabel(
    BuildContext context,
    FeedbackScreenSection section,
  ) {
    switch (section) {
      case FeedbackScreenSection.leaveRequestApproval:
        return S.of(context).leaveRequestApproval;
      case FeedbackScreenSection.leaveRequestNew:
        return S.of(context).leaveRequestNew;
      case FeedbackScreenSection.leaveRequestList:
        return S.of(context).leaveRequestList;
      case FeedbackScreenSection.businessTrip:
        return S.of(context).businessTrip;
      case FeedbackScreenSection.expenseClaim:
        return S.of(context).expenseClaim;
      case FeedbackScreenSection.certificateRequest:
        return S.of(context).certificateRequest;
    }
  }

  /// Something that looks wrong.
  static String designIssueLabel(
    BuildContext context,
    FeedbackDesignIssue issue,
  ) {
    switch (issue) {
      case FeedbackDesignIssue.layoutAlignment:
        return S.of(context).layoutAlignment;
      case FeedbackDesignIssue.coloursContrast:
        return S.of(context).coloursContrast;
      case FeedbackDesignIssue.textFont:
        return S.of(context).textFont;
      case FeedbackDesignIssue.iconsImages:
        return S.of(context).iconsImages;
      case FeedbackDesignIssue.spacingSizing:
        return S.of(context).spacingSizing;
      case FeedbackDesignIssue.arabicRtlLayout:
        return S.of(context).arabicRtlLayout;
      case FeedbackDesignIssue.darkMode:
        return S.of(context).darkMode;
      case FeedbackDesignIssue.doesntFitMyScreen:
        return S.of(context).doesntFitMyScreen;
      case FeedbackDesignIssue.otherDesignIssue:
        return S.of(context).otherDesignIssue;
    }
  }

  /// Something that behaves wrong.
  static String logicIssueLabel(
    BuildContext context,
    FeedbackLogicIssue issue,
  ) {
    switch (issue) {
      case FeedbackLogicIssue.buttonActionNotWorking:
        return S.of(context).buttonActionNotWorking;
      case FeedbackLogicIssue.wrongResultOrCalculation:
        return S.of(context).wrongResultOrCalculation;
      case FeedbackLogicIssue.dataNotSaving:
        return S.of(context).dataNotSaving;
      case FeedbackLogicIssue.dataNotLoading:
        return S.of(context).dataNotLoading;
      case FeedbackLogicIssue.wrongValidationMessage:
        return S.of(context).wrongValidationMessage;
      case FeedbackLogicIssue.accessDeniedWrongly:
        return S.of(context).accessDeniedWrongly;
      case FeedbackLogicIssue.notificationNotReceived:
        return S.of(context).notificationNotReceived;
      case FeedbackLogicIssue.duplicatedOrOutOfSync:
        return S.of(context).duplicatedOrOutOfSync;
      case FeedbackLogicIssue.crashOrFreeze:
        return S.of(context).crashOrFreeze;
      case FeedbackLogicIssue.otherLogicIssue:
        return S.of(context).otherLogicIssue;
    }
  }

  /// The hardware the problem was seen on.
  static String deviceLabel(BuildContext context, FeedbackDevice device) {
    switch (device) {
      case FeedbackDevice.iphone:
        return S.of(context).iphone;
      case FeedbackDevice.ipad:
        return S.of(context).ipad;
      case FeedbackDevice.androidPhone:
        return S.of(context).androidPhone;
      case FeedbackDevice.androidTablet:
        return S.of(context).androidTablet;
      case FeedbackDevice.windowsLaptopDesktop:
        return S.of(context).windowsLaptopDesktop;
      case FeedbackDevice.macLaptopDesktop:
        return S.of(context).macLaptopDesktop;
      case FeedbackDevice.webBrowser:
        return S.of(context).webBrowser;
      case FeedbackDevice.other:
        return S.of(context).other;
    }
  }

  /// The platform the app was running on.
  ///
  /// The four proper nouns — iOS, iPadOS, macOS, Android — are keys like every
  /// other label rather than literals, even though English and Arabic spell
  /// three of them identically. A brand that is currently the same in both
  /// locales is still a translator's call, not a developer's.
  static String softwareTypeLabel(
    BuildContext context,
    FeedbackSoftwareType type,
  ) {
    switch (type) {
      case FeedbackSoftwareType.ios:
        return S.of(context).ios;
      case FeedbackSoftwareType.ipados:
        return S.of(context).ipados;
      case FeedbackSoftwareType.android:
        return S.of(context).android;
      case FeedbackSoftwareType.windows:
        return S.of(context).windows;
      case FeedbackSoftwareType.macos:
        return S.of(context).macos;
      case FeedbackSoftwareType.webOrBrowser:
        return S.of(context).webOrBrowser;
    }
  }

  /// How reproducible the problem is.
  static String frequencyLabel(
    BuildContext context,
    FeedbackFrequency frequency,
  ) {
    switch (frequency) {
      case FeedbackFrequency.everyTime:
        return S.of(context).everyTime;
      case FeedbackFrequency.mostOfTheTime:
        return S.of(context).mostOfTheTime;
      case FeedbackFrequency.rarely:
        return S.of(context).rarely;
      case FeedbackFrequency.happenedOnce:
        return S.of(context).happenedOnce;
    }
  }

  /// A human size for an attachment. Same thresholds the knowledge-hub
  /// document card uses, so the two read identically.
  static String readableSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// File-type glyph for an attachment.
  ///
  /// Copied from `selectedDocumentWidget` (knowledge_hub) rather than imported:
  /// that widget hardcodes `width: 310.w`, which overflows the 265-wide cell
  /// this grid gives it. The mapping is duplicated, the layout is not — if a
  /// new type is added there, add it here too.
  static String fileIcon(String extension) {
    switch (extension.toLowerCase().replaceAll('.', '')) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ppt_attachment_icon.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
      case 'png':
      case 'jpg':
      case 'jpeg':
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'mkv':
      case 'webm':
        return 'assets/icons_assets/main_icons_assets/knowledgeVideo.svg';
      case 'xlsx':
      case 'xls':
      case 'xlsm':
      case 'csv':
        return 'assets/icons_assets/main_icons_assets/excell.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
    }
  }

  /// True for the extensions whose icon is a plain silhouette and therefore
  /// needs tinting to stay visible in dark mode. The coloured file-type icons
  /// (pdf red, excel green…) must NOT be tinted.
  static bool iconNeedsTint(String extension) {
    switch (extension.toLowerCase().replaceAll('.', '')) {
      case 'png':
      case 'jpg':
      case 'jpeg':
        return true;
      default:
        return false;
    }
  }
}
