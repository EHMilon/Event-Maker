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

    // Service Details
    'description': 'Description',
    'location': 'Location',
    'packagesPricings': 'Packages & Pricings',
    'pricing': 'Pricing',
    'bookNow': 'Book Now',
    'reviewsCount': '@count reviews',

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
    'chats': 'Chats',
    'customer': 'Customer',
    'admin': 'Admin',
    'postVibeFirstChat': 'Post a vibe to start your first chat.',
    'typeYourMessage': 'Type your message',
    'adminChatWelcome': 'Now you can easily contact with the admin.',
    'recommendedTopics': 'Recommended Topics',
    'howCanIImproveMyServices': 'How can I improve my Services?',
    'howCanIImprovedSleep': 'How can I improve my sleep?',
    'autoReplyAdmin': 'Thanks for reaching out! An admin will respond shortly.',
    'autoReplyCustomer': 'Thanks for your message! We will get back soon.',

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
    'noUpcomingRequests': 'No upcoming requests',
    'noPastRequests': 'No past requests',
    'noHistoryRequests': 'No history',
    'upcoming': 'Upcoming',
    'pastEvents': 'Past Events',
    'history': 'History',
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

    // Service Provider My Services
    'myServices': 'My Services',
    'searchServices': 'Search services...',
    'add': 'Add',
    'noServicesYet': 'No services yet',
    'noServicesFound': 'No services found',
    'tapToAddService': 'Tap the + button to add your first service',
    'servicesCount': '@count services',

    // Service Types
    'event': 'Event',
    'photography': 'Photography',
    'training': 'Training',
    'catering': 'Catering',
    'cleaning': 'Cleaning',
    'music': 'Music',
    'filming': 'Filming',

    // Profile & Settings Extra
    'profileSettings': 'Profile Settings',
    'security': 'Security',
    'certifications': 'Certifications',
    'myAvailability': 'My Availability',
    'myWallet': 'My Wallet',
    'myTransactions': 'My Transactions',
    'myBookmarks': 'My Bookmarks',
    'contactUs': 'Contact Us',
    'faq': 'FAQ',
    'language': 'Language',
    'deleteAccount': 'Delete Account',
    'accountDeletionTitle': 'Account Deletion',
    'accountDeletionSubtitle':
        'Are you sure you want to delete the account? Once you delete the account you cannot get it back again.',
    'accountDeletionSuccess':
        'Account deleted successfully. Hope to see you again soon.',
    'update': 'Update',
    'saveChanges': 'Save Changes',
    'profileUpdatedSuccessfully': 'Profile updated successfully',
    'removedFromBookmarks': 'Service removed from bookmarks',
    'addedToBookmarks': 'Service added to bookmarks',
    'removed': 'Removed',
    'bookmarked': 'Bookmarked',
    'currentPassword': 'Current Password',
    'changePassword': 'Change Password',
    'addImage': 'Add Image',
    'upload': 'Upload',
    'addCaption': 'Add a caption',
    'enterCaption': 'Enter Caption',
    'contactUsSubtitle':
        'You can get in touch with us through below platforms. Our team will reach out to you as soon as it would be possible.',
    'customerSupport': 'Customer Support',
    'socialMedia': 'Social Media',
    'myProfile': 'My Profile',
    'about': 'About',
    'reviews': 'Reviews',
    'bio': 'Bio',
    'withdraw': 'Withdraw',
    'transactions': 'Transactions',
    'viewCertification': 'View Certification',
    'addCertification': 'Add Certification',
    'editCertification': 'Edit Certification',
    'certName': 'Certification Name',
    'issuedBy': 'Issued By',
    'issueDate': 'Issue Date',
    'expiryDate': 'Expiry Date',
    'certAddedSuccess': 'Certification added successfully',
    'certUpdatedSuccess': 'Certification updated successfully',

    // Add Service Flow
    'editService': 'Edit Service',
    'addNewService': 'Add New Service',
    'serviceTitle': 'Service Title',
    'serviceTitleHint': 'Your title goes here...',
    'descriptionHint': 'Your description goes here...',
    'selectLocation': 'Select location',
    'selectAddressHint': 'Select address',
    'cannotGoOutsideLocation': "Can't go outside the location",
    'addPackage': 'Add Package',
    'updateService': 'Update Service',
    'selectAvailableDays': 'Select Available Days',
    'setTimeSlots': 'Set Time Slots',
    'to': 'to',
    'save': 'Save',
    'packagesInstructions':
        'Create packages with different pricing tiers for your service',
    'noPackagesAdded': 'No packages added yet',
    'addFirstPackage': 'Add your first package',
    'savePackages': 'Save Packages',
    'packageName': 'Package Name',
    'packageHint': 'e.g., Basic, Premium, Enterprise',
    'priceAED': 'Price (AED)',
    'features': 'Features',
    'addFeature': 'Add Feature',
    'enterFeatureHint': 'Enter feature',
    'noFeaturesAdded':
        'No features added. Click "Add Feature" to add features.',
    'packageLabel': 'Package @index',
    'availabilitySaved': 'Availability saved successfully',
    'packagesSaved': 'Packages saved successfully',
    'serviceAddedSuccess': 'Service added successfully',
    'serviceUpdatedSuccess': 'Service updated successfully',
    'insufficientFunds': 'Insufficient Funds',

    // Days
    'mon': 'Mon',
    'tue': 'Tue',
    'wed': 'Wed',
    'thu': 'Thu',
    'fri': 'Fri',
    'sat': 'Sat',
    'sun': 'Sun',
    'addDocumentTitle': 'Add Document',
    'uploadDocumentSubtitle': 'Upload documents showcasing your service',
    'changeFile': 'Change File',
    'documentTitleLabel': 'Document Title',
    'selectCategory': 'Select Category',
    'services': 'Services',
    'events': 'Events',
    'trainings': 'Trainings',
    'map': 'Map',
    'myLocation': 'My Location',
    'searchLocation': 'Search Location',
    'categories': 'Categories',
    'subCategoriesLabel': 'Sub Categories',
    'uae': 'UAE',
    'hospitality': 'Hospitality',
    'professionalTrainer': 'Professional Trainer',
    'professional trainer': 'Professional Trainer',
    'barista': 'Barista',
    'search': 'Search',
    'selectAll': 'Select All',
    'standard': 'Standard Package',

    // Customer Notifications
    'today': 'Today',
    'clearAll': 'Clear All',
    'noNotifications': 'No notifications yet',
    'acceptedBookingBody': 'Your booking request has been accepted',
    'rejectedBookingBody': 'Your booking request has been rejected',
    'confirmedBookingBody': 'Your booking is confirmed for tomorrow',
    'paymentReceivedBody': 'We have received your payment',
    'newServiceAvailableBody': 'New services are now available in your area',

    // Payment
    'payment': 'Payment',
    'bookingSummary': 'Booking Summary',
    'additionalFee': 'Additional Fee',
    'total': 'Total',
    'paymentMethod': 'Payment Method',
    'payNow': 'Pay now',
    'paymentDisclaimer':
        'Your payment information is secure and encrypted. By confirming, you agree to our Terms of Service.',
    'stripe': 'Stripe',
    'paypal': 'Paypal',

    // Payment Confirmation
    'paymentSuccessful': 'Payment Successful!',
    'bookingConfirmedSubtitle':
        'Your booking has been confirmed. Thank you for using our service!',
    'backToHome': 'Back to Home',
    // Customer Home
    'serviceCategories': 'Service Categories',
    'allCategories': 'All Categories',
    'cateringServices': 'Catering Services',
    'filmingEvents': 'Filming Events',
    'cleaningServices': 'Cleaning Services',
    'tryDifferentKeywords': 'Try different keywords',
    'resultsFound': 'results found',
    'lighting': 'Lighting',
    'caterer': 'Caterer',
    'musical': 'Musical',
    'photographer': 'Photographer',
    'locationLabel': 'Location',

    // Common
    'perHr': '/hr',
    'resultsFoundCount': '@count results found',
    // Booking Details
    'bookService': 'Book Service',
    'selectDateTime': 'Select Date & Time',
    'availableTimes': 'Available Times',
    'serviceDuration': 'Service Duration',
    'selectMonth': 'Select Month',
    'selectYear': 'Select Year',
    'selectDuration': 'Select Duration',
    'selectLocationTitle': 'Select Location',
    'additionalRequest': 'Additional Request',
    'specialRequests': 'Special Requests (Optional)',
    'specialRequestsHint':
        'Any special requirements or notes for the service provider...',
    'requestSentSuccessfully': 'Request Sent Successfully!',
    'requestSentSubtitle':
        'Your booking request has been sent to the service provider. You will be notified once they accept it.',
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

    // Service Details
    'description': 'الوصف',
    'location': 'الموقع',
    'packagesPricings': 'الباقات والأسعار',
    'pricing': 'التسعير',
    'bookNow': 'احجز الآن',
    'reviewsCount': '@count تقييم',

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
    'chats': 'الدردشات',
    'customer': 'العميل',
    'admin': 'المسؤول',
    'postVibeFirstChat': 'انشر حالة للبدء في الدردشة الأولى.',
    'typeYourMessage': 'اكتب رسالتك',
    'adminChatWelcome': 'الآن يمكنك التواصل بسهولة مع المسؤول.',
    'recommendedTopics': 'المواضيع الموصى بها',
    'howCanIImproveMyServices': 'كيف يمكنني تحسين خدماتي؟',
    'howCanIImprovedSleep': 'كيف يمكنني تحسين نومي؟',

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
    'noUpcomingRequests': 'لا توجد طلبات قادمة',
    'noPastRequests': 'لا توجد طلبات سابقة',
    'noHistoryRequests': 'لا يوجد سجل',
    'upcoming': 'قادم',
    'pastEvents': 'الفعاليات السابقة',
    'history': 'السجل',
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

    // Service Provider My Services
    'myServices': 'خدماتي',
    'searchServices': 'البحث في الخدمات...',
    'add': 'إضافة',
    'noServicesYet': 'لا توجد خدمات بعد',
    'noServicesFound': 'لم يتم العثور على خدمات',
    'tapToAddService': 'اضغط على زر + لإضافة خدمتك الأولى',
    'servicesCount': '@count خدمة',

    // Service Types
    'event': 'فعالية',
    'photography': 'تصوير فوتوغرافي',
    'training': 'تدريب',
    'catering': 'تموين',
    'cleaning': 'تنظيف',
    'music': 'موسيقى',
    'filming': 'تصوير سينمائي',

    // Profile & Settings Extra
    'profileSettings': 'إعدادات الملف الشخصي',
    'security': 'الأمان',
    'certifications': 'الشهادات',
    'myAvailability': 'توفري',
    'myWallet': 'محفظتي',
    'myTransactions': 'معاملاتي',
    'myBookmarks': 'إشاراتي المرجعية',
    'contactUs': 'اتصل بنا',
    'faq': 'الأسئلة الشائعة',
    'language': 'اللغة',
    'deleteAccount': 'حذف الحساب',
    'accountDeletionTitle': 'حذف الحساب',
    'accountDeletionSubtitle':
        'هل أنت متأكد أنك تريد حذف الحساب؟ بمجرد الحذف لن تتمكن من استعادته مرة أخرى.',
    'accountDeletionSuccess':
        'تم حذف الحساب بنجاح. نأمل أن نراك مرة أخرى قريباً.',
    'update': 'تحديث',
    'saveChanges': 'حفظ التغييرات',
    'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
    'profileUpdatedSuccessfully': 'تم تحديث الملف الشخصي بنجاح',
    'removedFromBookmarks': 'تمت إزالة الخدمة من الإشارات المرجعية',
    'addedToBookmarks': 'تمت إضافة الخدمة إلى الإشارات المرجعية',
    'removed': 'تمت الإزالة',
    'bookmarked': 'تمت الإضافة',
    'currentPassword': 'كلمة المرور الحالية',
    'changePassword': 'تغيير كلمة المرور',
    'addImage': 'إضافة صورة',
    'upload': 'تحميل',
    'addCaption': 'إضافة تعليق',
    'enterCaption': 'أدخل التعليق',
    'contactUsSubtitle':
        'يمكنك التواصل معنا من خلال المنصات أدناه. سيقوم فريقنا بالرد عليك في أقرب وقت ممكن.',
    'customerSupport': 'دعم العملاء',
    'socialMedia': 'وسائل التواصل الاجتماعي',
    'myProfile': 'ملفي الشخصي',
    'about': 'حول',
    'reviews': 'المراجعات',
    'bio': 'السيرة الذاتية',
    'withdraw': 'سحب',
    'transactions': 'المعاملات',
    'viewCertification': 'عرض الشهادة',
    'addCertification': 'إضافة شهادة',
    'editCertification': 'تعديل الشهادة',
    'certName': 'اسم الشهادة',
    'issuedBy': 'جهة الإصدار',
    'issueDate': 'تاريخ الإصدار',
    'expiryDate': 'تاريخ الانتهاء',
    'certAddedSuccess': 'تم إضافة الشهادة بنجاح',
    'certUpdatedSuccess': 'تم تحديث الشهادة بنجاح',

    // Add Service Flow
    'editService': 'تعديل الخدمة',
    'addNewService': 'إضافة خدمة جديدة',
    'serviceTitle': 'عنوان الخدمة',
    'serviceTitleHint': 'أدخل العنوان هنا...',
    'descriptionHint': 'أدخل الوصف هنا...',
    'selectLocation': 'اختر الموقع',
    'selectAddressHint': 'اختر العنوان',
    'cannotGoOutsideLocation': 'لا يمكن الخروج عن الموقع',
    'addPackage': 'إضافة باقة',
    'updateService': 'تحديث الخدمة',
    'selectAvailableDays': 'اختر أيام التوفر',
    'setTimeSlots': 'تحديد الفترات الزمنية',
    'to': 'إلى',
    'save': 'حفظ',
    'packagesInstructions': 'أنشئ باقات بمستويات تسعير مختلفة لخدمتك',
    'noPackagesAdded': 'لم يتم إضافة باقات بعد',
    'addFirstPackage': 'أضف باقتك الأولى',
    'savePackages': 'حفظ الباقات',
    'packageName': 'اسم الباقة',
    'packageHint': 'مثال: أساسية، مميزة، للمؤسسات',
    'priceAED': 'السعر (درهم)',
    'features': 'المميزات',
    'addFeature': 'إضافة ميزة',
    'enterFeatureHint': 'أدخل الميزة',
    'noFeaturesAdded': 'لم يتم إضافة مميزات. اضغط على "إضافة ميزة" لإضافتها.',
    'packageLabel': 'باقة @index',
    'availabilitySaved': 'تم حفظ التوفر بنجاح',
    'packagesSaved': 'تم حفظ الباقات بنجاح',
    'serviceAddedSuccess': 'تم إضافة الخدمة بنجاح',
    'serviceUpdatedSuccess': 'تم تحديث الخدمة بنجاح',
    'insufficientFunds': 'رصيد غير كافٍ',

    // Days
    'mon': 'الاثنين',
    'tue': 'الثلاثاء',
    'wed': 'الأربعاء',
    'thu': 'الخميس',
    'fri': 'الجمعة',
    'sat': 'السبت',
    'sun': 'الأحد',
    'addDocumentTitle': 'إضافة مستند',
    'uploadDocumentSubtitle': 'قم بتحميل المستندات التي تعرض خدمتك',
    'changeFile': 'تغيير الملف',
    'documentTitleLabel': 'عنوان المستند',
    'selectCategory': 'اختر الفئة',
    'services': 'الخدمات',
    'events': 'الفعاليات',
    'trainings': 'التدريبات',
    'map': 'الخريطة',
    'myLocation': 'موقعي',
    'searchLocation': 'البحث عن الموقع',
    'categories': 'الفئات',
    'subCategoriesLabel': 'الفئات الفرعية',
    'uae': 'الإمارات',
    'hospitality': 'ضيافة',
    'professionalTrainer': 'مدرب محترف',
    'professional trainer': 'مدرب محترف',
    'barista': 'باريستا',
    'search': 'بحث',
    'selectAll': 'تحديد الكل',
    'standard': 'الباقة الأساسية',

    // Customer Notifications
    'today': 'اليوم',
    'clearAll': 'مسح الكل',
    'noNotifications': 'لا توجد إشعارات بعد',
    'acceptedBookingBody': 'تم قبول طلب الحجز الخاص بك',
    'rejectedBookingBody': 'تم رفض طلب الحجز الخاص بك',
    'confirmedBookingBody': 'تم تأكيد حجزك ليوم غد',
    'paymentReceivedBody': 'لقد استلمنا دفعتك',
    'newServiceAvailableBody': 'خدمات جديدة متاحة الآن في منطقتك',

    // Payment
    'payment': 'الدفع',
    'bookingSummary': 'ملخص الحجز',
    'additionalFee': 'رسوم إضافية',
    'total': 'الإجمالي',
    'paymentMethod': 'طريقة الدفع',
    'payNow': 'ادفع الآن',
    'paymentDisclaimer':
        'معلومات الدفع الخاصة بك آمنة ومشفرة. من خلال التأكيد، فإنك توافق على شروط الخدمة الخاصة بنا.',
    'stripe': 'سترايب',
    'paypal': 'بايبال',

    // Payment Confirmation
    'paymentSuccessful': 'تم الدفع بنجاح!',
    'bookingConfirmedSubtitle': 'تم تأكيد حجزك. شكراً لاستخدامكم خدمتنا!',
    'backToHome': 'العودة للرئيسية',

    // Customer Home
    'serviceCategories': 'فئات الخدمة',
    'allCategories': 'جميع الفئات',
    'cateringServices': 'خدمات التموين',
    'filmingEvents': 'فعاليات التصوير',
    'cleaningServices': 'خدمات التنظيف',
    'tryDifferentKeywords': 'جرب كلمات رئيسية مختلفة',
    'resultsFound': 'نتائج وجدت',
    'lighting': 'إضاءة',
    'caterer': 'متعهد طعام',
    'musical': 'موسيقي',
    'photographer': 'مصور',
    'locationLabel': 'الموقع',

    // Common
    'perHr': '/ساعة',
    'resultsFoundCount': '@count نتائج وجدت',

    // Booking Details
    'bookService': 'حجز الخدمة',
    'selectDateTime': 'اختر التاريخ والوقت',
    'availableTimes': 'الأوقات المتاحة',
    'serviceDuration': 'مدة الخدمة',
    'selectMonth': 'اختر الشهر',
    'selectYear': 'اختر السنة',
    'selectDuration': 'اختر المدة',
    'selectLocationTitle': 'اختر الموقع',
    'additionalRequest': 'طلب إضافي',
    'specialRequests': 'طلبات خاصة (اختياري)',
    'specialRequestsHint': 'أي متطلبات خاصة أو ملاحظات لمقدم الخدمة...',
    'requestSentSuccessfully': 'تم إرسال الطلب بنجاح!',
    'requestSentSubtitle':
        'تم إرسال طلب الحجز الخاص بك إلى مقدم الخدمة. سيتم إخطارك بمجرد قبوله.',
  };
}
