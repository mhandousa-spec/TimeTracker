import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/repo/response_repo_impl.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/data/repository/home_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/repository/result_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/data/repository/group_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/data/repository/share_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/remote_data_source/form_data_source.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/repo/form_repo_impl.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/data_source/response_data_source.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/upload_media_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f5_submissions/presentation/controller/submission_cubit.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f3_form_details/presentation/ui/pages/form_details_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/ui/pages/home_screen.dart';
import 'package:knowticed_plus/core/helper/form_builder/form_navigator_service.dart';

// ✅ Import your actual screens
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/create_form_data_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/ui/pages/fill_out_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/result_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f5_submissions/presentation/ui/pages/submissions_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/pages/share_screen.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class FormResponsivePageLayout extends StatefulWidget {
  const FormResponsivePageLayout({super.key});

  /// ADDED 26/9/2026 (form bug report #25). Set by the Home "Forms
  /// Submission" card before it opens this module; consumed (and cleared) on
  /// the next build, which then opens that form's Results page inside the
  /// module so the Form Builder's own providers are available.
  static FormEntity? pendingResultForm;

  @override
  State<FormResponsivePageLayout> createState() => _FormResponsivePageLayoutState();
}

class _FormResponsivePageLayoutState extends State<FormResponsivePageLayout> {
  final _formNavigatorService = FormBuilderNavigatorService();

  // A navigator key UNIQUE to this page mount.
  //
  // The shared singleton key on FormBuilderNavigatorService was attached to
  // the Navigator below, so re-entering Form Builder (or a page transition
  // that briefly keeps the old page mounted) put the SAME GlobalKey on two
  // live Navigators and crashed with
  // "'_elements.contains(element)': is not true". A fresh key per State means
  // two mounts can never collide; the service is pointed at this one in
  // initState so its navigateTo/pop helpers still target the visible navigator.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _formNavigatorService.bindNavigatorKey(_navigatorKey);
  }

  @override
  Widget build(BuildContext context) {

    // Initialize GetX dependencies.
    //
    // MainCoreDepartmentCubit is created once in main.dart and registered both
    // with Get and with BlocProvider.value, so it is normally already present.
    // If it somehow is not, adopt the instance from the widget tree rather than
    // constructing a new one: the cubit fetches every department from Firestore
    // in its constructor (autoLoad), so a second instance would duplicate that
    // read and then drift out of sync with the one the rest of the app uses.
    if (!Get.isRegistered<MainCoreDepartmentCubit>()) {
      Get.put(context.read<MainCoreDepartmentCubit>());
    }
    if (!Get.isRegistered<MainCoreEmployeeController>()) {
      Get.put(MainCoreEmployeeController());
    }
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<CreateFormHeadCubit>(
          create: (context) => CreateFormHeadCubit(),
          lazy: false,
        ),
        BlocProvider<CreateFormDataCubit>(
          create: (context) {
            final mainCoreEmployeeController = Get.find<MainCoreEmployeeController>();
            final addDepartmentController = Get.find<MainCoreDepartmentCubit>();
            return CreateFormDataCubit(
              mainCoreEmployeeController: mainCoreEmployeeController,
              addDepartmentController: addDepartmentController,
              createFormHeadCubit: context.read<CreateFormHeadCubit>(),
            );
          },
          lazy: false,
        ),
        BlocProvider<HomeCubit>(
          create: (context) {
            final mainCoreEmployeeController = Get.find<MainCoreEmployeeController>();
            return HomeCubit(
              homeRepository: HomeRepository(),
              formRepo: FormRepoImpl(formDataSource: FormDataSource()),
              responseRepo: ResponseRepoImpl(responseDataSource: ResponseDataSource()),
              mainCoreEmployeeController: mainCoreEmployeeController,
            );
          },
          lazy: false,
        ),
        BlocProvider<FormSubmissionsCubit>(
          create: (context) => FormSubmissionsCubit(
            responseRepo: ResponseRepoImpl(responseDataSource: ResponseDataSource()),
          ),
          lazy: true,
        ),
        BlocProvider<FillOutCubit>(
          create: (context) => FillOutCubit(),
          lazy: true,
        ),
        BlocProvider<FormsGroupCubit>(
          create: (context) => FormsGroupCubit(groupRepository: GroupRepository()),
          lazy: true,
        ),
        BlocProvider<ShareCubit>(
          create: (context) => ShareCubit(shareRepository: ShareRepository()),
          lazy: true,
        ),
        BlocProvider<ResultCubit>(
          create: (context) => ResultCubit(resultRepository: ResultRepository()),
          lazy: true,
        ),
        BlocProvider<UploadMediaCubit>(
          create: (context) => UploadMediaCubit(resultCubit: context.read<ResultCubit>()),
          lazy: true,
        ),
        BlocProvider<PdfCubit>(
          create: (context) => PdfCubit(),
          lazy: true,
        ),
      ],
      child: Builder(builder: (providerContext) {
        _consumePendingResult(providerContext);
        return _FormNavigatorWidget(
          navigatorKey: _navigatorKey,
        );
      }),
    );
  }

  /// Opens [FormResponsivePageLayout.pendingResultForm]'s Results page once.
  void _consumePendingResult(BuildContext providerContext) {
    final FormEntity? form = FormResponsivePageLayout.pendingResultForm;
    if (form == null) return;
    FormResponsivePageLayout.pendingResultForm = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final NavigatorState? nested = _navigatorKey.currentState;
      if (nested != null) {
        // Tablet / desktop: the module's own Navigator, inside the shell.
        nested.pushNamed('/resultScreen', arguments: form);
        return;
      }
      // Phone: no nested Navigator, so carry the cubits the page reads.
      Navigator.of(providerContext).push(MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<ResultCubit>.value(
                value: providerContext.read<ResultCubit>()),
            BlocProvider<UploadMediaCubit>.value(
                value: providerContext.read<UploadMediaCubit>()),
          ],
          child: ResultScreen(form: form),
        ),
      ));
    });
  }
}

