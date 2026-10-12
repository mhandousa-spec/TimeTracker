
/// ******************* FILE INFO *******************
/// File Name: request_services_toggle.dart
/// Description: toggle in All Platform of this screen
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/request_services.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class RequestServicesToggle extends StatelessWidget {
  const RequestServicesToggle({super.key});

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
            return RequestServicesPage(); // Or tablet Landscape
          } else if (isTablet && !isLandscape) {
            return const RequestServicesPage();
          } else if (!isTablet && isLandscape) {
            return RequestServicesPage();
          } else {
            return RequestServicesPage();
          }
        },
      ),
    );
  }
}

/*
return Scaffold(
body: Builder(
builder: (context) {
final width = MediaQuery.of(context).size.width;
final orientation = MediaQuery.of(context).orientation;

if (width >= 1200) {
return RequestServicesDesktop();
} else if (width >= 900 && orientation == Orientation.landscape) {
return RequestServicesDesktop(); // ✅ Responsive tablet landscape
} else if (width >= 600 && orientation == Orientation.portrait) {
return RequestServicesTablet();
} else {
return RequestServicesMobile();
}
},
),
);
 */

