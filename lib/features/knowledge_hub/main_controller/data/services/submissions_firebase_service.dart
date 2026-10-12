/// Module: knowledge_hub_module / core/submissions_firebase_service.dart
/// ************************* FILE INFO *************************** ///
/// File Name: submissions_firebase_services.dart
/// Purpose: Firebase services specifically for Submissions screen
/// Author: Youssef Khaled
/// Created At: 18/10/2025

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import '../models/create_knowledge_new_model.dart';
import '../models/create_new_comment_model.dart';
import '../models/document_utilization_model.dart';
import '../models/employee_data.dart';

class SubmissionsFirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all knowledge documents for submissions view
  /// This is the main fetch - all filtering happens in the cubit after this
  Future<List<CreateKnowledgeModel>> fetchAllSubmissions() async {
    try {
      CollectionReference knowledgeRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge));
      QuerySnapshot querySnapshot = await knowledgeRef.get();

      List<CreateKnowledgeModel> submissionsList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // ✅ CRITICAL: Pass doc.id as the Firestore document ID
          CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(
            data,
            doc.id, // ✅ This is the actual Firestore document ID
          );
          submissionsList.add(model);

          log('✅ Loaded document - Firestore ID: ${doc.id}, Knowledge ID: ${model.currentKnowledgeId}');
        } catch (e) {
          log('Error parsing document ${doc.id}: $e');
        }
      }

      log('Fetched ${submissionsList.length} submissions');
      return submissionsList;
    } catch (e) {
      log('Error fetching submissions: $e');
      return [];
    }
  }

  /// Stream submissions for real-time updates
  Stream<List<CreateKnowledgeModel>> streamSubmissions() {
    try {
      return _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .snapshots()
          .map((snapshot) {
        List<CreateKnowledgeModel> submissionsList = [];

        for (var doc in snapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data();

            // ✅ Pass doc.id as the Firestore document ID
            CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(
              data,
              doc.id,
            );
            submissionsList.add(model);
          } catch (e) {
            log('Error parsing document ${doc.id}: $e');
          }
        }

        return submissionsList;
      });
    } catch (e) {
      log('Error streaming submissions: $e');
      return Stream.value([]);
    }
  }

  /// Update submission status (for admin actions)
  Future<bool> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) async {
    try {
      log('📝 Updating submission status for knowledgeId: $knowledgeId to $newStatus');

      // ✅ UPDATED: Query by Firestore document ID directly if it looks like a doc ID
      // Check if knowledgeId is a Firestore-style doc ID (alphanumeric, 20+ chars)
      if (knowledgeId.length >= 20 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(knowledgeId)) {
        log('   Attempting direct document access with ID: $knowledgeId');

        DocumentSnapshot docSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .doc(knowledgeId)
            .get();

        if (docSnapshot.exists) {
          log('   ✅ Found document directly by Firestore ID');

          Map<String, dynamic> existingData = docSnapshot.data() as Map<String, dynamic>;
          CreateKnowledgeModel existingModel = CreateKnowledgeModel.fromJson(
            existingData,
            docSnapshot.id,
          );

          // Add new status to the array
          List<String> updatedStatus = List<String>.from(existingModel.status)
            ..add(newStatus);
          List<int> updatedTimestamps = List<int>.from(existingModel.timestamps)
            ..add(DateTime.now().millisecondsSinceEpoch);

          await docSnapshot.reference.update({
            'status': updatedStatus,
            'timestamps': updatedTimestamps,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          log('✅ Submission status updated successfully via direct access');
          return true;
        } else {
          log('   ⚠️ Document not found via direct access, falling back to query...');
        }
      }

      // ✅ Fallback: Search by knowledgeId field (for backward compatibility)
      log('   Searching by knowledgeId field...');
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('knowledgeId', arrayContains: knowledgeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log('❌ No document found with knowledgeId: $knowledgeId');
        return false;
      }

      var targetDoc = querySnapshot.docs.first;
      log('   ✅ Found document via query: ${targetDoc.id}');

      // Get existing model
      Map<String, dynamic> existingData = targetDoc.data() as Map<String, dynamic>;
      CreateKnowledgeModel existingModel = CreateKnowledgeModel.fromJson(
        existingData,
        targetDoc.id,
      );

      // Add new status to the array
      List<String> updatedStatus = List<String>.from(existingModel.status)
        ..add(newStatus);
      List<int> updatedTimestamps = List<int>.from(existingModel.timestamps)
        ..add(DateTime.now().millisecondsSinceEpoch);

      await targetDoc.reference.update({
        'status': updatedStatus,
        'timestamps': updatedTimestamps,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      log('✅ Submission status updated successfully via query');
      return true;
    } catch (e) {
      log('❌ Error updating submission status: $e');
      return false;
    }
  }

  /// Fetch single submission by knowledgeId or Firestore document ID
  Future<CreateKnowledgeModel?> fetchSubmissionByKnowledgeId(
      String knowledgeId,
      ) async {
    try {
      log('🔍 Searching for knowledgeId: $knowledgeId');

      // ✅ Try direct document access first (if it's a Firestore doc ID)
      if (knowledgeId.length >= 20 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(knowledgeId)) {
        log('   Attempting direct document access...');

        DocumentSnapshot docSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .doc(knowledgeId)
            .get();

        if (docSnapshot.exists) {
          log('✅ Found document directly: ${docSnapshot.id}');
          Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
          return CreateKnowledgeModel.fromJson(data, docSnapshot.id);
        }

        log('   ⚠️ Not found via direct access, trying query...');
      }

      // ✅ Fallback: Query by knowledgeId field
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('knowledgeId', arrayContains: knowledgeId)
          .limit(1)
          .get();

      log('   Query returned ${querySnapshot.docs.length} documents');

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        log('✅ Submission fetched by query - Doc ID: ${doc.id}');
        return CreateKnowledgeModel.fromJson(data, doc.id);
      }

      log('❌ No submission found with knowledgeId: $knowledgeId');
      return null;
    } catch (e) {
      log('❌ Error fetching submission by knowledgeId: $e');
      return null;
    }
  }

  /// ✅ NEW: Fetch comments for a knowledge document
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
      String knowledgeId,
      ) async {
    try {
      log('📥 [FIREBASE] Fetching comments for knowledgeId: $knowledgeId');

      // ✅ Try direct document access first
      DocumentSnapshot? knowledgeDoc;

      if (knowledgeId.length >= 20 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(knowledgeId)) {
        log('   Attempting direct document access for comments...');
        DocumentSnapshot docSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .doc(knowledgeId)
            .get();

        if (docSnapshot.exists) {
          knowledgeDoc = docSnapshot;
          log('   ✅ Found document directly for comments');
        }
      }

      // ✅ Fallback: Query by knowledgeId field
      if (knowledgeDoc == null) {
        log('   Querying by knowledgeId field for comments...');
        QuerySnapshot knowledgeSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .where('knowledgeId', arrayContains: knowledgeId)
            .limit(1)
            .get();

        if (knowledgeSnapshot.docs.isEmpty) {
          log('⚠️ [FIREBASE] No document found with knowledgeId: $knowledgeId');
          return [];
        }

        knowledgeDoc = knowledgeSnapshot.docs.first;
      }

      // Fetch comments subcollection
      QuerySnapshot commentsSnapshot = await knowledgeDoc.reference
          .collection('Comments')
          .orderBy('timestamps', descending: false)
          .get();

      List<CreateNewCommentModel> commentsList = [];

      for (var doc in commentsSnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // ✅ Add the Firestore document ID to the data
          if (!data.containsKey('commentId') || (data['commentId'] as List).isEmpty) {
            data['commentId'] = [doc.id];
          }

          CreateNewCommentModel model = CreateNewCommentModel.fromJson(data);
          commentsList.add(model);

          log('   ✅ Loaded comment: ${doc.id}');
        } catch (e) {
          log('   ⚠️ Error parsing comment ${doc.id}: $e');
        }
      }

      log('✅ [FIREBASE] Fetched ${commentsList.length} comments');
      return commentsList;
    } catch (e) {
      log('❌ [FIREBASE] Error fetching comments: $e');
      return [];
    }
  }

  /// Stream comments for real-time updates
  Stream<List<CreateNewCommentModel>> streamCommentsByKnowledgeId(
      String knowledgeId,
      ) {
    try {
      // ✅ For streaming, we need to use query approach as streams don't support direct doc access easily
      return _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('knowledgeId', arrayContains: knowledgeId)
          .limit(1)
          .snapshots()
          .asyncMap((knowledgeSnapshot) async {
        if (knowledgeSnapshot.docs.isEmpty) {
          return <CreateNewCommentModel>[];
        }

        var knowledgeDoc = knowledgeSnapshot.docs.first;

        QuerySnapshot commentsSnapshot = await knowledgeDoc.reference
            .collection('Comments')
            .orderBy('timestamps', descending: false)
            .get();

        List<CreateNewCommentModel> commentsList = [];

        for (var doc in commentsSnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // Add Firestore document ID
            if (!data.containsKey('commentId') || (data['commentId'] as List).isEmpty) {
              data['commentId'] = [doc.id];
            }

            CreateNewCommentModel model = CreateNewCommentModel.fromJson(data);
            commentsList.add(model);
          } catch (e) {
            log('Error parsing comment ${doc.id}: $e');
          }
        }

        return commentsList;
      });
    } catch (e) {
      log('Error streaming comments: $e');
      return Stream.value([]);
    }
  }

  /// ✅ NEW: Add a new comment to a knowledge document
  Future<bool> addCommentToKnowledge({
    required String knowledgeId,
    required CreateNewCommentModel comment,
  }) async {
    try {
      log('💬 [FIREBASE] Adding comment to knowledgeId: $knowledgeId');

      // ✅ Try direct document access first
      DocumentSnapshot? knowledgeDoc;

      if (knowledgeId.length >= 20 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(knowledgeId)) {
        DocumentSnapshot docSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .doc(knowledgeId)
            .get();

        if (docSnapshot.exists) {
          knowledgeDoc = docSnapshot;
        }
      }

      // ✅ Fallback: Query by knowledgeId field
      if (knowledgeDoc == null) {
        QuerySnapshot knowledgeSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .where('knowledgeId', arrayContains: knowledgeId)
            .limit(1)
            .get();

        if (knowledgeSnapshot.docs.isEmpty) {
          log('❌ [FIREBASE] No document found with knowledgeId: $knowledgeId');
          return false;
        }

        knowledgeDoc = knowledgeSnapshot.docs.first;
      }

      // Add comment to Comments subcollection
      DocumentReference commentRef = await knowledgeDoc.reference
          .collection('Comments')
          .add(comment.toJson());

      log('✅ [FIREBASE] Comment added successfully with ID: ${commentRef.id}');
      return true;
    } catch (e) {
      log('❌ [FIREBASE] Error adding comment: $e');
      return false;
    }
  }

  /// ✅ NEW: Update an existing comment
  Future<bool> updateComment({
    required String knowledgeId,
    required String commentId,
    required CreateNewCommentModel updatedComment,
  }) async {
    try {
      log('📝 [FIREBASE] Updating comment $commentId in knowledge $knowledgeId');

      // ✅ Try direct document access first
      DocumentSnapshot? knowledgeDoc;

      if (knowledgeId.length >= 20 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(knowledgeId)) {
        DocumentSnapshot docSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .doc(knowledgeId)
            .get();

        if (docSnapshot.exists) {
          knowledgeDoc = docSnapshot;
        }
      }

      // ✅ Fallback: Query by knowledgeId field
      if (knowledgeDoc == null) {
        QuerySnapshot knowledgeSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .where('knowledgeId', arrayContains: knowledgeId)
            .limit(1)
            .get();

        if (knowledgeSnapshot.docs.isEmpty) {
          log('❌ [FIREBASE] No knowledge document found with knowledgeId: $knowledgeId');
          return false;
        }

        knowledgeDoc = knowledgeSnapshot.docs.first;
      }

      // Update the comment document
      await knowledgeDoc.reference
          .collection('Comments')
          .doc(commentId)
          .update(updatedComment.toJson());

      log('✅ [FIREBASE] Comment updated successfully');
      return true;
    } catch (e) {
      log('❌ [FIREBASE] Error updating comment: $e');
      return false;
    }
  }

  /// ✅ NEW: Delete a comment
  Future<bool> deleteComment({
    required String knowledgeId,
    required String commentId,
  }) async {
    try {
      log('🗑️ [FIREBASE] Deleting comment $commentId from knowledge $knowledgeId');

      // ✅ Try direct document access first
      DocumentSnapshot? knowledgeDoc;

      if (knowledgeId.length >= 20 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(knowledgeId)) {
        DocumentSnapshot docSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .doc(knowledgeId)
            .get();

        if (docSnapshot.exists) {
          knowledgeDoc = docSnapshot;
        }
      }

      // ✅ Fallback: Query by knowledgeId field
      if (knowledgeDoc == null) {
        QuerySnapshot knowledgeSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .where('knowledgeId', arrayContains: knowledgeId)
            .limit(1)
            .get();

        if (knowledgeSnapshot.docs.isEmpty) {
          log('❌ [FIREBASE] No knowledge document found with knowledgeId: $knowledgeId');
          return false;
        }

        knowledgeDoc = knowledgeSnapshot.docs.first;
      }

      // Delete the comment document
      await knowledgeDoc.reference
          .collection('Comments')
          .doc(commentId)
          .delete();

      log('✅ [FIREBASE] Comment deleted successfully');
      return true;
    } catch (e) {
      log('❌ [FIREBASE] Error deleting comment: $e');
      return false;
    }
  }

  /// Fetch user data by userId - returns single employee or null
  Future<EmployeeData?> fetchUserDataByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl('Employees'))
          .where('Id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log('No employee found with userId: $userId');
        return null;
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      EmployeeData employee = EmployeeData.fromJson(data);

      log('Successfully fetched employee data for userId: $userId');
      return employee;
    } catch (e) {
      log('Error fetching user data: $e');
      return null;
    }
  }

  /// ✅ Batch fetch user data for multiple comments
  /// ✅ Batch fetch user data for multiple user IDs or emails
  Future<Map<String, EmployeeData>> fetchMultipleUserData(
      List<String> userIds,
      ) async {
    try {
      if (userIds.isEmpty) return {};

      log('👥 [Firebase] Fetching data for ${userIds.length} users: $userIds', name: 'SubmissionsFirebase');

      final uniqueUserIds = userIds.toSet().toList();
      Map<String, EmployeeData> usersMap = {};

      // ✅ CRITICAL FIX: Check if the IDs are emails or numeric IDs
      bool areEmails = uniqueUserIds.first.contains('@');
      String queryField = areEmails ? 'Email' : 'Id';

      log('👥 [Firebase] Detected ${areEmails ? "emails" : "IDs"}, querying by: $queryField', name: 'SubmissionsFirebase');

      // Firestore 'in' queries are limited to 10 items
      for (int i = 0; i < uniqueUserIds.length; i += 10) {
        final batch = uniqueUserIds.skip(i).take(10).toList();

        log('📦 [Firebase] Fetching batch ${(i ~/ 10) + 1}: $batch', name: 'SubmissionsFirebase');

        QuerySnapshot querySnapshot = await _firestore
            .collection(getBaseUrl('Employees'))
            .where(queryField, whereIn: batch) // ✅ Use detected field
            .get();

        log('📥 [Firebase] Batch query returned ${querySnapshot.docs.length} documents', name: 'SubmissionsFirebase');

        for (var doc in querySnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // ✅ DEBUG: Log what we're getting
            log('📄 [Firebase] Document data keys: ${data.keys.toList()}', name: 'SubmissionsFirebase');

            EmployeeData employee = EmployeeData.fromJson(data);

            // ✅ Store by the ID/email that was used to query
            String key = areEmails ? employee.currentemployeeEmail : employee.currentemployeeId;
            usersMap[key] = employee;

            log('✅ [Firebase] Cached employee: $key - ${employee.currentemployeeName}', name: 'SubmissionsFirebase');
          } catch (e) {
            log('❌ [Firebase] Error parsing employee data from doc ${doc.id}: $e', name: 'SubmissionsFirebase');
          }
        }
      }

      log('✅ [Firebase] Successfully fetched ${usersMap.length} user records', name: 'SubmissionsFirebase');
      log('🗂️ [Firebase] User IDs in result: ${usersMap.keys.toList()}', name: 'SubmissionsFirebase');

      return usersMap;
    } catch (e, stackTrace) {
      log('❌ [Firebase] Error fetching multiple user data: $e', name: 'SubmissionsFirebase');
      log('📚 [Firebase] Stack trace: $stackTrace', name: 'SubmissionsFirebase');
      return {};
    }
  }

  /// Record file action (download or view)
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String userId,
  }) async {
    try {
      DocumentReference actionRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization))
          .doc();

      final String formattedTimeStamp = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());

      final DocumentUtilizationModel actionModel =
      DocumentUtilizationModel.createNew(
        timestamp: formattedTimeStamp,
        fileId: knowledgeId,
        typeOfAction: typeOfAction,
        userId: userId,
      );

      Map<String, dynamic> actionData = actionModel.toJson();
      actionData['actionTimestamp'] = FieldValue.serverTimestamp();

      await actionRef.set(actionData);

      log('File action recorded successfully: $typeOfAction for user: $userId');
      return true;
    } catch (e) {
      log('Error recording file action: $e');
      return false;
    }
  }
}