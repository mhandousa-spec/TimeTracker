import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/publish_access_bodies.dart';


class PublishScreen extends StatelessWidget {
  const PublishScreen({super.key, required this.model});

  final FormEntity model;

  @override
  Widget build(BuildContext context) {
    // CHANGED 19/8/2026 — header is SideFrameMasterServices now, not
    // CustomAppBar. The title was also the hard-coded literal 'Publish'.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).publish,
        onFirstTap: breadcrumbPop(context, 1),
        child: _buildScrollableBody(context),
      ),
    );
  }

  /// The frame scrolls the content itself on mobile; on tablet it hands the
  /// child a bounded height, so the scroll view stays here.
  Widget _buildScrollableBody(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: _buildBody(context),
    );

    return ContextExtension(context).isTablett
        ? SingleChildScrollView(child: content)
        : content;
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // stored values, not display text — see AccessManagementExtension.name
        if (model.formHeadModel.accessManagement ==
            AccessManagement.openAccess.name)
          PublishOpenAccessBody(model: model),
        if (model.formHeadModel.accessManagement ==
            AccessManagement.restrictedAccess.name)
          PublishRestrictedAccessBody(model: model),
      ],
    );
  }
}
