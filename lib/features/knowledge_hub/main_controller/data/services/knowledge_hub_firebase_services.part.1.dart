part of './knowledge_hub_firebase_services.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 1 of KnowledgeHubFirebaseServices (kept under 800 LOC, §7).
extension KnowledgeHubServicesPart1 on KnowledgeHubFirebaseServices {

  /// Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName =
          'knowledge_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      log(downloadUrl);
      log('Image Uploaded Successfully');
      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  /// Upload document to Firebase Storage
  Future<String?> uploadDocument(File documentFile, String fileName) async {
    try {
      String filePath =
          'knowledge_documents/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference storageRef = _storage.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(documentFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      log('Document Uploaded Successfully');
      return downloadUrl;
    } catch (e) {
      log('Error uploading document: $e');
      return null;
    }
  }

  Future<bool> createKnowledgeHub(CreateKnowledgeModel model) async {
    try {
      // Reference to Demo/84763782/Create_Knowledge collection
      CollectionReference knowledgeRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge));

      Map<String, dynamic> knowledgeData = model.toJson();

      // knowledgeData['createdAt'] = FieldValue.serverTimestamp();

      log('Uploading knowledge data: ${knowledgeData.toString()}');

      await knowledgeRef.add(knowledgeData);

      log('Data uploaded to document successfully');
      return true;
    } catch (e) {
      log('Error creating knowledge hub: $e');
      return false;
    }
  }

  /// Uploads a comment attachment to Storage and returns its download URL.
  /// Keeps `FirebaseStorage` out of the presentation layer (CR-KH-S5-04).
  Future<String?> uploadCommentAttachment({
    required File file,
    required String knowledgeId,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref(
        'knowledge_hub_comments/$knowledgeId/'
        '${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      log('Error uploading comment attachment: $e');
      return null;
    }
  }

  /// Returns the most recent removal reason for a knowledge doc, or null.
  /// Keeps Firestore out of the S5 published-content UI (CR-KH-S5-04).
  Future<String?> getRemovalReason(String knowledgeId) async {
    try {
      final collectionPath = getBaseUrl(FirebaseCollections.createKnowledge);
      if (knowledgeId.length >= 20 &&
          RegExp(r'^[a-zA-Z0-9]+$').hasMatch(knowledgeId)) {
        final docSnapshot =
            await _firestore.collection(collectionPath).doc(knowledgeId).get();
        if (docSnapshot.exists && docSnapshot.data() != null) {
          return _extractLastArrayValue(docSnapshot.data()!, 'removalReason');
        }
      }
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where('knowledgeId', arrayContains: knowledgeId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return null;
      return _extractLastArrayValue(
          querySnapshot.docs.first.data() as Map<String, dynamic>,
          'removalReason');
    } catch (e) {
      log('Error getRemovalReason: $e');
      return null;
    }
  }

  /// Returns the removal reason aligned to the last `removed` entry in the
  /// status array (reads the matching descriptionArabic/English index). Owns
  /// the Firestore access + collection path for the S7 details screen
  /// (CR-KH-S7-01 / S7-02).
  Future<String?> getRemovalReasonFromStatus(
    String knowledgeId,
    bool isArabic,
  ) async {
    try {
      final collectionPath = getBaseUrl(FirebaseCollections.createKnowledge);
      Map<String, dynamic>? data;

      if (knowledgeId.length >= 20 &&
          RegExp(r'^[a-zA-Z0-9]+$').hasMatch(knowledgeId)) {
        final doc =
            await _firestore.collection(collectionPath).doc(knowledgeId).get();
        if (doc.exists) data = doc.data();
      }

      if (data == null) {
        final q = await _firestore
            .collection(collectionPath)
            .where('knowledgeId', arrayContains: knowledgeId)
            .limit(1)
            .get();
        if (q.docs.isEmpty) return null;
        data = q.docs.first.data() as Map<String, dynamic>;
      }

      final statusArray = List<dynamic>.from(data['status'] ?? []);
      final removedIndex = statusArray.lastIndexOf('removed');
      if (removedIndex == -1) return null;

      final descriptionArray = isArabic
          ? (data['descriptionArabic'] ?? [])
          : (data['descriptionEnglish'] ?? []);
      if (descriptionArray is List && removedIndex < descriptionArray.length) {
        final reason = descriptionArray[removedIndex]?.toString() ?? '';
        return reason.isNotEmpty ? reason : null;
      }
      return null;
    } catch (e) {
      log('Error getRemovalReasonFromStatus: $e');
      return null;
    }
  }

  /// Returns the most recent approval justification, or null.
  Future<String?> getApprovalReason(String knowledgeId) async {
    try {
      final approvalsPath = getBaseUrl(FirebaseCollections.knowledgeApprovals);
      final docSnapshot =
          await _firestore.collection(approvalsPath).doc(knowledgeId).get();
      if (!docSnapshot.exists || docSnapshot.data() == null) return null;
      return _extractLastArrayValue(docSnapshot.data()!, 'approvalJustification');
    } catch (e) {
      log('Error getApprovalReason: $e');
      return null;
    }
  }

  String? _extractLastArrayValue(Map<String, dynamic> data, String field) {
    final List<dynamic> arr = data[field] ?? [];
    if (arr.isEmpty) return null;
    final value = arr.last?.toString() ?? '';
    return value.isNotEmpty ? value : null;
  }

  /// Refreshes a Firebase Storage download URL from a (possibly expired)
  /// file URL. Keeps `FirebaseStorage` out of the S5 viewers UI (CR-KH-S5-04).
  Future<String> refreshDownloadUrl(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.path.split('/o/');
      if (pathSegments.length > 1) {
        final storagePath =
            Uri.decodeComponent(pathSegments[1].split('?').first);
        return await _storage.ref(storagePath).getDownloadURL();
      }
    } catch (e) {
      log('Could not refresh download URL: $e');
    }
    return fileUrl;
  }

  /// Persists a notification record under the tenant's Notifications
  /// collection. Replaces the hardcoded `Demo`/`Notifications` write that used
  /// to live in the S5 removal dialog (CR-KH-S5-04 / §15).
  Future<void> saveNotificationRecord(Map<String, dynamic> data) async {
    try {
      String companyId = ApiConstants.baseUri.split('/').last;
      if (companyId.isEmpty) companyId = 'bayanatz';
      await _firestore
          .collection(FirebaseCollections.demo)
          .doc(companyId)
          .collection(FirebaseCollections.notifications)
          .add(data);
    } catch (e) {
      log('Error saving notification record: $e');
    }
  }

  /// `statusReason` padded to the same length as `status`.
  ///
  /// Documents written before `statusReason` existed have no such key, and a
  /// status change that carried no reason leaves a gap, so the two arrays
  /// cannot be assumed to line up. Padding with `''` before appending keeps
  /// "entry N explains status N" true for every document, old or new.
  List<dynamic> _alignedStatusReasons(Map<String, dynamic> data) {
    final statuses = List<dynamic>.from(data['status'] ?? []);
    final reasons = List<dynamic>.from(data['statusReason'] ?? []);
    while (reasons.length < statuses.length) {
      reasons.add('');
    }
    return reasons;
  }

  /// Records why a document was edited and resubmitted.
  ///
  /// ADDED 22/9/2026 for the "reason of editing" step on the resubmit dialog.
  /// Called AFTER the edit itself has been written, because the edit appends
  /// the new status and this attaches the reason to that entry.
  ///
  /// Best-effort by design: the edit has already been saved and shown as
  /// successful, so a failure here must not be reported as a failed edit. It
  /// returns false and logs instead.
  Future<bool> attachEditReason({
    required String documentId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) return false;

    try {
      final querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('knowledgeId', arrayContains: documentId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        log('⚠️ attachEditReason: no document with knowledgeId $documentId');
        return false;
      }

      final docSnapshot = querySnapshot.docs.first;
      final data = docSnapshot.data() as Map<String, dynamic>;
      final reasons = _alignedStatusReasons(data);

      // The edit has already appended its status entry, so the padding above
      // left a trailing '' that belongs to it — fill that rather than adding
      // one past the end of `status`.
      if (reasons.isNotEmpty) {
        reasons[reasons.length - 1] = reason.trim();
      } else {
        reasons.add(reason.trim());
      }

      await docSnapshot.reference.update({
        'statusReason': reasons,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('Error attachEditReason: $e');
      return false;
    }
  }

  /// Marks a knowledge document as `removed` with a justification, updating the
  /// parallel arrays in one place. Returns the creator info (for notifying), or
  /// null if the document can't be found / the update fails (CR-KH-S5-04).
  Future<RemoveKnowledgeReasonResult?> removeKnowledgeWithReason({
    required String documentId,
    required String currentUserEmail,
    required String justification,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('knowledgeId', arrayContains: documentId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return null;

      final docSnapshot = querySnapshot.docs.first;
      final docRef = docSnapshot.reference;
      final data = docSnapshot.data() as Map<String, dynamic>;

      String firstOf(String field, String fallback) {
        final list = data[field];
        if (list is List && list.isNotEmpty) return list.first.toString();
        return fallback;
      }

      final creatorEmail = firstOf('createdByEmail', '');
      final documentNameEnglish = firstOf('nameEnglish', 'Document');
      final documentNameArabic = firstOf('nameArabic', 'مستند');

      final createdByEmailArray = List<dynamic>.from(data['createdByEmail'] ?? []);
      final statusArray = List<dynamic>.from(data['status'] ?? []);
      final timestampsArray = List<dynamic>.from(data['timestamps'] ?? []);
      final timeStampArray = List<dynamic>.from(data['timeStamp'] ?? []);

      // FIXED 22/9/2026 — THE JUSTIFICATION NO LONGER OVERWRITES THE
      // DOCUMENT'S DESCRIPTION.
      //
      // This used to append `justification` to `descriptionArabic` and
      // `descriptionEnglish`. Those are history arrays whose `.last` entry is
      // what the app displays (`CreateKnowledgeModel.currentDescriptionEnglish`),
      // so removing a document REPLACED its description with the reason it was
      // removed — on the card, on the details page, in the approvals list,
      // everywhere. The description was not recoverable from the UI afterwards.
      //
      // The reason now goes in `statusReason`, the array added for it, which
      // runs parallel to `status`: entry N says why status N happened.
      final statusReasonArray = _alignedStatusReasons(data);

      createdByEmailArray.add(currentUserEmail);
      statusArray.add('removed');
      statusReasonArray.add(justification);
      timestampsArray.add(DateTime.now().millisecondsSinceEpoch);
      timeStampArray.add(DateTime.now().toIso8601String());

      await docRef.update({
        'createdByEmail': createdByEmailArray,
        'status': statusArray,
        'statusReason': statusReasonArray,
        'timestamps': timestampsArray,
        'timeStamp': timeStampArray,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ADDED 1/9/2026 — §1.1 "Document Withdrawn from Circulation".
      //
      // Raised here rather than at the call site on purpose. This method is
      // the single choke point for a reason-based removal — it is what every
      // removal dialog in K5 and K7 ends up calling — and it is the only
      // place that has already resolved the AUTHOR's address. (`createdByEmail`
      // is a history array: `firstOf` above is the author, while the entry
      // this method just appended is the person doing the removing. A caller
      // reading `currentCreatedByEmail` would notify the remover about their
      // own action.)
      //
      // The result object's own doc comment says it carries the creator info
      // "for notifying" — no caller ever did, so a document could be pulled
      // out of circulation and its author never told. Best-effort: a failed
      // notification must not turn a successful removal into a `null` return.
      unawaited(
        KnowledgeHubNotificationService.notifyOfRemoval(
          senderEmail: currentUserEmail,
          receiverEmail: creatorEmail,
          documentNameEn: documentNameEnglish,
          documentNameAr: documentNameArabic,
          isArabic: Get.locale?.languageCode == 'ar',
        ).catchError((Object e) {
          log('⚠️ [KH-NOTIFY] removal notification failed: $e');
          return false;
        }),
      );

      return RemoveKnowledgeReasonResult(
        creatorEmail: creatorEmail,
        documentNameEnglish: documentNameEnglish,
        documentNameArabic: documentNameArabic,
      );
    } catch (e) {
      log('Error removeKnowledgeWithReason: $e');
      return null;
    }
  }

  /// Deletes a knowledge document by id. Keeps the direct
  /// `FirebaseFirestore.instance` delete out of the analytics cubit
  /// (CR-KH-CUBIT-N02).
  ///
  /// FIXED 22/9/2026 — this resolved the document with `.doc(knowledgeId)`,
  /// the same wrong assumption `removeKnowledgeById` carried: `knowledgeId` is
  /// a history ARRAY FIELD on the document, not the Firestore document id, so
  /// the delete silently hit a non-existent document and reported success.
  /// See the note on `removeKnowledgeById` in part.2.
  Future<void> deleteKnowledgeById(String knowledgeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('knowledgeId', arrayContains: knowledgeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log('⚠️ deleteKnowledgeById: no document with knowledgeId $knowledgeId');
        return;
      }

      await querySnapshot.docs.first.reference.delete();
    } catch (e) {
      log('Error deleteKnowledgeById: $e');
      rethrow;
    }
  }

  /// Resolves a supervisor email from the employees / departments collections.
  /// Keeps those reads out of the create-knowledge cubit (CR-KH-CUBIT-N02/N08).
  Future<String?> getSupervisorEmailFromFirestore({
    String? employeeId,
    String? departmentId,
  }) async {
    try {
      if (employeeId != null) {
        final doc = await _firestore
            .collection(FirebaseCollections.employees)
            .doc(employeeId)
            .get();
        if (doc.exists) {
          final data = doc.data();
          final s = (data?['supervisorEmail'] ??
              data?['managerEmail'] ??
              data?['reportingTo']) as String?;
          if (s != null && s.isNotEmpty) return s;
        }
      }
      if (departmentId != null) {
        final doc = await _firestore
            .collection(FirebaseCollections.departments)
            .doc(departmentId)
            .get();
        if (doc.exists) {
          final data = doc.data();
          final s = (data?['supervisorEmail'] ??
              data?['managerEmail'] ??
              data?['headOfDepartment']) as String?;
          if (s != null && s.isNotEmpty) return s;
        }
      }
      return null;
    } catch (e) {
      log('Error getSupervisorEmailFromFirestore: $e');
      return null;
    }
  }

  /// Update knowledge status (for archiving)
  Future<bool> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) async {
    try {
      log('🔄 [FIREBASE] Updating knowledge status: $knowledgeId to $newStatus');

      await _firestore
          .collection('knowledge')
          .doc(knowledgeId)
          .update({
        'status': [newStatus],
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      log('✅ [FIREBASE] Knowledge status updated successfully');
      return true;
    } catch (e) {
      log('❌ [FIREBASE] Error updating knowledge status: $e');
      return false;
    }
  }

  Future<bool> createKnowledgeHubFromParams({
    required String knowledgeImage,
    required String nameEnglish,
    required String nameArabic,
    required String descriptionEnglish,
    required String descriptionArabic,
    required String knowledgeDocumentType,
    required String owningDepartment,
    List<String>? limitedDepartments,
    bool? schedulePublishing,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? startTime,      // ✅ ADD THIS
    String? endTime,        // ✅ ADD THIS
    required String imageUrl,
    required String documentUrl,
    required String documentFileName,
    required String timeStamp,
    required String documentExtension,
    required int documentSize,
    // required DateTime documentUploadedDate,
    required String createdByEmail,
    required String status,
  }) async {
    try {
      // Normalize the direct-publish status so the document actually appears in
      // the Knowledge Hub, which lists ONLY documents whose latest status is
      // 'published' (see _filterByPublishedStatusAndAccess in the create cubit).
      //
      // A user with the editDocumentWithoutApproval permission bypasses the
      // approval workflow, so the caller passes status 'approved'. Mirroring the
      // approval flow (approvals_firebase_services: schedule ON -> 'approved',
      // which flips to 'published' at its start time; schedule OFF -> 'published'
      // immediately), an approved-but-UNscheduled document must be saved as
      // 'published' — otherwise it is stored as 'approved' and never shows on the
      // home list. Scheduled documents correctly stay 'approved' until their
      // start time, and 'pending'/'draft'/'rejected' are left untouched so the
      // normal approval workflow is unaffected.
      String effectiveStatus = status;
      if (status.toLowerCase().trim() == 'approved' &&
          schedulePublishing != true) {
        effectiveStatus = 'published';
        log('ℹ️ Status normalized: approved + no scheduling -> published');
      }

      // Generate Id for new doc
      final knowledgeId = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .doc();
      // Create model instance using factory
      CreateKnowledgeModel model = CreateKnowledgeModel.createNew(
        knowledgeId: knowledgeId.id, // Genereated ID for the new doc
        knowledgeImage: knowledgeImage,
        nameEnglish: nameEnglish,
        nameArabic: nameArabic,
        descriptionEnglish: descriptionEnglish,
        descriptionArabic: descriptionArabic,
        knowledgeDocumentType: knowledgeDocumentType,
        owningDepartment: owningDepartment,
        limitedDepartments: limitedDepartments,
        schedulePublishing: schedulePublishing,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        startTime: startTime,     // ✅ ADD THIS
        endTime: endTime,         // ✅ ADD THIS
        imageUrl: imageUrl,
        documentUrl: documentUrl,
        documentFileName: documentFileName,
        timeStamp: timeStamp,
        documentExtension: documentExtension,
        documentSize: documentSize,
        status: effectiveStatus,
        createdByEmail: createdByEmail,
      );

      // Use the model-based method
      return await createKnowledgeHub(model);
    } catch (e) {
      log('Error creating knowledge hub from params: $e');
      return false;
    }
  }

}
