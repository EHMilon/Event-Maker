import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/models/review_model.dart';

/// Mock database acting as a backend server for services
/// This provides a centralized data source with API-like methods
class ServicesMock {
  // Simulate network delay
  static const Duration defaultDelay = Duration(seconds: 1);

  // =====================================================
  // IMAGE ASSETS - Centralized image references
  // =====================================================
  static const String imgPerson = 'https://i.pravatar.cc/150?u=user123';
  static const String imgCatering = 'assets/images/catering.jpg';
  static const String imgCleaning = 'assets/images/cleaning.jpg';
  static const String imgFilming = 'assets/images/filming.jpg';
  static const String imgPhotography = 'assets/images/photography.jpg';
  static const String imgCongress = 'assets/images/congress.png';

  // =====================================================
  // SERVICE PROVIDERS DATABASE
  // =====================================================
  static final Map<String, ServiceProvider> _providersDb = {
    'provider-1': ServiceProvider(
      name: 'Chef Antonio',
      role: 'Head Chef',
      imageUrl: 'https://i.pravatar.cc/150?img=11',
      bannerUrl: imgCatering,
      isVerified: true,
      bio:
          'Award-winning chef with 15 years of experience in international cuisine.',
      certifications: ['Certified Executive Chef', 'Food Safety Certified'],
    ),
    'provider-2': ServiceProvider(
      name: 'Grill Master Team',
      role: 'Catering Service',
      imageUrl: 'https://i.pravatar.cc/150?img=12',
      isVerified: true,
      bio: 'Professional BBQ and grilling specialists for outdoor events.',
      certifications: ['BBQ Championship Winner 2024'],
    ),
    'provider-3': ServiceProvider(
      name: 'Elite Cuisine',
      role: 'Premium Catering',
      imageUrl: 'https://i.pravatar.cc/150?img=13',
      bannerUrl: imgCatering,
      isVerified: true,
      bio: 'Luxury fine dining experiences for elite events.',
      certifications: ['Michelin Star Partner', 'Luxury Event Certified'],
    ),
    'provider-4': ServiceProvider(
      name: 'Wedding Films Co.',
      role: 'Professional Videographers',
      imageUrl: 'https://i.pravatar.cc/150?img=14',
      bannerUrl: imgFilming,
      isVerified: true,
      bio: 'Creating cinematic memories for your special day.',
      certifications: ['Cinematic Wedding Films Certified'],
    ),
    'provider-5': ServiceProvider(
      name: 'Studio Pro Films',
      role: 'Production House',
      imageUrl: 'https://i.pravatar.cc/150?img=15',
      isVerified: true,
      bio: 'High-quality video production for all occasions.',
      certifications: ['Film Production Licensed'],
    ),
    'provider-6': ServiceProvider(
      name: 'Truth Media',
      role: 'Documentary Filmmakers',
      imageUrl: 'https://i.pravatar.cc/150?img=16',
      isVerified: true,
      bio:
          'Professional documentary filming for corporate and personal projects.',
      certifications: ['Documentary Award Winner'],
    ),
    'provider-7': ServiceProvider(
      name: 'Sparkle Cleaners',
      role: 'Professional Cleaners',
      imageUrl: 'https://i.pravatar.cc/150?img=17',
      bannerUrl: imgCleaning,
      isVerified: true,
      bio: 'Thorough deep cleaning using eco-friendly products.',
      certifications: ['Eco-Friendly Certified', 'Deep Clean Specialist'],
    ),
    'provider-8': ServiceProvider(
      name: 'Clean Pro Team',
      role: 'Commercial Cleaning',
      imageUrl: 'https://i.pravatar.cc/150?img=18',
      isVerified: true,
      bio: 'Complete office cleaning and sanitization services.',
      certifications: ['Commercial Cleaning Licensed'],
    ),
    'provider-9': ServiceProvider(
      name: 'Event Clean Services',
      role: 'Event Specialists',
      imageUrl: 'https://i.pravatar.cc/150?img=19',
      isVerified: true,
      bio: 'Quick and efficient cleanup services after events.',
      certifications: ['Event Management Certified'],
    ),
    'provider-10': ServiceProvider(
      name: 'Portrait Studio',
      role: 'Photographers',
      imageUrl: 'https://i.pravatar.cc/150?img=20',
      bannerUrl: imgPhotography,
      isVerified: true,
      bio: 'Professional portrait photography for individuals and families.',
      certifications: ['Professional Photographer Guild'],
    ),
    'provider-11': ServiceProvider(
      name: 'Eternal Moments',
      role: 'Wedding Photographers',
      imageUrl: 'https://i.pravatar.cc/150?img=21',
      bannerUrl: imgPhotography,
      isVerified: true,
      bio: 'Capturing your special moments with artistic precision.',
      certifications: ['Wedding Photography Award', 'Adobe Certified'],
    ),
    'provider-12': ServiceProvider(
      name: 'Product Photo Pro',
      role: 'Commercial Photography',
      imageUrl: 'https://i.pravatar.cc/150?img=22',
      isVerified: true,
      bio: 'Professional product photography for e-commerce and marketing.',
      certifications: ['E-commerce Photography Expert'],
    ),
  };

