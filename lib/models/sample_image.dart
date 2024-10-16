class SampleImage {
  String id, image;

  SampleImage({required this.id, required this.image});

  SampleImage.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        image = json['image'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
      };
}
