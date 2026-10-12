// Date: 8/9/2024
// By: Nada Mohamed , Youssef Ashraf
// Last update: 8/9/2024
// Objectives: This file is responsible for providing a maps view for the user to pick a location.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:latlong2/latlong.dart' as latLng;

import 'package:knowticed_plus/core/helper/message_module/main_helper/share_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/custom_app_bar.dart';
import '../../controller/message_controller.dart';
import '../../../data/models/location_message_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

class MapsView extends StatelessWidget {
  final bool isSelecting;

  const MapsView({
    super.key,
    required this.isSelecting,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey key = GlobalKey();
    Uint8List? bytes;

    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        if (state is! MessageLoaded || state.pickedLocation == null) {
          return Scaffold(
            appBar: CustomAppBar(
              title: isSelecting ? S.of(context).pickALocation : S.of(context).location,
              centerTitle: false,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final messageCubit = context.read<MessageCubit>();
        final pickedLocation = state.pickedLocation!;

        return Scaffold(
          appBar: CustomAppBar(
            title: isSelecting ? S.of(context).pickALocation : S.of(context).location,
            centerTitle: false,
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              RepaintBoundary(
                key: key,
                child: FlutterMap(
                  mapController: messageCubit.mapController,
                  options: MapOptions(
                    onMapReady: () {
                      // move to the picked location
                      messageCubit.mapController.move(
                        latLng.LatLng(
                          pickedLocation.latitude,
                          pickedLocation.longitude,
                        ),
                        13,
                      );
                    },
                    initialCenter: latLng.LatLng(
                      pickedLocation.latitude,
                      pickedLocation.longitude,
                    ),
                    onTap: (position, point) async {
                      if (!isSelecting) return;
                      // set picked location point
                      await messageCubit.setPickedLocation(point, null);

                      messageCubit.mapController.move(point, 13);
                    },
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ensightvision',
                      maxNativeZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: latLng.LatLng(
                            pickedLocation.latitude,
                            pickedLocation.longitude,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red.shade700,
                            size: 40.r,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              if (isSelecting)
                Positioned(
                  bottom: 20.h,
                  child: customButton(
                    title: S.of(context).send,
                    color: AppColors.primary,
                    height: 36,
                    width: MediaQuery.of(context).size.width * 0.9,
                    textStyle: StyleText.fontSize18Weight500.copyWith(color: AppColors.textButton),
                    function: () async {
                      // make sure to move camera back again to the picked location if the user didn't pick a location
                      final point = latLng.LatLng(
                        pickedLocation.latitude,
                        pickedLocation.longitude,
                      );

                      messageCubit.mapController.move(point, 13);

                      // wait for a short duration to ensure the camera has moved before capturing the image
                      await Future.delayed(const Duration(milliseconds: 100));

                      bytes = await ShareHelper.capture(
                        boundary: key.currentContext?.findRenderObject()
                        as RenderRepaintBoundary,
                      );

                      if (context.mounted) {
                        await messageCubit.addMessage(
                          location: LocationMessageModel(
                            latitude: pickedLocation.latitude,
                            longitude: pickedLocation.longitude,
                            address: pickedLocation.address,
                            locationImagePngBytes: bytes,
                          ),
                          context: context,
                        );

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },

                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}