  // =====================================================
  // SERVICE PACKAGES DATABASE
  // =====================================================
  static final Map<String, List<ServicePackage>> _packagesDb = {
    // Photography packages
    'photo-pkg-individual': [
      ServicePackage(
        name: 'Individual Portrait',
        price: 150,
        features: [
          '30 minutes session',
          '5 high-res photos',
          '1 outfit change',
        ],
      ),
    ],
    'photo-pkg-family': [
      ServicePackage(
        name: 'Family Session',
        price: 350,
        features: [
          '60 minutes session',
          '15 high-res photos',
          'Group and individual shots',
          'Online gallery',
        ],
      ),
    ],
    // Wedding packages (shared between photo and film)
    'wedding-pkg-basic': [
      ServicePackage(
        name: 'Basic',
        price: 120,
        features: [
          '4 hours coverage',
          '100 edited photos',
          'Online gallery',
          'Basic retouching',
        ],
      ),
    ],
    'wedding-pkg-standard': [
      ServicePackage(
        name: 'Standard',
        price: 299,
        features: [
          '6 hours coverage',
          '200 edited photos',
          'Online gallery',
          'Advanced retouching',
          'Photo album',
        ],
      ),
    ],
    'wedding-pkg-premium': [
      ServicePackage(
        name: 'Premium',
        price: 499,
        features: [
          '8 hours coverage',
          '300 edited photos',
          'Online gallery',
          'Advanced retouching',
          'Photo album',
          'Video highlights',
        ],
      ),
    ],
    // Music video packages
    'music-video-pkg-social': [
      ServicePackage(
        name: 'Social Media Edit',
        price: 400,
        features: [
          '1 minute video',
          'Vertical & Horizontal',
          'Color grading',
          'Background music',
        ],
      ),
    ],
    'music-video-pkg-pro': [
      ServicePackage(
        name: 'Professional Video',
        price: 1200,
        features: [
          '4 minute video',
          'Advanced editing',
          'Professional lighting',
          'Drone shots included',
        ],
      ),
    ],
  };

