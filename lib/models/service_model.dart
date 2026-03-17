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
  // Productive Family options
  villas,
  farms,
  lands,
  // Professional Trainer options
  furniture,
  cateringTrainer,
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
    }
  }
}

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final ServiceType type;
  final ServiceProvider provider;
  final String location;
  final double? rating;
  final int? reviewCount;
  final DateTime? date;
  final double? basePrice;
  final String priceUnit;
  final List<ServicePackage>? packages;
  final bool isBookmarked;
  final ServiceAs? serviceAs;
  final EventVenue? eventVenue;
  final List<ServiceSubOption>? subOptions;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.type,
    required this.provider,
    required this.location,
    this.rating,
    this.reviewCount,
    this.date,
    this.basePrice,
    this.priceUnit = 'AED',
    this.packages,
    this.isBookmarked = false,
    this.serviceAs,
    this.eventVenue,
    this.subOptions,
  });

  ServiceModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? images,
    ServiceType? type,
    ServiceProvider? provider,
    String? location,
    double? rating,
    int? reviewCount,
    DateTime? date,
    double? basePrice,
    String? priceUnit,
    List<ServicePackage>? packages,
    bool? isBookmarked,
    ServiceAs? serviceAs,
    EventVenue? eventVenue,
    List<ServiceSubOption>? subOptions,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      date: date ?? this.date,
      basePrice: basePrice ?? this.basePrice,
      priceUnit: priceUnit ?? this.priceUnit,
      packages: packages ?? this.packages,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      serviceAs: serviceAs ?? this.serviceAs,
      eventVenue: eventVenue ?? this.eventVenue,
      subOptions: subOptions ?? this.subOptions,
    );
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

  ServiceProvider({
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
}

class ServicePackage {
  final String name;
  final double price;
  final List<String> features;

  ServicePackage({
    required this.name,
    required this.price,
    required this.features,
  });
}
