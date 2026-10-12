/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: failure_authentication_type.dart
/// Purpose: Why an authentication attempt failed, and the message shown for it.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N32: `package:get` is gone. The messages
///          were selected with `Get.locale?.languageCode == 'ar'` — a banned
///          service locator, read from a *domain* enum. The language is a
///          parameter now, defaulting to `Intl.getCurrentLocale()`, which
///          `main.dart` already sets via `Intl.defaultLocale`.
///
/// REMAINING: §13 wants these strings in the .arb bundle, resolved with
/// `S.of(context)` in the widget. That means the repository returning the
/// *type* rather than a formatted string, and 12 new key pairs — a change to
/// the failure plumbing across 25 call sites, staged rather than done here.

import 'package:intl/intl.dart';

enum FailureAuthenticationType {
  wrongPassword,
  emailNotFound,
  notFound,
  subscriptionError,
  subscriptionExpired,
  beforActivationDate,
  demoCancelled,
  wrongActivationPassword,
  notFoundInCompanyDatabase,
  dontHavePermission,
  tooManyUsers,
  moduleUserLimitReached; // ✅ NEW

  /// The message for the active locale.
  ///
  /// Kept as a getter so the 25 existing call sites are unchanged.
  String get dialogBoxMessage => messageFor(Intl.getCurrentLocale());

  /// Function Name: [messageFor]
  ///
  /// Purpose: The message in [languageCode] — `ar` for Arabic, anything else
  ///          for English.
  String messageFor(String languageCode) {
    final bool isArabic =
        languageCode.toLowerCase().startsWith(_arabicLanguageCode);

    switch (this) {
      case FailureAuthenticationType.emailNotFound:
        return isArabic
            ? 'لم يتم العثور على حساب بهذا البريد الإلكتروني. يرجى التحقق من بريدك الإلكتروني والمحاولة مرة أخرى، أو الاتصال بالمسؤول إذا كنت تعتقد أن هذا خطأ.'
            : 'No account found with this email address. Please check your email and try again, or contact your administrator if you believe this is an error.';

      case FailureAuthenticationType.wrongPassword:
        return isArabic
            ? 'كلمة المرور التي أدخلتها غير صحيحة. يرجى التحقق من بيانات الاعتماد والمحاولة مرة أخرى. إذا نسيت كلمة المرور، يمكنك إعادة تعيينها باستخدام خيار "نسيت كلمة المرور".'
            : 'The password you entered is incorrect. Please verify your credentials and try again. If you have forgotten your password, you may reset it using the "Forgot Password" option.';

      case FailureAuthenticationType.demoCancelled:
        return isArabic
            ? 'تم إلغاء هذه النسخة التجريبية وتم إلغاء الوصول. للحصول على مزيد من المساعدة أو لطلب نسخة تجريبية جديدة، يرجى الاتصال بمسؤول النظام.'
            : 'This demo trial has been canceled and access has been revoked. For further assistance or to request a new demo, please contact your system administrator.';

      case FailureAuthenticationType.beforActivationDate:
        return isArabic
            ? 'الوصول إلى هذه النسخة التجريبية غير نشط بعد. سيتم منح الوصول بمجرد بدء الفترة التجريبية رسميًا. يرجى التحقق من وقت البدء المجدول.'
            : 'This demo access is not yet active. Access will be granted once the trial period officially begins. Please check the scheduled start time.';

      case FailureAuthenticationType.notFound:
        return isArabic
            ? 'مجموعة البريد الإلكتروني وكلمة المرور المقدمة لا تتوافق مع أي حساب نشط في نظامنا. يرجى إعادة التحقق من بيانات الاعتماد الخاصة بك.'
            : 'The provided email and password combination does not correspond to any active account in our system. Please recheck your credentials.';

      case FailureAuthenticationType.subscriptionError:
        return isArabic
            ? 'خطأ في الاشتراك. يرجى الاتصال بمسؤول النظام.'
            : 'Subscription Error. Please contact your system administrator.';

      case FailureAuthenticationType.subscriptionExpired:
        return isArabic
            ? 'انتهت هذه الفترة التجريبية ولم يعد الوصول متاحًا. لمتابعة استكشاف النظام، يرجى طلب نسخة تجريبية جديدة أو الاتصال بمسؤول النظام.'
            : 'This demo period has ended and access is no longer available. To continue exploring the system, please request a new trial or contact your system administrator.';

      case FailureAuthenticationType.wrongActivationPassword:
        return isArabic
            ? 'كلمة مرور التفعيل المؤقتة التي أدخلتها غير صحيحة. يرجى التحقق من كلمة المرور المرسلة إلى بريدك الإلكتروني والمحاولة مرة أخرى.'
            : 'The temporary activation password you entered is incorrect. Please check the password sent to your email and try again.';

      case FailureAuthenticationType.notFoundInCompanyDatabase:
        return isArabic
            ? 'حسابك موجود ولكنه غير مهيأ بشكل صحيح في قاعدة بيانات الشركة. يرجى الاتصال بمسؤول النظام.'
            : 'Your account exists but is not properly configured in the company database. Please contact your system administrator.';

      case FailureAuthenticationType.dontHavePermission:
        return isArabic
            ? 'ليس لديك إذن بالوصول إلى النظام الآن. يرجى الاتصال بالمسؤول لطلب الوصول.'
            : 'You do not have permission to access the system now. Please contact your administrator to request access.';

      case FailureAuthenticationType.tooManyUsers:
        return isArabic
            ? 'تم تقليل عدد المستخدمين النشطين. يرجى مراجعة وتحديث سجلات الموظفين في Active Directory لتعكس الحد الجديد.'
            : 'The number of active users has been reduced. Please review and update the employee records in the Active Directory to reflect the new limit.';

    // ✅ NEW
      case FailureAuthenticationType.moduleUserLimitReached:
        return isArabic
            ? 'تم الوصول للحد الأقصى لعدد المستخدمين في أحد الوحدات أو أكثر في هذا الدور. يرجى التواصل مع المسؤول.'
            : 'The user limit for one or more modules in this role has been reached. Please contact your administrator.';

      default:
        return isArabic
            ? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'
            : 'An unexpected error occurred. Please try again.';
    }
  }

