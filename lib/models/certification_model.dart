class CertificationModel {
  final String id;
  final String title;
  final String date;
  final String school;
  final String? imageUrl;

  CertificationModel({
    required this.id,
    required this.title,
    required this.date,
    required this.school,
    this.imageUrl,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      school: json['school'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'school': school,
      'imageUrl': imageUrl,
    };
  }

  CertificationModel copyWith({
    String? id,
    String? title,
    String? date,
    String? school,
    String? imageUrl,
  }) {
    return CertificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      school: school ?? this.school,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
