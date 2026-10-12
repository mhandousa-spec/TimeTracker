// ****************** FILE INFO ******************
// File Name: crm_add_quote_page.dart
// Purpose: Multi-step Add Quote wizard container page hosting steps 1 to 4 with SideFrameMasterServices matching Figma screenshots
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_quote_step1_details.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_quote_step2_preview_products.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_quote_step3_commercial_terms.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_quote_step4_review_pdf.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_quote_stepper_header.dart';

class CrmAddQuotePage extends StatefulWidget {
  final CrmClientDealModel? deal;

  const CrmAddQuotePage({
    super.key,
    this.deal,
  });

  @override
  State<CrmAddQuotePage> createState() => _CrmAddQuotePageState();
}

class _CrmAddQuotePageState extends State<CrmAddQuotePage> {
  int _currentStep = 1;
  bool _showStep3Validation = false;

  // ── Step 1 Form Controllers ─────────────────────────────────────────────────
  final TextEditingController _quoteNumberController =
      TextEditingController(text: '78855A');
  final TextEditingController _quoteDateController =
      TextEditingController(text: '7 Jun 2026');
  final TextEditingController _quoteDateUntilController =
      TextEditingController();
  final TextEditingController _step1NoteEnController = TextEditingController();
  final TextEditingController _step1NoteArController = TextEditingController();

  // ── Step 3 Form State ───────────────────────────────────────────────────────
  String? _selectedPaymentTerm;
  String? _selectedDeliveryTerm;
  final TextEditingController _step3NoteEnController = TextEditingController();
  final TextEditingController _step3NoteArController = TextEditingController();
  final List<String> _uploadedFiles = <String>[];

  @override
  void dispose() {
    _quoteNumberController.dispose();
    _quoteDateController.dispose();
    _quoteDateUntilController.dispose();
    _step1NoteEnController.dispose();
    _step1NoteArController.dispose();
    _step3NoteEnController.dispose();
    _step3NoteArController.dispose();
    super.dispose();
  }

  bool get _isStep1Valid =>
      _quoteDateUntilController.text.trim().isNotEmpty &&
      _quoteNumberController.text.trim().isNotEmpty;

  bool get _isStep3Valid =>
      _selectedPaymentTerm != null &&
      _selectedPaymentTerm!.isNotEmpty &&
      _selectedDeliveryTerm != null &&
      _selectedDeliveryTerm!.isNotEmpty;

  void _onNextStep() {
    if (_currentStep == 1) {
      if (!_isStep1Valid) return;
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      if (!_isStep3Valid) {
        setState(() => _showStep3Validation = true);
        return;
      }
      setState(() => _currentStep = 4);
    } else if (_currentStep == 4) {
      _onSubmitQuote();
    }
  }

