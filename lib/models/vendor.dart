class Vendor {
  String id,
      name,
      image,
      address,
      phone,
      countryCode,
      tMoney,
      paymentMethod,
      email;
  bool approved, active;
  List<dynamic> profiles;
  List<dynamic> banks = [];
  Map<String, dynamic> coordinates;
  DateTime createdOn;
  Vendor({
    required this.id,
    required this.name,
    required this.image,
    required this.address,
    required this.email,
    required this.profiles,
    required this.coordinates,
    required this.phone,
    required this.countryCode,
    required this.tMoney,
    this.paymentMethod = 'mobile',
    this.banks = const [],
    required this.approved,
    required this.active,
    required this.createdOn,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      address: json['address'],
      email: json['email'] ?? '',
      profiles: json['profiles'] ?? [],
      coordinates: json['coordinates'],
      phone: json['phone'],
      countryCode: json['country_code'],
      tMoney: json['tMoney'] ?? json['phone'],
      paymentMethod: json['paymentMethod'] ?? 'mobile',
      banks: json['banks'] ?? [],
      approved: json['approved'],
      active: json['active'] ?? false,
      createdOn: json['createdOn'].toDate(),
    );
  }

  bool isCompeted() {
    return name.isNotEmpty && image.isNotEmpty && profiles.isNotEmpty;
  }
}
