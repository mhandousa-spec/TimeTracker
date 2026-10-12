/// Module: messaging / m5_support / data
///
///*************************** FILE INFO ****************************///
/// File Name: support_chat_repository.dart
/// Purpose: The signed-in user's conversation with Knowticed Support.
/// Author: Amr Mesbah
/// Created at: 23/9/2026
///
/// Every Comments and Feedback submission (Settings › App Info) opens — or
/// continues — ONE conversation per person with the Knowticed team. The
/// admin dashboard replies in its Messages section and the reply shows here,
/// in Messages › Knowticed Support.
///
/// Firestore (same project and company as the feedback):
///   {baseUri}/Modules/settings/App_Feedback/{id}          ← submissions
///   {baseUri}/Modules/settings/Support_Chats/{emailKey}
///     Employee_Email, Employee_Id, Employee_Name, Last_Message{Text,
///     Sender, Time}, Unread_By_Admin, Unread_By_User, Updated_At
///   …/Support_Chats/{emailKey}/Messages/{id}
///     Text, Type, Sender ('user' | 'admin'), Sender_Name, Send_Time,
///     Media_Url, File_Name, Is_Seen
///
/// {emailKey} = the user's email trimmed and lower-cased — the messaging
/// module identifies users by email. The admin dashboard reads the same
/// paths (knowticed_admin › messages/data/feedback_chat_source.dart).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/settings/se7_app_info/data/utils/feedback_collection_paths.dart';

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.text,
    required this.fromAdmin,
    required this.time,
    this.mediaUrl = '',
    this.fileName = '',
    this.feedbackKind,
    this.isSeen = false,
    this.type = 'text',
  });

  final String id;
  final String text;
  final bool fromAdmin;
  final DateTime? time;
  final String mediaUrl;
  final String fileName;

  /// Set when the message is one of the user's feedback submissions
  /// ('bug' / 'comment' / 'feature_request').
  final String? feedbackKind;
  final bool isSeen;

  /// Messages.Type — 'text' / 'image' / 'attachment' / 'voice' (24/9/2026:
  /// the admin can send voice notes).
  final String type;

  bool get isVoice => type == 'voice';
}

class SupportChatSummary {
  const SupportChatSummary({this.lastText = '', this.lastTime, this.unread = 0});

  final String lastText;
  final DateTime? lastTime;
  final int unread;
}

class SupportChatRepository {
  SupportChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String collection = 'Support_Chats';
  static const String messages = 'Messages';
  static const String senderUser = 'user';
  static const String senderAdmin = 'admin';

  static String emailKey(String email) => email.trim().toLowerCase();

  DocumentReference<Map<String, dynamic>> chatRef(String email) => _db
      .doc(FeedbackCollectionPaths.settingsDoc)
      .collection(collection)
      .doc(emailKey(email));

  static DateTime? _date(Object? v) => v is Timestamp ? v.toDate() : null;

  /// Header info of the conversation (last message + my unread count).
  Stream<SupportChatSummary> watchSummary(String email) =>
      chatRef(email).snapshots().map((s) {
        final m = s.data() ?? const <String, dynamic>{};
        final last = m['Last_Message'] is Map
            ? Map<String, dynamic>.from(m['Last_Message'] as Map)
            : const <String, dynamic>{};
        return SupportChatSummary(
          lastText: '${last['Text'] ?? ''}',
          lastTime: _date(last['Time']),
          unread: (m['Unread_By_User'] as num?)?.toInt() ?? 0,
        );
      });

  /// Chat messages (both directions), oldest first.
  Stream<List<SupportMessage>> watchMessages(String email) => chatRef(email)
      .collection(messages)
      .orderBy('Send_Time')
      .snapshots()
      .map((s) => s.docs.map((d) {
            final m = d.data();
            return SupportMessage(
              id: d.id,
              text: '${m['Text'] ?? ''}',
              fromAdmin: m['Sender'] == senderAdmin,
              time: _date(m['Send_Time']),
              mediaUrl: '${m['Media_Url'] ?? ''}',
              fileName: '${m['File_Name'] ?? ''}',
              isSeen: m['Is_Seen'] == true,
              type: '${m['Type'] ?? 'text'}',
            );
          }).toList());

  /// The user's own feedback submissions, shown as their messages.
  Stream<List<SupportMessage>> watchFeedback(String email) => _db
      .doc(FeedbackCollectionPaths.settingsDoc)
      .collection(FeedbackCollectionPaths.feedbackCollection)
      .where('employeeEmail', isEqualTo: email)
      .snapshots()
      .map((s) => s.docs.map((d) {
            final m = d.data();
            return SupportMessage(
              id: 'feedback_${d.id}',
              text: '${m['body'] ?? ''}',
              fromAdmin: false,
              time: _date(m['createdAt']),
              feedbackKind: '${m['type'] ?? 'comment'}',
              isSeen: true,
            );
          }).toList());

  Future<void> send({
    required String email,
    required String name,
    required String text,
  }) async {
    final ref = chatRef(email);
    final now = FieldValue.serverTimestamp();
    final batch = _db.batch()
      ..set(ref.collection(messages).doc(), <String, dynamic>{
        'Text': text,
        'Type': 'text',
        'Sender': senderUser,
        'Sender_Name': name,
        'Send_Time': now,
        'Media_Url': '',
        'File_Name': '',
        'Is_Seen': false,
      })
      ..set(
          ref,
          <String, dynamic>{
            'Employee_Email': email,
            'Employee_Name': name,
            'Last_Message': <String, dynamic>{
              'Text': text,
              'Type': 'text',
              'Sender': senderUser,
              'Time': now,
            },
            'Unread_By_Admin': FieldValue.increment(1),
            'Updated_At': now,
          },
          SetOptions(merge: true));
    await batch.commit();
  }

  /// Opening the chat: my unread counter → 0, the team's messages seen.
  Future<void> markRead(String email) async {
    try {
      final ref = chatRef(email);
      final doc = await ref.get();
      if (!doc.exists) return;
      await ref.update(<String, dynamic>{'Unread_By_User': 0});
      final unseen = await ref
          .collection(messages)
          .where('Sender', isEqualTo: senderAdmin)
          .where('Is_Seen', isEqualTo: false)
          .get();
      if (unseen.docs.isEmpty) return;
      final batch = _db.batch();
      for (final d in unseen.docs) {
        batch.update(d.reference, <String, dynamic>{'Is_Seen': true});
      }
      await batch.commit();
    } catch (_) {
      // Read receipts are best-effort.
    }
  }

  /// Called by the feedback submit batch: opens / bumps the conversation so
  /// the admin sees it at the top with an unread count.
  static void touchOnFeedback(
    WriteBatch batch,
    FirebaseFirestore db, {
    required String email,
    required String employeeId,
    required String name,
    required String lastText,
    required int count,
  }) {
    if (email.trim().isEmpty) return;
    final ref = db
        .doc(FeedbackCollectionPaths.settingsDoc)
        .collection(collection)
        .doc(emailKey(email));
    final now = FieldValue.serverTimestamp();
    batch.set(
        ref,
        <String, dynamic>{
          'Employee_Email': email,
          'Employee_Id': employeeId,
          'Employee_Name': name,
          'Last_Message': <String, dynamic>{
            'Text': lastText,
            'Type': 'text',
            'Sender': senderUser,
            'Time': now,
          },
          'Unread_By_Admin': FieldValue.increment(count),
          'Updated_At': now,
        },
        SetOptions(merge: true));
  }
}
