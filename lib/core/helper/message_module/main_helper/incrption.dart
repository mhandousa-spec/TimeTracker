/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: incrption.dart
/// Purpose: Declares `MessageEncryptionService`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Date: 2/3/2026
// Purpose: AES-256 encryption/decryption service for chat messages
// Dependencies: encrypt: ^5.0.3, crypto: ^3.0.3

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc; // ✅ aliased to avoid conflicts

class MessageEncryptionService {
  // ── Singleton ────────────────────────────────────────────────────────────
  static final MessageEncryptionService _instance =
  MessageEncryptionService._internal();

  factory MessageEncryptionService() => _instance;

  MessageEncryptionService._internal();

  // ── Key derivation ────────────────────────────────────────────────────────
  /// Derives a deterministic 32-byte AES key from the chatId using SHA-256.
  /// Both sender and receiver share the same chatId → same key → can decrypt.
  enc.Key _deriveKey(String chatId) {
    final bytes = utf8.encode(chatId);
    final hash = sha256.convert(bytes); // always 32 bytes
    return enc.Key(Uint8List.fromList(hash.bytes));
  }

  // ── Encrypt ───────────────────────────────────────────────────────────────
  /// Encrypts [plainText] using AES-256-CBC with a random IV.
  /// Returns a Base64 payload in the format: "<ivBase64>:<cipherBase64>"
  /// Falls back to [plainText] on error so chat never silently breaks.
  String encrypt(String plainText, {required String chatId}) {
    try {
      final key = _deriveKey(chatId);
      final iv = enc.IV.fromSecureRandom(16); // fresh random IV per message
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Combine IV + ciphertext so we can decrypt without storing IV separately
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      return plainText; // graceful fallback
    }
  }

  // ── Decrypt ───────────────────────────────────────────────────────────────
  /// Decrypts a payload produced by [encrypt].
  /// Handles legacy plain-text messages gracefully (no ":" separator).
  String decrypt(String payload, {required String chatId}) {
    try {
      // ── Legacy / plain-text guard ─────────────────────────────────────────
      if (!isEncrypted(payload)) return payload;

      final parts = payload.split(':');
      final key = _deriveKey(chatId);
      final iv = enc.IV.fromBase64(parts[0]);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (e) {
      return payload; // show raw content rather than crashing
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  /// Returns true only when the payload looks like an encrypted message.
  /// Format check: exactly one ":" separator with non-empty parts.
  bool isEncrypted(String? content) {
    if (content == null || content.isEmpty) return false;
    final parts = content.split(':');
    return parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty;
  }
}