  // =====================================================
  // SERVICES DATABASE
  // =====================================================
  static final List<ServiceModel> _servicesDb = [
    // ==================== CATERING SERVICES ====================
    ServiceModel(
      id: 'service-cat-1',
      title: 'Gourmet Catering',
      description:
          'Exquisite catering services for all your events. From intimate gatherings to grand celebrations.',
      images: [imgCatering],
      type: ServiceType.catering,
      provider: _providersDb['provider-1']!,
      location: 'Marina Mall, Abu Dhabi',
      rating: 4.8,
      reviewCount: 156,
      basePrice: 150,
      priceUnit: 'AED',
      isBookmarked: false,
    ),
    ServiceModel(
      id: 'service-cat-2',
      title: 'BBQ & Grilling Pro',
      description:
          'Professional BBQ and grilling services for outdoor events and parties.',
      images: [imgCatering],
      type: ServiceType.catering,
      provider: _providersDb['provider-2']!,
      location: 'Yas Island, Abu Dhabi',
      rating: 4.5,
      reviewCount: 89,
      basePrice: 120,
      priceUnit: 'AED',
      isBookmarked: true,
    ),
    ServiceModel(
      id: 'service-cat-3',
      title: 'Fine Dining Experience',
      description: 'Luxury fine dining experience with multi-course meals.',
      images: [imgCatering],
      type: ServiceType.catering,
      provider: _providersDb['provider-3']!,
      location: 'Corniche, Abu Dhabi',
      rating: 4.9,
      reviewCount: 234,
      basePrice: 250,
      priceUnit: 'AED',
      isBookmarked: false,
    ),

    // ==================== FILMING SERVICES ====================
    ServiceModel(
      id: 'service-film-1',
      title: 'Cinematic Wedding Films',
      description:
          'Beautiful cinematic films that capture your special day in stunning HD quality.',
      images: [imgFilming],
      type: ServiceType.filming,
      provider: _providersDb['provider-4']!,
      location: 'Emirates Palace, Abu Dhabi',
      rating: 4.9,
      reviewCount: 312,
      basePrice: 350,
      priceUnit: 'AED',
      isBookmarked: false,
      packages: [
        ...?_packagesDb['wedding-pkg-basic'],
        ...?_packagesDb['wedding-pkg-standard'],
        ...?_packagesDb['wedding-pkg-premium'],
      ],
    ),
    ServiceModel(
      id: 'service-film-2',
      title: 'Music Video Production',
      description:
          'High-quality music video production with professional equipment.',
      images: [imgFilming],
      type: ServiceType.filming,
      provider: _providersDb['provider-5']!,
      location: 'Downtown, Dubai',
      rating: 4.7,
      reviewCount: 178,
      basePrice: 400,
      priceUnit: 'AED',
      isBookmarked: true,
      packages: [
        ...?_packagesDb['music-video-pkg-social'],
        ...?_packagesDb['music-video-pkg-pro'],
      ],
    ),
    ServiceModel(
      id: 'service-film-3',
      title: 'Documentary Services',
      description:
          'Professional documentary filming for corporate and personal projects.',
      images: [imgFilming],
      type: ServiceType.filming,
      provider: _providersDb['provider-6']!,
      location: 'Business Bay, Dubai',
      rating: 4.6,
      reviewCount: 95,
      basePrice: 300,
      priceUnit: 'AED',
      isBookmarked: false,
    ),

    // ==================== CLEANING SERVICES ====================
    ServiceModel(
      id: 'service-clean-1',
      title: 'Deep Home Cleaning',
      description:
          'Thorough deep cleaning for your entire home using eco-friendly products.',
      images: [imgCleaning],
      type: ServiceType.cleaning,
      provider: _providersDb['provider-7']!,
      location: 'Khalidiya, Abu Dhabi',
      rating: 4.8,
      reviewCount: 445,
      basePrice: 80,
      priceUnit: 'AED',
      isBookmarked: false,
    ),
    ServiceModel(
      id: 'service-clean-2',
      title: 'Office Sanitization',
      description:
          'Complete office cleaning and sanitization services for workplaces.',
      images: [imgCleaning],
      type: ServiceType.cleaning,
      provider: _providersDb['provider-8']!,
      location: 'Al Maryah Island',
      rating: 4.6,
      reviewCount: 267,
      basePrice: 150,
      priceUnit: 'AED',
      isBookmarked: true,
    ),
    ServiceModel(
      id: 'service-clean-3',
      title: 'Post-Event Cleanup',
      description:
          'Quick and efficient cleanup services after events and parties.',
      images: [imgCleaning],
      type: ServiceType.cleaning,
      provider: _providersDb['provider-9']!,
      location: 'Convention Center',
      rating: 4.7,
      reviewCount: 189,
      basePrice: 200,
      priceUnit: 'AED',
      isBookmarked: false,
    ),

    // ==================== PHOTOGRAPHY SERVICES ====================
    ServiceModel(
      id: 'service-photo-1',
      title: 'Portrait Photography',
      description:
          'Professional portrait photography for individuals and families.',
      images: [imgPhotography],
      type: ServiceType.photography,
      provider: _providersDb['provider-10']!,
      location: 'Corniche, Abu Dhabi',
      rating: 4.7,
      reviewCount: 267,
      basePrice: 150,
      priceUnit: 'AED',
      isBookmarked: false,
      packages: [
        ...?_packagesDb['photo-pkg-individual'],
        ...?_packagesDb['photo-pkg-family'],
      ],
    ),
    ServiceModel(
      id: 'service-photo-2',
      title: 'Wedding Photography',
      description:
          'Capture your special moments with our expert wedding photographers.',
      images: [imgPhotography],
      type: ServiceType.photography,
      provider: _providersDb['provider-11']!,
      location: 'Sheikh Zayed Mosque',
      rating: 4.9,
      reviewCount: 567,
      basePrice: 350,
      priceUnit: 'AED',
      isBookmarked: true,
      packages: [
        ...?_packagesDb['wedding-pkg-basic'],
        ...?_packagesDb['wedding-pkg-standard'],
        ...?_packagesDb['wedding-pkg-premium'],
      ],
    ),
    ServiceModel(
      id: 'service-photo-3',
      title: 'Product Photography',
      description:
          'Professional product photography for e-commerce and marketing.',
      images: [imgPhotography],
      type: ServiceType.photography,
      provider: _providersDb['provider-12']!,
      location: 'Downtown, Dubai',
      rating: 4.6,
      reviewCount: 145,
      basePrice: 200,
      priceUnit: 'AED',
      isBookmarked: false,
    ),

    // ==================== EVENT SERVICES ====================
    ServiceModel(
      id: 'service-event-1',
      title: 'Corporate Event Planning',
      description:
          'Professional event planning for corporate needs including conferences, seminars, and team building events.',
      images: [imgCongress],
      type: ServiceType.event,
      provider: _providersDb['provider-1']!,
      location: 'Dubai World Trade Centre',
      rating: 4.8,
      reviewCount: 89,
      basePrice: 500,
      priceUnit: 'AED',
      isBookmarked: false,
    ),
    ServiceModel(
      id: 'service-event-2',
      title: 'Wedding Event Management',
      description:
          'Complete wedding planning and management services for your dream wedding.',
      images: [imgCongress],
      type: ServiceType.event,
      provider: _providersDb['provider-4']!,
      location: 'Emirates Palace, Abu Dhabi',
      rating: 4.9,
      reviewCount: 156,
      basePrice: 800,
      priceUnit: 'AED',
      isBookmarked: true,
    ),

    // ==================== TRAINING SERVICES ====================
    ServiceModel(
      id: 'service-training-1',
      title: 'Photography Workshop',
      description:
          'Learn professional photography techniques from industry experts.',
      images: [imgPhotography],
      type: ServiceType.training,
      provider: _providersDb['provider-10']!,
      location: 'Abu Dhabi Art Hub',
      rating: 4.7,
      reviewCount: 78,
      basePrice: 200,
      priceUnit: 'AED',
      isBookmarked: false,
    ),
    ServiceModel(
      id: 'service-training-2',
      title: 'Culinary Masterclass',
      description: 'Hands-on cooking classes with professional chefs.',
      images: [imgCatering],
      type: ServiceType.training,
      provider: _providersDb['provider-1']!,
      location: 'Marina Mall, Abu Dhabi',
      rating: 4.8,
      reviewCount: 134,
      basePrice: 300,
      priceUnit: 'AED',
      isBookmarked: false,
    ),
  ];

