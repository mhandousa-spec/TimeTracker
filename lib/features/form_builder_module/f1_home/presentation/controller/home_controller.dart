  import 'dart:async';

  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';

  import 'package:get/get.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/users_model.dart';
  import 'package:knowticed_plus/features/form_builder_module/f3_form_details/presentation/ui/pages/form_details_screen.dart';
  import 'package:knowticed_plus/features/form_builder_module/f1_home/data/repository/home_repository.dart';
import 'package:knowticed_plus/features/notification/presentation/controller/notification_controller_cubit_main_core.dart';
  import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
  import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
  import 'package:provider/provider.dart';

  import 'package:knowticed_plus/core/network/failure_model.dart' as networkFailure;
  import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';
  import 'package:knowticed_plus/core/extensions/context_extensions.dart';
  import 'package:knowticed_plus/core/network/failure_model.dart';
  import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
  import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
  import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
  import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_cubit.dart';
  import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/pages/conver_pdf_screen.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_model.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';
  import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_sort_option.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/repo/form_repo.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/create_head_form_screen.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/publish_screen.dart';
  import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/tablet/creating_form_tablet_screen.dart';
  import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/response_model.dart';
  import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/user_responses_model.dart';
  import 'package:knowticed_plus/features/form_builder_module/f4_fillout/domain/repo/response_repo.dart';
  import 'package:knowticed_plus/features/form_builder_module/f5_submissions/presentation/ui/pages/submissions_screen.dart' as FormBuilderSubmissions;
  import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
  import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';
  import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
  import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/menu.dart';
  import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/edit_validator.dart';
  import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_state.dart';

  class HomeCubit extends Cubit<HomeState> with EditValidator {
    final HomeRepository homeRepository;
    final FormRepo formRepo;
    final ResponseRepo responseRepo;
    final MainCoreEmployeeController mainCoreEmployeeController;

    HomeCubit({
      required this.homeRepository,
      required this.formRepo,
      required this.responseRepo,
      required this.mainCoreEmployeeController,
    }) : super(HomeInitial());

    bool isLoading = true;
    List<FormEntity> publishFormModels = [];
    List<FormEntity> draftFormModels = [];
    List<FormEntity> deleteFormModels = [];
    List<FormEntity> requestedFormModels = [];
    List<FormEntity> submissionsFormModels = [];
    late List<FormEntity> shownFormModels;
    late FormStatus selectedTab;
    late TabController tabController;
    TextEditingController searchController = TextEditingController();
    bool sortClicked = false;
    bool? isSortAscending;
    List<FormModel> forms = [];
    List<FormEntity> formsEntity = [];
    List<FormPrivacyModel> formPrivacyList = [];

    // Filter fields
    String? currentDropDownValue;
    late TextEditingController currentDate;

    String selectedSortOption = FormSortOption.publishedDate;
    bool isAscending = false;

    void initialize(TickerProvider vsync) async {
      currentDate = TextEditingController();
      shownFormModels = publishFormModels;
      selectedTab = FormStatus.publish;
      tabController = TabController(length: 5, vsync: vsync);
      tabController.addListener(() => onChangeTab(tabController.index));

      await getData();
    }

    /// Updates an existing form
    /// Updates an existing form
    /// Updates an existing form
    void updateExistingForm({
      required FormEntity model,
      required BuildContext context,
      required CreateFormDataCubit createFormDataCubit,
    }) async {

      

      AppDialogs.editForm(
        context,
            () async {
          // User clicked "Yes"

          try {
            // ✅ STEP 3: Convert entity to model
            final formModel = model.toModel();

            // ✅ STEP 4: Call updateForm
            final result = await formRepo.updateForm(formModel);

            // ✅ STEP 5: Close loading dialog
            if (context.mounted) {
              Navigator.of(context).pop();
            }

            // ✅ STEP 6: Handle result
            result.fold(
                  (failure) {

              },
                  (_) async {

                // ✅ STEP 7: Show success dialog
                if (context.mounted) {
                  await AppDialogs.editingFormSuccessfully(context);
                }

                await getForms(showLoading: false);  // ✅ CHANGED: Added showLoading: false

                // ✅ STEP 9: Navigate back to home after 2 seconds
                Timer(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close success dialog
                    Navigator.of(context).popUntil((route) => route.isFirst); // Go back to home
                  }
                });

              },
            );

            
          } catch (e, stackTrace) {

            

            // ✅ Close loading dialog if still open
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        },
      );
    }

    Future<void> getData() async {
      while (mainCoreEmployeeController.employeeEntity == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await getForms();
    }

    Future<void> getForms({bool showLoading = true}) async {
      forms = [];
      formsEntity = [];

      // ✅ ONLY show loading on initial load, not on refresh
      if (showLoading) {
        isLoading = true;
        emit(HomeLoading());
      }

      try {
        Either<Failure, dynamic> response = await formRepo.getMyCreatedFroms(
            mainCoreEmployeeController.employeeEntity!.email!);

        if (response.isRight()) {
          forms = response.getOrElse(() => []);
          await filterUserCreatedFormModels(response.getOrElse(() => []));
          await getAccessedForms();
        }
      } catch (e, stackTrace) {
        // ✅ Swallow errors so loading always resolves to a loaded state.
        // Without this, an exception here left the UI stuck on the spinner
        // until the user tapped a tab (which emits HomeLoaded separately).
        debugPrint('getForms error: $e\n$stackTrace');
      } finally {
        // ✅ ALWAYS resolve loading, even on error, so the no-data Lottie
        // (or the grid) shows immediately without needing a tab tap.
        isLoading = false;
        shownFormModels = publishFormModels;
        emit(HomeLoaded(
          publishForms: publishFormModels,
          draftForms: draftFormModels,
          deletedForms: deleteFormModels,
          requestedForms: requestedFormModels,
          submissionForms: submissionsFormModels,
          shownForms: shownFormModels,
          selectedTab: selectedTab,
          currentDropDownValue: currentDropDownValue,
          currentDateValue: currentDate.text.isEmpty ? null : currentDate.text,
        ));
      }
    }

    /// The option the user actively picked in Sort (null = none, the button
    /// shows neutral). [selectedSortOption] keeps the effective default.
    String? activeSortOption;

    void updateSortOption(String? option) {
      activeSortOption = option;
      selectedSortOption = option ?? _defaultSortForTab();
      sortForms();  // This already calls _emitLoadedState()
    }

    /// Bug report #24: the Submissions tab sorts by Submission / Received
    /// date; every other tab by Published date / Last update.
    String _defaultSortForTab() => tabController.index == 3
        ? FormSortOption.submissionDate
        : FormSortOption.publishedDate;

    void toggleSortOrder() {
      isAscending = !isAscending;
      sortForms();
    }

    void sortForms() {
      // Still emit when the list is empty so the Sort button reflects the pick.
      if (shownFormModels.isEmpty) {
        _emitLoadedState();
        return;
      }

      // FIXED 19/8/2026 — this switch used to carry one `case` per language
      // ('Published Date' / 'تاريخ النشر'), so sorting broke as soon as the
      // Arabic wording in the .arb changed. `SortDropdownMenu` now hands up a
      // FormSortOption constant and translates only for display.
      switch (selectedSortOption) {
        case FormSortOption.publishedDate:
          shownFormModels.sort((a, b) {
            final dateA = _getPublishedDate(a);
            final dateB = _getPublishedDate(b);
            return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
          });
          break;

        case FormSortOption.submissionDate:
          shownFormModels.sort((a, b) {
            final dateA = a.submissionDate ?? _getPublishedDate(a);
            final dateB = b.submissionDate ?? _getPublishedDate(b);
            return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
          });
          break;

        case FormSortOption.receivedDate:
          shownFormModels.sort((a, b) {
            final dateA = a.receivedDate ?? _getPublishedDate(a);
            final dateB = b.receivedDate ?? _getPublishedDate(b);
            return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
          });
          break;

        case FormSortOption.lastUpdate:
          shownFormModels.sort((a, b) {
            final dateA = _getLastUpdate(a);
            final dateB = _getLastUpdate(b);
            return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
          });
          break;

        default:
        // Default to Published Date if unknown option
          shownFormModels.sort((a, b) {
            final dateA = _getPublishedDate(a);
            final dateB = _getPublishedDate(b);
            return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
          });
      }

      _emitLoadedState();
    }

    DateTime _getPublishedDate(FormEntity form) {
      try {
        if (form.status == FormStatus.publish && form.createDate != null) {
          return form.createDate!;
        }
        return form.createDate ?? DateTime(2000);
      } catch (e) {
        return DateTime(2000);
      }
    }

    DateTime _getRequestedDate(FormEntity form) {
      try {
        if (form.submissionDate != null) {
          return form.submissionDate!;
        }
        return form.createDate ?? DateTime(2000);
      } catch (e) {
        return DateTime(2000);
      }
    }

    int _getDuration(FormEntity form) {
      try {
        if (form.submissionDate != null && form.createDate != null) {
          return form.submissionDate!.difference(form.createDate!).inDays;
        }
        if (form.createDate != null) {
          return DateTime.now().difference(form.createDate!).inDays;
        }
        return 0;
      } catch (e) {
        return 0;
      }
    }

    DateTime _getLastUpdate(FormEntity form) {
      try {
        if (form.submissionDate != null) {
          return form.submissionDate!;
        }
        return form.createDate ?? DateTime(2000);
      } catch (e) {
        return DateTime(2000);
      }
    }

    Future<void> getAccessedForms() async {
      Either<Failure, dynamic> response = await formRepo.getAllMyAccessData(
          mainCoreEmployeeController.employeeEntity!.email!);

      if (response.isRight()) {
        List<FormPrivacyModel> formPrivacyModels = response.getOrElse(() => []);
        UserResponsesModel? userResponsesModel =
        await homeRepository.getUserResponsesIds(
            mainCoreEmployeeController.employeeEntity!.email!);
        Set<String> submittedFormIds = {};

        submittedFormIds = userResponsesModel?.formIds.toSet() ?? {};

        for (FormPrivacyModel formPrivacyModel in formPrivacyModels) {
          
          int userIndex = formPrivacyModel.usersModel?.emails?.indexOf(
              mainCoreEmployeeController.employeeEntity!.email!) ??
              -1;
          if (userIndex == -1) continue;

          DateTime? accessBegin =
          formPrivacyModel.usersModel?.accessBegin?[userIndex]?.toDate();
          DateTime? accessEnd =
          formPrivacyModel.usersModel?.accessEnd?[userIndex]?.toDate();
          bool isActive =
              formPrivacyModel.usersModel?.status?[userIndex] == 'active';
          bool isEdit =
              formPrivacyModel.usersModel?.editPermission?[userIndex] ?? false;
          bool isHasAccess = true;

          if (accessBegin != null) {
            if (accessBegin.isAfter(DateTime.now())) {
              isHasAccess = false;
            }
          }
          if (accessEnd != null) {
            if (accessEnd.isBefore(DateTime.now())) {
              isHasAccess = false;
            }
          }

          if ((isHasAccess || submittedFormIds.contains(formPrivacyModel.id!)) &&
              isActive) {
            response = await formRepo.getForm(formPrivacyModel.id!);
            if (response.isLeft()) continue;
            Map<String, dynamic>? form = response.getOrElse(() => null);
            if (form == null) continue;
            FormModel? formModel = FormModel.fromMap(form);
            FormEntity formEntity = FormEntity.fromModel(
              formModel,
              formPrivacyModel,
              usedBy: 0,
              isEdit: isEdit,
              isHasAccess: isHasAccess,
            );

            if (submittedFormIds.contains(formEntity.id)) {
              formEntity.status = FormStatus.submissions;
              Either<networkFailure.Failure, dynamic> result =
              await homeRepository.getFormResponse(formEntity.id,
                  mainCoreEmployeeController.employeeEntity!.email!);
              if (result.isLeft()) continue;
              ResponseModel? responseModel = result.getOrElse(() => null);
              formEntity.pages = [];
              formEntity.submissionDate = userResponsesModel?.submissionTimestamp[
              userResponsesModel!.formIds.lastIndexOf(formEntity.id)]
                  .toDate();
              for (int pageIndex = 0;
              pageIndex < responseModel!.pages!.length;
              pageIndex++) {
                formEntity.pages
                    .add(PageEntity.fromModel(responseModel.pages![pageIndex]));
                submissionsFormModels.add(formEntity);
                formsEntity.add(formEntity);
              }
            } else {
              formEntity.status = FormStatus.requestedForms;
              formsEntity.add(formEntity);
              requestedFormModels.add(formEntity);
            }
          }
        }
      }
    }

    Future<void> filterUserCreatedFormModels(List<FormModel> createdForms) async {
      for (var form in createdForms) {
        int formNumberOfUsage =
        await homeRepository.getFormNumberOfUsage(form.id) as int;
        bool isHasAccess = false;
        if (form.accessMangement.last.toLowerCase() ==
            AccessManagement.personalAccess.name.toLowerCase()) {
          isHasAccess = true;
        }
        FormPrivacyModel? formPrivacyModel = FormPrivacyModel();

        if (form.accessMangement.last.toLowerCase() ==
            AccessManagement.openAccess.name.toLowerCase()) {
          await formRepo.getFormPrivacy(form.id).then((value) {
            value.fold((failure) {
              
            }, (privacyModel) {
              formPrivacyModel = privacyModel;
            });
          });
        }
        if (form.accessMangement.last.toLowerCase() ==
            AccessManagement.restrictedAccess.name.toLowerCase()) {
          await formRepo.getFormPrivacy(form.id).then((value) {
            value.fold((failure) {
              
            }, (privacyModel) {
              formPrivacyModel = privacyModel;
            });
          });
        }

        FormEntity formEntity = FormEntity.fromModel(form, formPrivacyModel!,
            usedBy: formNumberOfUsage, isHasAccess: isHasAccess);
        formsEntity.add(formEntity);
      }
      filterCreatedForms();
    }

    Future<void> filterCreatedForms() async {
      publishFormModels = [];
      draftFormModels = [];
      deleteFormModels = [];
      requestedFormModels = [];
      submissionsFormModels = [];
      UserResponsesModel? userResponsesModel =
      await homeRepository.getUserResponsesIds(
          mainCoreEmployeeController.employeeEntity!.email!);
      for (FormEntity form in formsEntity) {

        if (form.status == FormStatus.publish) {
          publishFormModels.add(form);
        }
        if (form.status == FormStatus.drafts) {
          draftFormModels.add(form);
        }
        if (form.status == FormStatus.deleted) {
          deleteFormModels.add(form);
        }

        if (form.isHasAccess) {
          form.status = FormStatus.requestedForms;
          if (userResponsesModel != null &&
              userResponsesModel.formIds.contains(form.id)) {
            form.status = FormStatus.submissions;
            form.submissionDate = userResponsesModel
                .submissionTimestamp[userResponsesModel.formIds.indexOf(form.id)]
                .toDate();
            submissionsFormModels.add(form);
          } else {
            requestedFormModels.add(form);
          }
        }
      }
    }

    Future<void> createForm(FormEntity formEntity) async {

      FormModel formModel = formEntity.toModel();

      // Upload images if needed
      if (formModel.image != null && formModel.image!.isNotEmpty) {
        final uploadImage = await formRepo.uploadFile(
            formModel.image?.first ?? '', getBaseUrl('${FormApiConstants.storageBase}/Images'));
        uploadImage.fold((failure) {
          
        }, (imageUrl) {
          formModel.image = [imageUrl];
        });
      }

      if (formModel.watermark != null &&
          formModel.watermark?.imageUrl != null &&
          formModel.watermark!.imageUrl.isNotEmpty) {
        final uploadWatermark = await formRepo.uploadFile(
            formModel.watermark?.imageUrl?.first ?? '', getBaseUrl('${FormApiConstants.storageBase}/WaterMarks'));
        uploadWatermark.fold((failure) {
          
        }, (url) {
          formModel.watermark?.imageUrl = [url];
        });
      }

      final response = await formRepo.createForm(formModel);
      response.fold(
              (failure) {
            
          },
              (r) {
            
          }
      );

      // ✅ CRITICAL FIX: Reload forms to update all lists
      await getForms(showLoading: false);

    }

    Future<void> addFormPrivcy(FormPrivacyModel formPrivacyModel, String formId,
        FormEntity model) async {
      final response = await formRepo.addFormPrivacy(formPrivacyModel, formId);
      response.fold((failure) {
        
      }, (r) {
        NotificationControllerCubit().sendNotification(
            title: "A New Form ${model.formHeadModel.title} Has Been Sent to You",
            arabicTitle:
            "تم إرسال نموذج جديد إليك ${model.formHeadModel.arTitle}",
            body:
            "You've received a new form ${model.formHeadModel.title} that requires your attention.",
            arabicBody:
            "لقد تلقيت نموذجًا جديدًا ${model.formHeadModel.arTitle} يتطلب انتباهك.",
            type: "formBuilder",
            emails: formPrivacyModel.usersModel?.emails ?? []);
      });
    }

    void addFormModelToDraft(FormEntity formModel) {
      draftFormModels.add(formModel);
      if (selectedTab == FormStatus.drafts) {
        shownFormModels = [];
        shownFormModels = draftFormModels;
      }
      _emitLoadedState();
    }

    /// Moves a restored form out of Deleted and back into the list it came
    /// from, in memory.
    ///
    /// REWRITTEN 19/8/2026 — it was `restoreFormModelToPublish`, and it did
    /// exactly that: `formModel.status = FormStatus.publish` unconditionally,
    /// then `publishFormModels.add(...)`. Delete a DRAFT and restore it and the
    /// form came back published — a form that was never published now sitting in
    /// the Publish tab. [statusBeforeDelete] is read from the form's own status
    /// history (see `FormDataSource.restoreForm`) so the form returns to
    /// whichever tab it was in.
    ///
    /// The removal also matched on TITLE, so restoring one of two forms with the
    /// same name dropped both from the Deleted list. It matches on `id` now.
    void restoreFormModel(FormEntity formModel, FormStatus statusBeforeDelete) {
      formModel.status = statusBeforeDelete;
      formModel.deleteDate = null;

      if (statusBeforeDelete == FormStatus.drafts) {
        draftFormModels.add(formModel);
      } else {
        publishFormModels.add(formModel);
      }

      deleteFormModels.removeWhere((element) => element.id == formModel.id);

      if (selectedTab == FormStatus.deleted) {
        shownFormModels = [];
        shownFormModels = deleteFormModels;
      }
      _emitLoadedState();
    }

    /// CHANGED: the callback now REPORTS whether the delete succeeded.
    ///
    /// `AppDialogs.deleteForm` runs `CustomDialogManager.showDialogFlow`, which
    /// shows the success dialog only when this returns true — so a delete that
    /// the repository rejects no longer ends on "You Successfully Deleted This
    /// Form". Nothing here pops: the flow closes the confirm dialog before it
    /// calls this, and shows/dismisses the success dialog itself.
    void popupDeleteFormModel(FormEntity formModel, BuildContext context) {
      AppDialogs.deleteForm(
        context,
            () async {
          final bool deleted = await deleteFormModel(formModel, context);
          if (deleted) {
            _emitLoadedState();
          }
          return deleted;
        },
      );
    }

    void popupDuplicateFormModel(FormEntity formModel, BuildContext context) {
      int duplicateVersion =
      _calculateDuplicateVersion(formModel.formHeadModel.title);

      AppDialogs.duplicateFormDialog(
        context,
        formModel.formHeadModel.title,
        formModel.formHeadModel.arTitle ?? formModel.formHeadModel.title,
        duplicateVersion,
            (newEnglishName, newArabicName) async {
          await duplicateFormModel(formModel, newEnglishName, newArabicName);
          _emitLoadedState();
        },
      );
    }

    int _calculateDuplicateVersion(String originalTitle) {
      int maxVersion = 1;

      List<FormEntity> allForms = [
        ...publishFormModels,
        ...draftFormModels,
        ...deleteFormModels,
      ];

      for (var form in allForms) {
        String formTitle = form.formHeadModel.title;

        if (formTitle.contains(originalTitle)) {
          RegExp regExp = RegExp(r'_(\d+)$');
          Match? match = regExp.firstMatch(formTitle);

          if (match != null) {
            int version = int.parse(match.group(1)!);
            if (version >= maxVersion) {
              maxVersion = version + 1;
            }
          } else if (formTitle == originalTitle) {
            maxVersion = 2;
          }
        }
      }

      return maxVersion;
    }

    void popupEditFormModel(BuildContext context, FormEntity formModel) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ContextExtension(context).isPhone
              ? CreateHeadFormScreen(formModel: formModel)
              : CreatingFormTabletScreen(formModel: formModel),
        ),
      );
    }

    void popupConvertPdf(FormEntity formModel, BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => PdfCubit()..initialize(formModel.pages.length),
            child: ConvertPdfScreen(formModel: formModel),
          ),
        ),
      );
    }

    void publishNewForm({
      required FormEntity model,
      required BuildContext context,
      required CreateFormDataCubit createFormDataCubit,
      bool skipDialog = false,  // ✅ Parameter to skip dialog
    }) {

      

      final accessManagement = model.formHeadModel.accessManagement;

      // ==================== OPEN ACCESS ====================
      if (accessManagement == 'Open Access' ||
          accessManagement == 'Open Access') {

        if (skipDialog) {
          
          _executeOpenAccessPublish(model, context, createFormDataCubit);
          return;
        }

        // Mobile: Navigate to PublishScreen
        if (!ContextExtension(context).isTablett) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (newContext) => MultiProvider(
                providers: [
                  BlocProvider<CreateFormDataCubit>.value(
                    value: createFormDataCubit,
                  ),
                  BlocProvider<CreateFormHeadCubit>.value(
                    value: context.read<CreateFormHeadCubit>(),
                  ),
                  BlocProvider<HomeCubit>.value(
                    value: context.read<HomeCubit>(),
                  ),
                ],
                child: PublishScreen(model: model),
              ),
            ),
          );
          return;
        }

        // Tablet: Show dialog directly
        AppDialogs.summaryOpenAccessDialog(
          context,
              () async {
            _executeOpenAccessPublish(model, context, createFormDataCubit);
          },
        );
      }
      // ==================== PERSONAL ACCESS ====================
      else if (accessManagement == 'Personal Access' ||
          accessManagement == 'Personal Access') {
        
        AppDialogs.creatingForm(context, () async {
          Navigator.of(context).pop();
          await createForm(model);
          await AppDialogs.creatingFormSuccessfully(context);

          Timer(const Duration(seconds: 2), () {
            Navigator.of(context).pop();
            Navigator.of(context).popUntil((route) => route.isFirst);
            getForms();
          });
        });
      }
      // ==================== RESTRICTED ACCESS ====================
      else if (accessManagement == 'Restricted Access' ||
          accessManagement == 'Restricted Access') {

        if (skipDialog) {
          
          _executeRestrictedAccessPublish(model, context, createFormDataCubit);
          return;
        }

        // Mobile: Navigate to PublishScreen
        if (!ContextExtension(context).isTablett) {
          
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (newContext) => MultiProvider(
                providers: [
                  BlocProvider<CreateFormDataCubit>.value(
                    value: createFormDataCubit,
                  ),
                  BlocProvider<CreateFormHeadCubit>.value(
                    value: context.read<CreateFormHeadCubit>(),
                  ),
                  BlocProvider<HomeCubit>.value(
                    value: context.read<HomeCubit>(),
                  ),
                ],
                child: PublishScreen(model: model),
              ),
            ),
          );
          return;
        }

        // Tablet: Show dialog directly
        
        AppDialogs.summaryRestrictedAccessDialog(
          context,
              () {
            _executeRestrictedAccessPublish(model, context, createFormDataCubit);
          },
        );
      } else {

      }

    }

  // ✅ EXTRACT RESTRICTED ACCESS LOGIC
    // ✅ EXTRACT OPEN ACCESS LOGIC
    Future<void> _executeOpenAccessPublish(
        FormEntity model,
        BuildContext context,
        CreateFormDataCubit createFormDataCubit,
        ) async
    {

      var isMobile = ContextExtension(context).isPhone;

      try {
        // ✅ CRITICAL: Get the LATEST state from cubit
        final dataState = createFormDataCubit.state;

        if (dataState is! CreateFormDataLoaded) {
          
          return;
        }

        

        // ✅ CRITICAL: Update model with LATEST data from dialog
        model = createFormDataCubit.addOpenAccessData(model);

        // ✅ VERIFY: Print what's in the model now

        

        // Get department employees
        List<String>? departrmentId = model.openAccessModel?.selectedDepartments
            ?.map((e) => e.id)
            .toList();

        List<EmployeeEntityPro>? employees = mainCoreEmployeeController
            .allEmployeesEntities!
            .where((element) => departrmentId!.contains(element.departmentId))
            .toList();

        // ✅ Create FormPrivacyModel with dates from model
        FormPrivacyModel formPrivacyModel = FormPrivacyModel(
          timestamps: [Timestamp.now()],
          usersModel: UsersModel(
            accessBegin: List.generate(
              employees.length,
                  (index) => (model.openAccessModel?.timeBegin != null
                  ? Timestamp.fromDate(model.openAccessModel!.timeBegin!)
                  : null),
            ),
            accessEnd: List.generate(
              employees.length,
                  (index) => (model.openAccessModel?.timeEnd != null
                  ? Timestamp.fromDate(model.openAccessModel!.timeEnd!)
                  : null),
            ),
            editPermission: List.generate(
              employees.length,
                  (index) => model.openAccessModel?.isEdit ?? false,
            ),
            emails: employees.map((e) => e.email!).toList(),
            status: employees.map((e) => 'active').toList(),
          ),
        );

        // ✅ VERIFY: Print what's being saved

        

        // Save to Firebase — behind a loading indicator (bug report #12), then
        // the success dialog.
        await _withLoading(context, () async {
          await createForm(model);
          await addFormPrivcy(formPrivacyModel, model.id, model);
        });
        await AppDialogs.creatingFormSuccessfully(context);

        Timer(const Duration(seconds: 2), () {
        isMobile ?   Navigator.of(context).pop() : Null ;
          Navigator.of(context).pop();
          Navigator.of(context).popUntil((route) => route.isFirst);
          getForms(showLoading: false);
        });

        
      } catch (e, stackTrace) {

      }
    }

    // ✅ EXTRACT RESTRICTED ACCESS LOGIC
    Future<void> _executeRestrictedAccessPublish(
        FormEntity model,
        BuildContext context,
        CreateFormDataCubit createFormDataCubit,
        ) async
    {

      AppDialogs.creatingForm(context, () async {
        try {
          // ✅ CRITICAL: Get the LATEST state from cubit
          final dataState = createFormDataCubit.state;

          if (dataState is! CreateFormDataLoaded) {
            
            return;
          }

          

          // ✅ CRITICAL: Update model with LATEST data from dialog
          model = createFormDataCubit.addRestrictedAccessData(model);

          // ✅ VERIFY: Print what's in the model now

          

          // ✅ Create FormPrivacyModel with dates from model
          FormPrivacyModel formPrivacyModel = FormPrivacyModel(
            timestamps: [Timestamp.now()],
            usersModel: UsersModel(
              accessBegin: List.generate(
                model.restrictedAccessModel?.selectedPersons?.length ?? 0,
                    (index) => (model.restrictedAccessModel?.timeBegin != null
                    ? Timestamp.fromDate(model.restrictedAccessModel!.timeBegin!)
                    : null),
              ),
              accessEnd: List.generate(
                model.restrictedAccessModel?.selectedPersons?.length ?? 0,
                    (index) => model.restrictedAccessModel?.timeEnd != null
                    ? Timestamp.fromDate(model.restrictedAccessModel!.timeEnd!)
                    : null,
              ),
              editPermission: List.generate(
                model.restrictedAccessModel?.selectedPersons?.length ?? 0,
                    (index) => model.restrictedAccessModel?.isEdit ?? false,
              ),
              emails: model.restrictedAccessModel?.selectedPersons
                  ?.map((e) => e.id)
                  .toList(),
              status: model.restrictedAccessModel?.selectedPersons
                  ?.map((e) => 'active')
                  .toList(),
            ),
          );

          // ✅ VERIFY: Print what's being saved

          

          Navigator.of(context).pop();

          await _withLoading(context, () async {
            await createForm(model);
            await addFormPrivcy(formPrivacyModel, model.id, model);
          });
          await AppDialogs.creatingFormSuccessfully(context);

          Timer(const Duration(seconds: 2), () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).popUntil((route) => route.isFirst);
            getForms(showLoading: false);
          });

          
        } catch (e, stackTrace) {

        }
      });
    }

    void draftNewForm({
      required FormEntity model,
      required BuildContext context,
    }) {
      model.status = FormStatus.drafts;
      AppDialogs.draftForm(context, () async {
        Navigator.of(context).pop();
        final response = await formRepo.createForm(model.toModel());
        if (response.isRight()) {
          await AppDialogs.draftingFormSuccessfully(context);
          await getForms(showLoading: false); // ✅ CHANGED

          Timer(const Duration(seconds: 2), () {
            Navigator.of(context).pop();
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
        }
      });
    }

    /// Confirm → restore → success → the form is back where it was.
    ///
    /// Reached from the Deleted tab's card menu (`MenuEnum.restore`) and from
    /// the Restore button on a deleted form's create screen.
    ///
    /// The empty `for (int i = 0; i < forms.length; i++) {}` that used to open
    /// this method is gone — it had no body and no effect.
    void restoreForm({required FormEntity model, required BuildContext context}) {
      FormModel formModel = forms.firstWhere((element) => element.id == model.id);

      // Read BEFORE the repo call: `FormDataSource.restoreForm` appends the
      // restored status to `formStatus`, so afterwards the last non-deleted
      // entry is the one it just wrote, not the one from before the delete.
      final FormStatus statusBeforeDelete = _statusBeforeDelete(formModel);

      AppDialogs.restoreForm(
        context,
            () async {
          Navigator.of(context).pop();
          var result = await formRepo.restoreForm(formModel);
          if (result.isRight()) {
            await AppDialogs.restoringFormSuccessfully(context);
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
            restoreFormModel(model, statusBeforeDelete);
          }
        },
      );
    }

    /// The status this form held immediately before it was deleted.
    ///
    /// `formStatus` is an append-only history — `FormDataSource.deletedForm`
    /// adds 'deleted' rather than replacing what was there — so the previous
    /// state is still on the record: it is the last entry that is not
    /// 'deleted'. A form deleted, restored and deleted again therefore reports
    /// the status from its most recent life, which is what "before the delete"
    /// means.
    ///
    /// Falls back to publish when the history holds nothing else, which is the
    /// behaviour restore had unconditionally before 19/8/2026.
    FormStatus _statusBeforeDelete(FormModel formModel) {
      final String deleted = FormStatus.deleted.name.toLowerCase();

      for (int i = formModel.formStatus.length - 1; i >= 0; i--) {
        final String entry = formModel.formStatus[i].toLowerCase();
        if (entry == deleted) continue;

        for (final FormStatus status in FormStatus.values) {
          if (status.name.toLowerCase() == entry) return status;
        }
      }

      return FormStatus.publish;
    }

    /// Runs [task] behind a non-dismissible loading indicator (bug report
    /// #12: "apply the loading indicator then show success message").
    Future<void> _withLoading(
        BuildContext context, Future<void> Function() task) async {
      bool shown = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        // Bug report p.34: the app's default loading indicator (the same
        // 70pt lightPrimary ring as showLoadingIndicator), not a bare
        // Material spinner.
        barrierColor: AppColors.totalBlack.withOpacity(0.5),
        builder: (_) => PopScope(
          canPop: false,
          child: Center(
            child: SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.lightPrimary),
                backgroundColor: AppColors.white.withOpacity(0.6),
                strokeWidth: 2.0,
              ),
            ),
          ),
        ),
      );
      try {
        await task();
      } finally {
        if (shown && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          shown = false;
        }
      }
    }

    /// Access list for an Open Access form: every employee of the selected
    /// departments. Same rules as [_executeOpenAccessPublish].
    FormPrivacyModel _openAccessPrivacy(FormEntity model) {
      final List<String> departmentIds = model
              .openAccessModel?.selectedDepartments
              ?.map((e) => e.id)
              .toList() ??
          <String>[];
      final List<EmployeeEntityPro> employees = (mainCoreEmployeeController
                  .allEmployeesEntities ??
              <EmployeeEntityPro>[])
          .where((e) => departmentIds.contains(e.departmentId))
          .toList();
      final Timestamp? begin = model.openAccessModel?.timeBegin != null
          ? Timestamp.fromDate(model.openAccessModel!.timeBegin!)
          : null;
      final Timestamp? end = model.openAccessModel?.timeEnd != null
          ? Timestamp.fromDate(model.openAccessModel!.timeEnd!)
          : null;
      return FormPrivacyModel(
        timestamps: [Timestamp.now()],
        usersModel: UsersModel(
          accessBegin: List.generate(employees.length, (_) => begin),
          accessEnd: List.generate(employees.length, (_) => end),
          editPermission: List.generate(
              employees.length, (_) => model.openAccessModel?.isEdit ?? false),
          emails: employees.map((e) => e.email!).toList(),
          status: employees.map((e) => 'active').toList(),
        ),
      );
    }

    /// Access list for a Restricted Access form: the picked people. Same
    /// rules as [_executeRestrictedAccessPublish].
    FormPrivacyModel _restrictedAccessPrivacy(FormEntity model) {
      final int n = model.restrictedAccessModel?.selectedPersons?.length ?? 0;
      final Timestamp? begin = model.restrictedAccessModel?.timeBegin != null
          ? Timestamp.fromDate(model.restrictedAccessModel!.timeBegin!)
          : null;
      final Timestamp? end = model.restrictedAccessModel?.timeEnd != null
          ? Timestamp.fromDate(model.restrictedAccessModel!.timeEnd!)
          : null;
      return FormPrivacyModel(
        timestamps: [Timestamp.now()],
        usersModel: UsersModel(
          accessBegin: List.generate(n, (_) => begin),
          accessEnd: List.generate(n, (_) => end),
          editPermission: List.generate(
              n, (_) => model.restrictedAccessModel?.isEdit ?? false),
          emails: model.restrictedAccessModel?.selectedPersons
              ?.map((e) => e.id)
              .toList(),
          status: model.restrictedAccessModel?.selectedPersons
              ?.map((e) => 'active')
              .toList(),
        ),
      );
    }

    void publishEdit({
      required FormEntity oldFormModel,
      required FormEntity newFormModel,
      required BuildContext context,
    })
    {
      // Bug report #13: switching an existing form to Open (or Restricted)
      // Access saved straight away, so there was never a chance to pick the
      // departments / people who get access. Show the same summary dialog
      // publishing a new form shows, and save the edit + access list from it.
      final String oldAccess = oldFormModel.formHeadModel.accessManagement;
      final String newAccess = newFormModel.formHeadModel.accessManagement;
      final bool accessChanged = oldAccess != newAccess &&
          (newAccess == 'Open Access' || newAccess == 'Restricted Access');
      if (accessChanged &&
          ContextExtension(context).isTablett &&
          allowEditing(old: oldFormModel, edited: newFormModel)) {
        final CreateFormDataCubit dataCubit =
            context.read<CreateFormDataCubit>();
        Future<void> saveWithAccess() async {
          final bool isOpen = newAccess == 'Open Access';
          final FormEntity model = isOpen
              ? dataCubit.addOpenAccessData(newFormModel)
              : dataCubit.addRestrictedAccessData(newFormModel);
          final FormPrivacyModel privacy = isOpen
              ? _openAccessPrivacy(model)
              : _restrictedAccessPrivacy(model);
          await _withLoading(context, () async {
            await editFormModel(oldFormModel, model);
            await addFormPrivcy(privacy, model.id, model);
          });
          await AppDialogs.editingFormSuccessfully(context);
          Timer(const Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          _emitLoadedState();
        }

        if (newAccess == 'Open Access') {
          AppDialogs.summaryOpenAccessDialog(context, saveWithAccess);
        } else {
          AppDialogs.summaryRestrictedAccessDialog(context, saveWithAccess);
        }
        return;
      }

      if (allowEditing(old: oldFormModel, edited: newFormModel)) {
        AppDialogs.editForm(
          context,
              () async {
            Navigator.of(context).pop();
            editFormModel(oldFormModel, newFormModel);
            await AppDialogs.editingFormSuccessfully(context);
            Timer(const Duration(seconds: 2), () {
              if (ContextExtension(context).isPhone) {
                Navigator.of(context).pop();
              }
              Navigator.of(context).pop();
            });
            _emitLoadedState();
          },
        );
      } else {
        AppDialogs.editingFormNotAllowed(context);
      }
    }

    /// Deletes the form and reports whether it worked.
    ///
    /// CHANGED: was `Future<void>` and called `AppDialogs.deletingFormSuccessfully`
    /// itself from inside the success branch. Two problems with that. The
    /// success dialog was awaited inside a `fold` callback whose Future nobody
    /// held, so `deleteFormModel` returned before the dialog was even shown —
    /// the caller's `await` was meaningless. And showing the dialog from here
    /// mixed "change the data" with "tell the user", which is why the failure
    /// branch could stay empty without anyone noticing.
    ///
    /// It now only reports the outcome; `CustomDialogManager.showDialogFlow`
    /// decides what the user sees. `fold` returns the value of whichever branch
    /// ran, so the bool comes straight out of the repository result.
    Future<bool> deleteFormModel(
        FormEntity formEntity, BuildContext context) async
    {
      FormModel formModel =
      forms.firstWhere((element) => element.id == formEntity.id);
      var response = await formRepo.deleteForm(formModel);
      return response.fold((failure) {
        return false;
      }, (r) {
        formEntity.status = FormStatus.deleted;
        deleteFormModels.add(formEntity);
        publishFormModels.remove(formEntity);
        return true;
      });
    }

    Future<void> duplicateFormModel(
        FormEntity formEntity,
        String newEnglishName,
        String newArabicName,
        ) async
    {
      FormEntity newFormModel = formEntity.duplicate();

      newFormModel.formHeadModel.title = newEnglishName;
      newFormModel.formHeadModel.arTitle = newArabicName;

      FormModel formModel = newFormModel.toModel();
      final response = await formRepo.createForm(formModel);

      response.fold(
            (failure) {
          
        },
            (r) {
          publishFormModels.add(newFormModel);
        },
      );

      if (formEntity.restrictedAccessModel != null) {
        FormPrivacyModel formPrivacyModel = FormPrivacyModel(
          timestamps: [Timestamp.now()],
          usersModel: UsersModel(
            accessBegin: formEntity.restrictedAccessModel?.timeBegin != null
                ? [
              Timestamp.fromDate(
                  formEntity.restrictedAccessModel!.timeBegin!)
            ]
                : null,
            accessEnd: formEntity.restrictedAccessModel?.timeEnd != null
                ? [
              Timestamp.fromDate(formEntity.restrictedAccessModel!.timeEnd!)
            ]
                : null,
            editPermission: [formEntity.restrictedAccessModel?.isEdit ?? false],
            emails: formEntity.restrictedAccessModel?.selectedPersons
                ?.map((e) => e.id)
                .toList(),
            status: formEntity.restrictedAccessModel?.selectedPersons
                ?.map((e) => 'active')
                .toList(),
          ),
        );
        addFormPrivcy(formPrivacyModel, formModel.id, newFormModel);
      }
    }

    Future<void> editFormModel(
        FormEntity oldFormModel, FormEntity newFormModel) async
    {

      

      newFormModel.id = oldFormModel.id; // Ensure same ID

      // ✅ Use updateForm for editing
      final result = await formRepo.updateForm(newFormModel.toModel());

      result.fold(
            (failure) {
          
        },
            (_) {
          
        },
      );

      await getForms();
      
    }

    void onChangeTab(int value) {
      tabController.index = value;

      switch (value) {
        case 0:
          selectedTab = FormStatus.publish;
          shownFormModels = publishFormModels;
          break;
        case 1:
          selectedTab = FormStatus.drafts;
          shownFormModels = draftFormModels;
          break;
        case 2:
          selectedTab = FormStatus.requestedForms;
          shownFormModels = requestedFormModels;
          break;
        case 3:
          selectedTab = FormStatus.submissions;
          shownFormModels = submissionsFormModels;
          break;
        case 4:
          selectedTab = FormStatus.deleted;
          shownFormModels = deleteFormModels;
          break;
      }

      onChangeDateValue(null);
      onChangeFilterDropDownValue(null);

      // Bug report #24: each tab has its own sort options; drop a pick that
      // does not belong to the new tab.
      final List<String> tabOptions = value == 3
          ? FormSortOption.submissionValues
          : FormSortOption.values;
      if (!tabOptions.contains(selectedSortOption)) {
        activeSortOption = null;
        selectedSortOption = _defaultSortForTab();
      }

      // ✅ RE-APPLY SORTING AFTER TAB CHANGE
      sortForms();
    }

    void onMenuSelect(MenuEnum? value, {
      required BuildContext context,
      required FormEntity formModel,
    })
    {
      switch (value) {
        case MenuEnum.duplicate:
        // ✅ Check permission before allowing duplicate
          if (Get.find<MainCoreEmployeeController>().isHasPermission(
            module: Modules.formBuilder,
            section: FormPermissionsSections.formPermissions,
            permission: FormPermissions.duplicateForm,
          )) {
            popupDuplicateFormModel(formModel, context);
          } else {
          }
          return;

        case MenuEnum.edit:
          popupEditFormModel(context, formModel);
          return;

        case MenuEnum.convertToPDF:
        // ✅ Check permission before allowing convert to PDF
          if (Get.find<MainCoreEmployeeController>().isHasPermission(
            module: Modules.formBuilder,
            section: FormPermissionsSections.formPermissions,
            permission: FormPermissions.convertToPdf,
          )) {
            
            popupConvertPdf(formModel, context);
          } else {
          }
          return;

        case MenuEnum.delete:
          popupDeleteFormModel(formModel, context);
          return;

        // Only offered on the Deleted tab — see
        // `HomeGridItemView._menuItemsForTab`. `restoreForm` owns the whole
        // flow: confirm dialog, repo call, success dialog, then moving the form
        // back into the tab it was deleted from.
        case MenuEnum.restore:
          restoreForm(model: formModel, context: context);
          return;

        case null:
          return;
      }
    }

    void onGridViewItemClicked(FormEntity model, BuildContext context) {
      var isMobile = ContextExtension(context).isPhone;
      switch (selectedTab) {
        case FormStatus.publish:
        // ✅ Convert FormEntity to FormModel for FormDetailsScreen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FormDetailsScreen(model: model),
            ),
          );
          break;
        case FormStatus.drafts:
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => isMobile
                  ? CreateHeadFormScreen(formModel: model)
                  : CreatingFormTabletScreen(formModel: model),
            ),
          );
          break;
        case FormStatus.requestedForms:
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FormBuilderSubmissions.FormSubmissionsScreen(model: model,name : "yes"),
            ),
          );
          break;
        case FormStatus.submissions:
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FormBuilderSubmissions.FormSubmissionsScreen(model: model,name : "yes"),
            ),
          );
          break;
        case FormStatus.deleted:
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ContextExtension(context).isPhone
                  ? CreateHeadFormScreen(formModel: model)
                  : CreatingFormTabletScreen(formModel: model),
            ),
          );
          break;
      }
    }

    List<FormEntity> _getListFromIndex(int index) {
      if (index == 0) {
        return publishFormModels;
      } else if (index == 1) {
        return draftFormModels;
      } else if (index == 2) {
        return requestedFormModels;
      } else if (index == 3) {
        return submissionsFormModels;
      } else {
        return deleteFormModels;
      }
    }

    void onChangeFilterDropDownValue(String? value) {
      currentDropDownValue = value;
      _emitLoadedState();
    }

    void onChangeDateValue(String? value) {
      currentDate.text = value ?? '';
      _emitLoadedState();
    }

    void reset(BuildContext context) {
      Navigator.of(context).pop();
      shownFormModels = _getListFromIndex(tabController.index);
      onChangeDateValue(null);
      onChangeFilterDropDownValue(null);
      searchController.text = '';
      _emitLoadedState();
    }

    void setFilter(BuildContext context) {
      Navigator.of(context).pop();

      if (currentDropDownValue != null) {
        shownFormModels =
            _filterByAccessManagement(currentDropDownValue, tabController.index);

        if (searchController.text.isNotEmpty) {
          shownFormModels = shownFormModels
              .where((element) =>
              element.getTitle.toLowerCase().contains(searchController.text.toLowerCase()))
              .toList();
        }
      }

      if (currentDate.text.isNotEmpty) {
        _filterByDate(currentDate.text);
      }

      // ✅ RE-APPLY SORTING AFTER FILTER
      sortForms();
    }

    List<FormEntity> _filterByAccessManagement(
        String? accessManagement, int tabIndex)
    {
      return _getListFromIndex(tabIndex)
          .where((element) =>
      element.formHeadModel.accessManagement == accessManagement)
          .toList();
    }

    void _filterByDate(String date) {
      if (currentDropDownValue == null) {
        shownFormModels = _getListFromIndex(tabController.index);
        if (searchController.text.isNotEmpty) {
          onSearch(searchController.text);
        }
      }
      shownFormModels = shownFormModels
          .where((element) =>
      FormDateTimeHelper.formatDate(element.createDate) == date)
          .toList();
    }

    void onSearch(String value) {
      // Start fresh from the current tab
      shownFormModels = _getListFromIndex(tabController.index);

      // Apply filter if exists
      if (currentDropDownValue != null) {
        shownFormModels = _filterByAccessManagement(currentDropDownValue, tabController.index);
      }

      // Apply date filter if exists
      if (currentDate.text.isNotEmpty) {
        shownFormModels = shownFormModels
            .where((element) =>
        FormDateTimeHelper.formatDate(element.createDate) == currentDate.text)
            .toList();
      }

      // Apply search
      if (value.isNotEmpty) {
        shownFormModels = shownFormModels
            .where((element) =>
            element.getTitle.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }

      // ✅ RE-APPLY SORTING AFTER SEARCH
      sortForms();
    }

    void sortClick() {
      sortClicked = true;
      isSortAscending = isSortAscending == null ? true : !isSortAscending!;
      if (isSortAscending!) {
        shownFormModels.sort(
                (a, b) => a.formHeadModel.title.compareTo(b.formHeadModel.title));
      } else {
        shownFormModels.sort(
                (a, b) => b.formHeadModel.title.compareTo(a.formHeadModel.title));
      }
      _emitLoadedState();
    }

    int _stateRevision = 0;

    void _emitLoadedState() {
      emit(HomeLoaded(
        revision: ++_stateRevision,
        publishForms: publishFormModels,
        draftForms: draftFormModels,
        deletedForms: deleteFormModels,
        requestedForms: requestedFormModels,
        submissionForms: submissionsFormModels,
        // A copy, so a later in-place sort cannot rewrite this state too.
        shownForms: List<FormEntity>.of(shownFormModels),
        selectedTab: selectedTab,
        currentDropDownValue: currentDropDownValue,  // ✅ ADD THIS
        currentDateValue: currentDate.text.isEmpty ? null : currentDate.text,  // ✅ ADD THIS
      ));
    }

    void dispose() {
      tabController.dispose();
      currentDate.dispose();
      searchController.dispose();
    }
  }