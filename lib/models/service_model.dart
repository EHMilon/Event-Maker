import 'review_model.dart';

enum ServiceType { event, photography, training, catering, cleaning, filming }

// Event Venue options for Event service type
enum EventVenue { hotelVenues, mallVenues, restaurantVenues, eventHalls }

extension EventVenueExtension on EventVenue {
  String get label {
    switch (this) {
      case EventVenue.hotelVenues:
        return 'Hotel Venues';
      case EventVenue.mallVenues:
        return 'Mall Venues';
      case EventVenue.restaurantVenues:
        return 'Restaurant Venues';
      case EventVenue.eventHalls:
        return 'Event Halls';
    }
  }
}

// Service Sub-Options for specific ServiceAs types (Buffet, Live Cooking, Outdoor Cafe Kiosk)
enum ServiceSubOption {
  // Buffet options
  indianBuffet,
  internationalBuffet,
  japaneseBuffet,
  thaiBuffet,
  // Live Cooking options
  pastryStation,
  shawarmaStation,
  burgerPizzaSushiStation,
  // Outdoor Cafe Kiosk options
  outdoorMobileFoodTruck,
  mobileCoffeeCarMiniCar,
  coffeeCart,
  outdoorCoffeeKiosk,
  coffeeHospitalityServiceSub,
}

extension ServiceSubOptionExtension on ServiceSubOption {
  String get label {
    switch (this) {
      // Buffet
      case ServiceSubOption.indianBuffet:
        return 'Indian Buffet';
      case ServiceSubOption.internationalBuffet:
        return 'International Buffet';
      case ServiceSubOption.japaneseBuffet:
        return 'Japanese Buffet';
      case ServiceSubOption.thaiBuffet:
        return 'Thai Buffet';
      // Live Cooking
      case ServiceSubOption.pastryStation:
        return 'Pastry Station';
      case ServiceSubOption.shawarmaStation:
        return 'Shawarma Station';
      case ServiceSubOption.burgerPizzaSushiStation:
        return 'Burger Station/Pizza Station/Sushi Station';
      // Outdoor Cafe Kiosk
      case ServiceSubOption.outdoorMobileFoodTruck:
        return 'Outdoor Mobile Food Truck';
      case ServiceSubOption.mobileCoffeeCarMiniCar:
        return 'Mobile Coffee Car/Mini Car';
      case ServiceSubOption.coffeeCart:
        return 'Coffee Cart';
      case ServiceSubOption.outdoorCoffeeKiosk:
        return 'Outdoor Coffee Kiosk';
      case ServiceSubOption.coffeeHospitalityServiceSub:
        return 'Coffee Hospitality Service';
    }
  }
}

// Service As options based on ProviderRole
enum ServiceAs {
  // Freelancer options
  waitress,
  barista,
  juiceMaker,
  sandwichMaker,
  burgerMaker,
  shawarmaMaker,
  chef,
  // Business options
  cateringBusiness,
  buffet,
  liveCooking,
  outdoorCafeKiosk,
  coffeeHospitalityService,
  decoration,
  // Productive Family options
  villas,
  farms,
  lands,
  // Professional Trainer options
  furniture,
  cateringTrainer,
  fitnessTrainer,
}