  // =====================================================
  // BOOKMARKS DATABASE (User-specific bookmarks)
  // =====================================================
  static final Set<String> _bookmarkedServiceIds = {
    'service-cat-2',
    'service-film-2',
    'service-clean-2',
    'service-photo-2',
    'service-event-2',
  };

  // =====================================================
  // REVIEWS DATABASE
  // =====================================================
  static final List<ReviewModel> _reviewsDb = [
    ReviewModel(
      userName: 'John Doe',
      userImageUrl: 'https://i.pravatar.cc/150?img=1',
      date: '10 Feb',
      rating: 4,
      reviewText: 'Thank you, Fresh Food L.L.C! That was a great event.',
      providerName: 'Chef Antonio',
    ),
    ReviewModel(
      userName: 'Jane Smith',
      userImageUrl: 'https://i.pravatar.cc/150?img=2',
      date: '12 Feb',
      rating: 5,
      reviewText: 'Loved the experience, super professional.',
      providerName: 'Chef Antonio',
    ),
    ReviewModel(
      userName: 'Mike Johnson',
      userImageUrl: 'https://i.pravatar.cc/150?img=3',
      date: '15 Feb',
      rating: 5,
      reviewText: 'Amazing wedding photography! Highly recommend.',
      providerName: 'Eternal Moments',
    ),
    ReviewModel(
      userName: 'Sarah Williams',
      userImageUrl: 'https://i.pravatar.cc/150?img=4',
      date: '18 Feb',
      rating: 4,
      reviewText: 'Great cleaning service, very thorough.',
      providerName: 'Sparkle Cleaners',
    ),
    ReviewModel(
      userName: 'David Brown',
      userImageUrl: 'https://i.pravatar.cc/150?img=5',
      date: '20 Feb',
      rating: 5,
      reviewText: 'Professional video production, exceeded expectations.',
      providerName: 'Wedding Films Co.',
    ),
  ];

