/// Request model for creating/updating services - backend compatible
/// Follows clean architecture with proper serialization
class ServiceRequestModel {
  final String? id; // Only for updates
  final String title;
  final String description;
  final String location;
  final String category; // hospitality, event, trainer
  final String providerRole; // freelancer, business, productiveFamily
  final String? serviceAs; // Optional - enum value or custom string
  final String? eventVenue; // Optional - for event category
  final List<String>? subOptions; // Optional - sub-options for specific service types
  final int? attendanceCapacity; // Optional - for event/trainer categories
  final List<PackageRequestModel> packages;
  final List<AvailabilityRequestModel> availability;
  final AvailabilityRequestModel? primaryAvailability;
  final bool? canGoOutside;
  final bool? cannotGoOutside;
  final bool needsConfirmationBeforePayment;
  final String? imagePath; // For multipart upload

  ServiceRequestModel({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.providerRole,
    this.serviceAs,
    this.eventVenue,
    this.subOptions,
    this.attendanceCapacity,
    this.packages = const [],
    this.availability = const [],
    this.primaryAvailability,
    this.canGoOutside,
    this.cannotGoOutside,
    this.needsConfirmationBeforePayment = false,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'provider_role': providerRole,
      if (serviceAs != null) 'service_as': serviceAs,
      if (eventVenue != null) 'event_venue': eventVenue,
      if (subOptions != null && subOptions!.isNotEmpty) 'sub_options': subOptions,
      if (attendanceCapacity != null) 'attendance_capacity': attendanceCapacity,
      if (packages.isNotEmpty) 'packages': packages.map((p) => p.toJson()).toList(),
      if (availability.isNotEmpty) 'availability': availability.map((a) => a.toJson()).toList(),
      if (primaryAvailability != null) 'primary_availability': primaryAvailability!.toJson(),
      if (canGoOutside != null) 'can_go_outside': canGoOutside,
      if (cannotGoOutside != null) 'cannot_go_outside': cannotGoOutside,
      'needs_confirmation_before_payment': needsConfirmationBeforePayment,
    };
  }

  /// For multipart requests with image upload
  Map<String, String> toMultipartFields() {
    final fields = <String, String>{
      if (id != null) 'id': id!,
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'provider_role': providerRole,
      if (serviceAs != null) 'service_as': serviceAs!,
      if (eventVenue != null) 'event_venue': eventVenue!,
      if (subOptions != null && subOptions!.isNotEmpty) 'sub_options': subOptions!.join(','),
      if (attendanceCapacity != null) 'attendance_capacity': attendanceCapacity.toString(),
      if (canGoOutside != null) 'can_go_outside': canGoOutside.toString(),
      if (cannotGoOutside != null) 'cannot_go_outside': cannotGoOutside.toString(),
      'needs_confirmation_before_payment': needsConfirmationBeforePayment.toString(),
      'packages': _encodePackages(packages),
      if (primaryAvailability != null) 'primary_availability': _encodeAvailability(primaryAvailability!),
    };
    return fields;
  }

  String _encodePackages(List<PackageRequestModel> packages) {
    return packages.map((p) => p.toJson()).toList().toString();
  }

  String _encodeAvailability(AvailabilityRequestModel availability) {
    return availability.toJson().toString();
  }

  ServiceRequestModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? category,
    String? providerRole,
    String? serviceAs,
    String? eventVenue,
    List<String>? subOptions,
    int? attendanceCapacity,
    List<PackageRequestModel>? packages,
    List<AvailabilityRequestModel>? availability,
    AvailabilityRequestModel? primaryAvailability,
    bool? canGoOutside,
    bool? cannotGoOutside,
    String? imagePath,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      providerRole: providerRole ?? this.providerRole,
      serviceAs: serviceAs ?? this.serviceAs,
      eventVenue: eventVenue ?? this.eventVenue,
      subOptions: subOptions ?? this.subOptions,
      attendanceCapacity: attendanceCapacity ?? this.attendanceCapacity,
      packages: packages ?? this.packages,
      availability: availability ?? this.availability,
      primaryAvailability: primaryAvailability ?? this.primaryAvailability,
      canGoOutside: canGoOutside ?? this.canGoOutside,
      cannotGoOutside: cannotGoOutside ?? this.cannotGoOutside,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

/// Package request model for service packages
class PackageRequestModel {
  final String name;
  final double price;
  final List<String> features;

  PackageRequestModel({
    required this.name,
    required this.price,
    this.features = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'features': features,
    };
  }

  factory PackageRequestModel.fromJson(Map<String, dynamic> json) {
    return PackageRequestModel(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}

/// Availability request model for service availability
class AvailabilityRequestModel {
  final String id;
  final List<String> selectedDays;
  final String? startTime;
  final String? endTime;
  final bool canGoOutside;
  final bool cannotGoOutside;

  AvailabilityRequestModel({
    required this.id,
    this.selectedDays = const [],
    this.startTime,
    this.endTime,
    this.canGoOutside = false,
    this.cannotGoOutside = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'selected_days': selectedDays,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      'can_go_outside': canGoOutside,
      'cannot_go_outside': cannotGoOutside,
    };
  }

  factory AvailabilityRequestModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityRequestModel(
      id: json['id'] as String,
      selectedDays: (json['selected_days'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      canGoOutside: json['can_go_outside'] as bool? ?? false,
      cannotGoOutside: json['cannot_go_outside'] as bool? ?? false,
    );
  }
}
