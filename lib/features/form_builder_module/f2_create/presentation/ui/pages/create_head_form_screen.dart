

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
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/head_screen_body.dart';


class CreateHeadFormScreen extends StatefulWidget {
  const CreateHeadFormScreen({super.key, this.formModel});
  final FormEntity? formModel;

  @override
  State<CreateHeadFormScreen> createState() => _CreateHeadFormScreenState();
}

class _CreateHeadFormScreenState extends State<CreateHeadFormScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CreateFormHeadCubit>().resetController();
    context.read<CreateFormHeadCubit>().init(editFormModel: widget.formModel);
  }

  @override
  Widget build(BuildContext context) {
    // CHANGED 19/8/2026 — see create_form_data_screen.dart.
    return ContextExtension(context).isTablett
        ?  CreatingFormTabletScreen()
        : Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).createNewForm,
        onFirstTap: breadcrumbPop(context, 1),
        child: Padding(
          padding: EdgeInsets.only(top: 20.h, left: 15.w, right: 15.w),
          child: BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
            builder: (context, state) {
              // You'll need to add formKey to CreateFormHeadCubit
              return Form(
                key: GlobalKey<FormState>(), // Placeholder
                child: HeadScreenBody(formModel: widget.formModel),
              );
            },
          ),
        ),
      ),
    );
  }
}