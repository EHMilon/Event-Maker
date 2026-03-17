import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'app_routes.dart';
import 'constants/app_themes.dart';
import 'constants/app_colors.dart';
import 'utils/user_preferences.dart';
import 'localization/app_localization.dart';
import 'bindings/initial_binding.dart';

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
            final brightness = Theme.of(context).brightness;
            final overlayStyle = SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  brightness == Brightness.dark ? Brightness.light : Brightness.dark,
              statusBarBrightness:
                  brightness == Brightness.dark ? Brightness.dark : Brightness.light,
            );

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlayStyle,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
