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
import '../../views/profile/profile_binding.dart';
import '../../views/customer_flow/customer_flow_scaffold.dart';
import '../../views/customer_flow/home/home_view.dart';
import '../../views/customer_flow/home/home_binding.dart';
import '../../views/service_provider_flow/home/sp_home_view.dart';
import '../../views/service_provider_flow/home/sp_home_binding.dart';

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
  static const String customerHome = '/customer-home';
  static const String serviceProviderHome = '/service-provider-home';

  static final routes = [
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
    GetPage(
      name: profileSettings,
      page: () => const ProfileSettingsView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: addImage,
      page: () => const AddImageView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: customerHome,
      page: () => const CustomerFlowScaffold(),
      binding: HomeBinding(),
    ),
    // GetPage(
    //   name: serviceProviderHome,
    //   page: () => const ServiceProviderHomeView(),
    //   binding: ServiceProviderHomeBinding(),
    // ),
  ];
}
