import 'package:get/get.dart';
import '../../views/splash/splash_view.dart';
import '../../views/splash/splash_binding.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/onboarding/onboarding_binding.dart';
import '../../views/auth/user_type/user_type_view.dart';
import '../../views/auth/user_type/user_type_binding.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String userType = '/user-type';

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
      binding: UserTypeBinding(),
    ),
  ];
}
