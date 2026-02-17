import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/routes/app_routes.dart';
import 'core/themes/app_themes.dart';
import 'shared/utils/user_preferences.dart';
import 'core/localization/app_localization.dart';
import 'core/bindings/initial_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedLanguageCode = await UserPreferences.getLanguageCode();
  runApp(MyApp(initialLocale: Locale(savedLanguageCode)));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X size as base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Event Maker',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          // darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.light,
          translations: AppLocalization(),
          locale: initialLocale,
          fallbackLocale: const Locale(AppLocalization.fallbackLanguage),
          initialBinding: InitialBinding(),
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.routes,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            );
          },
        );
      },
    );
  }
}
