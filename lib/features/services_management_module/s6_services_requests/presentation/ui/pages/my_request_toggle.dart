// ******************* FILE INFO *******************
// File Name: my_request_toggle.dart
// Description: toggle in All Platform of this screen
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/my_request.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MyRequestServicesToggle extends StatelessWidget {
  const MyRequestServicesToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          final width = MediaQuery.of(context).size.width;
          final height = MediaQuery.of(context).size.height;

          if (isTablet && isLandscape) {
            return MyRequestServices(); // Or tablet Landscape
          } else if (isTablet && !isLandscape) {
            return const MyRequestServices();
          } else if (!isTablet && isLandscape) {
            return MyRequestServices();
          } else {
            return MyRequestServices();
          }
        },
      ),
    );
  }
}

/*
return Scaffold(
body: LayoutBuilder(
builder: (context, constrain){

if (constrain.maxWidth >= 1200) {
return MyRequestServicesFullScreen(); // Desktop
} else if (constrain.maxWidth >= 900) {
return MyRequestServicesDesktop(); // Horizontal tablet
} else if (constrain.maxWidth >= 600) {
return MyRequestServicesTablet(); // // tablet
} else {
return MyRequestServicesMobile();  // mobile
}

}),
);
 */
