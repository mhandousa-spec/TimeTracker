import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
class GroupInfo extends StatelessWidget {
  const GroupInfo({this.isReadOnly = false, super.key});

  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormsGroupCubit, FormsGroupState>(
      builder: (context, state) {
        if (state is! FormsGroupLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            _buildGroupNameFields(context, state),
            verticalSpace(15),
            _buildDescriptionField(context, state),
          ],
        );
      },
    );
  }

  Widget _buildDescriptionField(BuildContext context, FormsGroupLoaded state) {
    return CustomTextField(
        minLines: 4,
        maxLines: 10,
        maxLength: 500,
        showCharCount: true,
        readOnly: isReadOnly,
        controller: state.descriptionController,
        label: 'Description',
      );
  }

  Widget _buildGroupNameField(BuildContext context, FormsGroupLoaded state) {
    return CustomTextField(
        controller: state.groupNameController,
        height: 36,
        readOnly: isReadOnly,
        label: 'Group Name',
      );
  }

  Widget _buildGroupNameFields(BuildContext context, FormsGroupLoaded state) {
    return !ContextExtension(context).isTablett
        ? _buildGroupNameField(context, state)
        : Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: _buildGroupNameField(context, state)),
        Expanded(child: Container()),
      ],
    );
  }
}