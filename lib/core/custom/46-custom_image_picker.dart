/// Module: Core · Custom · Image Picker
/// Description: Reusable circular avatar with a built-in image picker badge.
///              Extracted from role_image_editor.dart but decoupled from
///              RoleCubit so it can be used anywhere. Shows (in priority
///              order): externally provided File, internally picked File,
///              network image URL, or a placeholder svg. The small primary
///              camera badge opens the gallery/camera, validates the picked
///              image (format + decodability) and reports it via callback.
/// Author: Knowticed Team
/// Date: 06/07/2026
/// Dependencies: image_picker, flutter_svg, flutter_screenutil,
///               SkeletonAssets, AppColors.
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

// vector_graphics is a transitive dependency of flutter_svg and provides
// the low-level `vg.loadPicture` API used to rasterize an SVG into a ui.Image.
// ignore: depend_on_referenced_packages
import 'package:vector_graphics/vector_graphics.dart' as vg_lib;
class CustomImagePicker extends StatefulWidget {
  /// Externally controlled picked file (takes priority over internal state).
  final File? imageFile;

  /// Raw image bytes to preview, for call sites that hold the picture in
  /// memory rather than on disk — the web path, where `dart:io`'s [File] is
  /// not usable. Ranks between [imageFile] and [imageUrl]: a file on disk
  /// still wins, and these bytes still beat a stale network URL.
  final Uint8List? imageBytes;

  /// Fallback network image shown when no file is picked.
  final String? imageUrl;

  /// Called with the validated picked file.
  final ValueChanged<File> onImagePicked;

  /// Show the avatar WITHOUT the camera badge, and ignore taps.
  ///
  /// Added 24/8/2026 for the change-preview screens, which display the photo
  /// but must not let anyone swap it — a preview is a read-only comparison.
  /// Defaults to false so every existing call site is unaffected.
  final bool readOnly;

  /// Called with an error message; if null a red SnackBar is shown.
  final ValueChanged<String>? onError;

  /// Pick from camera instead of gallery.
  final bool camera;

  /// Avatar radius (defaults to 32.r).
  final double? radius;

  /// Badge radius (defaults to 12.r).
  final double? badgeRadius;

  final String placeholderSvg;
  final String badgeSvg;

  const CustomImagePicker({
    super.key,
    required this.onImagePicked,
    this.readOnly = false,
    this.imageFile,
    this.imageBytes,
    this.imageUrl,
    this.onError,
    this.camera = false,
    this.radius,
    this.badgeRadius,
    this.placeholderSvg = 'assets/icons_assets/main_icons_assets/image_photo_rounded.svg',
    this.badgeSvg = 'assets/icons_assets/messaging_assets/camera.svg',
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  static const List<String> _validFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic',
  ];

  File? _pickedFile;

  File? get _effectiveFile => widget.imageFile ?? _pickedFile;

  /// Drop the internally remembered pick whenever the parent changes the file
  /// it controls.
  ///
  /// Added 30/8/2026. `_effectiveFile` falls back to [_pickedFile], so a
  /// controlled call site that CLEARS [imageFile] — a delete button, a form
  /// reset — kept seeing the picture it just removed: the parent's null fell
  /// through to this State's leftover copy. A call site that never passes
  /// [imageFile] is unaffected, since null == null is not a change.
  @override
  void didUpdateWidget(covariant CustomImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageFile != oldWidget.imageFile) {
      _pickedFile = null;
    }
  }

