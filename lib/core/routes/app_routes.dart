import 'package:get/get.dart';
import '../../views/splash/splash_view.dart';
import '../../views/splash/splash_binding.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/onboarding/onboarding_binding.dart';
import '../../views/auth/user_type_view.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/auth_binding.dart';
import '../../views/auth/signup_view.dart';
import '../../views/auth/forgot_password_view.dart';
import '../../views/auth/otp_verification_view.dart';
import '../../views/auth/reset_password_view.dart';
import '../../views/auth/congratulations_view.dart';
import '../../views/auth/signup_step_two_view.dart';
import '../../views/auth/provider_details_view.dart';
import '../../views/auth/get_started_view.dart';
import '../../views/profile/profile_view.dart';
import '../../views/profile/profile_settings_view.dart';
import '../../views/profile/add_image_view.dart';
import '../../views/profile/change_password_view.dart';
import '../../views/profile/transactions_view.dart';
import '../../views/customer_flow/bookmarks/bookmarks_view.dart';
import '../../views/profile/faq_view.dart';
import '../../views/profile/contact_us_view.dart';
import '../../views/profile/profile_binding.dart';
import '../../views/customer_flow/customer_flow_scaffold.dart';
import '../../views/customer_flow/home/home_view.dart';
import '../../views/customer_flow/home/home_binding.dart';
import '../../views/service_provider_flow/home/sp_home_view.dart';
import '../../views/service_provider_flow/home/sp_home_binding.dart';
import '../../views/customer_flow/map/map_results_view.dart';
import '../../views/customer_flow/map/map_results_binding.dart';
import '../../views/notifications/notification_view.dart';
import '../../views/notifications/notification_binding.dart';
import '../../views/services/vendor_profile_view.dart';
import '../../views/services/category_services_view.dart';
import '../../views/services/category_services_controller.dart';
import '../../views/customer_flow/booking/book_service_date_view.dart';
import '../../views/customer_flow/booking/book_service_request_view.dart';
import '../../views/customer_flow/booking/payment_confirmation_view.dart';
import '../../views/customer_flow/booking/payment_view.dart';
import '../../views/customer_flow/booking/booking_request_sent_view.dart';
import '../../views/customer_flow/booking/booking_binding.dart';
import '../../views/services/spam_report_view.dart';
import '../../views/services/view_certificate_view.dart';
import '../../views/services/add_review_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String userType = '/user-type';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPasswordNew = '/reset-password-new';
  static const String congratulations = '/congratulations';
  static const String signupStepTwo = '/signup-step-two';
  static const String providerDetails = '/provider-details';
  static const String getStarted = '/get-started';
  static const String profile = '/profile';
  static const String profileSettings = '/profile-settings';
  static const String addImage = '/add-image';
  static const String changePassword = '/change-password';
  static const String transactions = '/transactions';
  static const String bookmarks = '/bookmarks';
  static const String faq = '/faq';
  static const String contactUs = '/contact-us';
  static const String customerHome = '/customer-home';
  static const String serviceProviderHome = '/service-provider-home';
  static const String notifications = '/notifications';
  static const String mapResults = '/map-results';
  static const String vendorProfile = '/vendor-profile';
  static const String bookServiceDate = '/book-service-date';
  static const String bookServiceRequest = '/book-service-request';
  static const String payment = '/payment';
  static const String paymentConfirmation = '/payment-confirmation';
  static const String bookingRequestSent = '/booking-request-sent';
  static const String spamReport = '/spam-report';
  static const String viewCertificate = '/view-certificate';
  static const String addReview = '/add-review';
  static const String categoryServices = '/category-services';

  static final routes = [
    GetPage(
      name: notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: userType,
      page: () => const UserTypeView(),
      binding: AuthBinding(),
    ),
    GetPage(name: login, page: () => const LoginView(), binding: AuthBinding()),
    GetPage(
      name: signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: otpVerification,
      page: () => const OtpVerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: resetPasswordNew,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: congratulations,
      page: () => const CongratulationsView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: signupStepTwo,
      page: () => const SignupStepTwoView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: providerDetails,
      page: () => const ProviderDetailsView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: getStarted,
      page: () => const GetStartedView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(name: profileSettings, page: () => const ProfileSettingsView()),
    GetPage(name: addImage, page: () => const AddImageView()),
    GetPage(name: changePassword, page: () => const ChangePasswordView()),
    GetPage(name: transactions, page: () => const TransactionsView()),
    GetPage(
      name: bookmarks,
      page: () => const BookmarksView(),
      binding: ProfileBinding(),
    ),
    GetPage(name: faq, page: () => const FAQView()),
    GetPage(name: contactUs, page: () => const ContactUsView()),
    GetPage(
      name: customerHome,
      page: () => const CustomerFlowScaffold(),
      binding: HomeBinding(),
    ),
    // GetPage(
    //   name: serviceProviderHome,
    //   binding: ServiceProviderHomeBinding(),
    // ),
    GetPage(
      name: mapResults,
      page: () => const MapResultsView(),
      binding: MapResultsBinding(),
    ),
    GetPage(name: vendorProfile, page: () => const VendorProfileView()),
    GetPage(
      name: bookServiceDate,
      page: () => const BookServiceDateView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: bookServiceRequest,
      page: () => const BookServiceRequestView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: payment,
      page: () => const PaymentView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: paymentConfirmation,
      page: () => const PaymentConfirmationView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: bookingRequestSent,
      page: () => const BookingRequestSentView(),
      binding: BookingBinding(),
    ),
    GetPage(name: spamReport, page: () => const SpamReportView()),
    GetPage(name: viewCertificate, page: () => const ViewCertificateView()),
    GetPage(name: addReview, page: () => const AddReviewView()),
    // Category Services route
    GetPage(
      name: categoryServices,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        return CategoryServicesView(
          categoryType: arguments?['categoryType'] ?? 'catering',
          categoryName: arguments?['categoryName'] ?? 'Services',
        );
      },
      binding: BindingsBuilder(() {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final categoryType = arguments?['categoryType'] ?? 'catering';
        Get.lazyPut<CategoryServicesController>(
          () => CategoryServicesController(
            categoryType: categoryType,
            categoryName: arguments?['categoryName'] ?? 'Services',
          ),
          tag: '${categoryType}_${arguments?["categoryName"] ?? "Services"}',
        );
      }),
    ),
  ];
}
