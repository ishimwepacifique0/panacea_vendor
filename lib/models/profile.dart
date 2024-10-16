class Profile {
  String id;
  Map<String, dynamic> name;

  Profile(
    this.id,
    this.name,
  );

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      json['id'],
      json['name'],
    );
  }
}
