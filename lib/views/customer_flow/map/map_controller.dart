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

  // Sub-categories map based on main category
  final Map<String, List<String>> subCategoriesMap = {
    'Hospitality': ['Catering', 'Barista', 'Bakery', 'Waitstaff', 'Host/Hostess'],
    'Event': ['Lighting', 'Sound', 'Decoration', 'Venue', 'Planner'],
    'Professional Trainer': ['Photographer', 'Videographer', 'Musician', 'DJ', 'MC'],
  };

  @override
  void onInit() {
    super.onInit();
    // Listen to main category changes and update sub-categories
    ever(selectedMainCategory, (_) => updateSubCategories());
    fetchSubCategories();
  }

  void updateSubCategories() {
    // Get sub-categories for the selected main category
    final newSubCategories = subCategoriesMap[selectedMainCategory.value] ?? [];
    
    // Convert to map format for the UI
    subCategories.assignAll(newSubCategories.map((name) => {'name': name}).toList());
    
    // Clear selected sub-categories when changing main category
    selectedSubCategories.clear();
    
    // Select default sub-categories (first 3) for better UX
    if (newSubCategories.isNotEmpty) {
      final names = newSubCategories.take(3).toList();
      selectedSubCategories.assignAll(names);
    }
  }

  Future<void> fetchSubCategories() async {
    isLoading.value = true;
    try {
      // simulate backend call with 2s delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Load initial sub-categories based on default main category
      updateSubCategories();
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
