import 'package:event_maker/models/service_model.dart';

class ServiceSectionModel {
  final String id;
  final String titleKey;
  final String categoryName;
  final ServiceType serviceType;

  const ServiceSectionModel({
    required this.id,
    required this.titleKey,
    required this.categoryName,
    required this.serviceType,
  });

  factory ServiceSectionModel.fromJson(Map<String, dynamic> json) {
    return ServiceSectionModel(
      id: json['id'] as String,
      titleKey: json['titleKey'] as String,
      categoryName: json['categoryName'] as String,
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['serviceType'],
        orElse: () => ServiceType.event,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKey': titleKey,
      'categoryName': categoryName,
      'serviceType': serviceType.name,
    };
  }
}
