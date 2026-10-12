// ******************* FILE INFO *******************
// File Name: image_upload_widget
// Description: Image upload widget.
// Module: services_management_module / presentation/s4_bulk_upload_services/ui/widgets
// *************************************************

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/controller/create_service_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/controller/create_service_state.dart';

/// ♻️ REFACTOR — the avatar, the placeholder svg, the camera badge and the
/// picking itself are no longer hand-rolled here. They now come from
/// `core/custom/46-custom_image_picker.dart` (`CustomImagePicker`), the shared
/// control the other screens already use, which additionally validates the
/// picked file (extension whitelist + a real decode) before it ever reaches
/// the cubit — a check this widget never did.
///
/// What stays local is what is specific to *this* form and has no place in a
/// core widget: the upload spinner and the delete-with-confirmation button,
/// both layered over the picker in a Stack.
///
/// RTL note: the corner badges used to be positioned with hand-written
/// `isArabic ? ... : ...` offsets. `AlignmentDirectional.bottomEnd` does the
/// same job correctly in both directions, so that plumbing is gone.
class ImageUploadWidget extends StatelessWidget {
  const ImageUploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateServiceCubit, CreateServiceState>(
      // ✅ FIX 26/8/2026 — `|| current is CreateServiceImageUploaded` was here,
      // and it is what made the image vanish at the moment the upload
      // succeeded.
      //
      // The builder below cannot render that state — its first line bails out
      // to an empty box for anything that is not `CreateServiceLoaded` — so
      // asking to rebuild on it was asking to be replaced by nothing. The
      // avatar, the camera badge and the delete button all disappeared exactly
      // when the picture was ready.
      //
      // `CreateServiceImageUploaded` carries only a URL and exists for the
      // listener in `create_new_services.dart` that shows the success dialog;
      // it is not this widget's business. The picture itself arrives on the
      // `CreateServiceLoaded` the cubit emits either side of it, and that one
      // this widget does rebuild on.
      //
      // Rule this breaks, worth keeping: a `buildWhen` must never admit a
      // state its builder refuses to draw.
      buildWhen: (previous, current) => current is CreateServiceLoaded,
      builder: (context, state) {
        if (state is! CreateServiceLoaded) return const SizedBox.shrink();

        final hasImage = state.formData.imageUrl != null ||
            state.webImage != null ||
            state.selectedImage != null;

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                CustomImagePicker(
                  radius: 30.r,
                  badgeRadius: 10.sp,
                  // On web the picture lives in memory as bytes; everywhere
                  // else it is a real file. Hand the picker whichever of the
                  // two this platform actually produced.
                  imageFile: kIsWeb ? null : state.selectedImage,
                  imageBytes: kIsWeb ? state.webImage : null,
                  imageUrl: state.formData.imageUrl,
                  // The badge and the delete button share the same corner, so
                  // only one is ever on screen: the badge invites a first
                  // pick, the delete button replaces it once there is
                  // something to remove. Mid-upload neither is offered.
                  readOnly: hasImage || state.isUploadingImage,
                  onImagePicked: (file) =>
                      context.read<CreateServiceCubit>().setPickedImage(file),
                  onError: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  },
                ),
                if (state.isUploadingImage) _buildLoadingIndicator(),
                if (hasImage && !state.isUploadingImage)
                  _buildDeleteButton(context),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 20.sp,
      height: 20.sp,
      decoration: BoxDecoration(
        color: AppColors.grey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: 12.sp,
          height: 12.sp,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDeleteConfirmation(context),
      child: Container(
        width: 15.sp,
        height: 15.sp,
        decoration: BoxDecoration(
          color: AppColors.red,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close,
          color: AppColors.white,
          size: 12.sp,
        ),
      ),
    );
  }

  /// ♻️ REFACTOR — this used to be a bare `AlertDialog` with a hand-built
  /// body (`DeleteImageDialogContent`) carrying two hardcoded English strings
  /// and a single Delete button with no way to back out except tapping the
  /// barrier. It also confirmed and stopped: the user never saw that the
  /// deletion had gone through.
  ///
  /// It now runs the standard confirm → success flow from
  /// `core/custom/57-custom_dialog_manager.dart`, the same one Cancel Request
  /// uses, so this screen matches every other destructive action in the app:
  /// a Yes/No confirm, then a success dialog — and the success step only
  /// appears when [CreateServiceCubit.removeImage] actually reports success.
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    // Resolve the cubit before the flow awaits: it pushes routes, and reading
    // an InheritedWidget off `context` afterwards is the classic
    // use-after-unmount.
    final cubit = context.read<CreateServiceCubit>();

    await CustomDialogManager.showDialogFlow(
      confirmWidth: 411,
      context: context,
      confirmLottie: 'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
      confirmTitle: S.of(context).deleteImage,
      confirmSubtitle: S.of(context).areYouSureToDeleteImage,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () => cubit.removeImage(),
      successLottie: 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
      successTitle: S.of(context).deleteImage,
      successSubtitle: S.of(context).imageDeletedSuccessfully,
    );
  }
}
