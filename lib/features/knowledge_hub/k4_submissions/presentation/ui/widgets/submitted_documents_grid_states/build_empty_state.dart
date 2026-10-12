/// Module: knowledge_hub / presentation / s4_submissions / widgets/submitted_documents_grid_states/build_empty_state.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_empty_state.dart
/// Purpose: Build empty state — Submissions (S4) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget buildEmptyState(BuildContext context) {
  return Center(
    child: Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_empty.json'),
  );
}
