import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../data/services/submissions_firebase_service.dart';
import '../../../../k4_submissions/presentation/controller/submissions_cubit.dart';
import '../../../../k4_submissions/presentation/ui/pages/submissions_screen.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget submissionsButton(BuildContext context) {
  final isMobile = ContextExtension(context).isPhone;
  return Align(
    alignment: AlignmentDirectional.topEnd,
    child: SizedBox(
      child: customButton(
        title: S.of(context).submissions,
        function: () {
          log('Submissions Button Pressed');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) =>
                    SubmissionsCubit(SubmissionsFirebaseServices()),
                child: SubmissionsScreen(),
              ),
            ),
          );
        },
        width: isMobile ? 100.w : 135.w,
        height: 38.h,
        textStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.textButton,
          letterSpacing: .1
        ),
      ),
    ),
  );
}
