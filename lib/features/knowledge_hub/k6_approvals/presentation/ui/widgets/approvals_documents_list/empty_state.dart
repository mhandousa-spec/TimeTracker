/// Module: knowledge_hub / presentation / s6_approvals / widgets/approvals_documents_list/empty_state.dart
/// ************************* FILE INFO *************************** ///
/// File Name: empty_state.dart
/// Purpose: Empty state — Approvals (S6) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget buildEmptyApprovalsState(BuildContext context) {
  return Center(
    child: Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_empty.json'),
  );
}