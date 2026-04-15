/// Request model for creating/updating services - backend compatible
/// Follows clean architecture with proper serialization
class ServiceRequestModel {
  final int? id; // Only for updates
  final String title;
  final String description;
  final String
  serviceTypeName; // Event, Professional Trainer, Photography, etc.
  final String roleName; // Business, Freelancer, Productive Family
  final String? serviceAsName; // Decoration, Fitness Trainer, etc.
  final String? subServiceName; // Optional - sub-service name
  final String? subSubServiceName; // Optional - sub-sub-service name
  final String? eventVenue; // Optional - for event category
  final String? options; // Optional - sub-options like "Indoor"
  final int? attendanceCapacity; // Optional - for event/trainer categories
  final List<PackageRequestModel> packages;
  final List<AvailabilityRequestModel> availabilities;
  final bool canGoOutsideLocation;
  final bool cannotGoOutsideLocation;
  final bool requiresConfirmation;
  final String currency;
  final String? coverImage; // For multipart upload path

  ServiceRequestModel({
    this.id,
    required this.title,
    required this.description,
    required this.serviceTypeName,
    required this.roleName,
    this.serviceAsName,
    this.subServiceName,
    this.subSubServiceName,
    this.eventVenue,
    this.options,
    this.attendanceCapacity,
    this.packages = const [],
    this.availabilities = const [],
    this.canGoOutsideLocation = false,
    this.cannotGoOutsideLocation = false,
    this.requiresConfirmation = false,
    this.currency = 'AED',
    this.coverImage,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'service_type_name': serviceTypeName,
      'role_name': roleName,
      if (serviceAsName != null) 'service_as_name': serviceAsName,
      if (subServiceName != null) 'sub_service_name': subServiceName,
      if (subSubServiceName != null) 'sub_sub_service_name': subSubServiceName,
      if (eventVenue != null) 'event_vanue': eventVenue, // Note: backend typo
      if (options != null) 'options': options,
      if (attendanceCapacity != null) 'attendance_capacity': attendanceCapacity,
      if (packages.isNotEmpty)
        'packages': packages.map((p) => p.toJson()).toList(),
      if (availabilities.isNotEmpty)
        'availabilities': availabilities.map((a) => a.toJson()).toList(),
      'can_go_outside_location': canGoOutsideLocation,
      'can_not_go_outside_location': cannotGoOutsideLocation,
      'requires_confirmation': requiresConfirmation,
      'currency': currency,
    };
  }

  /// For multipart requests with image upload
  Map<String, String> toMultipartFields() {
    final fields = <String, String>{
      if (id != null) 'id': id.toString(),
      'title': title,
      'description': description,
      'service_type_name': serviceTypeName,
      'role_name': roleName,
      if (serviceAsName != null && serviceAsName!.isNotEmpty)
        'service_as_name': serviceAsName!,
      if (subServiceName != null && subServiceName!.isNotEmpty)
        'sub_service_name': subServiceName!,
      if (subSubServiceName != null && subSubServiceName!.isNotEmpty)
        'sub_sub_service_name': subSubServiceName!,
      if (eventVenue != null && eventVenue!.isNotEmpty)
        'event_vanue': eventVenue!,
      if (options != null && options!.isNotEmpty) 'options': options!,
      if (attendanceCapacity != null)
        'attendance_capacity': attendanceCapacity.toString(),
      'can_go_outside_location': canGoOutsideLocation.toString(),
      'can_not_go_outside_location': cannotGoOutsideLocation.toString(),
      'requires_confirmation': requiresConfirmation.toString(),
      'currency': currency,
      'packages': _encodePackages(packages),
      'availabilities': _encodeAvailabilities(availabilities),
      // Include cover_image if available (required by backend for updates)
      if (coverImage != null && coverImage!.isNotEmpty)
        'cover_image': coverImage!,
    };
    return fields;
  }

  String _encodePackages(List<PackageRequestModel> packages) {
    return jsonEncode(packages.map((p) => p.toJson()).toList());
  }

