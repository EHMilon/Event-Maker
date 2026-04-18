import 'dart:async';
import 'dart:io';
import 'package:event_maker/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'app_routes.dart';
import 'constants/app_themes.dart';
import 'localization/app_localization.dart';
import 'global/init_binding.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    GoogleFonts.config.allowRuntimeFetching = true;

    await StorageService.init();

    final savedLanguageCode = await StorageService().getLanguageCode();
    runApp(MyApp(initialLocale: Locale(savedLanguageCode)));
  }, (error, stack) {
    if (error.toString().contains('Failed to load font') ||
        error.toString().contains('fonts.gstatic.com')) {
      debugPrint('GoogleFonts offline fetch failed. Using fallback system font.');
    } else {
      debugPrint('Unhandled error: $error');
    }
  });
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

