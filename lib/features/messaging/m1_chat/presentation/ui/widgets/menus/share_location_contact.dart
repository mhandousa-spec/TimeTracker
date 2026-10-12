/// Module: messaging / chat / presentation/ui/widgets/menus/share_location_contact.dart
/// Purpose: The Location and Contact buttons of the attachment menu
///          (bug report #23). Both were `onTap: () {}`.
///
///  • Location — WhatsApp-style "send current location": reads the device
///    position, looks up a street address when the platform can, confirms,
///    and sends a location card that opens in Google Maps.
///  • Contact  — pick a colleague from the app directory and send their
///    contact card (name, job title, photo) with a "Message" button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/services/geolocator/geolocator_repository.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import '../../../../../m2_connections/domain/entities/single_connection_entity.dart';
import '../../../../../m2_connections/presentation/controller/connections_controller.dart';
import '../../../../domain/entity/new_message_content_entity.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import '../dialogs/contact_picker_dialog.dart';

bool _isAr(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

void _toast(String msg) => Fluttertoast.showToast(
      msg: msg,
      backgroundColor: AppColors.primary,
      textColor: AppColors.textButton,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Location
// ─────────────────────────────────────────────────────────────────────────────

Future<void> shareCurrentLocation(
    BuildContext context, MasterChatCubit cubit) async {
  final bool isAr = _isAr(context);
  debugPrint('[ShareLocation] requesting current position…');

  final Position? position = await GelocatorRepository.getCurrentLocation();
  if (position == null) {
    debugPrint('[ShareLocation] ✗ no position (service off / permission '
        'denied / platform unsupported)');
    _toast(isAr
        ? 'تعذر تحديد موقعك. فعّل خدمات الموقع ثم حاول مرة أخرى'
        : 'Could not get your location. Turn on location services and try again');
    return;
  }

  final String? address =
      await _addressFor(position.latitude, position.longitude);
  final LocationPayload payload = LocationPayload(
    latitude: position.latitude,
    longitude: position.longitude,
    address: address,
  );
  debugPrint('[ShareLocation] got ${payload.latitude},${payload.longitude} '
      '(${address ?? 'no address'})');

  if (!context.mounted) return;
  final bool? confirmed = await CustomDialogManager.showContent<bool>(
    context: context,
    width: 360.sp,
    child: _ConfirmLocation(payload: payload, isAr: isAr),
  );
  if (confirmed != true) return;

  final bool sent = await cubit.sendLocationMessage(payload);
  if (!sent) _toast(isAr ? 'تعذر إرسال الموقع' : 'Could not send location');
}

/// Street address for a point, or null where geocoding is unavailable
/// (e.g. Windows desktop) — the card then shows the coordinates only.
Future<String?> _addressFor(double lat, double lng) async {
  try {
    final List<Placemark> marks =
        await Geocoding().placemarkFromCoordinates(lat, lng);
    if (marks.isEmpty) return null;
    final Placemark p = marks.first;
    final List<String> parts = <String?>[
      p.street,
      p.locality,
      p.administrativeArea,
      p.country,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(', ');
  } catch (e) {
    debugPrint('[ShareLocation] address lookup unavailable: $e');
    return null;
  }
}

class _ConfirmLocation extends StatelessWidget {
  const _ConfirmLocation({required this.payload, required this.isAr});

  final LocationPayload payload;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvgImage(
            assetPath: 'assets/icons_assets/messaging_assets/location_svg.svg',
            width: 48.sp,
            height: 48.sp,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12.h),
          Text(isAr ? 'إرسال موقعك الحالي؟' : 'Send your current location?',
              style: StyleText.fontSize16Weight500),
          SizedBox(height: 6.h),
          Text(
            payload.address ??
                '${payload.latitude.toStringAsFixed(5)}, '
                    '${payload.longitude.toStringAsFixed(5)}',
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.secondaryBlack),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12.sp,
            children: [
              _DialogButton(
                label: isAr ? 'إلغاء' : 'Cancel',
                primary: false,
                onTap: () => Navigator.of(context).pop(false),
              ),
              _DialogButton(
                label: isAr ? 'إرسال' : 'Send',
                primary: true,
                onTap: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact
// ─────────────────────────────────────────────────────────────────────────────

Future<void> shareContact(BuildContext context, MasterChatCubit cubit) async {
  final bool isAr = _isAr(context);
  if (!Get.isRegistered<ConnectionsCubit>() && !Get.isPrepared<ConnectionsCubit>()) {
    debugPrint('[ShareContact] ✗ ConnectionsCubit not registered');
    return;
  }
  final ConnectionsCubit connections = Get.find<ConnectionsCubit>();
  final String? otherId = cubit.state.otherConnectionSide?.otherSideId;
  final List<SingleConnectionEntity> people = connections.connections
      .where((c) => c.userId != otherId)
      .toList();
  debugPrint('[ShareContact] ${people.length} colleagues to pick from');

  // Figma 6799:5402 — multi-select grid with search + department filter.
  final List<SingleConnectionEntity> picked =
      await showContactPickerDialog(context, people: people);
  if (picked.isEmpty) return;

  int failed = 0;
  for (final SingleConnectionEntity p in picked) {
    final bool sent = await cubit.sendContactMessage(ContactPayload(
      userId: p.userId,
      name: p.primaryLanguageName,
      nameAr: p.secondaryLanguageName,
      jobTitle: p.primaryLanguageSubInfo,
      jobTitleAr: p.secondaryLanguageSubInfo,
      imageUri: p.imageUri,
    ));
    if (!sent) failed++;
  }
  if (failed > 0) {
    _toast(isAr ? 'تعذر إرسال جهة الاتصال' : 'Could not send contact');
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: 120.sp,
        height: 38.sp,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : AppColors.field,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            color: primary ? AppColors.textButton : AppColors.text,
          ),
        ),
      ),
    );
  }
}
