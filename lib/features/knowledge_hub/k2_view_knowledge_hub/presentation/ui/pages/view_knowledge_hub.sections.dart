part of './view_knowledge_hub.dart';
/// Module: knowledge_hub / presentation / s2_view_knowledge_hub/view_knowledge_hub.sections.dart

/// View state + builder/init helpers for [ViewKnowledgeHub], split out of
/// the page to keep each file under the 800-LOC limit (§7).
mixin _ViewKnowledgeHubSections on State<ViewKnowledgeHub> {
  int selectedIndex = 0;
  int innerIndex = 0;
  final TextEditingController searchController = TextEditingController();
  bool _isEmployeeDataLoaded = false;
  List<DepartmentModelPro> _cachedDepartments = [];

  // ✅ ADD Animation Controllers
  late AnimationController _gridAnimationController;
  List<Animation<Offset>> _slideAnimations = [];
  List<Animation<double>> _fadeAnimations = [];
  bool _animationsCreated = false;

  KnowledgeHubFirebaseServices knowledgeHubFirebaseServices =
  KnowledgeHubFirebaseServices();

// ✅ CREATE HORIZONTAL STAGGERED ANIMATIONS
  void _createSlideAnimations(int itemCount) {
    _slideAnimations.clear();
    _fadeAnimations.clear();

    for (int i = 0; i < itemCount; i++) {
      // Stagger delay: 40ms between each item (adjusted for 1 second total)
      final delay = i * 0.04;

      // ✅ HORIZONTAL Slide animation from LEFT
      final slideAnimation = Tween<Offset>(
        begin: const Offset(-0.3, 0.0), // ✅ Changed to horizontal (left to right)
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delay.clamp(0.0, 0.6), // Start delay
            (delay + 0.4).clamp(0.0, 1.0), // End delay
            curve: Curves.easeOutCubic,
          ),
        ),
      );

      // Fade animation
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delay.clamp(0.0, 0.6),
            (delay + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeIn,
          ),
        ),
      );

      _slideAnimations.add(slideAnimation);
      _fadeAnimations.add(fadeAnimation);
    }

    _animationsCreated = true;
  }

  // ✅ PLAY ANIMATION
  void _playGridAnimation() {
    if (_gridAnimationController.isAnimating) return;
    _gridAnimationController.forward(from: 0.0);
  }

  String getFileIcon(String extension) {
    final ext = extension.toLowerCase().trim();

    switch (ext) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ppt_attachment_icon.svg';
      case 'doc':
        return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
      case 'docx':
        return 'assets/icons_assets/knowledge_hub_assets/docx_icon.svg';
      case 'xls':
      case 'csv':
      case 'xlsx':
        return 'assets/icons_assets/knowledge_hub_assets/xls_icon.svg';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
      default:
        return 'assets/icons_assets/knowledge_hub_assets/view_icon.svg';
    }
  }

  void _initializeData() async {
    try {
      final cubit = context.read<CreateKnowledgeCubit>();

      // Add listener to track state changes
      final subscription = cubit.stream.listen((state) {
        if (state is FetchingDepartmentSuccessState) {
          if (mounted) {
            setState(() {
              _cachedDepartments = state.departmentList;
            });
          }
        }
      });

      // ✅ STEP 1: Fetch departments FIRST
      await cubit.fetchAllDepartments();

      if (cubit.allDepartments.isNotEmpty && mounted) {
        setState(() {
          _cachedDepartments = cubit.allDepartments;
        });
      }

      // ✅ STEP 2: Get current user info and map department ID to name
      try {
        final employeeController = Get.find<MainCoreEmployeeController>();

        if (employeeController.employeeEntity != null) {
          final employee = employeeController.employeeEntity!;

          String? userDepartmentId = employee.departmentId;
          String? userEmail = employee.email;

          String? userDepartmentName;
          if (userDepartmentId != null && cubit.allDepartments.isNotEmpty) {
            try {
              final department = cubit.allDepartments.firstWhere(
                    (dept) => dept.departmentID == userDepartmentId,
                orElse: () => DepartmentModelPro(),
              );

              userDepartmentName = department.departmentName;
            } catch (e) {
              log('Could not map department ID to name: $e', name: 'INIT_DATA');
            }
          }

          cubit.setCurrentUser(
            department: userDepartmentName,
            email: userEmail,
          );
        }
      } catch (e) {
        log('Error setting user info: $e', name: 'INIT_DATA');
      }

      // ✅ STEP 3: Now fetch knowledge with proper user department set
      await cubit.fetchAllKnowledge();

      cubit.chooseIndex(0);

      await Future.delayed(Duration(milliseconds: 100));

      if (cubit.filteredKnowledge.isNotEmpty &&
          cubit.state is! FetchingKnowledgeSuccessState) {
        cubit.emit(FetchingKnowledgeSuccessState(cubit.filteredKnowledge));
      }
    } catch (e, stackTrace) {
      log('Error in _initializeData: $e',
          name: 'INIT_DATA', error: e, stackTrace: stackTrace);
    }
  }

  void _initializeEmployeeController() {
    try {
      final employeeController = Get.find<MainCoreEmployeeController>();

      if (employeeController.employeeEntity != null ||
          employeeController.mapOfEmployeesWithEmailKey.isNotEmpty) {
        _isEmployeeDataLoaded = true;

        if (employeeController.employeeEntity == null &&
            employeeController.mapOfEmployeesWithEmailKey.isNotEmpty) {
          _findCurrentEmployeeInMap(employeeController);
        }
      } else {
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            employeeController.getAllNewEmployees().then((_) {
              if (mounted) {
                setState(() {
                  _isEmployeeDataLoaded = employeeController.employeeEntity !=
                      null ||
                      employeeController.mapOfEmployeesWithEmailKey.isNotEmpty;
                });
              }
            });
          }
        });
      }
    } catch (e) {
      log('Error initializing employee controller: $e', name: 'INIT_EMPLOYEE');
    }
  }

  Widget _buildEmployeeDataWrapper({required Widget child}) {
    return GetBuilder<MainCoreEmployeeController>(
      id: 'employee_data',
      builder: (employeeController) {
        bool hasEmployeeData = employeeController.employeeEntity != null ||
            employeeController.mapOfEmployeesWithEmailKey.isNotEmpty;

        if (!hasEmployeeData) {
          Future.microtask(() {
            try {
              employeeController.getAllNewEmployees().then((employees) {
                if (employees != null && employees.isNotEmpty) {
                  if (employeeController.employeeEntity == null) {
                    _setCurrentEmployeeManually(employeeController, employees);
                  }
                }
              });
            } catch (e) {
              log('Error fetching employees',
                  name: 'EMPLOYEE_WRAPPER', error: e);
            }
          });

          return Column(
            children: [
              Container(
                color: AppColors.orange.withOpacity(0.2),
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppColors.orange, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Loading employee data...',
                        style: TextStyle(
                            fontSize: 12.sp, color: AppColors.orange),
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          );
        }

        if (employeeController.employeeEntity != null) {
          final employee = employeeController.employeeEntity!;

          if (ConstantVar.emailUser.isEmpty && employee.email != null) {
            ConstantVar.emailUser = employee.email!;
          }
        } else if (employeeController.mapOfEmployeesWithEmailKey.isNotEmpty) {
          _findCurrentEmployeeInMap(employeeController);
        }

        return child;
      },
    );
  }

  void _setCurrentEmployeeManually(MainCoreEmployeeController controller,
      List<EmployeeEntityPro> employees) {
    List<String> possibleEmails = [
      "ahmed_sami_1901@bayanatz.com",
      "yousef_jamal_2508@bayanatz.com",
      "salem_saeed_0802@bayanatz.com",
      "omar_jamal_2101@bayanatz.com",
      "faisal_hussein_1912@bayanatz.com"
    ];

    for (String email in possibleEmails) {
      EmployeeEntityPro? employee = employees.firstWhere(
            (emp) => emp.email == email,
        orElse: () => EmployeeEntityPro(),
      );

      if (employee.email != null) {
        controller.setCurrentEmployeeByEmail(email);
        break;
      }
    }
  }

  Widget _buildDepartmentsWithCache() {
    return BlocBuilder<CreateKnowledgeCubit, CreateKnowledgeState>(
      builder: (context, state) {
        if (state is FetchingDepartmentLoadingState &&
            _cachedDepartments.isEmpty) {
          // CHANGED 22/9/2026 — this is the spinner that shows where the
          // department counters belong while they load, on the Knowledge Hub
          // home page. It was Material's bare default, unstyled and a
          // different shape from every other loader on the same screen.
          //
          // CHANGED 28/9/2026 (Knowledge Hub bug report p.15 — the spinner is
          // struck out): nothing is drawn here while the counters load. The
          // documents grid below already shows its own loader, and a second
          // spinner floating between the header buttons and the search bar
          // read as the page being stuck.
          return const SizedBox.shrink();
        }

        if (state is FetchingDepartmentErrorState &&
            _cachedDepartments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: AppColors.red),
                SizedBox(height: 16),
                Text('Error: ${state.error}'),
                ElevatedButton(
                  onPressed: _initializeData,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<DepartmentModelPro> departments = _cachedDepartments;
        if (state is FetchingDepartmentSuccessState) {
          departments = state.departmentList;
          _cachedDepartments = departments;
        }

        if (departments.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: Text(
                'No departments found',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          );
        }

        return departmentsListView(
          context,
          selectedIndex: selectedIndex,
          cubit: context.read<CreateKnowledgeCubit>(),
          departmentNames: departments,
        );
      },
    );
  }

  void _debugCubitState() {
    try {
      final cubit = context.read<CreateKnowledgeCubit>();
    } catch (e) {
      log('Error accessing cubit', name: 'DEBUG', error: e);
    }
  }

  void _findCurrentEmployeeInMap(MainCoreEmployeeController controller) {
    if (controller.mapOfEmployeesWithEmailKey.isNotEmpty) {
      String firstEmail = controller.mapOfEmployeesWithEmailKey.keys.first;

      controller.setCurrentEmployeeByEmail(firstEmail);

      if (ConstantVar.emailUser.isEmpty) {
        ConstantVar.emailUser = firstEmail;
      }
    }
  }

  void _handleStateChanges(BuildContext context, CreateKnowledgeState state) {
    if (state is ChangedIndexSuccessState) {
      setState(() {
        selectedIndex = state.index;
        // ✅ REPLAY ANIMATION WHEN INDEX CHANGES
        _animationsCreated = false;
        log('📍 Selected department index: $selectedIndex',
            name: 'STATE_CHANGE');
      });
    } else if (state is ChangedInnerIndexSuccessState) {
      setState(() {
        innerIndex = state.index;
        // ✅ REPLAY ANIMATION WHEN INNER INDEX CHANGES
        _animationsCreated = false;
        log('📍 Selected inner index: $innerIndex', name: 'STATE_CHANGE');
      });
    }
  }
}

class DocumentTypeHelper {
  static final Map<String, Map<String, String>> documentTypes = {
    'presentation': {
      'en': 'Presentation',
      'ar': 'عرض تقديمي',
    },
    'form': {
      'en': 'Form',
      'ar': 'نموذج',
    },
    'report': {
      'en': 'Report',
      'ar': 'تقرير',
    },
    'booklet': {
      'en': 'Booklet',
      'ar': 'كتيب',
    },
    'video_recording': {
      'en': 'Video Recording',
      'ar': 'تسجيل فيديو',
    },
    'letter': {
      'en': 'Letter',
      'ar': 'خطاب',
    },
    'mandate': {
      'en': 'Mandate',
      'ar': 'تفويض',
    },
    'policy': {
      'en': 'Policy',
      'ar': 'سياسة',
    },
    'frame_work': {
      'en': 'Frame Work',
      'ar': 'إطار عمل',
    },
    'workshop': {
      'en': 'Workshop',
      'ar': 'ورشة عمل',
    },
    'guidelines': {
      'en': 'Guidelines',
      'ar': 'إرشادات',
    },
    'other': {
      'en': 'Other',
      'ar': 'أخرى',
    },
  };

  static String getLocalizedType(String typeKey, bool isArabic) {
    final typeMap = documentTypes[typeKey.toLowerCase().replaceAll(' ', '_')];
    if (typeMap == null) {
      return typeKey;
    }
    return isArabic ? (typeMap['ar'] ?? typeKey) : (typeMap['en'] ?? typeKey);
  }

  static String? getTypeKey(String typeName) {
    for (var entry in documentTypes.entries) {
      if (entry.value['en']?.toLowerCase() == typeName.toLowerCase() ||
          entry.value['ar'] == typeName) {
        return entry.key;
      }
    }
    return null;
  }
}
