import 'dart:async';
import 'dart:ui' as ui;
import 'package:event_maker/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';

/// Map service result model
class MapServiceResult {
  final int id;
  final int providerId;
  final String title;
  final String description;
  final String serviceTypeName;
  final String serviceAsName;
  final String roleName;
  final String coverImage;
  final bool requiresConfirmation;
  final bool isFeatured;
  final String currency;
  final double startingPrice;
  final double distanceKm;
  final double rating;
  final int totalReviews;
  final double latitude;
  final double longitude;
  final String address;
  final String providerName;
  final String providerAvatar;

  MapServiceResult({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.serviceTypeName,
    required this.serviceAsName,
    required this.roleName,
    required this.coverImage,
    required this.requiresConfirmation,
    required this.isFeatured,
    required this.currency,
    required this.startingPrice,
    required this.distanceKm,
    required this.rating,
    required this.totalReviews,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.providerName,
    required this.providerAvatar,
  });

  factory MapServiceResult.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final provider = json['provider'] as Map<String, dynamic>? ?? {};

    return MapServiceResult(
      id: json['id'] as int? ?? 0,
      providerId: json['provider_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      serviceTypeName: json['service_type_name'] as String? ?? '',
      serviceAsName: json['service_as_name'] as String? ?? '',
      roleName: json['role_name'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      requiresConfirmation: json['requires_confirmation'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      currency: json['currency'] as String? ?? 'AED',
      startingPrice: (json['starting_price'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      latitude: (location['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (location['longitude'] as num?)?.toDouble() ?? 0.0,
      address: location['address'] as String? ?? '',
      providerName: provider['name'] as String? ?? '',
      providerAvatar: provider['avatar'] as String? ?? '',
    );
  }

  String get fullCoverImageUrl {
    if (coverImage.isEmpty) return '';
    if (coverImage.startsWith('http://') || coverImage.startsWith('https://')) {
      return coverImage;
    }
    return ApiConstant.getFullMediaUrl(coverImage);
  }

  String get fullProviderAvatarUrl {
    if (providerAvatar.isEmpty) return '';
    if (providerAvatar.startsWith('http://') ||
        providerAvatar.startsWith('https://')) {
      return providerAvatar;
    }
    return ApiConstant.getFullMediaUrl(providerAvatar);
  }
}

class MapResultsController extends GetxController {
  final ServiceRepository _serviceRepository = const ServiceRepository();

  final isLoading = true.obs;
  final services = <MapServiceResult>[].obs;
  final selectedServiceIndex = RxnInt();
  final markers = <Marker>{}.obs;

  // Search center
  double searchLatitude = 25.2048;
  double searchLongitude = 55.2708;
  double searchRadius = 20.0;

  // Map controller
  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  void _loadArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final isSingleServiceView = args['is_single_service_view'] as bool? ?? false;

    if (isSingleServiceView) {
      _loadSingleService(args);
    } else {
      _loadSearchResults(args);
    }

    isLoading.value = false;
  }

  void _loadSingleService(Map<String, dynamic> args) {
    final serviceId = args['service_id'] as int? ?? 0;
    final serviceTitle = args['service_title'] as String? ?? '';
    final serviceAddress = args['service_address'] as String? ?? '';
    final serviceLatitude = (args['latitude'] as num?)?.toDouble() ?? 25.2048;
    final serviceLongitude = (args['longitude'] as num?)?.toDouble() ?? 55.2708;
    final coverImage = args['cover_image'] as String? ?? '';
    final providerName = args['provider_name'] as String? ?? '';
    final providerAvatar = args['provider_avatar'] as String? ?? '';
    final startingPrice = (args['starting_price'] as num?)?.toDouble() ?? 0.0;
    final currency = args['currency'] as String? ?? 'AED';
    final roleName = args['role_name'] as String? ?? '';
    final rating = (args['rating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = args['total_reviews'] as int? ?? 0;

    searchLatitude = serviceLatitude;
    searchLongitude = serviceLongitude;

    final singleService = MapServiceResult(
      id: serviceId,
      providerId: args['provider_id'] as int? ?? 0,
      title: serviceTitle,
      description: args['service_description'] as String? ?? '',
      serviceTypeName: args['service_type_name'] as String? ?? '',
      serviceAsName: args['service_as_name'] as String? ?? '',
      roleName: roleName,
      coverImage: coverImage,
      requiresConfirmation: args['requires_confirmation'] as bool? ?? false,
      isFeatured: args['is_featured'] as bool? ?? false,
      currency: currency,
      startingPrice: startingPrice,
      distanceKm: 0.0,
      rating: rating,
      totalReviews: totalReviews,
      latitude: serviceLatitude,
      longitude: serviceLongitude,
      address: serviceAddress,
      providerName: providerName,
      providerAvatar: providerAvatar,
    );

    services.value = [singleService];
    _createSimpleMarkers();
  }

  void _loadSearchResults(Map<String, dynamic> args) {
    searchLatitude = args['latitude'] as double? ?? 25.2048;
    searchLongitude = args['longitude'] as double? ?? 55.2708;

    final apiData = args['api_data'] as Map<String, dynamic>?;
    if (apiData != null) {
      searchRadius = (apiData['radius_km'] as num?)?.toDouble() ?? 20.0;

      final results = apiData['results'] as List<dynamic>? ?? [];
      services.value = results
          .map((e) => MapServiceResult.fromJson(e as Map<String, dynamic>))
          .toList();

      _createSimpleMarkers();
    }
  }

  void _createSimpleMarkers() {
    _createTextMarkers();
  }

  /// Create custom text-based markers using Canvas
  void _createTextMarkers() async {
    final Set<Marker> newMarkers = {};

    for (int i = 0; i < services.length; i++) {
      final service = services[i];
      final markerId = MarkerId('service_${service.id}');
      final capturedIndex = i;

      final bitmapDescriptor = await _createTextMarkerBitmap(
        service.title,
        service.startingPrice,
        service.currency,
        isSelected: i == (selectedServiceIndex.value ?? 0),
      );

      newMarkers.add(
        Marker(
          markerId: markerId,
          position: LatLng(service.latitude, service.longitude),
          onTap: () => onMarkerTap(capturedIndex),
          icon: bitmapDescriptor,
        ),
      );
    }

    markers.assignAll(newMarkers);
    
    // Select first service by default
    if (services.isNotEmpty && selectedServiceIndex.value == null) {
      selectedServiceIndex.value = 0;
    }
  }

  /// Create a custom marker bitmap with text using Canvas
  Future<BitmapDescriptor> _createTextMarkerBitmap(
    String title,
    double price,
    String currency, {
    bool isSelected = false,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Marker dimensions
    const double width = 120;
    const double height = 60;
    const double padding = 8;
    
    // Colors based on selection state
    final bgColor = isSelected ? AppColors.primary : Colors.white;
    final textColor = isSelected ? Colors.white : const Color(0xFF333333);
    final priceColor = isSelected ? Colors.white : AppColors.primary;
    final borderColor = isSelected ? AppColors.primary : const Color(0xFFE0E0E0);
    
    // Draw rounded rectangle background
    final bgRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(12),
    );
    
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 2, width, height),
        const Radius.circular(12),
      ),
      shadowPaint,
    );
    
    // Background
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(bgRect, bgPaint);
    
    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2 : 1;
    canvas.drawRRect(bgRect, borderPaint);
    
    // Draw title text (truncated if too long)
    final truncatedTitle = title.length > 14 ? '${title.substring(0, 14)}..' : title;
    final titleTextSpan = TextSpan(
      text: truncatedTitle,
      style: TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
    );
    final titlePainter = TextPainter(
      text: titleTextSpan,
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
      ellipsis: '..',
    );
    titlePainter.layout(maxWidth: width - (padding * 2));
    titlePainter.paint(canvas, Offset(padding, padding));
    
    // Draw price text
    final priceTextSpan = TextSpan(
      text: '${price.toStringAsFixed(0)} $currency/hr',
      style: TextStyle(
        color: priceColor,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
    final pricePainter = TextPainter(
      text: priceTextSpan,
      textDirection: ui.TextDirection.ltr,
    );
    pricePainter.layout();
    pricePainter.paint(canvas, Offset(padding, padding + 22));
    
    // Draw pointer/triangle at bottom center
    final trianglePath = Path()
      ..moveTo(width / 2 - 10, height)
      ..lineTo(width / 2, height + 10)
      ..lineTo(width / 2 + 10, height)
      ..close();
    
    final trianglePaint = Paint()..color = bgColor;
    canvas.drawPath(trianglePath, trianglePaint);
    
    // Triangle border (left and right sides only)
    final triangleBorderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2 : 1;
    canvas.drawPath(
      Path()
        ..moveTo(width / 2 - 10, height)
        ..lineTo(width / 2, height + 10)
        ..lineTo(width / 2 + 10, height),
      triangleBorderPaint,
    );
    
    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), (height + 10).toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }
    
    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }

  void onMarkerTap(int index) {
    selectedServiceIndex.value = index;

    final service = services[index];
    mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(service.latitude, service.longitude)),
    );
    
    // Update markers to show selection
    _updateMarkerColors();
  }

  void _updateMarkerColors() {
    _createTextMarkers();
  }

  void onServiceCardTap(int index) {
    selectedServiceIndex.value = index;
    _updateMarkerColors();

    final service = services[index];
    mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(service.latitude, service.longitude)),
    );
  }

  /// Navigate to service details when bottom card is tapped
  Future<void> onBottomCardTap(int serviceId) async {
    try {
      isLoading.value = true;
      final service = await _serviceRepository.fetchCustomerServiceDetail(serviceId);
      Get.to(() => ServiceDetailView(service: service));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load service details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  CameraPosition get initialCameraPosition {
    return CameraPosition(
      target: LatLng(searchLatitude, searchLongitude),
      zoom: 12.0,
    );
  }

  MapServiceResult? get selectedService {
    final index = selectedServiceIndex.value;
    if (index == null || index < 0 || index >= services.length) {
      return services.isNotEmpty ? services.first : null;
    }
    return services[index];
  }
}
