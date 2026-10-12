/// Module: services_management_module
/// Description: Status chip filter (All/Active/Inactive/Draft) for the
///              current user's own services on the home services page.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: StatusChipFilter, ServicesHistoryModel, AppColors
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from home_page_services.dart
///     (fix item 1c — build-method decomposition).
import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/enums/service_display_status.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/widgets/home_services_visibility_filter.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HomeServicesStatusFilter extends StatelessWidget {
  final List<ServicesHistoryModel> allServices;
  final String currentUserEmail;
  final int selectedStatusIndex;
  final ValueChanged<int> onIndexSelected;

  const HomeServicesStatusFilter({
    super.key,
    required this.allServices,
    required this.currentUserEmail,
    required this.selectedStatusIndex,
    required this.onIndexSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final email = currentUserEmail.toLowerCase().trim();

    // Use English keys internally, translate only for display
    final String kAll = "All";
    final String kActive = l.active;
    final String kInactive = l.inactive;
    final String kDraft = l.draft;

    // Whose service is this? Kept separate from WHAT it is — conflating the two
    // is how the draft count broke.
    //
    // The id test is for the legacy `draft_<email>_...` documents, which carry
    // no requester email of their own.
    bool isUsersService(ServicesHistoryModel service) {
      final serviceEmail =
          (service.currentEmailRequester ?? '').toLowerCase().trim();
      final serviceId = service.currentId.toLowerCase();
      return serviceEmail == email ||
          (serviceId.startsWith('draft_') && serviceId.contains(email));
    }

    final userServices = allServices.where(isUsersService).toList();

    // ✅ FIX 26/8/2026 — all three counts were wrong, in two different ways.
    //
    // ACTIVE and INACTIVE read `currentStatus` alone with no draft exclusion. A
    // draft stores the availability it is destined for once published, and that
    // is 'active' by default, so every saved draft was counted under Active.
    //
    // DRAFT additionally required `serviceId.startsWith('draft_')` — and real
    // drafts are not named that. `SlaNotificationCubit._ensureDraftDoc` mints
    // ids shaped `User<random><MMMdd_yyyy>`, and a draft resumed from the create
    // wizard keeps the id it was given there. The `draft_` prefix only ever
    // belonged to the older SharedPrefs drafts, so this counted the legacy ones
    // and none of the current ones — in practice, zero.
    //
    // Those two together are the reported symptom exactly: save for later, and
    // the service is counted under Active while Draft stays empty.
    //
    // Classification now goes through the same helper the row filter uses, so a
    // count and the list it labels can no longer disagree.
    List<ServicesHistoryModel> countedAs(ServiceDisplayStatus status) =>
        userServices
            .where((service) =>
                HomeServicesVisibilityFilter.displayStatusOf(service) == status)
            .toList();

    final userActiveServices = countedAs(ServiceDisplayStatus.active);
    final userInactiveServices = countedAs(ServiceDisplayStatus.inactive);
    final userDraftServices = countedAs(ServiceDisplayStatus.draft);

    final Map<String, int> statusCountsNoAll = {
      kActive: userActiveServices.length,
      kInactive: userInactiveServices.length,
      kDraft: userDraftServices.length,
    };

    String currentSelectedKey;
    switch (selectedStatusIndex) {
      case 0:
        currentSelectedKey = kAll;
        break;
      case 1:
        currentSelectedKey = kActive;
        break;
      case 2:
        currentSelectedKey = kInactive;
        break;
      case 3:
        currentSelectedKey = kDraft;
        break;
      default:
        currentSelectedKey = kAll;
    }

    return StatusChipFilter(
      selectedKey: currentSelectedKey,
      onSelected: (key) {
        if (key == kAll) {
          onIndexSelected(0);
        } else if (key == kActive) {
          onIndexSelected(1);
        } else if (key == kInactive) {
          onIndexSelected(2);
        } else if (key == kDraft) {
          onIndexSelected(3);
        }
      },
      items: departmentChipItems(
        totalCount: userServices.length,
        departmentCounts: statusCountsNoAll,
        isArabic: isArabic,
        labelColors: {
          kActive: AppColors.green,
          kInactive: AppColors.red,
          // ✅ FIX (bug report p20): Draft was AppColors.grey, which read as
          // disabled next to the green/red status chips. Use the brand
          // secondary so it reads as "in progress".
          kDraft: AppColors.darkGrey,
        },
      ),
    );
  }
}
