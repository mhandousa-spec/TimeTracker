import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:get/get.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';


class PdfCubit extends Cubit<PdfState> {
  PdfCubit() : super(PdfInitial());

  // ✅ Store keys as instance variables, NOT in state
  late List<GlobalKey> _widgetKeys;

  // ✅ Static counter to ensure GLOBAL uniqueness across ALL instances and initializations
  static int _globalCounter = 0;

  // ✅ Instance-specific counter that increments on each initialize() call
  int _initializeCounter = 0;

  List<GlobalKey> get widgetKeys => _widgetKeys;

  void initialize(int pagesLength) {
    // ✅ Increment counters on each initialization to create truly unique IDs
    _initializeCounter++;
    final globalId = _globalCounter++;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final uniqueId = '${globalId}_${timestamp}_$_initializeCounter';

    // ✅ Create completely new keys with guaranteed unique identifiers
    // Even if called multiple times or from multiple instances, keys will be unique
    _widgetKeys = List<GlobalKey>.generate(
      pagesLength,
          (index) => GlobalKey(debugLabel: 'pdf_page_${uniqueId}_$index'),
    );

    final isExpanded = List<bool>.generate(
      pagesLength,
          (index) => true,
    );

    

    emit(PdfLoaded(
      isExpanded: isExpanded,
      fileName: TextEditingController(),
    ));
  }

  void toggleExpanded(int index) {
    if (state is! PdfLoaded) return;
    final currentState = state as PdfLoaded;

    final newIsExpanded = List<bool>.from(currentState.isExpanded);
    newIsExpanded[index] = !newIsExpanded[index];

    emit(currentState.copyWith(isExpanded: newIsExpanded));
  }

  Future<void> onDownloadClicked(

      FormEntity model,
      BuildContext context,
      ) async {
    if (state is! PdfLoaded) return;
    final currentState = state as PdfLoaded;

    AppDialogs.downloadFile(
      currentState.fileName,
      context,
          () {
        // Form bug report #39. showInput already closes the file-name dialog
        // before calling this, so the old `Get.back()` popped the PDF PAGE
        // and the success dialog was shown on a dead context. Now: confirm,
        // write the file, and only then report success.
        if (!context.mounted) return;
        AppDialogs.confirmDownloadPdf(context, () async {
          try {
            await convertWidgetToPdf(model);
            return true;
          } catch (e, st) {
            debugPrint('PDF download failed: $e\n$st');
            return false;
          }
        });
      },
    );
  }

  Future<void> convertWidgetToPdf(FormEntity model) async {
    if (state is! PdfLoaded) return;

    final pdf = pw.Document();

    for (int i = 0; i < model.pages.length; i++) {
      // ✅ Use instance variable keys
      RenderRepaintBoundary boundary = _widgetKeys[i]
          .currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3);

      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginLeft: 0,
            marginRight: 0,
            marginBottom: 0,
            marginTop: 0,
          ),
          build: (pw.Context context) => pw.Container(
            width: double.infinity,
            height: double.infinity,
            color: PdfColor.fromInt(AppColors.card.value),
            child: pw.Stack(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(
                    horizontal:
                    model.formHeadModel.horizontalPadding!.toDouble(),
                    vertical: model.formHeadModel.verticalPadding!.toDouble(),
                  ),
                  child: pw.Image(pw.MemoryImage(pngBytes)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      downloadsDir = await getDownloadsDirectory();
    }

    String stringFileName = (state as PdfLoaded).fileName.text;
    final file = File('${downloadsDir?.path}/$stringFileName.pdf');

    await file.writeAsBytes(await pdf.save());
    
  }

  @override
  Future<void> close() {
    if (state is PdfLoaded) {
      final currentState = state as PdfLoaded;
      currentState.fileName.dispose();
    }
    return super.close();
  }
}