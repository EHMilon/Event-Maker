import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'loading_controller.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;

  const LoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoadingController>();
    return Stack(
      children: [
        child,
        Obx(() {
          if (!controller.isLoading) return const SizedBox.shrink();
          return AbsorbPointer(
            child: Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }),
      ],
    );
  }
}
