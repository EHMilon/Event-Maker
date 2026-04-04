import 'package:event_maker/models/service_model.dart';

class CustomerBookingModel {
  final String image;
  final String date;
  final String title;
  final String subtitle;
  final ServiceModel? service;

  CustomerBookingModel({
    required this.image,
    required this.date,
    required this.title,
    required this.subtitle,
    this.service,
  });

  factory CustomerBookingModel.fromJson(Map<String, dynamic> json) {
    return CustomerBookingModel(
      image: json['image'] ?? '',
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      service: json['service'] != null
          ? ServiceModel(
              id: json['service']['id'] ?? '',
              title: json['service']['title'] ?? '',
              description: json['service']['description'] ?? '',
              images: List<String>.from(json['service']['images'] ?? []),
              type: ServiceType.values.firstWhere(
                (e) => e.name == json['service']['type'],
                orElse: () => ServiceType.event,
              ),
              provider: ServiceProvider(
                name: json['service']['provider']['name'] ?? '',
                role: json['service']['provider']['role'] ?? '',
                imageUrl: json['service']['provider']['imageUrl'] ?? '',
                isVerified: json['service']['provider']['isVerified'] ?? false,
              ),
              location: json['service']['location'] ?? '',
              rating: (json['service']['rating'] as num?)?.toDouble(),
              reviewCount: json['service']['reviewCount'],
              basePrice: (json['service']['basePrice'] as num?)?.toDouble(),
              priceUnit: json['service']['priceUnit'] ?? 'AED',
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'date': date,
      'title': title,
      'subtitle': subtitle,
      'service': service != null
          ? {
              'id': service!.id,
              'title': service!.title,
              'description': service!.description,
              'images': service!.images,
              'type': service!.type.name,
              'provider': {
                'name': service!.provider.name,
                'role': service!.provider.role,
                'imageUrl': service!.provider.imageUrl,
                'isVerified': service!.provider.isVerified,
              },
              'location': service!.location,
              'rating': service!.rating,
              'reviewCount': service!.reviewCount,
              'basePrice': service!.basePrice,
              'priceUnit': service!.priceUnit,
            }
          : null,
    };
  }

  CustomerBookingModel copyWith({
    String? image,
    String? date,
    String? title,
    String? subtitle,
    ServiceModel? service,
  }) {
    return CustomerBookingModel(
      image: image ?? this.image,
      date: date ?? this.date,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      service: service ?? this.service,
    );
  }
}
