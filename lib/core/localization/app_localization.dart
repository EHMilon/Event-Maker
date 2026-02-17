import 'package:get/get.dart';

/// Supported languages in the application
enum SupportedLanguage {
  english('en', 'English', '🇺🇸'),
  arabic('ar', 'العربية', '🇸🇦');

  final String code;
  final String name;
  final String flag;

  const SupportedLanguage(this.code, this.name, this.flag);
}

/// Application localization class extending GetX Translations
///
/// Provides translations for all supported languages (English and Arabic)
/// English is the default and fallback language
class AppLocalization extends Translations {
  // Default language is English
  static const String defaultLanguage = 'en';
  static const String fallbackLanguage = 'en';

  @override
  Map<String, Map<String, String>> get keys => {'en': english, 'ar': arabic};

  // English translations
  static const Map<String, String> english = {
    // App
    'appName': 'Event Maker',

    // Language Selection
    'selectLanguage': 'Select Language',
    'selectLanguageSubtitle': 'Choose your preferred language',
    'english': 'English',
    'arabic': 'العربية',
    'continueText': 'Continue',

    // Onboarding
    'skip': 'Skip',
    'next': 'Next',
    'onboardingTitle1': 'Grab all events now only in your hands',
    'onboardingSubtitle1':
        'Event Maker is here to help you to find the best events based on your interests.',
    'onboardingTitle2': 'Find best events near you',
    'onboardingSubtitle2':
        'By enabling your location, you help us provide recommendations for events around you.',
    'onboardingTitle3': "Let's go to your favorite event now",
    'onboardingSubtitle3':
        'Event Maker is here to help you to find the best events based on your interests.',

    // User Type
    'selectUserType': 'Select a user type',
    'joinNowToStreamline': 'Join now to streamline you',
    'asCustomer': 'As a Customer',
    'asServiceProvider': 'As a Service Provider',

    // Auth - Login
    'login': 'Log In',
    'welcomeBack': 'Hey! welcome back to app',
    'email': 'Email',
    'password': 'Password',
    'rememberMe': 'Remember me',
    'forgotPassword': 'Forgot password?',
    'dontHaveAccount': "Don't have an account? ",
    'signUp': 'Sign Up',
    'emailPlaceholder': 'eg: mail@gmail.com',
    'passwordPlaceholder': 'Enter your password',

    // Auth - Signup
    'registerNewAccount': 'Register New Account',
    'fullName': 'Full Name',
    'fullNamePlaceholder': 'John Doe',
    'createAccount': 'Create Account',
    'alreadyHaveAccount': 'Already have an account? ',
    'termsAndPrivacy':
        'By using the Event Maker app you agree to our Terms of Use and Privacy-Notice',
    'termsOfUse': 'Terms of Use',
    'privacyNotice': 'Privacy-Notice',
    'and': ' and ',

    // Auth - Forgot Password
    'resetPassword': 'Reset password',
    'resetPasswordSubtitle': 'To reset password enter your email',
    'verifyEmail': 'Verify Email',
    'verifyEmailSubtitle': 'we sent a 4 code to your email',
    'didntGetOtp': "Didn't got OTP? ",
    'resend': 'Resend',
    'verify': 'Verify',

    // Auth - Reset Password
    'newPassword': 'New password',
    'pleaseResetPassword': 'Please reset password',
    'confirmPassword': 'Rewrite password',
    'confirm': 'Confirm',
    'congratulations': 'Congratulations !',
    'resetSuccessful':
        'Password Reset successful! You\'ll be redirected to the login screen now',

    // Auth - Signup Step Two
    'phoneNumber': 'Phone Number',
    'nationality': 'Nationality',
    'selectNationality': 'Select Nationality',

    // Auth - Provider Details
    'serviceType': 'Service Type',
    'selectServiceType': 'Select Service Type',
    'role': 'Role',
    'selectRole': 'Select Role',
    'serviceCategory': 'Service Category',
    'selectServiceCategory': 'Select Service Category',

    // Get Started
    'getStarted': 'Get Started',

    // Validation Messages
    'pleaseEnterEmail': 'Please enter your email',
    'pleaseEnterValidEmail': 'Please enter a valid email',
    'pleaseEnterPassword': 'Please enter your password',
    'passwordMinLength': 'Password must be at least 6 characters',
    'pleaseEnterName': 'Please enter your name',
    'pleaseEnterPhone': 'Please enter your phone number',
    'pleaseSelectUserType': 'Please select a user type',
    'pleaseSelectAllFields': 'Please select all fields',
    'pleaseAcceptTerms': 'Please accept the terms and conditions',

    // Error Messages
    'error': 'Error',
    'success': 'Success',
    'loading': 'Loading...',
    'noInternet': 'No Internet Connection',
    'serverError': 'Server Error. Please try again later.',
    'somethingWentWrong': 'Something went wrong. Please try again.',
    'loginFailed': 'Login failed. Please check your credentials.',
    'signupFailed': 'Sign up failed. Please try again.',
    'otpSent': 'OTP sent successfully',
    'otpFailed': 'Failed to send OTP',
    'passwordResetSuccess': 'Password reset successful',
    'passwordResetFailed': 'Failed to reset password',

    // Profile & Settings
    'profile': 'Profile',
    'settings': 'Settings',
    'logout': 'Logout',
    'logoutConfirmation': 'Are you sure you want to logout?',

    // Navigation
    'home': 'Home',
    'bookings': 'Bookings',
    'notifications': 'Notifications',
    'messages': 'Messages',

    // Service Provider Home
    'goodMorning': 'Good Morning',
    'analytics': 'Analytics',
    'basedOnLast30Days': 'Based on last 30 days',
    'totalEarnings': 'Total Earnings',
    'totalRequests': 'Total Requests',
    'completed': 'Completed',
    'pending': 'Pending',
    'totalBalance': 'Total Balance',
    'addService': 'Add Service',
    'schedule': 'Schedule',
    'earnings': 'Earnings',
    'documents': 'Documents',
    'activeOrders': 'Active Orders',
    'seeAll': 'See All',
    'fromLastMonth': 'from last month',
    'noActiveOrdersFound': 'No active orders found',
    'retry': 'Retry',

    // Service Provider Requests
    'requests': 'Requests',
    'noRequestsYet': 'No requests yet',
    'accept': 'Accept',
    'reject': 'Reject',
    'cancel': 'Cancel',
    'done': 'Done',
    'requestDetails': 'Request Details',
    'confirmAcceptTitle': 'Confirm Request Acceptance',
    'confirmAcceptSubtitle': 'Are you sure you want to accept this request?',
    'confirmRejectTitle': 'Confirm Request Rejection',
    'confirmRejectSubtitle': 'Are you sure you want to reject this request?',
    'acceptSuccessTitle': 'Request Accepted Successfully',
    'acceptSuccessSubtitle':
        'You have successfully accepted the request. The client will be notified shortly.',
    'rejectSuccessTitle': 'Request Rejected Successfully',
    'rejectSuccessSubtitle': 'You have successfully rejected the request.',
  };

