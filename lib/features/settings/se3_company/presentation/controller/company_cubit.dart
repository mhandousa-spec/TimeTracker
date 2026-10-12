/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_cubit.dart
/// Purpose: Owns the company document, the company-information form and the
///          branding selections, and persists them through the repositories.
/// Author: Amr Mesbah
/// Created at: 11/12/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N07/N08/N09/N10: Firestore moved behind
///          CompanyRepository / EmployeeBrandingRepository; the repositories
///          and SystemLogsController are injected rather than constructed and
///          `Get.find`-ed in field initializers; `RestartWidget.restartApp(
///          Get.context!)` after a `Future.delayed` replaced with a
///          `restartRequested` flag the page acts on; the global loading
///          overlay is gone in favour of the existing `CompanyStatus.loading`.
///
/// Merged: add_company_controller.dart + company_controller_personal.dart
///         (the latter was a strict superset; nothing was lost), then
///         converted from GetxController+StateMixin to Cubit<CompanyState>.
///
/// NOTE ON LIFECYCLE: this cubit is created in main() and provided at the app
/// root via BlocProvider.value, because ThemeController is constructed before
/// runApp and depends on it. Same pattern as ThemeAndLocalizationsCubit.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/arabic_font_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_logo_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/english_font_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/primary_color_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/secondary_color_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/repository/company_repository.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/repository/employee_branding_repository.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/utils/company_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se3_company/domain/base_repository/company_base_repository.dart';
import 'package:knowticed_plus/features/settings/se3_company/domain/base_repository/employee_branding_base_repository.dart';
import 'package:knowticed_plus/features/settings/se3_company/domain/entities/employee_branding_entity.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  CompanyCubit({
    CompanyBaseRepository? companyRepository,
    EmployeeBrandingBaseRepository? employeeBrandingRepository,
  })  : companyRepository = companyRepository ?? CompanyRepository(),
        employeeBrandingRepository =
            employeeBrandingRepository ?? EmployeeBrandingRepository(),
        super(CompanyState.initial());

  /// Guard against emit-after-close when the user navigates away mid-await.
  /// Matches the convention in DashboardAdminCubit.
  @override
  void emit(CompanyState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Both typed as domain contracts so they can be faked in tests.
  final CompanyBaseRepository companyRepository;
  final EmployeeBrandingBaseRepository employeeBrandingRepository;

  /// Resolved lazily rather than in a field initializer: the cubit is built in
  /// main() before the GetX bindings have necessarily registered this
  /// (CR-SKEL-SE3-N08).
  SystemLogsController get _systemLogs => Get.find<SystemLogsController>();

  final GetStorage storage = GetStorage();

  /// Convenience accessor — a lot of call sites still want the raw model.
  CompanyModel? get company => state.company;

  // ───────────────────────────── Bootstrap ──────────────────────────────────

  /// Replaces GetxController.onInit(). Called once from main() after the cubit
  /// is created, so the first frame already has company data in flight.
  Future<void> bootstrap() async {
    await getCompany(shouldRestart: false);
  }

  // ─────────────────────────── Form field setters ───────────────────────────
  // Every text field is state now; widgets push edits through these.

  void setCompanyName(String v) => emit(state.copyWith(companyName: v));
  void setTaxNumber(String v) => emit(state.copyWith(taxNumber: v));
  void setBirthDate(String v) => emit(state.copyWith(birthDate: v));
  void setCountry(String v) => emit(state.copyWith(country: v));
  void setCity(String v) => emit(state.copyWith(city: v));
  void setStateOrProvince(String v) => emit(state.copyWith(stateOrProvince: v));
  void setEmail(String v) => emit(state.copyWith(email: v));
  void setPhone(String v) => emit(state.copyWith(phone: v));
  void setStreetAddress(String v) => emit(state.copyWith(streetAddress: v));
  void setCode(String v) => emit(state.copyWith(code: v));
  void setContactFirstName(String v) => emit(state.copyWith(contactFirstName: v));
  void setContactLastName(String v) => emit(state.copyWith(contactLastName: v));
  void setContactEmail(String v) => emit(state.copyWith(contactEmail: v));
  void setContactPhone(String v) => emit(state.copyWith(contactPhone: v));

  // ───────────────────────── Branding selection setters ─────────────────────

  void setBrandingSelectedIndex(int v) =>
      emit(state.copyWith(brandingSelectedIndex: v));
  void setSelectedEnglishFont(String? v) =>
      emit(state.copyWith(selectedEnglishFont: v));
  void setSelectedArabicFont(String? v) =>
      emit(state.copyWith(selectedArabicFont: v));
  void setPrimaryColor(Color? v) => emit(state.copyWith(primaryColor: v));
  void setSecondaryColor(Color? v) => emit(state.copyWith(secondaryColor: v));
  void setImageUrl(String? v) => emit(state.copyWith(imageUrl: v));

  /// Clears the unsaved branding selections (company_branding_screen's reset).
  void clearBrandingSelections() => emit(state.copyWith(
        imageUrl: null,
        selectedEnglishFont: null,
        selectedArabicFont: null,
        primaryColor: null,
        secondaryColor: null,
      ));

  /// Drops one-shot feedback after a BlocListener has displayed it.
  void clearMessages() => emit(state.consumed());

  // ─────────────────────────── Employee branding ────────────────────────────

  /// Initialize Employee_Data collection (call once on app start).
  Future<void> initializeEmployeeDataCollection() async {
    if (await employeeBrandingRepository.isInitialized()) return;

    final CompanyModel? c = state.company;
    await employeeBrandingRepository.initializeEmployeeDataCollection(
      companyLogo: c?.companyLogo?.companyLogo?.lastOrNull,
      companyPrimaryColor: c?.primaryColor?.primaryColor?.lastOrNull,
      companySecondaryColor: c?.secondaryColor?.secondaryColor?.lastOrNull,
      companyFontEnglish: c?.englishFont?.englishFont?.lastOrNull,
      companyFontArabic: c?.arabicFont?.arabicFont?.lastOrNull,
    );
  }

  /// Load employee branding (call on login).
  ///
  /// A failed read and "this employee has no override" both fall back to the
  /// company branding, as before — but they are now distinguishable, so the
  /// failure is not silent.
  Future<void> loadEmployeeBranding(String employeeId) async {
    final Either<Failure, EmployeeBrandingEntity?> result =
        await employeeBrandingRepository.getEmployeeBranding(employeeId);

    result.fold(
      (Failure failure) {
        emit(state.copyWith(errorMessage: failure.errMessage));
        _applyCompanyBrandingToStorage();
      },
      (EmployeeBrandingEntity? branding) {
        emit(state.copyWith(employeeBranding: branding));
        if (branding != null) {
          _applyEmployeeBrandingToStorage();
        } else {
          _applyCompanyBrandingToStorage();
        }
      },
    );
  }

  void _applyEmployeeBrandingToStorage() {
    final branding = state.employeeBranding;
    if (branding == null) return;

    storage.write('logo', branding.logo);
    storage.write('primaryColor', branding.primaryColor);
    storage.write('secondaryColor', branding.secondaryColor);
    storage.write('font', _capitalize(branding.fontEnglish));
    storage.write('font_arabic', _capitalize(branding.fontArabic));
  }

  void _applyCompanyBrandingToStorage() {
    if (!state.isCompanyActive) {
      _clearBrandingStorage();
      return;
    }
    _syncStorageFromFirebase();
  }

  Future<void> saveEmployeeBranding({
    required String employeeId,
    String? logo,
    String? primaryColor,
    String? secondaryColor,
    String? fontEnglish,
    String? fontArabic,
  }) async {
    emit(state.copyWith(status: CompanyStatus.loading));

    final EmployeeBrandingEntity branding = EmployeeBrandingEntity(
      employeeId: employeeId,
      logo: logo,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      fontEnglish: fontEnglish,
      fontArabic: fontArabic,
    );

    final Either<Failure, void> result =
        await employeeBrandingRepository.saveEmployeeBranding(branding);

    if (result.isLeft()) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: result.fold((Failure l) => l.errMessage, (_) => null),
      ));
      return;
    }

    emit(state.copyWith(employeeBranding: branding));
    _applyEmployeeBrandingToStorage();

    themeController.updatePrimaryColor();
    themeController.updateSecondaryColor();
    themeController.updateFonts();

    emit(state.copyWith(
      status: CompanyStatus.success,
      successMessage: 'Personal branding saved successfully',
      // Fonts are resolved at build time, so the subtree has to be remounted.
      // The page does it with its own context once it sees this flag.
      restartRequested: fontEnglish != null || fontArabic != null,
    ));
  }

  Future<void> resetEmployeeBrandingToCompany(String employeeId) async {
    emit(state.copyWith(status: CompanyStatus.loading));

    final CompanyModel? c = state.company;
    final Either<Failure, void> result =
        await employeeBrandingRepository.resetToCompanyBranding(
      employeeId: employeeId,
      companyLogo: c?.companyLogo?.companyLogo?.lastOrNull,
      companyPrimaryColor: c?.primaryColor?.primaryColor?.lastOrNull,
      companySecondaryColor: c?.secondaryColor?.secondaryColor?.lastOrNull,
      companyFontEnglish: c?.englishFont?.englishFont?.lastOrNull,
      companyFontArabic: c?.arabicFont?.arabicFont?.lastOrNull,
    );

    if (result.isLeft()) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: result.fold((Failure l) => l.errMessage, (_) => null),
      ));
      return;
    }

    await loadEmployeeBranding(employeeId);

    themeController.updatePrimaryColor();
    themeController.updateSecondaryColor();
    themeController.updateFonts();

    emit(state.copyWith(
      status: CompanyStatus.success,
      successMessage: 'Personal branding reset to company defaults',
      restartRequested: true,
    ));
  }

  // ───────────────────────────── Company CRUD ───────────────────────────────

  /// Function Name: [addCompany]
  ///
  /// Purpose: Persist the company document.
  ///
  /// Returns: [Future<bool>] — `false` when the write failed, so the callers
  ///          below stop instead of reporting success regardless.
  Future<bool> addCompany(CompanyModel companyModel, String companyId) async {
    final Either<Failure, void> result =
        await companyRepository.saveCompany(companyId, companyModel);

    if (result.isLeft()) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: result.fold((Failure l) => l.errMessage, (_) => null),
      ));
      return false;
    }

    _systemLogs.systemLogsAction('update company info');

    emit(state.copyWith(
      company: companyModel,
      status: CompanyStatus.success,
    ));
    return true;
  }

  Future<CompanyModel?> getCompany({
    String? companyName,
    bool shouldRestart = false,
  }) async {
    emit(state.copyWith(status: CompanyStatus.loading));

    String companyId = companyName ?? CompanyCollectionPaths.companyId;
    if (companyId.isEmpty) companyId = _fallbackCompanyId;

    final Either<Failure, CompanyModel?> result =
        await companyRepository.getCompany(companyId);

    if (result.isLeft()) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: result.fold((Failure l) => l.errMessage, (_) => null),
      ));
      return null;
    }

    final CompanyModel? loaded = result.getOrElse(() => null);
    if (loaded == null) {
      emit(state.copyWith(status: CompanyStatus.failure));
      return null;
    }

    emit(state.copyWith(company: loaded, status: CompanyStatus.success));

    // Mirror the loaded company into the form fields.
    _populateFormFields(loaded);

    // Storage first — the theme controller reads these keys and only falls back
    // to the company document when a key is empty.
    if (loaded.status == _activeStatus) {
      _syncStorageFromFirebase();
    } else {
      _clearBrandingStorage();
    }

    // FIXED 23/8/2026: the refresh below used to sit inside the active branch
    // only. `resetCompanyBranding()` sets the company to `inactive`, so a reset
    // always took the else branch: storage was cleared, but AppTheme/AppColors
    // still held the old brand in memory and no `Get.forceAppUpdate()` ever
    // ran — Reset wrote the nulls to Firestore and left the screen showing the
    // old colours until the app was relaunched. `restartRequested` was skipped
    // for the same reason, so the page never remounted either.
    //
    // With storage cleared and the company inactive, each of these resolves to
    // its default (#FFDE59 primary, #E5B800 secondary, Cairo/Vazirmatn fonts),
    // so running them on both branches is what makes Reset restore defaults.
    themeController.updatePrimaryColor();
    themeController.updateSecondaryColor();
    themeController.updateFonts();

    // Was `await Future.delayed(300ms); RestartWidget.restartApp(Get.context!)`.
    // The page owns the remount now, so there is nothing to wait for
    // (CR-SKEL-SE3-N09).
    if (shouldRestart) emit(state.copyWith(restartRequested: true));

    return loaded;
  }

  /// Used when the tenant root has not been resolved yet — a pre-existing
  /// fallback, kept so behaviour does not change.
  static const String _fallbackCompanyId = '70843020';

  /// The one company status the branding pipeline reacts to.
  static const String _activeStatus = 'active';

  /// Replaces GetX's `.capitalize` string extension (CR-SKEL-SE3-N08).
  ///
  /// FIXED 23/8/2026: this capitalised only the FIRST character, while the GetX
  /// extension it replaced capitalises EVERY word. The value it returns is used
  /// as a pubspec font family name, and fonts are stored lower-cased
  /// (`updateCompanyBranding` writes `selectedEnglishFont.toLowerCase()`), so
  /// "open sans" came back as "Open sans" — no family by that name is declared,
  /// and Flutter silently falls back to the default font instead of erroring.
  /// Every multi-word family was affected ("Open Sans", "M Plus", "Noto Sans",
  /// "Ibm Plex"); the single-word ones happened to survive, which is why
  /// changing the font looked like it worked sometimes and not others.
  static String? _capitalize(String? value) {
    if (value == null || value.isEmpty) return value;
    return value
        .split(' ')
        .map((String word) =>
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // ───────────────────────────── Storage sync ───────────────────────────────

  void _syncStorageFromFirebase() {
    final c = state.company;
    if (c == null) return;

    storage.write('font', _capitalize(c.englishFont?.englishFont?.lastOrNull));
    storage.write(
        'font_arabic', _capitalize(c.arabicFont?.arabicFont?.lastOrNull));
    storage.write('primaryColor', c.primaryColor?.primaryColor?.lastOrNull);
    storage.write('secondaryColor', c.secondaryColor?.secondaryColor?.lastOrNull);
    storage.write('logo', c.companyLogo?.companyLogo?.lastOrNull);
  }

  void _clearBrandingStorage() {
    storage.write('font', null);
    storage.write('font_arabic', null);
    storage.write('primaryColor', null);
    storage.write('secondaryColor', null);
    storage.write('logo', null);
  }

  /// Mirrors the loaded company into the form-field slice of state.
  /// (Was `_populateControllers()`, which wrote into TextEditingControllers.)
  void _populateFormFields(CompanyModel c) {
    emit(state.copyWith(
      companyName: c.companyName?.companyName?.lastOrNull ?? '',
      taxNumber: c.taxNumber?.taxNumber?.lastOrNull ?? '',
      country: c.country?.country?.lastOrNull ?? '',
      city: c.city?.city?.lastOrNull ?? '',
      stateOrProvince: c.province?.province?.lastOrNull ?? '',
      email: c.email?.emails?.lastOrNull ?? '',
      phone: c.phone?.phones?.lastOrNull ?? '',
      streetAddress: c.companyAddress?.address?.lastOrNull ?? '',
      code: c.zipCode?.zipCode?.lastOrNull ?? '',
      contactFirstName: c.firstName?.firstNames?.lastOrNull ?? '',
      contactLastName: c.lastName?.lastNames?.lastOrNull ?? '',
      // Contact email/phone share the company's fields in this model shape.
      contactEmail: c.email?.emails?.lastOrNull ?? '',
      contactPhone: c.phone?.phones?.lastOrNull ?? '',
    ));
  }

  // ─────────────────────────────── Mutations ────────────────────────────────

  /// Persists the unsaved branding selections (logo, colors, fonts).
  Future<void> updateCompanyModel() async {
    if (state.company == null) {
      await getCompany(shouldRestart: false);
      if (state.company == null) {
        emit(state.copyWith(
          status: CompanyStatus.failure,
          errorMessage: 'Company data not loaded. Please try again.',
        ));
        return;
      }
    }

    emit(state.copyWith(status: CompanyStatus.loading));

    try {
      final CompanyModel c = state.company!;

      if (state.imageUrl != null) {
        c.companyLogo!.companyLogo!.add(state.imageUrl);
        c.companyLogo!.timestamps!.add(Timestamp.now());
      }

      c.status = _activeStatus;

      if (state.primaryColor != null) {
        c.primaryColor!.primaryColor!
            .add('0x${state.primaryColor!.value.toRadixString(16)}');
        c.primaryColor!.timestamps!.add(Timestamp.now());
      }

      if (state.secondaryColor != null) {
        c.secondaryColor!.secondaryColor!
            .add('0x${state.secondaryColor!.value.toRadixString(16)}');
        c.secondaryColor!.timestamps!.add(Timestamp.now());
      }

      if (state.selectedEnglishFont != null) {
        c.englishFont!.englishFont!.add(state.selectedEnglishFont!.toLowerCase());
        c.englishFont!.timestamps!.add(Timestamp.now());
      }

      if (state.selectedArabicFont != null) {
        c.arabicFont!.arabicFont!.add(state.selectedArabicFont!.toLowerCase());
        c.arabicFont!.timestamps!.add(Timestamp.now());
      }

      // Stop on a failed write: the old code reported success regardless,
      // because addCompany could not signal failure.
      if (!await addCompany(c, CompanyCollectionPaths.companyId)) return;
      await getCompany(shouldRestart: true);

      emit(state.copyWith(
        status: CompanyStatus.success,
        successMessage: 'Company branding updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: 'Failed to update company branding: $e',
      ));
    }
  }

  /// Function Name: [resetCompanyBranding]
  ///
  /// Purpose: Clear the company's logo, colours and fonts and mark it inactive.
  ///
  /// Returns: [Future<bool>] — `false` when the company could not be loaded or
  ///          the write failed, so the caller can show its error dialog.
  ///
  /// Moved here from `company_branding_screen.dart`, which held the model
  /// mutation, the Firestore write and two `try` blocks inside a widget — try
  /// is forbidden in presentation/ui/ (§20/§21). The widget now only drives the
  /// dialog flow and reads the boolean.
  Future<bool> resetCompanyBranding() async {
    if (state.company == null) {
      await getCompany(shouldRestart: false);
      if (state.company == null) return false;
    }

    emit(state.copyWith(status: CompanyStatus.loading));

    try {
      final CompanyModel company = state.company!;
      final Timestamp now = Timestamp.now();

      // Each field used to be written through `?.add(...)` behind a
      // `lastOrNull != null` guard, so a null sub-model or list silently
      // skipped that part of the brand. The containers are created up front.
      company.companyLogo ??= CompanyLogo(companyLogo: [], timestamps: []);
      _appendNull(company.companyLogo!.companyLogo ??= <String?>[],
          company.companyLogo!.timestamps ??= <Timestamp?>[], now);

      company.primaryColor ??= PrimaryColor(primaryColor: [], timestamps: []);
      _appendNull(company.primaryColor!.primaryColor ??= <String?>[],
          company.primaryColor!.timestamps ??= <Timestamp?>[], now);

      company.secondaryColor ??=
          SecondaryColor(secondaryColor: [], timestamps: []);
      _appendNull(company.secondaryColor!.secondaryColor ??= <String?>[],
          company.secondaryColor!.timestamps ??= <Timestamp?>[], now);

      company.englishFont ??= EnglishFont(englishFont: [], timestamps: []);
      _appendNull(company.englishFont!.englishFont ??= <String?>[],
          company.englishFont!.timestamps ??= <Timestamp?>[], now);

      company.arabicFont ??= ArabicFont(arabicFont: [], timestamps: []);
      _appendNull(company.arabicFont!.arabicFont ??= <String?>[],
          company.arabicFont!.timestamps ??= <Timestamp?>[], now);

      company.status = _inactiveStatus;

      clearBrandingSelections();

      return await addCompany(company, CompanyCollectionPaths.companyId);
    } catch (e) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: 'Failed to reset company branding: $e',
      ));
      return false;
    }
  }

  /// Appends a null "cleared" entry to a branding history, but only when the
  /// history currently holds a value — clearing an already-clear field would
  /// just grow the document.
  static void _appendNull(
    List<String?> values,
    List<Timestamp?> stamps,
    Timestamp now,
  ) {
    if (values.isEmpty || values.last == null) return;
    values.add(null);
    stamps.add(now);
  }

  /// The status a company carries once its branding has been reset.
  static const String _inactiveStatus = 'inactive';

  /// Persists the company-information form. Reads the form values straight out
  /// of state (was `companyName.text`, etc.).
  Future<void> updateCompanyInformation() async {
    final CompanyModel? c = state.company;
    if (c == null) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: 'Company data not loaded. Please try again.',
      ));
      return;
    }

    emit(state.copyWith(status: CompanyStatus.loading));

    try {
      final Timestamp now = Timestamp.now();

      void put(String value, List<String?>? target, List<Timestamp?>? stamps) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return;
        target?.add(trimmed);
        stamps?.add(now);
      }

      put(state.companyName, c.companyName?.companyName, c.companyName?.timestamps);
      put(state.taxNumber, c.taxNumber?.taxNumber, c.taxNumber?.timestamps);
      put(state.country, c.country?.country, c.country?.timestamps);
      put(state.city, c.city?.city, c.city?.timestamps);
      put(state.stateOrProvince, c.province?.province, c.province?.timestamps);
      put(state.email, c.email?.emails, c.email?.timestamps);
      put(state.phone, c.phone?.phones, c.phone?.timestamps);
      put(state.streetAddress, c.companyAddress?.address,
          c.companyAddress?.timestamps);
      put(state.code, c.zipCode?.zipCode, c.zipCode?.timestamps);
      put(state.contactFirstName, c.firstName?.firstNames, c.firstName?.timestamps);
      put(state.contactLastName, c.lastName?.lastNames, c.lastName?.timestamps);

      if (!await addCompany(c, CompanyCollectionPaths.companyId)) return;
      await getCompany(shouldRestart: false);

      emit(state.copyWith(
        status: CompanyStatus.success,
        successMessage: 'Company information updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: 'Failed to update company information: $e',
      ));
    }
  }
}
