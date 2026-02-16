import 'package:event_maker/views/customer_flow/map/map_results_binding.dart';
import 'package:event_maker/views/customer_flow/map/map_results_view.dart';
import 'package:get/get.dart';

class MapController extends GetxController {
  final isLoading = false.obs;

  final locationSearch = ''.obs;

  final selectedMainCategory = 'Hospitality'.obs;
  final mainCategories = ['Hospitality', 'Event', 'Professional Trainer'];

  final selectedSubCategories = <String>[].obs;
  final subCategories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubCategories();
  }

  Future<void> fetchSubCategories() async {
    isLoading.value = true;
    try {
      // simulate backend call with 2s delay
      await Future.delayed(const Duration(seconds: 2));
      subCategories.assignAll([
        {'name': 'Lighting', 'icon': 'assets/icons/event.png'},
        {'name': 'Musical', 'icon': 'assets/icons/musical.png'},
        {'name': 'Filming', 'icon': 'assets/icons/filming.png'},
        {'name': 'Photography', 'icon': 'assets/icons/photography.png'},
        {'name': 'Catering', 'icon': 'assets/icons/catering.png'},
        {'name': 'Cleaning', 'icon': 'assets/icons/catering.png'},
        {'name': 'Barista', 'icon': 'assets/icons/event.png'},
      ]);

      // Default selections from design
      selectedSubCategories.assignAll(['Musical', 'Filming', 'Photography']);
    } catch (e) {
      Get.snackbar(
        'Connection Error',
        'Please check your internet connection.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSubCategory(String name) {
    print('Toggling subcategory: $name');
    if (selectedSubCategories.contains(name)) {
      selectedSubCategories.remove(name);
    } else {
      selectedSubCategories.add(name);
    }
    print('Selected subcategories: $selectedSubCategories');
  }

  void selectAll() {
    if (selectedSubCategories.length == subCategories.length) {
      selectedSubCategories.clear();
    } else {
      selectedSubCategories.assignAll(
        subCategories.map((e) => e['name'] as String).toList(),
      );
    }
  }

  Future<void> search() async {
    // Show loading for search action too
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;

    // Navigate to the interactive map view using direct navigation
    Get.to(
      () => const MapResultsView(),
      binding: MapResultsBinding(),
      transition: Transition.fadeIn,
    );
  }
}
