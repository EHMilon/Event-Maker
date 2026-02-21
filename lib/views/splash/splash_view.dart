import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';
import '../../core/themes/app_colors.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  SystemUiOverlayStyle get _overlayStyle => SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.primary,
        body: SizedBox.expand(
          child: Image.asset(
            'assets/images/splash_screen.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  "Logo Not Found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
