/// Module: knowledge_hub_module / core/create_comment_firebase_service.dart
/// ************************* FILE INFO *************************** ///
/// File Name: comments_firebase_services.dart
/// Purpose: Handles all Firebase operations for comments
/// Author: Youssef Khaled
/// Created At: 12/10/2025
/// Updated: Refactored to match simplified comment model

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import '../models/create_new_comment_model.dart';
import '../models/document_utilization_model.dart';
import '../models/employee_data.dart';

class CommentsFirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload comment attachment to Firebase Storage
  /// Returns a map with attachment details
  /// Note: Only extension and size are stored in comment model
  Future<Map<String, dynamic>?> uploadCommentAttachment(File file) async {
    try {
      String fileName = file.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();
      int fileSize = await file.length();

      String filePath =
          'comment_attachments/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference storageRef = _storage.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Determine icon based on file extension
      String icon = _getFileIcon(fileExtension);

      log('Comment attachment uploaded successfully');

      // ✅ Return all details for reference
      // Only extension and size will be stored in comment model
      return {
        'url': downloadUrl,
        'name': fileName,
        'extension': fileExtension,
        'size': fileSize,
        'icon': icon,
      };
    } catch (e) {
      log('Error uploading comment attachment: $e');
      return null;
    }
  }

  /// Helper method to get file icon based on extension
  String _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
      case 'xls':
      case 'xlsx':
        return 'assets/svg/excel_icon.svg';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
      default:
        return 'assets/svg/file_icon.svg';
    }
  }

  /// Create a new comment for a knowledge document
  /// Note: Only stores essential fields. User details fetched via createdById when needed in UI
  /// TODO: Attachment filename will need separate solution later
  Future<bool> createComment({
    required String knowledgeId,
    required String commentText,
    required String createdById,
    required String createdByEmail,
    String? attachmentExtension,
    int? attachmentSize,
  }) async {
    try {
      // Generate new comment document reference
      DocumentReference commentRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))

          .doc();

      //Comments

      // Create comment model
      CreateNewCommentModel commentModel = CreateNewCommentModel.createNew(
        commentId: commentRef.id,
        commentText: commentText,
        createdById: createdById,
        createdByEmail: createdByEmail,
        attachmentExtension: attachmentExtension,
        attachmentSize: attachmentSize,
      );

      // Convert to JSON and add knowledgeId reference
      Map<String, dynamic> commentData = commentModel.toJson();
      commentData['knowledgeId'] = knowledgeId;

      // Save to Firestore
      await commentRef.set(commentData);

      log('Comment created successfully for knowledge: $knowledgeId');
      return true;
    } catch (e) {
      log('Error creating comment: $e');
      return false;
    }
  }

  /// Fetch all comments for a specific knowledge document
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
    String knowledgeId,
  ) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))
          .where('knowledgeId', isEqualTo: knowledgeId)
          .get();
      List<CreateNewCommentModel> commentsList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          CreateNewCommentModel model = CreateNewCommentModel.fromJson(data);
          commentsList.add(model);
        } catch (e) {
          log('Error parsing comment ${doc.id}: $e');
        }
      }

      // ✅ Sort by the first timestamp (creation time)
      commentsList.sort((a, b) {
        try {
          // Parse timestamp strings to integers for comparison
          int timestampA = int.parse(a.timestamps.first);
          int timestampB = int.parse(b.timestamps.first);
          return timestampA.compareTo(timestampB);
        } catch (e) {
          log('Error parsing timestamps for sorting: $e');
          return 0;
        }
      });

      log(
        'Fetched ${commentsList.length} comments for knowledge: $knowledgeId',
      );
      return commentsList;
    } catch (e) {
      log('Error fetching comments: $e');
      return [];
    }
  }

  /// Stream comments for real-time updates
  Stream<List<CreateNewCommentModel>> streamCommentsByKnowledgeId(
    String knowledgeId,
  ) {
    try {
      return _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))
          .where('knowledgeId', isEqualTo: knowledgeId)
          .snapshots()
          .map((snapshot) {
            List<CreateNewCommentModel> commentsList = [];

            for (var doc in snapshot.docs) {
              try {
                Map<String, dynamic> data = doc.data();
                CreateNewCommentModel model = CreateNewCommentModel.fromJson(
                  data,
                );
                commentsList.add(model);
              } catch (e) {
                log('Error parsing comment ${doc.id}: $e');
              }
            }

            // ✅ Sort by timestamp
            commentsList.sort((a, b) {
              try {
                int timestampA = int.parse(a.timestamps.first);
                int timestampB = int.parse(b.timestamps.first);
                return timestampA.compareTo(timestampB);
              } catch (e) {
                log('Error parsing timestamps for sorting: $e');
                return 0;
              }
            });

            return commentsList;
          });
    } catch (e) {
      log('Error streaming comments: $e');
      return Stream.value([]);
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))

          .doc(commentId)
          .delete();
