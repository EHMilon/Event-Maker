import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/constants/env_config.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
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

  // Navigation state
  final isNavigating = false.obs;
  final polylines = <Polyline>{}.obs;
  final currentLocation = Rxn<LatLng>();

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
    final isSingleServiceView =
        args['is_single_service_view'] as bool? ?? false;

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

  /// Create custom text-based markers with image using Canvas
  void _createTextMarkers() async {
    final Set<Marker> newMarkers = {};

    for (int i = 0; i < services.length; i++) {
      final service = services[i];
      final markerId = MarkerId('service_${service.id}');
      final capturedIndex = i;

      final bitmapDescriptor = await _createImageMarkerBitmap(
        service.title,
        service.startingPrice,
        service.currency,
        service.fullCoverImageUrl,
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

  /// Load image from network and convert to ui.Image
  Future<ui.Image?> _loadNetworkImage(String url) async {
    try {
      if (url.isEmpty) return null;

      final imageProvider = CachedNetworkImageProvider(url);
      final completer = Completer<ui.Image>();

      final listener = ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info.image);
        },
        onError: (dynamic error, StackTrace? stackTrace) {
          completer.completeError(error);
        },
      );

      imageProvider.resolve(const ImageConfiguration()).addListener(listener);
      return await completer.future.timeout(const Duration(seconds: 5));
    } catch (e) {
      return null;
    }
  }

  /// Create a custom marker bitmap with image and text using Canvas
  /// Uses 3x scale for crisp rendering on high-DPI devices
  Future<BitmapDescriptor> _createImageMarkerBitmap(
    String title,
    double price,
    String currency,
    String imageUrl, {
    bool isSelected = false,
  }) async {
    final recorder = ui.PictureRecorder();

    // Scale factor for high-DPI rendering (3x for crisp text)
    const double scale = 3.0;

    // Base marker dimensions (logical pixels) - wider to accommodate image
    const double baseWidth = 170;
    const double baseHeight = 70;
    const double basePadding = 8;
    const double imageSize = 50;

    // Scaled dimensions (physical pixels)
    final double width = baseWidth * scale;
    final double height = baseHeight * scale;

    // Create canvas with scaled dimensions
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width, height + (10 * scale)),
    );

    // Scale the canvas for high-DPI rendering
    canvas.scale(scale);

    // Colors based on selection state
    final bgColor = isSelected ? AppColors.primary : Colors.white;
    final textColor = isSelected ? Colors.white : const Color(0xFF333333);
    final priceColor = isSelected ? Colors.white : AppColors.primary;
    final borderColor = isSelected
        ? AppColors.primary
        : const ui.Color.fromARGB(255, 131, 131, 131);

    // Draw rounded rectangle background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, baseWidth, baseHeight),
      const Radius.circular(12),
    );

    // Shadow (scaled)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, baseWidth, baseHeight),
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

    // Load and draw image on the left side
    final ui.Image? networkImage = await _loadNetworkImage(imageUrl);
    if (networkImage != null) {
      // Create circular clip path for the image
      final imageCenterX = basePadding + imageSize / 2;
      final imageCenterY = baseHeight / 2;
      final imageRadius = imageSize / 2;

      // Save canvas state
      canvas.save();

      // Create circular clip
      final clipPath = Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(imageCenterX, imageCenterY),
            radius: imageRadius - 1,
          ),
        );
      canvas.clipPath(clipPath);

      // Draw the image scaled to fit the circular area
      final dstRect = Rect.fromLTWH(
        basePadding,
        (baseHeight - imageSize) / 2,
        imageSize,
        imageSize,
      );

      paintImage(
        canvas: canvas,
        rect: dstRect,
        image: networkImage,
        fit: BoxFit.cover,
      );

      // Restore canvas
      canvas.restore();

      // Draw circular border around the image
      final imageBorderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(
        Offset(imageCenterX, imageCenterY),
        imageRadius,
        imageBorderPaint,
      );
    } else {
      // Draw placeholder icon if image fails to load
      final placeholderRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          basePadding,
          (baseHeight - imageSize) / 2,
          imageSize,
          imageSize,
        ),
        const Radius.circular(8),
      );

      final placeholderBgPaint = Paint()..color = Colors.grey.shade200;
      canvas.drawRRect(placeholderRect, placeholderBgPaint);

      // Draw placeholder icon
      final iconTextSpan = TextSpan(
        text: '📷',
        style: const TextStyle(fontSize: 20),
      );
      final iconPainter = TextPainter(
        text: iconTextSpan,
        textDirection: ui.TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(
          basePadding + (imageSize - iconPainter.width) / 2,
          (baseHeight - iconPainter.height) / 2,
        ),
      );
    }

    // Text starting position (after image)
    final textStartX = basePadding + imageSize + 8;
    final availableTextWidth = baseWidth - textStartX - basePadding;

    // Draw title text (truncated if too long)
    final truncatedTitle = title.length > 14
        ? '${title.substring(0, 14)}..'
        : title;
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
    titlePainter.layout(maxWidth: availableTextWidth);
    titlePainter.paint(canvas, Offset(textStartX, basePadding + 4));

    // Draw price text
    final priceTextSpan = TextSpan(
      text: '${price.toStringAsFixed(0)} $currency',
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
    pricePainter.paint(canvas, Offset(textStartX, basePadding + 26));

    // Draw pointer/triangle at bottom center
    final trianglePath = Path()
      ..moveTo(baseWidth / 2 - 10, baseHeight)
      ..lineTo(baseWidth / 2, baseHeight + 10)
      ..lineTo(baseWidth / 2 + 10, baseHeight)
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
        ..moveTo(baseWidth / 2 - 10, baseHeight)
        ..lineTo(baseWidth / 2, baseHeight + 10)
        ..lineTo(baseWidth / 2 + 10, baseHeight),
      triangleBorderPaint,
    );

    // Convert to image at scaled resolution
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      width.toInt(),
      (height + (10 * scale)).toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }

    return BitmapDescriptor.bytes(
      byteData.buffer.asUint8List(),
      imagePixelRatio: scale,
    );
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
      final service = await _serviceRepository.fetchCustomerServiceDetail(
        serviceId,
      );
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

  /// Get current user location
  Future<LatLng?> getCurrentLocation({bool requestPermission = true}) async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        if (requestPermission) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return null;
          }
        } else {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final loc = LatLng(position.latitude, position.longitude);
      currentLocation.value = loc;
      return loc;
    } catch (e) {
      return null;
    }
  }

  /// Start navigation to the selected service
  Future<void> startNavigation() async {
    final service = selectedService;
    if (service == null) return;

    // Get current location
    final myLocation = await getCurrentLocation(requestPermission: true);

    if (myLocation == null) {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required for navigation',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Please enable location permission in settings',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          Get.snackbar(
            'Location Disabled',
            'Please enable location services',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to get current location',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
      return;
    }

    isNavigating.value = true;

    // Get directions polyline points
    final points = await _getPolylinePoints(
      myLocation,
      LatLng(service.latitude, service.longitude),
    );

    if (points.isNotEmpty) {
      // Create polyline
      final polyline = Polyline(
        polylineId: const PolylineId('navigation_route'),
        points: points,
        color: AppColors.primary,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      );

      polylines.assignAll({polyline});

      // Add current location marker
      final currentMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: myLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location'),
      );

      // Update markers to include current location
      markers.add(currentMarker);

      // Zoom to show both points
      await _zoomToShowRoute(
        myLocation,
        LatLng(service.latitude, service.longitude),
      );
    }
  }

  /// Stop navigation and clear route
  void stopNavigation() {
    isNavigating.value = false;
    polylines.clear();

    // Remove current location marker
    markers.removeWhere((m) => m.markerId.value == 'current_location');
  }

  /// Get polyline points between two locations using Google Directions API
  Future<List<LatLng>> _getPolylinePoints(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      // Get API key from EnvConfig
      final apiKey = EnvConfig.googleMapsApiKey;

      if (apiKey.isEmpty) {
        // If no API key, draw a straight line as fallback
        return [origin, destination];
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          return _decodePolyline(points);
        }
      }

      // Fallback to straight line
      return [origin, destination];
    } catch (e) {
      // Fallback to straight line on error
      return [origin, destination];
    }
  }

  /// Decode polyline string to list of LatLng points
  List<LatLng> _decodePolyline(String encoded) {
    final poly = <LatLng>[];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return poly;
  }

  /// Zoom map to show both current location and destination
  Future<void> _zoomToShowRoute(LatLng origin, LatLng destination) async {
    if (mapController == null) return;

    // Calculate bounds
    final bounds = LatLngBounds(
      southwest: LatLng(
        origin.latitude < destination.latitude
            ? origin.latitude
            : destination.latitude,
        origin.longitude < destination.longitude
            ? origin.longitude
            : destination.longitude,
      ),
      northeast: LatLng(
        origin.latitude > destination.latitude
            ? origin.latitude
            : destination.latitude,
        origin.longitude > destination.longitude
            ? origin.longitude
            : destination.longitude,
      ),
    );

    await mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }
}