  /// ✅ Get localized dialog title (supports Arabic and English)
  String get dialogBoxTitle => titleFor(Intl.getCurrentLocale());

  /// Function Name: [titleFor]
  ///
  /// Purpose: The dialog title in [languageCode] — `ar` for Arabic, anything
  ///          else for English. Mirrors [messageFor]; the title previously
  ///          read an `isArabic` that only existed as a local inside
  ///          [messageFor], which is what produced "Undefined name 'isArabic'".
  String titleFor(String languageCode) {
    final bool isArabic =
        languageCode.toLowerCase().startsWith(_arabicLanguageCode);

    switch (this) {
      case FailureAuthenticationType.emailNotFound:
        return isArabic
            ? 'البريد الإلكتروني غير موجود'
            : 'Email Not Found';

      case FailureAuthenticationType.wrongPassword:
        return isArabic
            ? 'كلمة مرور غير صحيحة'
            : 'Incorrect Password';

      case FailureAuthenticationType.demoCancelled:
        return isArabic
            ? 'تم إلغاء النسخة التجريبية'
            : 'Demo Trial Canceled';

      case FailureAuthenticationType.beforActivationDate:
        return isArabic
            ? 'محاولة الوصول قبل تفعيل النسخة التجريبية'
            : 'Access Attempt Before Demo Activation';

      case FailureAuthenticationType.notFound:
        return isArabic
            ? 'بيانات الدخول غير معترف بها'
            : 'Login Credentials Unrecognized';

      case FailureAuthenticationType.subscriptionError:
        return isArabic
            ? 'خطأ في الاشتراك'
            : 'Subscription Error';

      case FailureAuthenticationType.subscriptionExpired:
        return isArabic
            ? 'انتهت صلاحية النسخة التجريبية'
            : 'Demo Trial Expired';

      case FailureAuthenticationType.wrongActivationPassword:
        return isArabic
            ? 'كلمة مرور تفعيل غير صحيحة'
            : 'Incorrect Activation Password';

      case FailureAuthenticationType.notFoundInCompanyDatabase:
        return isArabic
            ? 'خطأ في إعدادات الحساب'
            : 'Account Configuration Error';

      case FailureAuthenticationType.dontHavePermission:
        return isArabic
            ? 'تم رفض الوصول'
            : 'Access Denied';

      case FailureAuthenticationType.tooManyUsers:
        return isArabic
            ? 'مطلوب تعديل حد المستخدمين'
            : 'User Limit Adjustment Required';

    // ✅ NEW
      case FailureAuthenticationType.moduleUserLimitReached:
        return isArabic
            ? 'تم الوصول للحد الأقصى'
            : 'Module User Limit Reached';

      default:
        return isArabic
            ? 'خطأ'
            : 'Error';
    }
  }

  static const String _arabicLanguageCode = 'ar';
}
