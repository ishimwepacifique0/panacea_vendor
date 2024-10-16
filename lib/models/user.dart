class User {
  String id, phoneNumber, tMoney, countryCode;
  String? email, fullName, profilePicture;
  List<dynamic> recommendations, tokens;
  DateTime joinedOn;
  User({
    required this.id,
    required this.phoneNumber,
    required this.tMoney,
    required this.countryCode,
    this.email,
    this.fullName,
    this.profilePicture,
    required this.recommendations,
    required this.tokens,
    required this.joinedOn,
  });

  factory User.fromJSON(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      countryCode: json['country_code'],
      profilePicture: json['profilePicture'],
      phoneNumber: json['phoneNumber'],
      recommendations: json['recommendations'] ?? [],
      tokens: json['tokens'] ?? [],
      tMoney: json['tMoney'] ?? json['phoneNumber'],
      joinedOn: json['joinedOn'].toDate(),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'country_code': countryCode,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
      'recommendations': recommendations,
      'tMoney': tMoney,
      'joinedOn': joinedOn,
      'tokens': tokens,
    };
  }

  @override
  String toString() {
    return 'User(id=$id)';
  }
}