  Future<void> _pick() async {
    try {
      final ImagePicker picker = ImagePicker();

      final result = await picker.pickImage(
        source: widget.camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (result == null) return;

      // Validate image format.
      final extension = result.path.split('.').last.toLowerCase();
      if (!_validFormats.contains(extension)) {
        _fail('Invalid format. Please use JPG, PNG, or WEBP');
        return;
      }

      final file = File(result.path);
      if (!await file.exists()) {
        _fail('Image file not found');
        return;
      }

      // Try to decode image to verify it's valid.
      try {
        final bytes = await result.readAsBytes();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        frameInfo.image.dispose();
        codec.dispose();
      } catch (_) {
        _fail('Invalid or corrupted image file');
        return;
      }

      setState(() => _pickedFile = file);
      widget.onImagePicked(file);
    } catch (_) {
      _fail('Failed to pick image');
    }
  }

  void _fail(String message) {
    if (widget.onError != null) {
      widget.onError!(message);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.radius ?? 32.r;
    final double badgeRadius = widget.badgeRadius ?? 12.r;
    final file = _effectiveFile;

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.background,
          child: file != null
              ? CircleAvatar(
                  radius: radius,
                  backgroundImage: FileImage(file.absolute),
                )
              : widget.imageBytes != null && widget.imageBytes!.isNotEmpty
              ? CircleAvatar(
                  radius: radius,
                  backgroundImage: MemoryImage(widget.imageBytes!),
                )
              : widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                  ? CircleAvatar(
                      radius: radius,
                      backgroundImage: NetworkImage(widget.imageUrl!),
                      onBackgroundImageError: (_, __) {},
                    )
                  : Container(
                      padding: EdgeInsets.all(8.sp),
                      child: CustomSvgImage(
                     assetPath: widget.placeholderSvg,
                     width: 30.sp,
                     color: AppColors.text,
                     height: 30.sp,
                     fit: BoxFit.contain,
 ),
                    ),
        ),
        // The badge is the only interactive part, so read-only simply drops it
        // rather than disabling a control that still looks tappable.
        if (!widget.readOnly)
          GestureDetector(
            onTap: _pick,
            child: CircleAvatar(
              radius: badgeRadius,
              backgroundColor: AppColors.primary,
              child: CustomSvgImage(
                assetPath: widget.badgeSvg,
                width: 16.w,
                height: 16.h,
                fit: BoxFit.contain,
                color: AppColors.textButton,
              ),
            ),
          ),
      ],
    );
  }
}

// --------------------------------------------------------------------------
// Image source helpers, merged here from the old
// features/services_management_module/main_controller/data/utils/app_image_provider.dart
// --------------------------------------------------------------------------

/// Returns the correct [ImageProvider] for a given path.
///
/// - `http`/`https` urls  -> [NetworkImage]
/// - asset paths ending in `.svg` -> [SvgImageProvider] (rasterizes the SVG)
/// - everything else (png/jpg/... asset) -> [AssetImage]
///
/// This lets existing `AssetImage(path)` / `backgroundImage:` / `DecorationImage`
/// call sites keep working even when the path now points to an `.svg` file.
ImageProvider appImageProvider(String path) {
  if (path.startsWith('http')) {
    return NetworkImage(path);
  }
  if (path.toLowerCase().endsWith('.svg')) {
    return SvgImageProvider(path);
  }
  return AssetImage(path);
}

/// Returns a widget that renders [path] whether it is an svg asset, a raster
/// asset, or a network image. Use this to replace raw `Image.asset(path)` calls
/// that may now receive an `.svg` path.
Widget appImageWidget(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
  Color? color,
}) {
  if (path.startsWith('http')) {
    return Image.network(path, width: width, height: height, fit: fit);
  }
  if (path.toLowerCase().endsWith('.svg')) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
  return Image.asset(path, width: width, height: height, fit: fit, color: color);
}

/// An [ImageProvider] that loads an SVG asset and rasterizes it so it can be
/// used anywhere a normal [ImageProvider] is expected (e.g.
/// `CircleAvatar.backgroundImage`, `DecorationImage`, `Image(image: ...)`).
@immutable
class SvgImageProvider extends ImageProvider<SvgImageProvider> {
  const SvgImageProvider(this.assetName, {this.scale = 1.0, this.pixelSize});

  /// The asset path of the `.svg` file.
  final String assetName;

  /// Output scale passed to the produced [ImageInfo].
  final double scale;

  /// Optional rasterization size (width == height) in pixels. Defaults to the
  /// SVG's intrinsic size.
  final int? pixelSize;

  @override
  Future<SvgImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<SvgImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    SvgImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      _loadAsync(key),
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('SVG asset: $assetName'),
      ],
    );
  }

  Future<ImageInfo> _loadAsync(SvgImageProvider key) async {
    final SvgAssetLoader loader = SvgAssetLoader(assetName);
    final vg_lib.PictureInfo pictureInfo =
        await vg_lib.vg.loadPicture(loader, null);

    final ui.Size size = pictureInfo.size;
    int width = pixelSize ?? size.width.ceil();
    int height = pixelSize ?? size.height.ceil();
    if (width <= 0) width = 1;
    if (height <= 0) height = 1;

    final ui.Image image = pictureInfo.picture.toImageSync(width, height);
    pictureInfo.picture.dispose();

    return ImageInfo(image: image, scale: key.scale);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SvgImageProvider &&
        other.assetName == assetName &&
        other.scale == scale &&
        other.pixelSize == pixelSize;
  }

  @override
  int get hashCode => Object.hash(assetName, scale, pixelSize);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'SvgImageProvider')}("$assetName", scale: $scale)';
}
