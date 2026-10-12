// ******************* FILE INFO *******************
// File Name: safe_json
// Description: Null-returning JSON decode helper so UI code does not need
//   try/catch around jsonDecode (§11.2).
// Module: core / utils
// *************************************************

import 'dart:convert';

/// Decodes [source] as JSON, returning null instead of throwing on malformed
/// input. Keeps the try/catch in this utility (data layer) rather than in
/// widgets.
dynamic safeJsonDecode(String? source) {
  if (source == null || source.isEmpty) return null;
  try {
    return jsonDecode(source);
  } catch (_) {
    return null;
  }
}
