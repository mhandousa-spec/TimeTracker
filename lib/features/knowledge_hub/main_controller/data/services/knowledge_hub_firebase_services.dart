/// Module: knowledge_hub_module / core/knowledge_hub_firebase_services.dart
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_hub_firebase_services.dart
/// Purpose: Knowledge hub firebase services — knowledge_hub_module core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
// ADDED 1/9/2026 — removal raises §1.1 "Document Withdrawn from Circulation"
// from `removeKnowledgeWithReason`; see the note there for why the author's
// address is only correctly resolvable at that point.
import '../notifications/knowledge_hub_notification_service.dart';
import '../models/create_knowledge_new_model.dart';

part './knowledge_hub_firebase_services.part.1.dart';
part './knowledge_hub_firebase_services.part.2.dart';


/// Outcome of a knowledge-removal request, so the UI can react without
/// touching Firestore or knowing collection paths (CR-KP-KH §3 / §15).
enum RemoveKnowledgeResult { success, notFound, alreadyRemoved, error }

/// Result of a reason-based knowledge removal — carries the creator info the
/// UI needs to send notifications, without exposing Firestore (CR-KH-S5-04).
class RemoveKnowledgeReasonResult {
  final String creatorEmail;
  final String documentNameEnglish;
  final String documentNameArabic;

  const RemoveKnowledgeReasonResult({
    required this.creatorEmail,
    required this.documentNameEnglish,
    required this.documentNameArabic,
  });
}

class KnowledgeHubFirebaseServices {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;
}
