import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/service_model.dart';

class MapResultsController extends GetxController {
  final isLoading = false.obs;
  final selectedService = Rxn<ServiceModel>();
  final markers = <Marker>{}.obs;

  // Mock points for polyline (as seen in the image)
  final List<LatLng> polylinePoints = [
    const LatLng(24.4539, 54.3773),
    const LatLng(24.4500, 54.3800),
    const LatLng(24.4450, 54.3700),
    const LatLng(24.4400, 54.3750),
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
  final Map<String, LatLng> serviceLocations = {
    '1': const LatLng(24.4539, 54.3773),
    '2': const LatLng(24.4600, 54.3900),
    '3': const LatLng(24.4400, 54.3600), // Food Catering
  };

  @override
  void onInit() {
    super.onInit();
    selectedService.value = mockServices[0];
    _buildMarkers();
  }

  void _buildMarkers() {
    final Set<Marker> newMarkers = {};
    
    // Center red marker (mock user location or search center)
    newMarkers.add(
      const Marker(
        markerId: MarkerId('center'),
        position: LatLng(24.4450, 54.3780),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );

    // Dynamic mock services
    for (var service in mockServices) {
      final point = serviceLocations[service.id] ?? const LatLng(0, 0);
      newMarkers.add(
        Marker(
          markerId: MarkerId(service.id),
          position: point,
          onTap: () => onMarkerTap(service),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            service.id == '1' ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: service.title,
            snippet: '${service.basePrice} ${service.priceUnit}',
          ),
        ),
      );
    }
    
    markers.assignAll(newMarkers);
  }

  void onMarkerTap(ServiceModel service) {
    selectedService.value = service;
  }
}
