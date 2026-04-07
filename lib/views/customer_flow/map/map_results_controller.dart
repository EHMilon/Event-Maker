import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../../../models/service_model.dart';

/// Availability location data for map markers
class AvailabilityLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String days;
  final String time;

  AvailabilityLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.days,
    required this.time,
  });
}

class MapResultsController extends GetxController {
  final isLoading = false.obs;
  final selectedService = Rxn<ServiceModel>();

  // Availability locations passed from service detail
  List<AvailabilityLocation> availabilityLocations = [];

  // Service title for display
  String serviceTitle = '';

  // Mock points for polyline (as seen in the image)
  final List<gmaps.LatLng> polylinePoints = [
    const gmaps.LatLng(24.4539, 54.3773),
    const gmaps.LatLng(24.4500, 54.3800),
    const gmaps.LatLng(24.4450, 54.3700),
    const gmaps.LatLng(24.4400, 54.3750),
  ];

  final List<ServiceModel> mockServices = [
    ServiceModel(
      id: '1',
      title: 'Elite photography',
      description: 'Professional photography services for all occasions.',
      images: [
        'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?q=80&w=400&auto=format&fit=crop',
      ],
      type: ServiceType.photography,
      provider: ServiceProvider(
        name: 'John Doe',
        role: 'Freelancer',
        imageUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=1000&auto=format&fit=crop',
        isVerified: true,
      ),
      location: 'AD, Louver Museum',
      rating: 4.3,
      reviewCount: 120,
      basePrice: 120,
      priceUnit: 'AED / hr',
      date: DateTime.now(),
    ),
    ServiceModel(
      id: '2',
      title: 'Dan Videography',
      description: 'Capture your moments in high definition.',
      images: [
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400&auto=format&fit=crop',
      ],
      type: ServiceType.filming,
      provider: ServiceProvider(
        name: 'Dan Smith',
        role: 'Business',
        imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop',
        isVerified: true,
      ),
      location: 'AD, Marina Mall',
      rating: 4.8,
      reviewCount: 95,
      basePrice: 150,
      priceUnit: 'AED / hr',
      date: DateTime.now(),
    ),
    ServiceModel(
      id: '3',
      title: 'Food Catering',
      description: 'Delicious food for your events.',
      images: [
        'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=400&auto=format&fit=crop',
      ],
      type: ServiceType.catering,
      provider: ServiceProvider(
        name: 'Chef Maria',
        role: 'Productive Family',
        imageUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1000&auto=format&fit=crop',
        isVerified: true,
      ),
      location: 'AD, Corniche',
      rating: 4.5,
      reviewCount: 210,
      basePrice: 200,
      priceUnit: 'AED / hr',
      date: DateTime.now(),
    ),
  ];

  // Coordinates for services
  final Map<String, gmaps.LatLng> serviceLocations = {
    '1': const gmaps.LatLng(24.4539, 54.3773),
    '2': const gmaps.LatLng(24.4600, 54.3900),
    '3': const gmaps.LatLng(24.4400, 54.3600), // Food Catering
  };

  @override
  void onInit() {
    super.onInit();

    // Parse passed arguments from service detail view
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      // Parse service title
      if (args.containsKey('serviceTitle')) {
        serviceTitle = args['serviceTitle'] as String? ?? '';
      }

      // Parse availability locations
      if (args.containsKey('availabilities')) {
        final availabilities = args['availabilities'] as List<dynamic>?;
        if (availabilities != null) {
          availabilityLocations = availabilities.map((avail) {
            return AvailabilityLocation(
              latitude:
                  double.tryParse(avail['latitude']?.toString() ?? '0') ?? 0,
              longitude:
                  double.tryParse(avail['longitude']?.toString() ?? '0') ?? 0,
              address: avail['address']?.toString() ?? '',
              days: (avail['week_days'] as List<dynamic>?)?.join(', ') ?? '',
              time: '${avail['start_time'] ?? ''} - ${avail['end_time'] ?? ''}',
            );
          }).toList();
        }
      }

      // Fallback: single location if no availabilities array
      if (availabilityLocations.isEmpty && args.containsKey('latitude')) {
        availabilityLocations.add(
          AvailabilityLocation(
            latitude: double.tryParse(args['latitude']?.toString() ?? '0') ?? 0,
            longitude:
                double.tryParse(args['longitude']?.toString() ?? '0') ?? 0,
            address: args['address']?.toString() ?? '',
            days: '',
            time: '',
          ),
        );
      }
    }

    // If no data passed, use mock services
    if (availabilityLocations.isEmpty) {
      selectedService.value = mockServices[0];
    }
  }

  void onMarkerTap(ServiceModel service) {
    selectedService.value = service;
  }
}