  // Arabic translations
  static const Map<String, String> arabic = {
    // App
    'appName': 'صانع الفعاليات',

    // Language Selection
    'selectLanguage': 'اختر اللغة',
    'selectLanguageSubtitle': 'اختر لغتك المفضلة',
    'english': 'English',
    'arabic': 'العربية',
    'continueText': 'متابعة',

    // Onboarding
    'skip': 'تخطي',
    'next': 'التالي',
    'onboardingTitle1': 'احصل على جميع الفعاليات الآن بين يديك',
    'onboardingSubtitle1':
        'صانع الفعاليات هنا لمساعدتك في العثور على أفضل الفعاليات بناءً على اهتماماتك.',
    'onboardingTitle2': 'ابحث عن أفضل الفعاليات بالقرب منك',
    'onboardingSubtitle2':
        'من خلال تمكين موقعك، تساعدنا في تقديم توصيات للفعاليات من حولك.',
    'onboardingTitle3': 'لنذهب إلى فعاليتك المفضلة الآن',
    'onboardingSubtitle3':
        'صانع الفعاليات هنا لمساعدتك في العثور على أفضل الفعاليات بناءً على اهتماماتك.',

    // User Type
    'selectUserType': 'اختر نوع المستخدم',
    'joinNowToStreamline': 'انضم الآن لتبسيط أمورك',
    'asCustomer': 'كعميل',
    'asServiceProvider': 'كمقدم خدمة',

    // Auth - Login
    'login': 'تسجيل الدخول',
    'welcomeBack': 'مرحباً! مرحباً بعودتك للتطبيق',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'rememberMe': 'تذكرني',
    'forgotPassword': 'نسيت كلمة المرور؟',
    'dontHaveAccount': 'ليس لديك حساب؟ ',
    'signUp': 'إنشاء حساب',
    'emailPlaceholder': 'مثال: mail@gmail.com',
    'passwordPlaceholder': 'أدخل كلمة المرور',

    // Auth - Signup
    'registerNewAccount': 'تسجيل حساب جديد',
    'fullName': 'الاسم الكامل',
    'fullNamePlaceholder': 'محمد أحمد',
    'createAccount': 'إنشاء حساب',
    'alreadyHaveAccount': 'لديك حساب بالفعل؟ ',
    'termsAndPrivacy':
        'باستخدام تطبيق صانع الفعاليات فإنك توافق على شروط الاستخدام وإشعار الخصوصية',
    'termsOfUse': 'شروط الاستخدام',
    'privacyNotice': 'إشعار الخصوصية',
    'and': ' و ',

    // Auth - Forgot Password
    'resetPassword': 'إعادة تعيين كلمة المرور',
    'resetPasswordSubtitle': 'لإعادة تعيين كلمة المرور أدخل بريدك الإلكتروني',
    'verifyEmail': 'تحقق من البريد الإلكتروني',
    'verifyEmailSubtitle': 'أرسلنا رمز مكون من 4 أرقام إلى بريدك الإلكتروني',
    'didntGetOtp': 'لم تستلم رمز التحقق؟ ',
    'resend': 'إعادة الإرسال',
    'verify': 'تحقق',

    // Auth - Reset Password
    'newPassword': 'كلمة المرور الجديدة',
    'pleaseResetPassword': 'يرجى إعادة تعيين كلمة المرور',
    'confirmPassword': 'تأكيد كلمة المرور',
    'confirm': 'تأكيد',
    'congratulations': 'تهانينا!',
    'resetSuccessful':
        'تم إعادة تعيين كلمة المرور بنجاح! سيتم توجيهك إلى شاشة تسجيل الدخول الآن',

    // Auth - Signup Step Two
    'phoneNumber': 'رقم الهاتف',
    'nationality': 'الجنسية',
    'selectNationality': 'اختر الجنسية',

    // Auth - Provider Details
    'serviceType': 'نوع الخدمة',
    'selectServiceType': 'اختر نوع الخدمة',
    'role': 'الدور',
    'selectRole': 'اختر الدور',
    'serviceCategory': 'فئة الخدمة',
    'selectServiceCategory': 'اختر فئة الخدمة',

    // Get Started
    'getStarted': 'ابدأ الآن',

    // Validation Messages
    'pleaseEnterEmail': 'يرجى إدخال بريدك الإلكتروني',
    'pleaseEnterValidEmail': 'يرجى إدخال بريد إلكتروني صالح',
    'pleaseEnterPassword': 'يرجى إدخال كلمة المرور',
    'passwordMinLength': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
    'pleaseEnterName': 'يرجى إدخال اسمك',
    'pleaseEnterPhone': 'يرجى إدخال رقم هاتفك',
    'pleaseSelectUserType': 'يرجى اختيار نوع المستخدم',
    'pleaseSelectAllFields': 'يرجى اختيار جميع الحقول',
    'pleaseAcceptTerms': 'يرجى قبول الشروط والأحكام',

    // Error Messages
    'error': 'خطأ',
    'success': 'نجاح',
    'loading': 'جاري التحميل...',
    'noInternet': 'لا يوجد اتصال بالإنترنت',
    'serverError': 'خطأ في الخادم. يرجى المحاولة لاحقاً.',
    'somethingWentWrong': 'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
    'loginFailed': 'فشل تسجيل الدخول. يرجى التحقق من بيانات الاعتماد.',
    'signupFailed': 'فشل إنشاء الحساب. يرجى المحاولة مرة أخرى.',
    'otpSent': 'تم إرسال رمز التحقق بنجاح',
    'otpFailed': 'فشل إرسال رمز التحقق',
    'passwordResetSuccess': 'تم إعادة تعيين كلمة المرور بنجاح',
    'passwordResetFailed': 'فشل إعادة تعيين كلمة المرور',

    // Profile & Settings
    'profile': 'الملف الشخصي',
    'settings': 'الإعدادات',
    'logout': 'تسجيل الخروج',
    'logoutConfirmation': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',

    // Navigation
    'home': 'الرئيسية',
    'bookings': 'الحجوزات',
    'notifications': 'الإشعارات',
    'messages': 'الرسائل',

    // Service Provider Home
    'goodMorning': 'صباح الخير',
    'analytics': 'التحليلات',
    'basedOnLast30Days': 'بناءً على آخر 30 يومًا',
    'totalEarnings': 'إجمالي الأرباح',
    'totalRequests': 'إجمالي الطلبات',
    'completed': 'مكتمل',
    'pending': 'قيد الانتظار',
    'totalBalance': 'إجمالي الرصيد',
    'addService': 'إضافة خدمة',
    'schedule': 'الجدول الزمني',
    'earnings': 'الأرباح',
    'documents': 'المستندات',
    'activeOrders': 'الطلبات النشطة',
    'seeAll': 'عرض الكل',
    'fromLastMonth': 'منذ الشهر الماضي',
    'noActiveOrdersFound': 'لم يتم العثور على طلبات نشطة',
    'retry': 'إعادة المحاولة',

    // Service Provider Requests
    'requests': 'الطلبات',
    'noRequestsYet': 'لا توجد طلبات بعد',
    'accept': 'قبول',
    'reject': 'رفض',
    'cancel': 'إلغاء',
    'done': 'تم',
    'requestDetails': 'تفاصيل الطلب',
    'confirmAcceptTitle': 'تأكيد قبول الطلب',
    'confirmAcceptSubtitle': 'هل أنت متأكد أنك تريد قبول هذا الطلب؟',
    'confirmRejectTitle': 'تأكيد رفض الطلب',
    'confirmRejectSubtitle': 'هل أنت متأكد أنك تريد رفض هذا الطلب؟',
    'acceptSuccessTitle': 'تم قبول الطلب بنجاح',
    'acceptSuccessSubtitle': 'لقد قبلت الطلب بنجاح. سيتم إخطار العميل قريباً.',
    'rejectSuccessTitle': 'تم رفض الطلب بنجاح',
    'rejectSuccessSubtitle': 'لقد رفضت الطلب بنجاح.',
  };
}
