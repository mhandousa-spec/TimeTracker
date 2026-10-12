part of 'provider_selection_cubit.dart';

// Methods extracted from provider_selection_cubit.dart to keep it <700 LOC.
extension ProviderSelectionCubitPart on ProviderSelectionCubit {
  Future<void> handleSaveForLater() async {
    final currentState = state as ProviderSelectionLoaded;

    try {
      await _saveSelectionToPrefsAndCubit();
      await Future.delayed(const Duration(milliseconds: 100));

      // ✅ FIX: Pass required parameters
      final completeModel = await _getCompleteServiceModel(
        data: currentState.data,
        allEmployees: currentState.allEmployees,
      );

      final data = currentState.data;

      if (data.editingModel != null &&
          data.editingModel!.currentId != null &&
          data.editingModel!.currentId!.isNotEmpty) {
        final updatedModel = completeModel.copyWith(
          id: data.editingModel!.currentId,
        );

        await SharedPrefsServiceMaster.updateDraft(data.editingModel!, updatedModel);
      } else {
        final cubitModel = servicesManagerCubit.docService;

        if (cubitModel != null &&
            cubitModel.currentId != null &&
            cubitModel.currentId.startsWith('draft_')) {
          final updatedModel = completeModel.copyWith(
            id: cubitModel.currentId,
          );
          await SharedPrefsServiceMaster.updateDraft(cubitModel, updatedModel);
        } else {
          await SharedPrefsServiceMaster.saveDraft(completeModel);
        }
      }

      await SharedPrefsServiceMaster.debugSavedDrafts();
      emit(const ProviderSelectionSaved());

    } catch (error) {
      emit(ProviderSelectionError('Failed to save draft: $error'));
    }
  }

  // ==================== MODEL BUILDING ====================

  // ==================== HELPER METHODS ====================

  // CHANGED: Made public from private (_normalizeEmail -> normalizeEmail)
  String normalizeEmail(String? email) {
    if (email == null || email.isEmpty) return '';
    return email.trim().toLowerCase();
  }

  // CHANGED: Updated to accept bool instead of String
  String getOrdinal(int number, bool isArabic) {
    return isArabic ? this._ordinalAr(number) : this._ordinalEn(number);
  }

  EmployeeEntityModell _mapToEmployeeEntityModell(EmployeeEntityPro e) {
    return EmployeeEntityModell(
      id: e.id,
      state: "pending",
      firstName: e.firstName,
      middleName: e.middleName,
      lastName: e.lastName,
      email: e.email,
      gender: e.gender,
      title: e.title,
      titleInArabic: e.titleInArabic,
      photo: e.photo,
      departmentId: e.departmentId,
      language: e.language,
      maritalStatus: e.maritalStatus,
      middleNameInArabic: e.middleNameInArabic,
      lastNameInArabic: e.lastNameInArabic,
      firstNameInArabic: e.firstNameInArabic,
      homePhone: e.homePhone,
      drivingLicenseId: e.drivingLicenseId,
      country: e.country,
      city: e.city,
      postalCode: e.postalCode,
      province: e.province,
      role: e.role,
      status: e.status,
      supervisor: e.supervisor,
      workLocation: e.workLocation,
      mobilePhone: (e.mobilePhone != null)
          ? ServicesMobilePhoneEntity.fromMobilePhoneEntity(e.mobilePhone!)
          : null,
    );
  }

  // ==================== UI HELPERS ====================
}