extension ServiceAsExtension on ServiceAs {
  String get label {
    switch (this) {
      // Freelancer
      case ServiceAs.waitress:
        return 'Waitress';
      case ServiceAs.barista:
        return 'Barista (Hot drinks)';
      case ServiceAs.juiceMaker:
        return 'Juice Maker';
      case ServiceAs.sandwichMaker:
        return 'Sandwich Maker';
      case ServiceAs.burgerMaker:
        return 'Burger Maker';
      case ServiceAs.shawarmaMaker:
        return 'Shawarma Maker';
      case ServiceAs.chef:
        return 'Chef';
      // Business
      case ServiceAs.cateringBusiness:
        return 'Catering';
      case ServiceAs.buffet:
        return 'Buffet';
      case ServiceAs.liveCooking:
        return 'Live Cooking';
      case ServiceAs.outdoorCafeKiosk:
        return 'Outdoor Cafe Kiosk';
      case ServiceAs.coffeeHospitalityService:
        return 'Coffee Hospitality Service';
      case ServiceAs.decoration:
        return 'Decoration';
      // Productive Family
      case ServiceAs.villas:
        return 'Villas';
      case ServiceAs.farms:
        return 'Farms';
      case ServiceAs.lands:
        return 'Lands';
      // Professional Trainer
      case ServiceAs.furniture:
        return 'Furniture';
      case ServiceAs.cateringTrainer:
        return 'Catering';
      case ServiceAs.fitnessTrainer:
        return 'Fitness Trainer';
    }
  }
}

/// Service availability model matching API response
class ServiceAvailability {
  final int id;
  final List<String> weekDays;
  final String startTime;
  final String endTime;
  final String address;
  final String latitude;
  final String longitude;
  final int sortOrder;

  const ServiceAvailability({
    required this.id,
    required this.weekDays,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.sortOrder,
  });

