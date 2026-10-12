// ******************* FILE INFO *******************
// File Name: request_provider_section
// Description: FutureBuilder that resolves the assigned provider for a request
//              and renders the provider details (with shimmer while loading).
//              Extracted from MyRequestDetails.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/request_provider_resolver.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/info_text.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/provider_details.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/show_request_details_shimmer.dart';

class RequestProviderSection extends StatelessWidget {
  final ServicesHistoryModel model;
  final String requesterEmail;
  final bool isMobile;
  final bool isLoadingServiceDetails;
  final String durationToDisplay;

  const RequestProviderSection({
    Key? key,
    required this.model,
    required this.requesterEmail,
    required this.isMobile,
    required this.isLoadingServiceDetails,
    required this.durationToDisplay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resolver = RequestProviderResolver(
      model: model,
      requesterEmail: requesterEmail,
    );

    return FutureBuilder<Map<String, dynamic>?>(
      future: resolver.getRequestSpecificProvider(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerPlaceholder(context, width: 200, height: 20),
                  SizedBox(height: 10.h),
                  shimmerPlaceholder(context, width: 150, height: 20),
                  SizedBox(height: 10.h),
                  shimmerPlaceholder(context, width: 180, height: 20),
                ],
              ),
              isMobile
                  ? SizedBox()
                  : SizedBox(
                width: !isTabletLandscape(context)
                    ? MediaQuery.sizeOf(context).width * .05
                    : MediaQuery.sizeOf(context).width * .1,
              ),
              isMobile
                  ? SizedBox()
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerPlaceholder(context, width: 160, height: 20),
                  SizedBox(height: 10.h),
                  shimmerPlaceholder(context, width: 140, height: 20),
                  SizedBox(height: 10.h),
                  shimmerPlaceholder(context, width: 180, height: 20),
                ],
              ),
            ],
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final providerData = snapshot.data!;

          final providerModel =
              resolver.convertMapToEmployeeEntityModel(providerData);

          final durationTimestamp = model.currentDurationOfServicesTimestamp;

          return buildProviderDetailsSectionMaster(
            context: context,
            duration: isLoadingServiceDetails
                ? model.currentDurationOfServices
                : durationToDisplay.split(' ').first,
            durationUnit: isLoadingServiceDetails
                ? model.currentSelectedDurationUnit
                : durationToDisplay.split(' ').length > 1
                    ? durationToDisplay.split(' ').sublist(1).join(' ')
                    : model.currentSelectedDurationUnit,
            durationTimeStamp: durationTimestamp,
            approvalCycle: model.currentApprovalCycle,
            model: providerModel,
            state: model.currentState.isNotEmpty
                ? model.currentState
                : 'pending',
          );
        } else {
          return Center(
            child: Text(S.of(context).Noproviderdatafound),
          );
        }
      },
    );
  }
}
