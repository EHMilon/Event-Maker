class HomeHeaderModel {
  final String greeting;
  final String userName;
  final String location;
  final String avatarUrl;

  const HomeHeaderModel({
    required this.greeting,
    required this.userName,
    required this.location,
    required this.avatarUrl,
  });

  String get greetingText => 'Hi, $userName!';

  factory HomeHeaderModel.fromJson(Map<String, dynamic> json) {
    return HomeHeaderModel(
      greeting: json['greeting'] ?? 'Hi',
      userName: json['user_name'] ?? json['userName'] ?? '',
      location: json['location'] ?? '',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'greeting': greeting,
      'user_name': userName,
      'location': location,
      'avatar_url': avatarUrl,
    };
  }
}
