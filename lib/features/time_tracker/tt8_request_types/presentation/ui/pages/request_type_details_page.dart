/// Module: time_tracker / tt8_request_types / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_details_page.dart
/// Purpose: Declares `RequestTypeDetailsPage` — "Tracking Time › {Request
///          Type}": every value of the type, Edit · Remove · Active /
///          Inactive.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:44218`. Gates: Edit `Edit_Request_Type`, Remove
/// `Remove_Request_Type` (status `removed`; hidden once removed), the status
/// switch `Change_Request_Type_Status` (a removed type can be re-activated).
/// Dialogs (owner copy fixes): Remove `661:44426` → "Removing Request Type"
/// / "Request Type Removed" (the button says Remove, the Figma dialog said
/// Delete); Status `661:44439` "Changing Status" → `661:44452`. Live from
/// `RequestTypesCubit`.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/pages/request_type_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/widgets/request_type_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestTypeDetailsPage extends StatelessWidget {
  const RequestTypeDetailsPage({super.key, required this.typeId});

  final String typeId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestTypesCubit, RequestTypesState>(
      builder: (BuildContext context, RequestTypesState state) {
        final RequestType? type = state.byId(typeId);
        if (type == null) {
          return Scaffold(backgroundColor: AppColors.background, body: const Center(child: CustomEmptyState()));
        }
        return _Details(type: type, state: state);
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.type, required this.state});

  final RequestType type;
  final RequestTypesState state;

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  Future<void> _afterFlow(BuildContext context) async {
    final RequestTypesCubit cubit = context.read<RequestTypesCubit>();
    if (!context.mounted || cubit.state.failure == TimeTrackerActionFailure.none) return;
    final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
    cubit.acknowledgeFailure();
    await showTimeTrackerFailure(context, denied: denied);
  }

  Future<void> _remove(BuildContext context) async {
    final S s = S.of(context);
    final RequestTypesCubit cubit = context.read<RequestTypesCubit>();
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      destructive: true,
      confirmLottie: AppAssets.lottieWarning,
      confirmTitle: s.timeTrackerRemovingRequestType,
      confirmSubtitle: s.timeTrackerRemoveRequestTypeConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () => cubit.remove(type),
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerRequestTypeRemovedTitle,
      successSubtitle: s.timeTrackerRequestTypeRemoved,
    );
    if (context.mounted) await _afterFlow(context);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<String> headers = RequestTypeText.headers(context);
    final List<String> cells = RequestTypeText.cells(context, type, state);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final List<(String, String)> items = <(String, String)>[
      for (int i = 0; i < headers.length; i++) (headers[i], cells[i]),
    ];
    final String description = type.description(isArabic: ar);
    if (description.isNotEmpty) items.insert(1, (s.timeTrackerRequestDescription, description));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: RequestTypeText.name(context, type),
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: SideFrameScrollableBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SlideInContent(child: _actions(context, s)),
              SizedBox(height: 15.h),
              SlideInContent(
                delay: const Duration(milliseconds: 60),
                child: TtFormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (int i = 0; i < items.length; i += 2) ...<Widget>[
                        if (i > 0) SizedBox(height: 12.h),
                        TtPair(start: _value(items[i]), end: i + 1 < items.length ? _value(items[i + 1]) : null),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, S s) {
    // UI quality pass (owner 13:45 #7 / #8): the status shows here as text
    // only — it is changed inside Edit (`TtStatusSwitch`); Remove is red
    // with a white trash + text.
    return Row(
      children: <Widget>[
        RequestTypeStatusText(status: type.status),
        const Spacer(),
        if (_access.canEditRequestType)
          CustomEditIcon(
            key: const ValueKey<String>('requestTypeEditButton'),
            title: s.edit,
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => RequestTypeFormPage(original: type)),
            ),
          ),
        if (_access.canRemoveRequestType && type.status != RequestTypeStatus.removed) ...<Widget>[
          SizedBox(width: 10.w),
          TtDeleteButton(
            key: const ValueKey<String>('requestTypeRemoveButton'),
            title: s.timeTrackerRemove,
            onTap: () => _remove(context),
          ),
        ],
      ],
    );
  }

  Widget _value((String, String) item) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(item.$1, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
          SizedBox(height: 4.h),
          Text(item.$2, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        ],
      );
}
