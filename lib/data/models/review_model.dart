class ReviewModel {
  final String userName;
  final String userImageUrl;
  final String date;
  final double rating;
  final String reviewText;

  ReviewModel({
    required this.userName,
    required this.userImageUrl,
    required this.date,
    required this.rating,
    required this.reviewText,
  });
}