//Comments
      log('Comment deleted successfully: $commentId');
      return true;
    } catch (e) {
      log('Error deleting comment: $e');
      return false;
    }
  }

  /// Get comment count for a knowledge document
  Future<int> getCommentCount(String knowledgeId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))

              .where('knowledgeId', isEqualTo: knowledgeId)
          .get();
//Comments
      return querySnapshot.size;
    } catch (e) {
      log('Error getting comment count: $e');
      return 0;
    }
  }

  /// Record file action (download or view) using DocumentUtilizationModel
  /// ✅ Simplified to store only essential tracking data
  /// User details should be fetched via userId using fetchUserDataByUserId() in UI
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction, // 'download' or 'view'
    required String userId,
  }) async {
    try {
      // Generate new action document reference
      DocumentReference actionRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization))
          .doc();
      // ✅ Create formatted timestamp
      final String formattedTimeStamp = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());

      // ✅ Create DocumentUtilizationModel instance
      final DocumentUtilizationModel actionModel =
          DocumentUtilizationModel.createNew(
            timestamp: formattedTimeStamp,
            fileId: knowledgeId,
            typeOfAction: typeOfAction,
            userId: userId,
          );

      // ✅ Convert model to JSON
      Map<String, dynamic> actionData = actionModel.toJson();

      // Add server timestamp for querying purposes
      actionData['actionTimestamp'] = FieldValue.serverTimestamp();

      // Save to Firestore
      await actionRef.set(actionData);

      log('File action recorded successfully: $typeOfAction for user: $userId');
      return true;
    } catch (e) {
      log('Error recording file action: $e');
      return false;
    }
  }

  /// Fetch file actions by knowledge/file ID
  /// ✅ Returns DocumentUtilizationModel with userId - use fetchUserDataByUserId() to get user details in UI
  Future<List<DocumentUtilizationModel>> fetchFileActionsByKnowledgeId(
    String knowledgeId,
  ) async
  {
    try
    {
      log('Searching for fileId: $knowledgeId');

      // Use array-contains since fileId is stored as an array
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization))

          .where('fileId', arrayContains: knowledgeId)
          .get();
//Document_Utilization
      log('Filtered query returned: ${querySnapshot.docs.length} documents');

      List<DocumentUtilizationModel> actionsList = [];
      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DocumentUtilizationModel model = DocumentUtilizationModel.fromJson(
            data,
          );
          actionsList.add(model);
        } catch (e) {
          log('Error parsing action ${doc.id}: $e');
        }
      }

      return actionsList;
    } catch (e) {
      log('Error fetching file actions: $e');
      return [];
    }
  }

  /// Stream file actions for real-time updates
  /// ✅ Returns DocumentUtilizationModel with userId - use fetchUserDataByUserId() to get user details in UI
  Stream<List<DocumentUtilizationModel>> streamFileActionsByKnowledgeId(
    String knowledgeId,
  ) {
    try {
      return _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization))

          .where('fileId', arrayContains: knowledgeId)
          .orderBy('actionTimestamp', descending: true)
          .snapshots()

      //Document_Utilization
          .map((snapshot) {
            List<DocumentUtilizationModel> actionsList = [];

            for (var doc in snapshot.docs) {
              try {
                Map<String, dynamic> data = doc.data();
                DocumentUtilizationModel model =
                    DocumentUtilizationModel.fromJson(data);
                actionsList.add(model);
              } catch (e) {
                log('Error parsing action ${doc.id}: $e');
              }
            }

            return actionsList;
          });
    } catch (e) {
      log('Error streaming file actions: $e');
      return Stream.value([]);
    }
  }

  /// Fetch user data by userId - returns single employee or null
  /// ✅ Use this to get user details (name, photo, department, role) for display
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

      // Get the first (and only) document
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
  /// This is more efficient than fetching individually for each comment
  /// ✅ Batch fetch user data for multiple comments
  /// This is more efficient than fetching individually for each comment
  Future<Map<String, EmployeeData>> fetchMultipleUserData(
    List<String> userIds,
  ) async {
    try {
      if (userIds.isEmpty) {
        log(
          '⚠️ [Firebase] fetchMultipleUserData called with empty userIds list',
        );
        return {};
      }

      log('👥 [Firebase] Fetching data for ${userIds.length} users: $userIds');

      // Remove duplicates
      final uniqueUserIds = userIds.toSet().toList();
      log('👥 [Firebase] Unique user IDs: ${uniqueUserIds.length}');

      // Firestore 'in' queries are limited to 10 items, so we batch them
      Map<String, EmployeeData> usersMap = {};

      for (int i = 0; i < uniqueUserIds.length; i += 10) {
        final batch = uniqueUserIds.skip(i).take(10).toList();
        log('📦 [Firebase] Fetching batch ${(i ~/ 10) + 1}: $batch');

        QuerySnapshot querySnapshot = await _firestore
            .collection(getBaseUrl('Employees'))
            .where('Id', whereIn: batch)
            .get();
        log(
          '📥 [Firebase] Batch query returned ${querySnapshot.docs.length} documents',
        );

        for (var doc in querySnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            log('📄 [Firebase] Parsing employee doc: ${doc.id}');
            log('📄 [Firebase] Data keys: ${data.keys.toList()}');

            EmployeeData employee = EmployeeData.fromJson(data);
            usersMap[employee.currentemployeeId] = employee;

            log(
              '✅ [Firebase] Parsed employee: id="${employee.currentemployeeId}", name="${employee.currentemployeeName}", dept="${employee.currentemployeeDepartment}"',
            );
          } catch (e, stack) {
            log(
              '❌ [Firebase] Error parsing employee data from doc ${doc.id}: $e',
            );
            log('📄 [Firebase] Raw data: ${doc.data()}');
            log('🧱 Stack: $stack');
          }
        }
      }

      log('✅ [Firebase] Successfully fetched ${usersMap.length} user records');
      log('🗂️ [Firebase] User IDs in result: ${usersMap.keys.toList()}');

      return usersMap;
    } catch (e) {
      log('❌ [Firebase] Error fetching multiple user data: $e');
      return {};
    }
  }

  /// Fetch department name by department ID