  // =====================================================
  // API-LIKE METHODS (Simulating Backend Endpoints)
  // =====================================================

  /// Fetch all services with optional simulated delay
  static Future<List<ServiceModel>> fetchAllServices({Duration? delay}) async {
    await Future.delayed(delay ?? defaultDelay);
    return _getServicesWithBookmarkStatus();
  }

  /// Fetch services by type
  static Future<List<ServiceModel>> fetchServicesByType(
    ServiceType type, {
    Duration? delay,
  }) async {
    await Future.delayed(delay ?? defaultDelay);
    final services = _servicesDb.where((s) => s.type == type).toList();
    return _applyBookmarkStatus(services);
  }

  /// Fetch services by category string (for home sections)
  static Future<List<ServiceModel>> fetchServicesByCategory(
    String category, {
    Duration? delay,
  }) async {
    await Future.delayed(delay ?? defaultDelay);

    if (category == 'all') {
      return _getServicesWithBookmarkStatus();
    }

    final typeMap = {
      'catering': ServiceType.catering,
      'filming': ServiceType.filming,
      'cleaning': ServiceType.cleaning,
      'photography': ServiceType.photography,
      'event': ServiceType.event,
      'training': ServiceType.training,
    };

    final type = typeMap[category];
    if (type == null) return [];

    final services = _servicesDb.where((s) => s.type == type).toList();
    return _applyBookmarkStatus(services);
  }

  /// Fetch a single service by ID
  static Future<ServiceModel?> fetchServiceById(
    String id, {
    Duration? delay,
  }) async {
    await Future.delayed(delay ?? defaultDelay);
    try {
      final service = _servicesDb.firstWhere((s) => s.id == id);
      return _applyBookmarkStatus([service]).first;
    } catch (e) {
      return null;
    }
  }

  /// Fetch bookmarked services
  static Future<List<ServiceModel>> fetchBookmarkedServices({
    Duration? delay,
  }) async {
    await Future.delayed(delay ?? defaultDelay);
    final bookmarked = _servicesDb
        .where((s) => _bookmarkedServiceIds.contains(s.id))
        .toList();
    return _applyBookmarkStatus(bookmarked);
  }

  /// Toggle bookmark status for a service
  static Future<bool> toggleBookmark(
    String serviceId, {
    Duration? delay,
  }) async {
    await Future.delayed(delay ?? Duration(milliseconds: 300));

    if (_bookmarkedServiceIds.contains(serviceId)) {
      _bookmarkedServiceIds.remove(serviceId);
      return false; // Removed from bookmarks
    } else {
      _bookmarkedServiceIds.add(serviceId);
      return true; // Added to bookmarks
    }
  }

