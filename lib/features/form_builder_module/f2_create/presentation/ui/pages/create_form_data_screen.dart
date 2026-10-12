

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/tablet/creating_form_tablet_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/create_data_screen_body.dart';


class CreateFormDataScreen extends StatefulWidget {
  const CreateFormDataScreen({super.key, this.formModel});

  final FormEntity? formModel;

  @override
  State<CreateFormDataScreen> createState() => _CreateFormDataScreenState();
}

class _CreateFormDataScreenState extends State<CreateFormDataScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CreateFormDataCubit>().resetController();
    context.read<CreateFormDataCubit>().init(editFormModel: widget.formModel);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateFormDataCubit>();

    // CHANGED 19/8/2026 — header is SideFrameMasterServices now, not
    // CustomAppBar. The frame supplies the phone back-chevron that
    // CustomAppBar's leading used to draw, so nothing is lost.
    return ContextExtension(context).isTablett
        ?  CreatingFormTabletScreen()
        : Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).createNewForm,
        onFirstTap: breadcrumbPop(context, 1),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 15.w, right: 15.w),
            child: Form(
              key: cubit.formCreateDataKey,
              child: CreateDataScreenBody(formModel: widget.formModel),
            ),
          ),
        ),
      ),
    );
  }
}