  String _encodeAvailabilities(List<AvailabilityRequestModel> availabilities) {
    return jsonEncode(availabilities.map((a) => a.toJson()).toList());
  }

  ServiceRequestModel copyWith({
    int? id,
    String? title,
    String? description,
    String? serviceTypeName,
    String? roleName,
    String? serviceAsName,
    String? subServiceName,
    String? subSubServiceName,
    String? eventVenue,
    String? options,
    int? attendanceCapacity,
    List<PackageRequestModel>? packages,
    List<AvailabilityRequestModel>? availabilities,
    bool? canGoOutsideLocation,
    bool? cannotGoOutsideLocation,
    bool? requiresConfirmation,
    String? currency,
    String? coverImage,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      serviceTypeName: serviceTypeName ?? this.serviceTypeName,
      roleName: roleName ?? this.roleName,
      serviceAsName: serviceAsName ?? this.serviceAsName,
      subServiceName: subServiceName ?? this.subServiceName,
      subSubServiceName: subSubServiceName ?? this.subSubServiceName,
      eventVenue: eventVenue ?? this.eventVenue,
      options: options ?? this.options,
      attendanceCapacity: attendanceCapacity ?? this.attendanceCapacity,
      packages: packages ?? this.packages,
      availabilities: availabilities ?? this.availabilities,
      canGoOutsideLocation: canGoOutsideLocation ?? this.canGoOutsideLocation,
      cannotGoOutsideLocation:
          cannotGoOutsideLocation ?? this.cannotGoOutsideLocation,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      currency: currency ?? this.currency,
      coverImage: coverImage ?? this.coverImage,
    );
  }
}

/// Package request model for service packages
class PackageRequestModel {
  final String name;
  final String price;
  final List<String> features;
  final int sortOrder;

  PackageRequestModel({
    required this.name,
    required this.price,
    this.features = const [],
    this.sortOrder = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'sort_order': sortOrder,
      // Send features as simple strings, not as objects
      'features': features,
    };
  }

  factory PackageRequestModel.fromJson(Map<String, dynamic> json) {
    return PackageRequestModel(
      name: json['name'] as String,
      price: json['price'].toString(),
      features:
          (json['features'] as List<dynamic>?)
              ?.map(
                (e) => e is Map<String, dynamic>
                    ? e['title'] as String
                    : e.toString(),
              )
              .toList() ??
          [],
      sortOrder: json['sort_order'] as int? ?? 1,
    );
  }
}

/// Availability request model for service availability
class AvailabilityRequestModel {
  final int? id;
  final List<String> weekDays;
  final String startTime;
  final String endTime;
  final String address;
  final String latitude;
  final String longitude;
  final int sortOrder;

  AvailabilityRequestModel({
    this.id,
    required this.weekDays,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.sortOrder = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'week_days': weekDays,
      'start_time': startTime,
      'end_time': endTime,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'sort_order': sortOrder,
    };
  }

  factory AvailabilityRequestModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityRequestModel(
      id: json['id'] as int?,
      weekDays:
          (json['week_days'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startTime: json['start_time'] as String? ?? '09:00:00',
      endTime: json['end_time'] as String? ?? '17:00:00',
      address: json['address'] as String? ?? '',
      latitude: json['latitude'] as String? ?? '0.0',
      longitude: json['longitude'] as String? ?? '0.0',
      sortOrder: json['sort_order'] as int? ?? 1,
    );
  }
}

// Helper function for JSON encoding
String jsonEncode(dynamic value) {
  return _JsonEncoder().convert(value);
}

class _JsonEncoder {
  String convert(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"${_escapeString(value)}"';
    if (value is num || value is bool) return value.toString();
    if (value is List) {
      return '[${value.map(convert).join(',')}]';
    }
    if (value is Map) {
      final entries = value.entries
          .map((e) => '"${e.key}":${convert(e.value)}')
          .join(',');
      return '{$entries}';
    }
    return '"$value"';
  }

  String _escapeString(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
