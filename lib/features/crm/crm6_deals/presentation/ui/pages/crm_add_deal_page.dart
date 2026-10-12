// ****************** FILE INFO ******************
// File Name: crm_add_deal_page.dart
// Purpose: Multi-step Add Deal wizard container page hosting steps 1 to 4 with SideFrameMasterServices matching Figma screenshots
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
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_step1_details.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_step2_products_services.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_step3_progress.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_step4_review.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_stepper_header.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmAddDealPage extends StatefulWidget {
  final String? clientId;

  const CrmAddDealPage({
    super.key,
    this.clientId,
  });

  @override
  State<CrmAddDealPage> createState() => _CrmAddDealPageState();
}

class _CrmAddDealPageState extends State<CrmAddDealPage> {
  int _currentStep = 1;
  bool _isSubmitted = false;

  // ── Step 1 Form Controllers & State ─────────────────────────────────────────
  final TextEditingController _dealNameEnController = TextEditingController();
  final TextEditingController _dealNameArController = TextEditingController();
  final TextEditingController _noteEnController = TextEditingController();
  final TextEditingController _noteArController = TextEditingController();
  final TextEditingController _expectedValueController =
      TextEditingController();

  String? _selectedCategory;
  String? _selectedCurrency = 'EGP';
  String? _selectedLikelihood;
  DateTime? _startDate;
  DateTime? _closeDate;
  CrmTeamMemberModel? _selectedEmployee;

  // ── Step 2 Form State ───────────────────────────────────────────────────────
  bool _productsEnabled = true;
  String? _productCategory;
  bool _servicesEnabled = true;
  String? _serviceCategory;

  final List<DealProductLineItem> _productLines = <DealProductLineItem>[
    DealProductLineItem(
      product: null,
      quantity: '',
      unitPrice: 50.0,
      discount: 20.0,
      tax: 50.0,
    ),
    DealProductLineItem(
      product: null,
      quantity: '',
      unitPrice: 50.0,
      discount: 20.0,
      tax: 50.0,
    ),
  ];

  final List<DealServiceLineItem> _serviceLines = <DealServiceLineItem>[
    DealServiceLineItem(
      service: null,
      price: 50.0,
      discount: '',
      tax: 50.0,
    ),
    DealServiceLineItem(
      service: null,
      price: 50.0,
      discount: '',
      tax: 50.0,
    ),
  ];

  // ── Step 3 Form State ───────────────────────────────────────────────────────
  bool _editMode = false;

  @override
  void dispose() {
    _dealNameEnController.dispose();
    _dealNameArController.dispose();
    _noteEnController.dispose();
    _noteArController.dispose();
    _expectedValueController.dispose();
    super.dispose();
  }

  bool _validateStep1() {
    setState(() => _isSubmitted = true);
    final bool validName = _dealNameEnController.text.trim().isNotEmpty &&
        _dealNameArController.text.trim().isNotEmpty;
    final bool validCategory = _selectedCategory != null;
    final bool validValue = _expectedValueController.text.trim().isNotEmpty;
    final bool validDates = _startDate != null && _closeDate != null;
    final bool validEmployee = _selectedEmployee != null;

    return validName &&
        validCategory &&
        validValue &&
        validDates &&
        validEmployee;
  }

  void _onNext() {
    if (_currentStep == 1) {
      if (_validateStep1()) {
        setState(() {
          _isSubmitted = false;
          _currentStep = 2;
        });
      }
    } else if (_currentStep == 2) {
      setState(() {
        _isSubmitted = false;
        _currentStep = 3;
      });
    } else if (_currentStep == 3) {
      setState(() {
        _isSubmitted = false;
        _currentStep = 4;
      });
    } else if (_currentStep == 4) {
      _confirmDeal();
    }
  }