Future<String> fetchDepartmentNameById(String departmentId) async {
  try {
    if (departmentId.isEmpty) {
      log('⚠️ Empty department ID provided');
      return 'Unknown Department';
    }

    log('🔍 [Firebase] Fetching department for ID: $departmentId');

    QuerySnapshot querySnapshot = await _firestore
        .collection(getBaseUrl('Departments'))
        .where('Department_ID', isEqualTo: departmentId)
        .limit(1)
        .get();

    //Departments
    if (querySnapshot.docs.isEmpty) {
      log('⚠️ No department found with ID: $departmentId');
      return 'Unknown Department';
    }

    var doc = querySnapshot.docs.first;
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    String departmentName = data['Department_Name'] as String? ?? 'Unknown Department';
    
    log('✅ Found department: $departmentName for ID: $departmentId');
    return departmentName;
  } catch (e) {
    log('❌ Error fetching department by ID: $e');
    return 'Unknown Department';
  }
}

/// Batch fetch department names for multiple department IDs
/// More efficient than fetching individually
Future<Map<String, String>> fetchMultipleDepartmentNames(
  List<String> departmentIds,
) async {
  try {
    if (departmentIds.isEmpty) {
      log('⚠️ [Firebase] fetchMultipleDepartmentNames called with empty list');
      return {};
    }

    log('🏢 [Firebase] Fetching ${departmentIds.length} departments: $departmentIds');

    // Remove duplicates
    final uniqueIds = departmentIds.toSet().toList();
    log('🏢 [Firebase] Unique department IDs: ${uniqueIds.length}');

    Map<String, String> departmentMap = {};

    // Firestore 'in' queries are limited to 10 items
    for (int i = 0; i < uniqueIds.length; i += 10) {
      final batch = uniqueIds.skip(i).take(10).toList();
      log('📦 [Firebase] Fetching department batch ${(i ~/ 10) + 1}: $batch');

      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl('Departments'))
          .where('Department_ID', whereIn: batch)
          .get();
      log('📥 [Firebase] Department batch query returned ${querySnapshot.docs.length} documents');

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          String? deptId = data['Department_ID'] as String?;
          String? deptName = data['Department_Name'] as String?;
          
          if (deptId != null && deptId.isNotEmpty && deptName != null) {
            departmentMap[deptId] = deptName;
            log('✅ [Firebase] Mapped department: ID="$deptId" → Name="$deptName"');
          }
        } catch (e) {
          log('❌ [Firebase] Error parsing department doc ${doc.id}: $e');
        }
      }
    }

    log('✅ [Firebase] Successfully fetched ${departmentMap.length} department names');
    log('🗂️ [Firebase] Department IDs in result: ${departmentMap.keys.toList()}');
    
    return departmentMap;
  } catch (e) {
    log('❌ [Firebase] Error fetching multiple department names: $e');
    return {};
  }
}
}
