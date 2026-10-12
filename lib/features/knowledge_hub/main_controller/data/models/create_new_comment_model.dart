/// Module: knowledge_hub / core/data/models/create_new_comment_model.dart
import 'dart:developer';
/// ************************* FILE INFO *************************** ///
/// File Name: create_new_comment_model.dart
/// Purpose: Contains the model class to create new comment on knowledge file.
/// Author: Youssef Khaled
/// Created At: 11/10/2025


class CreateNewCommentModel {
  // Core fields - Direct lists
  final List<String> timestamps;
  final List<String> commentId;
  final List<String> commentText;
  final List<String> createdById;
  final List<String> createdByEmail;
  final List<String> attachmentExtension;
  final List<int> attachmentSize;

  CreateNewCommentModel({
    required this.timestamps,
    required this.commentId,
    required this.commentText,
    required this.createdById,
    required this.createdByEmail,
    required this.attachmentExtension,
    required this.attachmentSize,
  });

  // ✅ Helper getters for current (latest) values
  String get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : '';
  String get currentCommentId => commentId.isNotEmpty ? commentId.last : '';
  String get currentCommentText => commentText.isNotEmpty ? commentText.last : '';
  String get currentCreatedById => createdById.isNotEmpty ? createdById.last : '';
  String get currentCreatedByEmail => createdByEmail.isNotEmpty ? createdByEmail.last : '';
  String get currentAttachmentExtension => attachmentExtension.isNotEmpty ? attachmentExtension.last : '';
  int get currentAttachmentSize => attachmentSize.isNotEmpty ? attachmentSize.last : 0;

  // ✅ Get value at specific index
  String? getTimestampAt(int index) => index < timestamps.length ? timestamps[index] : null;
  String? getCommentIdAt(int index) => index < commentId.length ? commentId[index] : null;
  String? getCommentTextAt(int index) => index < commentText.length ? commentText[index] : null;
  String? getCreatedByIdAt(int index) => index < createdById.length ? createdById[index] : null;
  String? getCreatedByEmailAt(int index) => index < createdByEmail.length ? createdByEmail[index] : null;
  String? getAttachmentExtensionAt(int index) => index < attachmentExtension.length ? attachmentExtension[index] : null;
  int? getAttachmentSizeAt(int index) => index < attachmentSize.length ? attachmentSize[index] : null;

  // Factory: Create from JSON
  factory CreateNewCommentModel.fromJson(Map<String, dynamic> json) {
      return CreateNewCommentModel(
        timestamps: _parseList<String>(json['timestamps'], (v) => v?.toString() ?? ''),
        commentId: _parseList<String>(json['commentId'], (v) => v as String? ?? ''),
        commentText: _parseList<String>(json['commentText'], (v) => v as String? ?? ''),
        createdById: _parseList<String>(json['createdById'], (v) => v as String? ?? ''),
        createdByEmail: _parseList<String>(json['createdByEmail'], (v) => v as String? ?? ''),
        attachmentExtension: _parseList<String>(json['attachmentExtension'], (v) => v as String? ?? ''),
        attachmentSize: _parseList<int>(json['attachmentSize'], (v) => v as int? ?? 0),
      );
  }

  // Helper: Parse list (handles multiple legacy formats)
  static List<T> _parseList<T>(dynamic value, T Function(dynamic) deserializer) {
    // If it's already a list
    if (value is List) {
      return value.map((e) => deserializer(e)).toList();
    }

    // Legacy format with FieldHistory: {timestamps: [...], values: [...]}
    if (value is Map<String, dynamic> && value.containsKey('values')) {
      final values = value['values'];
      if (values is List) {
        return values.map((e) => deserializer(e)).toList();
      }
    }

    // Legacy format: {value: ..., timestamp: ...}
    if (value is Map<String, dynamic> && value.containsKey('value')) {
      return [deserializer(value['value'])];
    }

    // Simple value
    return [deserializer(value)];
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamps': timestamps,
      'commentId': commentId,
      'commentText': commentText,
      'createdById': createdById,
      'createdByEmail': createdByEmail,
      'attachmentExtension': attachmentExtension,
      'attachmentSize': attachmentSize,
    };
  }

  // Factory: Create with initial values
  factory CreateNewCommentModel.createNew({
    required String commentId,
    required String commentText,
    required String createdById,
    required String createdByEmail,
    String? attachmentExtension,
    int? attachmentSize,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    return CreateNewCommentModel(
      timestamps: [timestamp],
      commentId: [commentId],
      commentText: [commentText],
      createdById: [createdById],
      createdByEmail: [createdByEmail],
      attachmentExtension: [attachmentExtension ?? ''],
      attachmentSize: [attachmentSize ?? 0],
    );
  }

  // copyWith method - adds new timestamp and new values
  CreateNewCommentModel copyWith({
    String? commentId,
    String? commentText,
    String? createdById,
    String? createdByEmail,
    String? attachmentExtension,
    int? attachmentSize,
  }) {
    // ✅ Add new timestamp
    final newTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final newTimestamps = List<String>.from(timestamps)..add(newTimestamp);

    return CreateNewCommentModel(
      timestamps: newTimestamps,
      commentId: commentId != null ? (List<String>.from(this.commentId)..add(commentId)) : this.commentId,
      commentText: commentText != null ? (List<String>.from(this.commentText)..add(commentText)) : this.commentText,
      createdById: createdById != null ? (List<String>.from(this.createdById)..add(createdById)) : this.createdById,
      createdByEmail: createdByEmail != null ? (List<String>.from(this.createdByEmail)..add(createdByEmail)) : this.createdByEmail,
      attachmentExtension: attachmentExtension != null ? (List<String>.from(this.attachmentExtension)..add(attachmentExtension)) : this.attachmentExtension,
      attachmentSize: attachmentSize != null ? (List<int>.from(this.attachmentSize)..add(attachmentSize)) : this.attachmentSize,
    );
  }

  // Update methods - add new values to lists
  void updateCommentText(String text) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    timestamps.add(timestamp);
    commentText.add(text);
  }

  void updateAttachment({
    String? extension,
    int? size,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    timestamps.add(timestamp);
    if (extension != null) attachmentExtension.add(extension);
    if (size != null) attachmentSize.add(size);
  }

  void updateCreatorInfo({
    String? id,
    String? email,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    timestamps.add(timestamp);
    if (id != null) createdById.add(id);
    if (email != null) createdByEmail.add(email);
  }
}