  void _onBack() {
    if (_currentStep > 1) {
      setState(() {
        _isSubmitted = false;
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _confirmDeal() {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Deal Created Successfully',
        arabicName: 'تم إنشاء الصفقة بنجاح',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'The new deal has been created and added to the pipeline.',
        arabicName: 'تمت إضافة الصفقة الجديدة بنجاح إلى مسار المبيعات.',
      ),
      onComplete: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crmClients,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Client Profile',
          arabicName: 'ملف العميل',
        ),
        thirdTitle: FormatHelper.localizedString(
          englishName: 'Add Deal',
          arabicName: 'إضافة صفقة',
        ),
        onFirstTap: () => Navigator.pop(context),
        onSecondTap: () => Navigator.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Wizard Stepper Header
              CrmAddDealStepperHeader(
                currentStep: _currentStep,
                onStepTapped: (int step) {
                  if (step <= _currentStep) {
                    setState(() => _currentStep = step);
                  }
                },
              ),

              SizedBox(height: 24.sp),

              // 2. Active Step Content
              if (_currentStep == 1)
                CrmAddDealStep1Details(
                  dealNameEnController: _dealNameEnController,
                  dealNameArController: _dealNameArController,
                  noteEnController: _noteEnController,
                  noteArController: _noteArController,
                  expectedValueController: _expectedValueController,
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (String? val) =>
                      setState(() => _selectedCategory = val),
                  selectedCurrency: _selectedCurrency,
                  onCurrencyChanged: (String? val) =>
                      setState(() => _selectedCurrency = val),
                  selectedLikelihood: _selectedLikelihood,
                  onLikelihoodChanged: (String? val) =>
                      setState(() => _selectedLikelihood = val),
                  startDate: _startDate,
                  onStartDateChanged: (DateTime? val) =>
                      setState(() => _startDate = val),
                  closeDate: _closeDate,
                  onCloseDateChanged: (DateTime? val) =>
                      setState(() => _closeDate = val),
                  selectedEmployee: _selectedEmployee,
                  onEmployeeSelected: (CrmTeamMemberModel? val) =>
                      setState(() => _selectedEmployee = val),
                  isSubmitted: _isSubmitted,
                )
              else if (_currentStep == 2)
                CrmAddDealStep2ProductsServices(
                  productsEnabled: _productsEnabled,
                  onProductsToggleChanged: (bool val) =>
                      setState(() => _productsEnabled = val),
                  productCategory: _productCategory,
                  onProductCategoryChanged: (String? val) =>
                      setState(() => _productCategory = val),
                  servicesEnabled: _servicesEnabled,
                  onServicesToggleChanged: (bool val) =>
                      setState(() => _servicesEnabled = val),
                  serviceCategory: _serviceCategory,
                  onServiceCategoryChanged: (String? val) =>
                      setState(() => _serviceCategory = val),
                  productLines: _productLines,
                  serviceLines: _serviceLines,
                  onAddProductLine: () {
                    setState(() {
                      _productLines.add(
                        DealProductLineItem(
                          product: null,
                          quantity: '',
                          unitPrice: 50.0,
                          discount: 20.0,
                          tax: 50.0,
                        ),
                      );
                    });
                  },
                  onRemoveProductLine: (int idx) {
                    setState(() {
                      if (_productLines.length > 1) {
                        _productLines.removeAt(idx);
                      }
                    });
                  },
                  onAddServiceLine: () {
                    setState(() {
                      _serviceLines.add(
                        DealServiceLineItem(
                          service: null,
                          price: 50.0,
                          discount: '',
                          tax: 50.0,
                        ),
                      );
                    });
                  },
                  onRemoveServiceLine: (int idx) {
                    setState(() {
                      if (_serviceLines.length > 1) {
                        _serviceLines.removeAt(idx);
                      }
                    });
                  },
                  isSubmitted: _isSubmitted,
                )
              else if (_currentStep == 3)
                CrmAddDealStep3Progress(
                  editMode: _editMode,
                  onEditModeChanged: (bool val) =>
                      setState(() => _editMode = val),
                )
              else if (_currentStep == 4)
                CrmAddDealStep4Review(
                  dealNameEn: _dealNameEnController.text.trim(),
                  dealNameAr: _dealNameArController.text.trim(),
                  category: _selectedCategory ?? '',
                  expectedValue: _expectedValueController.text.trim(),
                  currency: _selectedCurrency ?? 'EGP',
                  likelihood: _selectedLikelihood ?? '',
                  startDate: _startDate,
                  closeDate: _closeDate,
                  employee: _selectedEmployee,
                  productLines: _productLines,
                  serviceLines: _serviceLines,
                ),

              SizedBox(height: 32.sp),

              // 3. Bottom Action Buttons
              _buildBottomActions(context),

              SizedBox(height: 24.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final bool isConfirmStep = _currentStep == 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Back Button
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Back',
            arabicName: 'رجوع',
          ),
          color: const Color(0xFFE5E7EB),
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
          function: _onBack,
        ),

        // Next / Confirm Button
        customButton(
          title: isConfirmStep
              ? FormatHelper.localizedString(
                  englishName: 'Confirm',
                  arabicName: 'تأكيد',
                )
              : FormatHelper.localizedString(
                  englishName: 'Next',
                  arabicName: 'التالي',
                ),
          color: AppColors.primary,
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
          function: _onNext,
        ),
      ],
    );
  }
}
