import 'package:event_maker/models/review_model.dart';

class ReviewMock {
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

  static List<ReviewModel> getReviewsForProvider(String providerName) {
    return reviews
        .where((review) => review.providerName == providerName)
        .toList();
  }
}
