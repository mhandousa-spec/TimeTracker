/// Module: messaging / chat / domain/entity/new_message_content_entity.dart
import 'dart:convert';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../m3_groups/domain/entities/member_entity.dart';
import '../../data/models/message/audio_message_model.dart';
import '../../data/models/message/doc_message_model.dart';
import '../../data/models/message/video_message_model.dart';

/// NewMessageContentEntity is an abstract class that is used to create new message content entities.
/// Purpose: this class is used to avoid creating many functions for each message type.
/// Example: if we have 10 message types, we will have to create 10 functions for each message type.
/// Instead, we can create a single function that takes NewMessageContentEntity as a parameter.
/// and make single part of the follow handle the message type.
/// Author: Mohamed Elrashidy
/// Created At: 24 oct 2024
sealed class NewMessageContentEntity {
  MessageTypes messageType;
  String? repliedMessageId;

  NewMessageContentEntity({required this.messageType, this.repliedMessageId});
}

class TextMessageContentEntity extends NewMessageContentEntity {
  String messageContent;
  Map<String, MemberEntity>? mentionedMembers;
  String? previewContent;
  TextMessageContentEntity(
      {required this.messageContent,
        super.repliedMessageId,
        this.mentionedMembers,
        this.previewContent})
      : super(messageType: MessageTypes.text);
}

class ImageMessageContentEntity extends NewMessageContentEntity {
  String filePath;
  String? caption;
  ImageMessageContentEntity(
      {required this.filePath, required this.caption, super.repliedMessageId})
      : super(messageType: MessageTypes.cameraImage);
}

class DocumentMessageContentEntity extends NewMessageContentEntity {
  DocMessageModel documentMessageModel;
  DocumentMessageContentEntity(
      {required this.documentMessageModel, super.repliedMessageId})
      : super(messageType: MessageTypes.doc);
}

class VideoMessageContentEntity extends NewMessageContentEntity {
  VideoMessageModel video;
  String? caption;
  VideoMessageContentEntity(
      {required this.video, required this.caption, super.repliedMessageId})
      : super(messageType: MessageTypes.video);
}

class AudioMessageContentEntity extends NewMessageContentEntity {
  AudioMessageModel audio;
  AudioMessageContentEntity({required this.audio, super.repliedMessageId})
      : super(messageType: MessageTypes.audio);
}
/// Shared location (bug report #23). Travels as JSON in the message's
/// `Message_Content` — see [LocationPayload].
class LocationMessageContentEntity extends NewMessageContentEntity {
  LocationPayload location;
  LocationMessageContentEntity({required this.location, super.repliedMessageId})
      : super(messageType: MessageTypes.location);
}

/// Shared colleague contact card (bug report #23). Travels as JSON in the
/// message's `Message_Content` — see [ContactPayload].
class ContactMessageContentEntity extends NewMessageContentEntity {
  ContactPayload contact;
  ContactMessageContentEntity({required this.contact, super.repliedMessageId})
      : super(messageType: MessageTypes.contact);
}

/// A poll (Figma 6799:5666). Travels as JSON in the message's
/// `Message_Content` — see [PollPayload]. Votes live outside the message, in
/// `PollVotesService`, so voting never rewrites the (encrypted) message.
/// ADDED 30/9/2026.
class PollMessageContentEntity extends NewMessageContentEntity {
  PollPayload poll;
  PollMessageContentEntity({required this.poll, super.repliedMessageId})
      : super(messageType: MessageTypes.poll);
}

/// Wire format of a poll message.
class PollPayload {
  final String question;
  final List<String> options;

  /// Voters can tick more than one option.
  final bool allowMultiple;

  /// Only the counts are shown, never who voted.
  final bool hideVoters;

  const PollPayload({
    required this.question,
    required this.options,
    this.allowMultiple = false,
    this.hideVoters = false,
  });

  String encode() => jsonEncode(<String, dynamic>{
        'question': question,
        'options': options,
        'multiple': allowMultiple,
        'hideVoters': hideVoters,
      });

  static PollPayload? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      return PollPayload(
        question: m['question'] as String,
        options: List<String>.from(m['options'] as List<dynamic>),
        allowMultiple: m['multiple'] as bool? ?? false,
        hideVoters: m['hideVoters'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Wire format of a location message.
class LocationPayload {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationPayload({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  String get googleMapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  String encode() => jsonEncode(<String, dynamic>{
        'lat': latitude,
        'lng': longitude,
        if (address != null) 'address': address,
      });

  static LocationPayload? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      return LocationPayload(
        latitude: (m['lat'] as num).toDouble(),
        longitude: (m['lng'] as num).toDouble(),
        address: m['address'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Wire format of a contact message: a colleague from the app directory.
class ContactPayload {
  final String userId; // email = messaging user id
  final String name;
  final String? nameAr;
  final String? jobTitle;
  final String? jobTitleAr;
  final String? imageUri;

  const ContactPayload({
    required this.userId,
    required this.name,
    this.nameAr,
    this.jobTitle,
    this.jobTitleAr,
    this.imageUri,
  });

  String encode() => jsonEncode(<String, dynamic>{
        'userId': userId,
        'name': name,
        if (nameAr != null) 'nameAr': nameAr,
        if (jobTitle != null) 'jobTitle': jobTitle,
        if (jobTitleAr != null) 'jobTitleAr': jobTitleAr,
        if (imageUri != null) 'imageUri': imageUri,
      });

  static ContactPayload? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      return ContactPayload(
        userId: m['userId'] as String,
        name: m['name'] as String,
        nameAr: m['nameAr'] as String?,
        jobTitle: m['jobTitle'] as String?,
        jobTitleAr: m['jobTitleAr'] as String?,
        imageUri: m['imageUri'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