  factory ServiceAvailability.fromJson(Map<String, dynamic> json) {
    return ServiceAvailability(
      id: json['id'] as int? ?? 0,
      weekDays:
          (json['week_days'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: json['latitude'] as String? ?? '',
      longitude: json['longitude'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_days': weekDays,
      'start_time': startTime,
      'end_time': endTime,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'sort_order': sortOrder,
    };
  }
}

/// Package feature model matching API response
class PackageFeature {
  final int id;
  final String title;
  final int sortOrder;

  const PackageFeature({
    required this.id,
    required this.title,
    required this.sortOrder,
  });

  factory PackageFeature.fromJson(Map<String, dynamic> json) {
    return PackageFeature(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'sort_order': sortOrder};
  }

  /// Convert to string for display
  @override
  String toString() => title;
}

/// Service package model matching API response
/// Supports both legacy format (List<String> features) and new API format (List<PackageFeature> features)
class ServicePackage {
  final int id;
  final String name;
  final String price;
  final int sortOrder;
  final List<PackageFeature> features;

  const ServicePackage({
    this.id = 0,
    required this.name,
    required this.price,
    this.sortOrder = 0,
    this.features = const [],
  });

  /// Legacy constructor for backward compatibility with List<String> features
  factory ServicePackage.legacy({
    required String name,
    required double price,
    List<String> features = const [],
  }) {
    return ServicePackage(
      name: name,
      price: price.toStringAsFixed(2),
      features: features
          .asMap()
          .map(
            (index, title) => MapEntry(
              index,
              PackageFeature(id: index, title: title, sortOrder: index),
            ),
          )
          .values
          .toList(),
    );
  }

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    // Parse features with better error handling
    final featuresList = <PackageFeature>[];
    final rawFeatures = json['features'] as List<dynamic>?;
    if (rawFeatures != null) {
      for (final feature in rawFeatures) {
        if (feature is Map) {
          // Handle any Map type (Map<String, dynamic>, _InternalLinkedHashMap, etc.)
          final map = Map<String, dynamic>.from(feature);
          featuresList.add(PackageFeature.fromJson(map));
        } else if (feature is String) {
          // Handle case where feature might be a stringified dictionary
          // Backend sends: {'title': 'text', 'sort_order': 0} with single quotes
          String extractedTitle = feature;
          if (feature.trim().startsWith('{') && feature.contains('title')) {
            // Try to extract title from single-quoted JSON: {'title': 'value', ...}
            final singleQuoteMatch = RegExp(
              r"'title'\s*:\s*'([^']+)'",
            ).firstMatch(feature);
            // Try to extract title from double-quoted JSON: {"title": "value", ...}
            final doubleQuoteMatch = RegExp(
              r'"title"\s*:\s*"([^"]+)"',
            ).firstMatch(feature);

            if (singleQuoteMatch != null && singleQuoteMatch.group(1) != null) {
              extractedTitle = singleQuoteMatch.group(1)!;
            } else if (doubleQuoteMatch != null &&
                doubleQuoteMatch.group(1) != null) {
              extractedTitle = doubleQuoteMatch.group(1)!;
            }
          }

          featuresList.add(
            PackageFeature(id: 0, title: extractedTitle, sortOrder: 0),
          );
        }
      }
    }

    return ServicePackage(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      price: json['price']?.toString() ?? '0.00',
      sortOrder: json['sort_order'] as int? ?? 0,
      features: featuresList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'sort_order': sortOrder,
      'features': features.map((f) => f.toJson()).toList(),
    };
  }

  /// Get price as double
  double get priceValue => double.tryParse(price) ?? 0.0;

  /// Get feature titles as strings (for backward compatibility)
  List<String> get featureTitles => features.map((f) => f.title).toList();
}

class ServiceModel {
  // API response fields
  final int apiId;
  final int providerId;
  final String title;
  final String description;
  final String serviceTypeName;
  final String roleName;
  final String serviceAsName;
  final String? eventVenue;
  final int? attendanceCapacity;
  final String? options;
  final String coverImage;
  final bool canGoOutsideLocation;
  final bool canNotGoOutsideLocation;
  final bool requiresConfirmation;
  final String currency;
  final String status;
  final String approvalStatus;
  final bool isFeatured;
  final bool isDeleted;
  final String averageRating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ServiceAvailability> availabilities;
  final List<ServicePackage> packages;

  // Legacy fields for backward compatibility with existing UI
  final String id;
  final ServiceType type;
  final ServiceProvider provider;
  final List<String> images;
  final String location;
  final double? rating;
  final int? reviewCount;
  final DateTime? date;
  final double? basePrice;
  final String priceUnit;
  final bool isBookmarked;
  final ServiceAs? serviceAs;
  final EventVenue? eventVenueEnum;
  final List<ServiceSubOption>? subOptions;

  ServiceModel({
    // Support both int (API) and String (legacy) id
    dynamic id,
    this.apiId = 0,
    this.providerId = 0,
    required this.title,
    required this.description,
    this.serviceTypeName = '',
    this.roleName = '',
    this.serviceAsName = '',
    this.eventVenue,
    this.attendanceCapacity,
    this.options,
    this.coverImage = '',
    this.canGoOutsideLocation = false,
    this.canNotGoOutsideLocation = false,
    this.requiresConfirmation = false,
    this.currency = 'AED',
    this.status = 'active',
    this.approvalStatus = 'pending',
    this.isFeatured = false,
    this.isDeleted = false,
    this.averageRating = '0.00',
    this.totalReviews = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.availabilities = const [],
    this.packages = const [],
    // Legacy fields
    this.type = ServiceType.catering,
    this.provider = const ServiceProvider(name: '', role: '', imageUrl: ''),
    this.images = const [],
    this.location = '',
    this.rating,
    this.reviewCount,
    this.date,
    this.basePrice,
    this.priceUnit = 'AED',
    this.isBookmarked = false,
    this.serviceAs,
    this.eventVenueEnum,
    this.subOptions,
  }) : id = id?.toString() ?? apiId.toString(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Factory constructor from API response
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final apiId = json['id'] as int? ?? 0;
    return ServiceModel(
      id: apiId.toString(),
      apiId: apiId,
      providerId: json['provider_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      serviceTypeName: json['service_type_name'] as String? ?? '',
      roleName: json['role_name'] as String? ?? '',
      serviceAsName: json['service_as_name'] as String? ?? '',
      eventVenue: json['event_vanue'] as String?, // Note: API has typo "vanue"
      attendanceCapacity: json['attendance_capacity'] as int?,
      options: json['options'] as String?,
      coverImage: json['cover_image'] as String? ?? '',
      canGoOutsideLocation: json['can_go_outside_location'] as bool? ?? false,
      canNotGoOutsideLocation:
          json['can_not_go_outside_location'] as bool? ?? false,
      requiresConfirmation: json['requires_confirmation'] as bool? ?? false,
      currency: json['currency'] as String? ?? 'AED',
      status: json['status'] as String? ?? 'active',
      approvalStatus: json['approval_status'] as String? ?? 'pending',
      isFeatured: json['is_featured'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      averageRating: json['average_rating'] as String? ?? '0.00',
      totalReviews: json['total_reviews'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      availabilities:
          (json['availabilities'] as List<dynamic>?)
              ?.map(
                (e) => ServiceAvailability.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      packages:
          (json['packages'] as List<dynamic>?)
              ?.map((e) => ServicePackage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      // Map serviceTypeName to ServiceType enum
      type: _parseServiceType(json['service_type_name'] as String?),
      // Parse provider data from nested provider object
      provider: _parseProvider(
        json['provider'] as Map<String, dynamic>?,
        json['role_name'] as String?,
      ),
      // Use coverImage for images list
      images: json['cover_image'] != null
          ? [json['cover_image'] as String]
          : [],
      // Get location from first availability
      location: _extractLocation(json['availabilities'] as List<dynamic>?),
      // Use provider's rating if service-level rating is not available
      rating: double.tryParse(json['average_rating'] as String? ?? 
          (json['provider'] as Map<String, dynamic>?)?['average_rating'] as String? ?? '0'),
      reviewCount: json['total_reviews'] as int? ?? 
          (json['provider'] as Map<String, dynamic>?)?['total_reviews'] as int?,
    );
  }

  static ServiceType _parseServiceType(String? typeName) {
    if (typeName == null) return ServiceType.catering;
    switch (typeName.toLowerCase()) {
      case 'event':
        return ServiceType.event;
      case 'photography':
        return ServiceType.photography;
      case 'professional trainer':
      case 'training':
        return ServiceType.training;
      case 'catering':
      case 'hospitality':
        return ServiceType.catering;
      case 'cleaning':
        return ServiceType.cleaning;
      case 'filming':
        return ServiceType.filming;
      default:
        return ServiceType.catering;
    }
  }

  static String _extractLocation(List<dynamic>? availabilities) {
    if (availabilities == null || availabilities.isEmpty) return '';
    final firstAvailability = availabilities.first as Map<String, dynamic>?;
    return firstAvailability?['address'] as String? ?? '';
  }

  /// Parse provider data from API response
  /// API returns: {"id": 4, "name": "Abdul ALi", "avatar": "/media/users/avatar/...", "average_rating": "4.50", "total_reviews": 2}
  static ServiceProvider _parseProvider(
    Map<String, dynamic>? providerJson,
    String? roleName,
  ) {
    if (providerJson == null) {
      return ServiceProvider(
        name: '',
        role: roleName ?? '',
        imageUrl: '',
      );
    }

    return ServiceProvider(
      name: providerJson['name'] as String? ?? '',
      role: roleName ?? '',
      imageUrl: providerJson['avatar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': apiId,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'service_type_name': serviceTypeName,
      'role_name': roleName,
      'service_as_name': serviceAsName,
      'event_vanue': eventVenue, // Note: API has typo "vanue"
      'attendance_capacity': attendanceCapacity,
      'options': options,
      'cover_image': coverImage,
      'can_go_outside_location': canGoOutsideLocation,
      'can_not_go_outside_location': canNotGoOutsideLocation,
      'requires_confirmation': requiresConfirmation,
      'currency': currency,
      'status': status,
      'approval_status': approvalStatus,
      'is_featured': isFeatured,
      'is_deleted': isDeleted,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'availabilities': availabilities.map((a) => a.toJson()).toList(),
      'packages': packages.map((p) => p.toJson()).toList(),
    };
  }

  ServiceModel copyWith({
    dynamic id,
    int? apiId,
    int? providerId,
    String? title,
    String? description,
    String? serviceTypeName,
    String? roleName,
    String? serviceAsName,
    String? eventVenue,
    int? attendanceCapacity,
    String? options,
    String? coverImage,
    bool? canGoOutsideLocation,
    bool? canNotGoOutsideLocation,
    bool? requiresConfirmation,
    String? currency,
    String? status,
    String? approvalStatus,
    bool? isFeatured,
    bool? isDeleted,
    String? averageRating,
    int? totalReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ServiceAvailability>? availabilities,
    List<ServicePackage>? packages,
    // Legacy fields
    ServiceType? type,
    ServiceProvider? provider,
    List<String>? images,
    String? location,
    double? rating,
    int? reviewCount,
    DateTime? date,
    double? basePrice,
    String? priceUnit,
    bool? isBookmarked,
    ServiceAs? serviceAs,
    EventVenue? eventVenueEnum,
    List<ServiceSubOption>? subOptions,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      apiId: apiId ?? this.apiId,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      description: description ?? this.description,
      serviceTypeName: serviceTypeName ?? this.serviceTypeName,
      roleName: roleName ?? this.roleName,
      serviceAsName: serviceAsName ?? this.serviceAsName,
      eventVenue: eventVenue ?? this.eventVenue,
      attendanceCapacity: attendanceCapacity ?? this.attendanceCapacity,
      options: options ?? this.options,
      coverImage: coverImage ?? this.coverImage,
      canGoOutsideLocation: canGoOutsideLocation ?? this.canGoOutsideLocation,
      canNotGoOutsideLocation:
          canNotGoOutsideLocation ?? this.canNotGoOutsideLocation,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isFeatured: isFeatured ?? this.isFeatured,
      isDeleted: isDeleted ?? this.isDeleted,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      availabilities: availabilities ?? this.availabilities,
      packages: packages ?? this.packages,
      // Legacy fields
      type: type ?? this.type,
      provider: provider ?? this.provider,
      images: images ?? this.images,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      date: date ?? this.date,
      basePrice: basePrice ?? this.basePrice,
      priceUnit: priceUnit ?? this.priceUnit,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      serviceAs: serviceAs ?? this.serviceAs,
      eventVenueEnum: eventVenueEnum ?? this.eventVenueEnum,
      subOptions: subOptions ?? this.subOptions,
    );
  }

  /// Get rating as double
  double get ratingValue => double.tryParse(averageRating) ?? 0.0;

  /// Check if service is approved
  bool get isApproved => approvalStatus == 'approved';

  /// Check if service is pending approval
  bool get isPendingApproval => approvalStatus == 'pending';

  /// Check if service is rejected
  bool get isRejected => approvalStatus == 'rejected';

  /// Get first availability address as location
  String get displayLocation =>
      availabilities.isNotEmpty ? availabilities.first.address : location;

  /// Get lowest package price as base price
  double get lowestPackagePrice {
    if (packages.isEmpty) return basePrice ?? 0;
    final prices = packages.map((p) => p.priceValue).toList();
    return prices.reduce((a, b) => a < b ? a : b);
  }
}

class ServiceProvider {
  final String name;
  final String role;
  final String imageUrl;
  final String? bannerUrl;
  final bool isVerified;
  final List<String>? certifications;
  final String? bio;
  final List<ServiceModel>? services;
  final List<ReviewModel>? reviews;

  const ServiceProvider({
    required this.name,
    required this.role,
    required this.imageUrl,
    this.bannerUrl,
    this.isVerified = false,
    this.certifications,
    this.bio,
    this.services,
    this.reviews,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      bannerUrl: json['banner_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'image_url': imageUrl,
      'banner_url': bannerUrl,
      'is_verified': isVerified,
      'certifications': certifications,
      'bio': bio,
    };
  }
}
