/// Module: knowledge_hub_module / core/approvals_firebase_services.dart
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_firebase_services.dart
/// Purpose: Firebase services for Approvals screen - consolidated service
/// Author: Youssef Khaled
/// Created At: 26/10/2025
/// ✅ FIXED: ALL paths now use dynamic company ID from ApiConstants

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import '../models/approval_model.dart';
import '../models/create_knowledge_new_model.dart';
import '../models/create_new_comment_model.dart';
import '../models/document_utilization_model.dart';
import '../models/employee_data.dart';

part './approvals_firebase_services.part.1.dart';
part './approvals_firebase_services.part.2.dart';


class ApprovalsFirebaseServices {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;
}
