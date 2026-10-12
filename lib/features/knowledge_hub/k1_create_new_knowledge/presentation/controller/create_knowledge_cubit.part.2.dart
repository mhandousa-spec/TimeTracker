part of './create_knowledge_cubit.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 2 of CreateKnowledgeCubit (kept under 800 LOC, §7).
extension CreateKnowledgeCubitPart2 on CreateKnowledgeCubit {

  // ✅ FIXED: Handle 'All' in search as well
  Future<void> searchKnowledge(String query) async {
    try {
      searchQuery = query;
      emit(FetchingKnowledgeLoadingState());

      if (query.isEmpty) {
        // ✅ FIX: Check for both 'All' and 'الكل'
        if (selectedOwningDepartment == null ||
            selectedOwningDepartment == 'All' ||
            selectedOwningDepartment == 'الكل') {
          filteredKnowledge = List.from(allKnowledge);
        } else {
          filteredKnowledge = allKnowledge.where((knowledge) {
            String currentDept = knowledge.owningDepartment.first;
            return currentDept == selectedOwningDepartment;
          }).toList();
        }
      } else {
        _applySearch();
      }

      if (filteredKnowledge.isEmpty) {
        emit(FetchingKnowledgeEmptyState());
      } else {
        emit(FetchingKnowledgeSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in searchKnowledge: $e');
      emit(FetchingKnowledgeErrorState(e.toString()));
    }
  }


  // ✅ FIXED: Handle 'All' in _applySearch
  void _applySearch() {
    String lowerQuery = searchQuery.toLowerCase();

    // ✅ FIX: Check for both 'All' and 'الكل'
    List<CreateKnowledgeModel> searchBase =
    selectedOwningDepartment == null ||
        selectedOwningDepartment == 'All' ||
        selectedOwningDepartment == 'الكل'
        ? List.from(allKnowledge)
        : allKnowledge
        .where(
          (k) => k.owningDepartment.first == selectedOwningDepartment,
    )
        .toList();

    filteredKnowledge = searchBase.where((knowledge) {
      String nameEn = knowledge.nameEnglish.first.toLowerCase();
      String nameAr = knowledge.nameArabic.first.toLowerCase();
      String descEn = knowledge.descriptionEnglish.first.toLowerCase();
      String descAr = knowledge.descriptionArabic.first.toLowerCase();

      return nameEn.contains(lowerQuery) ||
          nameAr.contains(lowerQuery) ||
          descEn.contains(lowerQuery) ||
          descAr.contains(lowerQuery);
    }).toList();
  }


  String? _getCurrentUserEmail() {
    if (currentUserEmail != null && currentUserEmail!.isNotEmpty) {
      return currentUserEmail;
    }

    try {
      if (Get.isRegistered<MainCoreEmployeeController>()) {
        final employeeController = Get.find<MainCoreEmployeeController>();
        if (employeeController.employeeEntity?.email != null) {
          currentUserEmail = employeeController.employeeEntity!.email!;
          log('✅ Email from MainCoreEmployeeController: $currentUserEmail');
          return currentUserEmail;
        }
      }
    } catch (e) {
      log('⚠️ Error accessing MainCoreEmployeeController: $e');
    }

    if (ConstantVar.emailUser.isNotEmpty) {
      currentUserEmail = ConstantVar.emailUser;
      log('✅ Email from ConstantVar: $currentUserEmail');
      return currentUserEmail;
    }

    log('⚠️ No user email found');
    return null;
  }


  Future<void> applyFilters({
    String? documentType,
    String? owningDepartment,
    String? owningStatus,
    // ADDED 28/8/2026 — publish-date range. Both optional and independent:
    // pass only `publishFrom` for "published on or after", only `publishTo`
    // for "published on or before", both for a closed window, neither to leave
    // the date filter off. Callers pass DAYS (time 00:00); FILTER 4 below
    // normalises both ends so the range is inclusive of whole days.
    DateTime? publishFrom,
    DateTime? publishTo,
  }) async {
    try {
      emit(FetchingKnowledgeLoadingState());

      selectedDocumentType = documentType;
      selectedOwningDepartment = owningDepartment;
      selectedOwningStatus = owningStatus;
      selectedPublishFromDate = publishFrom;
      selectedPublishToDate = publishTo;

      // Start with all knowledge
      filteredKnowledge = List.from(allKnowledge);

      String? userEmail = _getCurrentUserEmail();

      log('═══════════════════════════════════════');
      log('🔍 [APPLY FILTERS] Starting');
      log('📊 Initial count: ${filteredKnowledge.length}');
      log('📌 Document Type: $documentType');
      log('📌 Department: $owningDepartment');
      log('📌 Owning Status: $owningStatus');
      log('📌 Publish From: $publishFrom');
      log('📌 Publish To: $publishTo');
      log('👤 User Email: $userEmail');
      log('═══════════════════════════════════════');

      // ✅ FILTER 1: Document Type
      if (documentType != null && documentType.isNotEmpty) {
        log('\n📄 [FILTER 1] Filtering by document type: "$documentType"');

        int beforeCount = filteredKnowledge.length;

        filteredKnowledge = filteredKnowledge.where((knowledge) {
          if (knowledge.knowledgeDocumentType.isEmpty) {
            return false;
          }

          String storedType = knowledge.knowledgeDocumentType.first.trim().toLowerCase();
          String filterType = documentType.trim().toLowerCase();

          // Direct match
          bool matches = storedType == filterType;

          if (matches) {
            log('   ✅ MATCH: "${knowledge.nameEnglish.first}" - Type: "$storedType"');
          }

          return matches;
        }).toList();

        log('📊 [FILTER 1] Before: $beforeCount, After: ${filteredKnowledge.length}');

        if (filteredKnowledge.isEmpty) {
          log('⚠️ [FILTER 1] No documents match type "$documentType"');
          log('⚠️ [FILTER 1] Available types in data:');
          Set<String> availableTypes = {};
          for (var knowledge in allKnowledge) {
            if (knowledge.knowledgeDocumentType.isNotEmpty) {
              availableTypes.add(knowledge.knowledgeDocumentType.first);
            }
          }
          log('   Available: ${availableTypes.join(", ")}');
        }
      }

      // ✅ FILTER 2: Department
      if (owningDepartment != null &&
          owningDepartment.isNotEmpty &&
          owningDepartment != 'All' &&
          owningDepartment != 'الكل') {

        log('\n🏢 [FILTER 2] Filtering by department: "$owningDepartment"');

        int beforeCount = filteredKnowledge.length;

        filteredKnowledge = filteredKnowledge.where((knowledge) {
          if (knowledge.owningDepartment.isEmpty) {
            return false;
          }

          String knowledgeDept = knowledge.owningDepartment.first.trim().toLowerCase();
          String filterDept = owningDepartment.trim().toLowerCase();

          bool matches = knowledgeDept == filterDept;

          if (matches) {
            log('   ✅ MATCH: "${knowledge.nameEnglish.first}" - Dept: "$knowledgeDept"');
          }

          return matches;
        }).toList();

        log('📊 [FILTER 2] Before: $beforeCount, After: ${filteredKnowledge.length}');

        if (filteredKnowledge.isEmpty) {
          log('⚠️ [FILTER 2] No documents match department "$owningDepartment"');
          log('⚠️ [FILTER 2] Available departments in data:');
          Set<String> availableDepts = {};
          for (var knowledge in allKnowledge) {
            if (knowledge.owningDepartment.isNotEmpty) {
              availableDepts.add(knowledge.owningDepartment.first);
            }
          }
          log('   Available: ${availableDepts.join(", ")}');
        }
      }

      // ✅ FILTER 3: Owning Status
      if (owningStatus != null &&
          owningStatus.isNotEmpty &&
          owningStatus != 'All' &&
          owningStatus != 'الكل') {

        log('\n👤 [FILTER 3] Filtering by owning status: "$owningStatus"');

        if (userEmail == null || userEmail.isEmpty) {
          log('⚠️ [FILTER 3] No user email - skipping owner/contributor filter');
        } else {
          int beforeCount = filteredKnowledge.length;
          String userEmailLower = userEmail.trim().toLowerCase();

          filteredKnowledge = filteredKnowledge.where((knowledge) {
            if (knowledge.createdByEmail.isEmpty) {
              return false;
            }

            String creatorEmail = knowledge.createdByEmail.first.trim().toLowerCase();

            bool matches = false;
            if (owningStatus == 'Owner') {
              matches = creatorEmail == userEmailLower;
              if (matches) {
                log('   ✅ OWNER: "${knowledge.nameEnglish.first}"');
              }
            } else if (owningStatus == 'Contributor') {
              matches = creatorEmail != userEmailLower;
              if (matches) {
                log('   ✅ CONTRIBUTOR: "${knowledge.nameEnglish.first}"');
              }
            }

            return matches;
          }).toList();

          log('📊 [FILTER 3] Before: $beforeCount, After: ${filteredKnowledge.length}');
        }
      }

      // ✅ FILTER 4: Publish date range  (ADDED 28/8/2026)
      //
      // Runs on CreateKnowledgeModel.publishedAt — the timestamp paired with
      // the FIRST `published` entry in the status history, which is the same
      // date the cards and the details page show.
      //
      // Both ends are inclusive and are normalised to whole days, because the
      // picker hands back a day at 00:00 while a real publish timestamp carries
      // a time of day. Without widening `to` to 23:59:59.999, a document
      // published at 14:30 on the very day the user picked as the end of the
      // range would fall outside it — the single most confusing way an
      // inclusive-looking range can behave.
      //
      // A document that was never published has no date to compare, so it is
      // excluded as soon as either end is set.
      if (publishFrom != null || publishTo != null) {
        log('\n📅 [FILTER 4] Filtering by publish date: '
            '${publishFrom ?? "—"} → ${publishTo ?? "—"}');

        final int beforeCount = filteredKnowledge.length;

        final DateTime? fromBound = publishFrom == null
            ? null
            : DateTime(publishFrom.year, publishFrom.month, publishFrom.day);

        final DateTime? toBound = publishTo == null
            ? null
            : DateTime(
                publishTo.year,
                publishTo.month,
                publishTo.day,
                23,
                59,
                59,
                999,
              );

        filteredKnowledge = filteredKnowledge.where((knowledge) {
          final DateTime? published = knowledge.publishedAt;
          if (published == null) return false;

          if (fromBound != null && published.isBefore(fromBound)) return false;
          if (toBound != null && published.isAfter(toBound)) return false;

          return true;
        }).toList();

        log('📊 [FILTER 4] Before: $beforeCount, After: ${filteredKnowledge.length}');
      }

      // ✅ FILTER 5: Apply search if exists
      if (searchQuery.isNotEmpty) {
        log('\n🔍 [FILTER 5] Applying search: "$searchQuery"');
        int beforeCount = filteredKnowledge.length;
        _applySearch();
        log('📊 [FILTER 5] Before: $beforeCount, After: ${filteredKnowledge.length}');
      }

      log('\n═══════════════════════════════════════');
      log('✅ [APPLY FILTERS] COMPLETE');
      log('📊 Final count: ${filteredKnowledge.length}');
      log('═══════════════════════════════════════\n');

      if (filteredKnowledge.isEmpty) {
        emit(FetchingKnowledgeEmptyState());
      } else {
        emit(FetchingKnowledgeSuccessState(filteredKnowledge));
      }
    } catch (e, stackTrace) {
      log('❌ [APPLY FILTERS] Error: $e');
      log('❌ Stack trace: $stackTrace');
      emit(FetchingKnowledgeErrorState(e.toString()));
    }
  }


  Future<void> resetFilters() async {
    try {
      selectedDocumentType = null;
      selectedOwningDepartment = null;
      selectedOwningStatus = null;
      // ADDED 28/8/2026 — clear the publish-date range too, otherwise Reset
      // leaves the date window silently applied on the next applyFilters call
      // and the filter button stays highlighted with nothing visible behind it.
      selectedPublishFromDate = null;
      selectedPublishToDate = null;
      searchQuery = '';
      selectedDepartmentIndex = 0;
      selectedInnerIndex = 0;
      selectedInnerCategory = null;

      filteredKnowledge = List.from(allKnowledge);

      emit(ChangedIndexSuccessState(0));
      emit(ChangedInnerIndexSuccessState(0));

      if (filteredKnowledge.isEmpty) {
        emit(FetchingKnowledgeEmptyState());
      } else {
        emit(FetchingKnowledgeSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in resetFilters: $e');
      emit(FetchingKnowledgeErrorState(e.toString()));
    }
  }


  void chooseIndex(int index) {
    selectedDepartmentIndex = index;
    emit(ChangedIndexSuccessState(index));
  }




  Future<void> fetchAllDepartments() async {
    try {
      emit(FetchingDepartmentLoadingState());

      allDepartments = await _firebaseServices.fetchAllDepartments();
      log('Departments has been fetched successfully');

      emit(FetchingDepartmentSuccessState(allDepartments));
    } catch (e) {
      log('Error in fetchAllDepartments: $e');
      emit(FetchingDepartmentErrorState(e.toString()));
    }
  }


  void clearCurrentKnowledge() {
    currentKnowledgeDocument = null;
    emit(CreateKnowledgeInitial());
  }


  Future<void> fetchKnowledgeByKnowledgeId(String knowledgeId) async {
    try {
      emit(FetchingKnowledgeByIdLoadingState());

      final knowledge = await _firebaseServices.fetchKnowledgeByKnowledgeId(
        knowledgeId,
      );

      if (knowledge != null) {
        currentKnowledgeDocument = knowledge;
        emit(FetchingKnowledgeByIdSuccessState(knowledge));
        log(
          'Knowledge document fetched by knowledgeId successfully: ${knowledge.nameEnglish.first}',
        );
      } else {
        emit(FetchingKnowledgeByIdErrorState('Knowledge document not found'));
        log('Knowledge document with knowledgeId $knowledgeId not found');
      }
    } catch (e) {
      log('Error in fetchKnowledgeByKnowledgeId: $e');
      emit(FetchingKnowledgeByIdErrorState(e.toString()));
    }
  }


  Future<void> filterByInnerCategory(String category, int index) async {
    try {
      selectedInnerIndex = index;
      selectedInnerCategory = category;

      emit(ChangedInnerIndexSuccessState(index));
      emit(FetchingKnowledgeLoadingState());

      List<CreateKnowledgeModel> baseList;

      // Get base list (all or department-filtered)
      if (selectedOwningDepartment == null ||
          selectedOwningDepartment == 'All' ||
          selectedOwningDepartment == 'الكل') {
        baseList = List.from(allKnowledge);
      } else {
        baseList = allKnowledge.where((knowledge) {
          String currentDept = knowledge.owningDepartment.first;
          return currentDept == selectedOwningDepartment;
        }).toList();
      }

      // Apply category filter
      if (category == 'all') {
        filteredKnowledge = baseList;
      }
      else if (category == 'owner') {
        // ✅ Documents I created
        filteredKnowledge = baseList.where((knowledge) {
          if (knowledge.createdByEmail.isEmpty) return false;
          String createdBy = knowledge.createdByEmail.first.toLowerCase().trim();
          String userEmail = (currentUserEmail ?? '').toLowerCase().trim();
          return createdBy == userEmail;
        }).toList();
      }
      else if (category == 'contributor') {
        // ✅ FIXED: Documents I have access to but didn't create
        filteredKnowledge = baseList.where((knowledge) {
          if (knowledge.createdByEmail.isEmpty) return false;
          String createdBy = knowledge.createdByEmail.first.toLowerCase().trim();
          String userEmail = (currentUserEmail ?? '').toLowerCase().trim();
          return createdBy != userEmail; // ✅ NOT the owner = contributor
        }).toList();
      }

      // Apply search if exists
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // Emit results
      if (filteredKnowledge.isEmpty) {
        emit(FetchingKnowledgeEmptyState());
      } else {
        emit(FetchingKnowledgeSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in filterByInnerCategory: $e');
      emit(FetchingKnowledgeErrorState(e.toString()));
    }
  }


  void resetInnerFilter() {
    selectedInnerIndex = 0;
    selectedInnerCategory = null;
    emit(ChangedInnerIndexSuccessState(0));
  }

}