  /// Fetch provider by ID
  static ServiceProvider? fetchProviderById(String providerId) {
    return _providersDb[providerId];
  }

  /// Fetch all providers
  static List<ServiceProvider> fetchAllProviders() {
    return _providersDb.values.toList();
  }

  /// Fetch reviews for a provider
  static Future<List<ReviewModel>> fetchReviewsForProvider(
    String providerName, {
    Duration? delay,
  }) async {
    await Future.delayed(delay ?? defaultDelay);
    return _reviewsDb.where((r) => r.providerName == providerName).toList();
  }

  /// Fetch all reviews
  static Future<List<ReviewModel>> fetchAllReviews({Duration? delay}) async {
    await Future.delayed(delay ?? defaultDelay);
    return List.from(_reviewsDb);
  }

  /// Search services by query
  static Future<List<ServiceModel>> searchServices(
    String query, {
    Duration? delay,
  }) async {
    await Future.delayed(delay ?? defaultDelay);

    if (query.isEmpty) return _getServicesWithBookmarkStatus();

    final searchLower = query.toLowerCase();
    final results = _servicesDb.where((service) {
      return service.title.toLowerCase().contains(searchLower) ||
          service.description.toLowerCase().contains(searchLower) ||
          service.location.toLowerCase().contains(searchLower) ||
          service.provider.name.toLowerCase().contains(searchLower);
    }).toList();

    return _applyBookmarkStatus(results);
  }

  // =====================================================
  // SYNC METHODS (For immediate access without delay)
  // =====================================================

  /// Get all services immediately (no delay)
  static List<ServiceModel> get allServices => _getServicesWithBookmarkStatus();

  /// Get bookmarked services immediately (no delay)
  static List<ServiceModel> get bookmarkedServices {
    final bookmarked = _servicesDb
        .where((s) => _bookmarkedServiceIds.contains(s.id))
        .toList();
    return _applyBookmarkStatus(bookmarked);
  }

  /// Get services by type immediately (no delay)
  static List<ServiceModel> getServicesByType(ServiceType type) {
    final services = _servicesDb.where((s) => s.type == type).toList();
    return _applyBookmarkStatus(services);
  }

  /// Get services for home section immediately (no delay)
  static List<ServiceModel> getHomeSectionServices(String section) {
    if (section == 'all') return _getServicesWithBookmarkStatus();

    final typeMap = {
      'catering': ServiceType.catering,
      'filming': ServiceType.filming,
      'cleaning': ServiceType.cleaning,
      'photography': ServiceType.photography,
      'event': ServiceType.event,
      'training': ServiceType.training,
    };

    final type = typeMap[section];
    if (type == null) return [];

    final services = _servicesDb.where((s) => s.type == type).toList();
    return _applyBookmarkStatus(services);
  }

  /// Get all reviews immediately (no delay)
  static List<ReviewModel> get allReviews => List.from(_reviewsDb);

  // =====================================================
  // HELPER METHODS
  // =====================================================

  /// Apply bookmark status to services based on current bookmarks
  static List<ServiceModel> _applyBookmarkStatus(List<ServiceModel> services) {
    return services.map((service) {
      final isBookmarked = _bookmarkedServiceIds.contains(service.id);
      return service.copyWith(isBookmarked: isBookmarked);
    }).toList();
  }

  /// Get all services with current bookmark status
  static List<ServiceModel> _getServicesWithBookmarkStatus() {
    return _applyBookmarkStatus(_servicesDb);
  }

  /// Get service count by type
  static int getServiceCountByType(ServiceType type) {
    return _servicesDb.where((s) => s.type == type).length;
  }

  /// Get total service count
  static int get totalServiceCount => _servicesDb.length;

  /// Get total provider count
  static int get totalProviderCount => _providersDb.length;

  /// Check if service is bookmarked
  static bool isServiceBookmarked(String serviceId) {
    return _bookmarkedServiceIds.contains(serviceId);
  }
}