// ✅ Separated widget to fix framework assertion error
class _FormNavigatorWidget extends StatelessWidget {
  /// Owned by the parent State (unique per mount) rather than pulled from the
  /// singleton service, so this Navigator's key can never clash with another
  /// live form-builder Navigator.
  final GlobalKey<NavigatorState> navigatorKey;

  const _FormNavigatorWidget({
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    if (isTablet) {
      return Navigator(
        key: navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {

          switch (settings.name) {
          // ==================== HOME ====================
            case '/':
            case null:
              
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => FormBuilderHomeScreen(),
              );

          // ==================== FORM DETAILS ====================
            case '/FormDetailsScreen':
              
              final formEntity = settings.arguments as FormEntity;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => FormDetailsScreen(model: formEntity),
              );

          // ==================== CREATE/EDIT FORM ====================
            case 'creatingFormTablet':
              
              final formModel = settings.arguments as FormEntity?;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => CreateFormDataScreen(formModel: formModel),
              );

          // ==================== FILL OUT FORM ====================
            case '/FillOutScreen':
              
              final formEntity = settings.arguments as FormEntity;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => FillOutScreen(formModel: formEntity),
              );

          // ==================== RESULTS ====================
            case '/resultScreen':
              
              final formEntity = settings.arguments as FormEntity;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => ResultScreen(form: formEntity),
              );

          // ==================== SUBMISSIONS ====================
            case '/SubmissionsScreen':
              
              final formEntity = settings.arguments as FormEntity;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => FormSubmissionsScreen(model: formEntity, name: "yes"),
              );

          // ==================== SHARE ====================
            case '/shareScreen':
              
              final formEntity = settings.arguments as FormEntity;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => FormShareScreen(form: formEntity),
              );

          // ==================== UNKNOWN ROUTE ====================
            default:
              
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(S.of(context).error),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: AppColors.red),
                        SizedBox(height: 16),
                        Text(
                          S.of(context).routeNotFound,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('${settings.name}'),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(S.of(context).goBack),
                        ),
                      ],
                    ),
                  ),
                ),
              );
          }
        },
      );
    } else {
      // Mobile view - direct widget
      return FormBuilderHomeScreen();
    }
  }
}