  void _onSubmitQuote() {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Quote Created',
        arabicName: 'تم إنشاء عرض الأسعار',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Quote has been sent to approval workflow successfully.',
        arabicName: 'تم إرسال عرض الأسعار إلى مسار الموافقة بنجاح.',
      ),
      onComplete: () => Navigator.pop(context),
    );
  }

  Future<void> _pickDateUntil() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (BuildContext ctx, Widget? child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.black,
              onSurface: AppColors.black,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      final List<String> months = <String>[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final String formatted =
          '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      setState(() {
        _quoteDateUntilController.text = formatted;
      });
    }
  }

  void _onUploadFile() {
    setState(() {
      _uploadedFiles
          .add('Commercial_Terms_Spec_${_uploadedFiles.length + 1}.pdf');
    });
  }

  void _onAddFiles() {
    setState(() {
      _uploadedFiles.add('Attachment_${_uploadedFiles.length + 1}.docx');
    });
  }

  void _onDownloadPdf() {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Download PDF',
        arabicName: 'تحميل ملف PDF',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'PDF quote document is being prepared for download.',
        arabicName: 'جاري تجهيز ملف عرض الأسعار بصيغة PDF للتحميل.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String dealName = widget.deal?.dealNameEn ?? 'ERP System Deal';

    return SideFrameMasterServices(
      titleText: FormatHelper.localizedString(
        englishName: 'Deals',
        arabicName: 'الصفقات',
      ),
      secondTitle: dealName,
      thirdTitle: FormatHelper.localizedString(
        englishName: 'Add Quote',
        arabicName: 'إضافة عرض أسعار',
      ),
      onFirstTap: () => Navigator.pop(context),
      onSecondTap: () => Navigator.pop(context),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── 1. 4-Step Navigation Header ───────────────────────────────────
            CrmAddQuoteStepperHeader(
              currentStep: _currentStep,
              onStepTapped: (int step) {
                if (step < _currentStep || (step == 2 && _isStep1Valid)) {
                  setState(() => _currentStep = step);
                }
              },
            ),

            SizedBox(height: 20.sp),

            // ── 2. Active Step Content ────────────────────────────────────────
            _buildActiveStepContent(),

            SizedBox(height: 24.sp),

            // ── 3. Bottom Action Buttons Row ──────────────────────────────────
            _buildBottomActionsRow(context),

            SizedBox(height: 32.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveStepContent() {
    switch (_currentStep) {
      case 1:
        return CrmAddQuoteStep1Details(
          quoteNumberController: _quoteNumberController,
          quoteDateController: _quoteDateController,
          quoteDateUntilController: _quoteDateUntilController,
          noteEnController: _step1NoteEnController,
          noteArController: _step1NoteArController,
          onSelectQuoteDateUntil: _pickDateUntil,
          onChanged: (_) => setState(() {}),
        );
      case 2:
        return const CrmAddQuoteStep2PreviewProducts();
      case 3:
        return CrmAddQuoteStep3CommercialTerms(
          selectedPaymentTerm: _selectedPaymentTerm,
          selectedDeliveryTerm: _selectedDeliveryTerm,
          onPaymentTermChanged: (String? val) =>
              setState(() => _selectedPaymentTerm = val),
          onDeliveryTermChanged: (String? val) =>
              setState(() => _selectedDeliveryTerm = val),
          noteEnController: _step3NoteEnController,
          noteArController: _step3NoteArController,
          uploadedFiles: _uploadedFiles,
          onUploadFile: _onUploadFile,
          onAddFiles: _onAddFiles,
          showValidationErrors: _showStep3Validation,
          onChanged: (_) => setState(() {}),
        );
      case 4:
        return CrmAddQuoteStep4ReviewPdf(
          quoteNumber: _quoteNumberController.text,
          quoteDate: _quoteDateController.text,
          quoteDateUntil: _quoteDateUntilController.text.isNotEmpty
              ? _quoteDateUntilController.text
              : '14 Jun 2026',
          clientName: widget.deal?.assignedEmployee ?? 'John Doe Enterprises',
          onDownloadPdf: _onDownloadPdf,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomActionsRow(BuildContext context) {
    final bool isNextActive = (_currentStep == 1 && _isStep1Valid) ||
        _currentStep == 2 ||
        (_currentStep == 3 && _isStep3Valid) ||
        _currentStep == 4;

    final String nextButtonTitle = _currentStep == 4
        ? FormatHelper.localizedString(
            englishName: 'Sent to Approve',
            arabicName: 'إرسال للموافقة',
          )
        : FormatHelper.localizedString(
            englishName: 'Next',
            arabicName: 'التالي',
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Left Column: Discard + Save For Later
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            customButton(
              title: FormatHelper.localizedString(
                englishName: 'Discard',
                arabicName: 'تراجع',
              ),
              color: const Color(0xFFE5E7EB),
              borderColor: Colors.transparent,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
              function: () => Navigator.pop(context),
            ),
            SizedBox(height: 10.sp),
            customButton(
              title: FormatHelper.localizedString(
                englishName: 'Save For Later',
                arabicName: 'حفظ لوقت لاحق',
              ),
              color: const Color(0xFF595959),
              borderColor: Colors.transparent,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              function: () {
                CrmControlDialogs.showSuccessDialog(
                  context: context,
                  title: FormatHelper.localizedString(
                    englishName: 'Quote Draft Saved',
                    arabicName: 'تم حفظ مسودة عرض الأسعار',
                  ),
                  subtitle: FormatHelper.localizedString(
                    englishName: 'Draft saved successfully.',
                    arabicName: 'تم حفظ المسودة بنجاح.',
                  ),
                  onComplete: () => Navigator.pop(context),
                );
              },
            ),
          ],
        ),

        // Right Button: Next or Sent to Approve
        customButton(
          title: nextButtonTitle,
          color: isNextActive ? AppColors.primary : const Color(0xFFE5E7EB),
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            color: isNextActive ? AppColors.black : const Color(0xFF9CA3AF),
          ),
          function: isNextActive ? _onNextStep : () {},
        ),
      ],
    );
  }
}
