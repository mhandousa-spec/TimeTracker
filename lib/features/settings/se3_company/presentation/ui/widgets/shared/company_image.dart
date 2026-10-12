/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_image.dart
/// Purpose: The logo picker — uploads an image and reports the resulting URL.
/// Author: Amr Mesbah
/// Created at: 11/12/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N25: added the standard header.

import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';

class CompanyImage extends StatefulWidget {
   CompanyImage({required this.onChangedImageUrl,super.key});
   final ValueChanged<String> onChangedImageUrl;

  @override
  State<CompanyImage> createState() => _CompanyImageState();
}

class _CompanyImageState extends State<CompanyImage> {
  final ImagePicker picker = ImagePicker();

  File? _image;

  Future<void> _uploadImage() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles();

    if (pickedFile != null) {
      if (pickedFile.paths[0]!.toLowerCase().endsWith('.svg')) {
        showLoadingIndicator();
        _image = File(pickedFile.paths[0]!);
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('/company_logo/${DateTime.now()}.svg');
        final metadata = SettableMetadata(contentType: 'image/svg+xml');
        UploadTask uploadTask = ref.putFile(_image!, metadata);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        final String url = await taskSnapshot.ref.getDownloadURL();
        if (!mounted) return;
        context.read<CompanyCubit>().setImageUrl(url);
        widget.onChangedImageUrl(url);
        hideLoadingIndicator();
        setState(() {});
      } else {
        CustomDialogManager.showMessage(
          context: context,
          title: S.of(context).unsuccessful,
          subtitle: S.of(context).pleaseSelectImageInSvgFormat,
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) => InkWell(
      onTap: () {
        _uploadImage();
      },
      child: Stack(
        children: <Widget>[
          state.imageUrl == null &&
              (state.company?.companyLogo
                  ?.companyLogo?.lastOrNull ==
                  null ||
                  state.company!.status ==
                      'inactive')
              ? CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.background,
            child: Center(
              child: Transform.scale(
                  scale: isTablet ? 1.2 : 0.8,
                  child: SvgPicture.asset(
                      color: AppColors.text,
                      "assets/icons_assets/main_icons_assets/image_photo_rounded.svg")),
            ),
          )
              : CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.background,
            child: ClipOval(
              child: SizedBox(
                width: isTablet
                    ? (isVertical ? 0.07.h : 0.06.w)
                    : 0.09.h,
                height: isTablet
                    ? (isVertical ? 0.07.h : 0.06.w)
                    : 0.09.h,
                child: SvgPicture.network(
                  color: AppColors.text,
                  state.imageUrl ??
                      state.company!.companyLogo!
                          .companyLogo!.last!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: AlignmentDirectional.bottomEnd,  // Changed from Alignment.bottomRight
              child: Transform.scale(
                scale: isTablet ? 1.1 : 1.1,
                child: CircleAvatar(
                    backgroundColor: AppColors.signOut,
                    radius: isVertical ? 0.01.h : 0.013.h,
                    child: SvgPicture.asset(
                      "assets/icons_assets/messaging_assets/camera.svg",
                      color: AppColors.textButton,
                      height: 0.015.h,
                    )),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
