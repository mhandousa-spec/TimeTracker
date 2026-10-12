/// Module: GRC Approvals
/// Description: The Module Owner's "Give Score" tab on Approvals.
///
/// ADDED 28/9/2026 (GRC bug report p3). Lists the controls whose owner was
/// added with "Give Score" off (p2) and has already approved the evidence —
/// the score is the Module Owner's to give. Loaded by
/// [MyAuditCubit.getScoreRequests]; each row opens the normal My Audit
/// details page in score-only mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_item.dart';
import 'package:knowticed_plus/features/grc/my_audit/presentation/controller/my_audit_cubit.dart';
import 'package:knowticed_plus/features/grc/my_audit/presentation/ui/pages/my_audit_details_page.dart';
import 'package:knowticed_plus/features/grc/my_audit/presentation/ui/widgets/my_audit_card.dart';

class ApprovalGiveScoreTab extends StatelessWidget {
  final GRCModuleEntity module;

  const ApprovalGiveScoreTab({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyAuditCubit>(
      create: (_) => GetIt.instance<MyAuditCubit>()
        ..getScoreRequests(moduleId: module.moduleId),
      child: _GiveScoreList(module: module),
    );
  }
}

class _GiveScoreList extends StatefulWidget {
  final GRCModuleEntity module;
  const _GiveScoreList({required this.module});

  @override
  State<_GiveScoreList> createState() => _GiveScoreListState();
}

class _GiveScoreListState extends State<_GiveScoreList> {
  List<MyAuditItem> _last = const [];

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    return BlocBuilder<MyAuditCubit, MyAuditState>(
      buildWhen: (_, s) =>
          s is MyAuditListLoaded || s is MyAuditLoading || s is MyAuditFailure,
      builder: (context, state) {
        if (state is MyAuditListLoaded) _last = state.items;
        if (state is MyAuditFailure) {
          return Center(
            child: Text(state.message,
                style: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.red)),
          );
        }
        if (state is! MyAuditListLoaded && _last.isEmpty) {
          return const Center(child: CircleProgressMaster());
        }
        if (_last.isEmpty) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const CustomEmptyState(size: 220),
                Text(
                  isArabic
                      ? 'لا توجد ضوابط بانتظار درجتك'
                      : 'No controls are waiting for your score',
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          itemCount: _last.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, i) {
            final item = _last[i];
            return MyAuditCard(
              item: item,
              isArabic: isArabic,
              onTap: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => BlocProvider.value(
                    value: context.read<MyAuditCubit>(),
                    child: MyAuditDetailsPage(
                      item: item,
                      module: widget.module,
                      scoreOnly: true,
                    ),
                  ),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
