// ******************* FILE INFO *******************
// File Name: approval_request_toggle.dart
// Description: toggle in All Platform of this screen
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/pages/approval_request.dart';

class ApprovalToggle extends StatelessWidget {
  const ApprovalToggle({super.key});

  @override
  Widget build(BuildContext context) {
    // S7-024: every responsive branch resolved to the same widget — the variant
    // router was dead code (§17).
    return Scaffold(
      body: ApprovalServices(),
    );
  }
}

/*

return Scaffold(
body: LayoutBuilder(
builder: (context, constrain){
if (constrain.maxWidth >= 1200) {
return ApprovalMasterFullScreen(); // Desktop
} else if (constrain.maxWidth >= 900) {
return ApprovalMasterDesktop(); // Horizontal tablet
} else if (constrain.maxWidth >= 600) {
return ApprovalMasterTablet(); // // tablet
} else {
return MasterApprovalMobile(); // mobile
}

}),
);
 */
