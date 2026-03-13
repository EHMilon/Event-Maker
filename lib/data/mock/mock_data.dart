import 'package:event_maker/data/models/review_model.dart';
import 'package:event_maker/data/models/service_model.dart';

// Centralized mock data file
// Use local images and bookmark flag for each service

class MockData {
  // Available local images
  static const String imgPerson = 'https://i.pravatar.cc/150?u=user123';
  static const String imgCatering = 'assets/images/catering.jpg';
  static const String imgCleaning = 'assets/images/cleaning.jpg';
  static const String imgFilming = 'assets/images/filming.jpg';
  static const String imgPhotography = 'assets/images/photography.jpg';
  static const String imgCongress = 'assets/images/congress.png';

  // Home screen services with unique data and bookmark flag
  static final List<ServiceModel> homeServices = [
    // Catering Services
    ServiceModel(
      id: 'cat-1',
      title: 'Gourmet Catering',
      description:
          'Exquisite catering services for all your events. From intimate gatherings to grand celebrations.',
      images: [imgCatering],
      type: ServiceType.catering,
      provider: ServiceProvider(
        name: 'Chef Antonio',
        role: 'Head Chef',
        imageUrl: imgPerson,
        isVerified: true,
        bio:
            'Award-winning chef with 15 years of experience in international cuisine.',
      ),
      location: 'Marina Mall, Abu Dhabi',
      rating: 4.8,
      reviewCount: 156,
      basePrice: 150,
      priceUnit: 'AED',
      isBookmarked: false,
    ),
    ServiceModel(
      id: 'cat-2',
      title: 'BBQ & Grilling Pro',
      description:
          'Professional BBQ and grilling services for outdoor events and parties.',
      images: [imgCatering],
      type: ServiceType.catering,
      provider: ServiceProvider(
        name: 'Grill Master Team',
        role: 'Catering Service',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Yas Island, Abu Dhabi',
      rating: 4.5,
      reviewCount: 89,
      basePrice: 120,
      priceUnit: 'AED',
      isBookmarked: true,
    ),
    ServiceModel(
      id: 'cat-3',
      title: 'Fine Dining Experience',
      description: 'Luxury fine dining experience with multi-course meals.',
      images: [imgCatering],
      type: ServiceType.catering,
      provider: ServiceProvider(
        name: 'Elite Cuisine',
        role: 'Premium Catering',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Corniche, Abu Dhabi',
      rating: 4.9,
      reviewCount: 234,
      basePrice: 250,
      priceUnit: 'AED',
      isBookmarked: false,
    ),

    // Filming Services
    ServiceModel(
      id: 'film-1',
      title: 'Cinematic Wedding Films',
      description:
          'Beautiful cinematic films that capture your special day in stunning HD quality.',
      images: [imgFilming],
      type: ServiceType.filming,
      provider: ServiceProvider(
        name: 'Wedding Films Co.',
        role: 'Professional Videographers',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Emirates Palace, Abu Dhabi',
      rating: 4.9,
      reviewCount: 312,
      basePrice: 350,
      priceUnit: 'AED',
      isBookmarked: false,
      packages: [
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
    ),
    ServiceModel(
      id: 'film-2',
      title: 'Music Video Production',
      description:
          'High-quality music video production with professional equipment.',
      images: [imgFilming],
      type: ServiceType.filming,
      provider: ServiceProvider(
        name: 'Studio Pro Films',
        role: 'Production House',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Downtown, Dubai',
      rating: 4.7,
      reviewCount: 178,
      basePrice: 400,
      priceUnit: 'AED',
      isBookmarked: true,
      packages: [
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
    ),
    ServiceModel(
      id: 'film-3',
      title: 'Documentary Services',
      description:
          'Professional documentary filming for corporate and personal projects.',
      images: [imgFilming],
      type: ServiceType.filming,
      provider: ServiceProvider(
        name: 'Truth Media',
        role: 'Documentary Filmmakers',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Business Bay, Dubai',
      rating: 4.6,
      reviewCount: 95,
      basePrice: 300,
      priceUnit: 'AED',
      isBookmarked: false,
    ),

    // Cleaning Services
    ServiceModel(
      id: 'clean-1',
      title: 'Deep Home Cleaning',
      description:
          'Thorough deep cleaning for your entire home using eco-friendly products.',
      images: [imgCleaning],
      type: ServiceType.cleaning,
      provider: ServiceProvider(
        name: 'Sparkle Cleaners',
        role: 'Professional Cleaners',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Khalidiya, Abu Dhabi',
      rating: 4.8,
      reviewCount: 445,
      basePrice: 80,
      priceUnit: 'AED',
      isBookmarked: false,
    ),
    ServiceModel(
      id: 'clean-2',
      title: 'Office Sanitization',
      description:
          'Complete office cleaning and sanitization services for workplaces.',
      images: [imgCleaning],
      type: ServiceType.cleaning,
      provider: ServiceProvider(
        name: 'Clean Pro Team',
        role: 'Commercial Cleaning',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Al Maryah Island',
      rating: 4.6,
      reviewCount: 267,
      basePrice: 150,
      priceUnit: 'AED',
      isBookmarked: true,
    ),
    ServiceModel(
      id: 'clean-3',
      title: 'Post-Event Cleanup',
      description:
          'Quick and efficient cleanup services after events and parties.',
      images: [imgCleaning],
      type: ServiceType.cleaning,
      provider: ServiceProvider(
        name: 'Event Clean Services',
        role: 'Event Specialists',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Convention Center',
      rating: 4.7,
      reviewCount: 189,
      basePrice: 200,
      priceUnit: 'AED',
      isBookmarked: false,
    ),

    // Photography Services
    ServiceModel(
      id: 'photo-1',
      title: 'Portrait Photography',
      description:
          'Professional portrait photography for individuals and families.',
      images: [imgPhotography],
      type: ServiceType.photography,
      provider: ServiceProvider(
        name: 'Portrait Studio',
        role: 'Photographers',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Corniche, Abu Dhabi',
      rating: 4.7,
      reviewCount: 267,
      basePrice: 150,
      priceUnit: 'AED',
      isBookmarked: false,
      packages: [
        ServicePackage(
          name: 'Individual Portrait',
          price: 150,
          features: [
            '30 minutes session',
            '5 high-res photos',
            '1 outfit change',
          ],
        ),
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
    ),
    ServiceModel(
      id: 'photo-2',
      title: 'Wedding Photography',
      description:
          'Capture your special moments with our expert wedding photographers.',
      images: [imgPhotography],
      type: ServiceType.photography,
      provider: ServiceProvider(
        name: 'Eternal Moments',
        role: 'Wedding Photographers',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Sheikh Zayed Mosque',
      rating: 4.9,
      reviewCount: 567,
      basePrice: 350,
      priceUnit: 'AED',
      isBookmarked: true,
      packages: [
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
    ),
    ServiceModel(
      id: 'photo-3',
      title: 'Product Photography',
      description:
          'Professional product photography for e-commerce and marketing.',
      images: [imgPhotography],
      type: ServiceType.photography,
      provider: ServiceProvider(
        name: 'Product Photo Pro',
        role: 'Commercial Photography',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Downtown, Dubai',
      rating: 4.6,
      reviewCount: 145,
      basePrice: 200,
      priceUnit: 'AED',
      isBookmarked: false,
    ),
  ];

  // Bookmark services (subset with isBookmarked: true)
  static final List<ServiceModel> bookmarkedServices = homeServices
      .where((s) => s.isBookmarked)
      .toList();

  // Get services by type
  static List<ServiceModel> getServicesByType(ServiceType type) {
    return homeServices.where((s) => s.type == type).toList();
  }

  // Requests mock data for SP
  static final List<ServiceModel> requests = [
    // Upcoming requests (future dates)
    ServiceModel(
      id: 'req-upcoming-1',
      title: 'Wedding Catering Services',
      description:
          'Capturing your special moments with artistic precision and creativity. We specialize in event photography with over 8 years of experience documenting weddings, corporate events, and celebrations.',
      images: [
        'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=1000&auto=format&fit=crop',
      ],
      type: ServiceType.catering,
      provider: ServiceProvider(
        name: 'Elite Event Photography',
        role: 'Photographer',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location:
          'Airport Rd - Al Manhal - W14 02 - Abu Dhabi - United Arab Emirates',
      date: DateTime(2026, 3, 15, 16, 0), // Future date - March 15, 2026
      basePrice: 120,
      priceUnit: 'AED',
      packages: [
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
    ),
    // Past requests (past dates - before current date Feb 20, 2026)
    ServiceModel(
      id: 'req-past-1',
      title: 'Corporate Event Planning',
      description: 'Professional event planning for corporate needs.',
      images: [
        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=1000&auto=format&fit=crop',
      ],
      type: ServiceType.event,
      provider: ServiceProvider(
        name: 'Pro Events',
        role: 'Planner',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Business Bay, Dubai',
      date: DateTime(2026, 1, 10, 16, 0), // Past date - Jan 10, 2026
      basePrice: 200,
      priceUnit: 'AED',
    ),
    ServiceModel(
      id: 'req-past-2',
      title: 'Birthday Party Décor',
      description: 'Stunning decorations for birthday parties.',
      images: [
        'https://images.unsplash.com/photo-1530103043960-ef38714abb15?q=80&w=1000&auto=format&fit=crop',
      ],
      type: ServiceType.event,
      provider: ServiceProvider(
        name: 'Decor Masters',
        role: 'Decorator',
        imageUrl: imgPerson,
        isVerified: true,
      ),
      location: 'Corniche, Abu Dhabi',
      date: DateTime(2025, 12, 5, 16, 0), // Past date - Dec 5, 2025
      basePrice: 150,
      priceUnit: 'AED',
    ),
  ];

  // Get services for home section
  static List<ServiceModel> getHomeSectionServices(String section) {
    final typeMap = {
      'catering': ServiceType.catering,
      'filming': ServiceType.filming,
      'cleaning': ServiceType.cleaning,
      'photography': ServiceType.photography,
    };
    final type = typeMap[section] ?? ServiceType.event;
    return getServicesByType(type);
  }

  static final List<ReviewModel> reviews = [
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
  ];
}
