// Date: 8/9/2024
// By: Nada Mohammed
// Last update: 8/9/2024
// Objectives: This file is responsible for providing a model for the location of a place.

import 'dart:typed_data';

class LocationMessageModel {
  final double latitude;
  final double longitude;
  final String address;
  final Uint8List? locationImagePngBytes;

  const LocationMessageModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.locationImagePngBytes,
  });
}
