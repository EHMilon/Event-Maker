import 'package:event_maker/data/models/service_model.dart';
import 'package:get/get.dart';

class SPServicesController extends GetxController {
  var isLoading = true.obs;
  var services = <ServiceModel>[].obs;
  var searchQuery = ''.obs;

  /// Filtered services based on search query
  List<ServiceModel> get filteredServices {
    if (searchQuery.value.isEmpty) {
      return services;
    }
    return services.where((service) {
      return service.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          service.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          service.location.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    loadMockData();
  }

  Future<void> loadMockData() async {
    isLoading.value = true;
    // Add 2s delay as requested in user global rules
    await Future.delayed(const Duration(seconds: 2));

    services.value = [
      ServiceModel(
        id: '2',
        title: 'Corporate Event Planning',
        description:
            'Professional event planning for corporate meetings, galas, and conferences.',
        images: [
          'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?q=80&w=2012',
        ],
        type: ServiceType.event,
        provider: ServiceProvider(
          name: 'Sarah Smith',
          role: 'Event Expert',
          imageUrl: 'https://i.pravatar.cc/150?u=sarah',
        ),
        location: 'Business Bay, Dubai',
        basePrice: 1200,
        priceUnit: 'AED',
        date: DateTime(2026, 1, 10, 16, 0),
        rating: 4.9,
        reviewCount: 85,
      ),
      ServiceModel(
        id: '3',
        title: 'Birthday Party Décor',
        description:
            'Creative and vibrant decorations for birthday parties of all ages.',
        images: [
          'https://images.unsplash.com/photo-1530103043960-ef38714abb15?q=80&w=2069',
        ],
        type: ServiceType.event,
        provider: ServiceProvider(
          name: 'Mike Johnson',
          role: 'Vocalist',
          imageUrl: 'https://i.pravatar.cc/150?u=mike',
        ),
        location: 'Palm Jumeirah, Dubai',
        basePrice: 300,
        priceUnit: 'AED',
        date: DateTime(2026, 1, 10, 16, 0),
        rating: 4.7,
        reviewCount: 50,
      ),
      ServiceModel(
        id: '4',
        title: 'Live Music for Anniversary',
        description:
            'Soulful live music performances to make your anniversary unforgettable.',
        images: [
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?q=80&w=2070',
        ],
        type: ServiceType.music,
        provider: ServiceProvider(
          name: 'Emily Davis',
          role: 'Musician',
          imageUrl: 'https://i.pravatar.cc/150?u=emily',
        ),
        location: 'Silicon Oasis, Dubai',
        basePrice: 800,
        priceUnit: 'AED',
        date: DateTime(2026, 1, 10, 16, 0),
        rating: 4.9,
        reviewCount: 200,
      ),
    ];

    isLoading.value = false;
  }

  void refreshServices() {
    loadMockData();
  }

  /// Add a new service to the list
  void addService(ServiceModel service) {
    services.insert(0, service);
  }

  /// Update an existing service in the list
  void updateService(ServiceModel updatedService) {
    final index = services.indexWhere((s) => s.id == updatedService.id);
    if (index != -1) {
      services[index] = updatedService;
    }
  }
}
