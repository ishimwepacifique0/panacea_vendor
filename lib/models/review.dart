class Review {
  String id, order, vendor, user, comments;
  double review;
  List<dynamic> likes;
  DateTime createdOn;

  Review({
    required this.id,
    required this.order,
    required this.vendor,
    required this.user,
    required this.comments,
    required this.likes,
    required this.review,
    required this.createdOn,
  });

  factory Review.fromJson(Map<String, dynamic> data) {
    return Review(
      id: data['id'],
      order: data['order'],
      vendor: data['vendor'],
      user: data['user'],
      comments: data['comments'],
      likes: data['likes'] ?? [],
      review: data['review'],
      createdOn: data['createdOn'].toDate(),
    );
  }
}
