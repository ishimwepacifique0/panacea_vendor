class UserOrder {
  String id, user, vendor, phone, orderId;
  int amount;
  int? tip;
  String? reason;
  List<dynamic> products;
  bool paid, served, rejected, tapped;
  DateTime date;

  UserOrder({
    required this.id,
    required this.user,
    required this.vendor,
    required this.amount,
    this.tip,
    this.reason,
    required this.phone,
    required this.orderId,
    required this.products,
    required this.paid,
    required this.served,
    required this.rejected,
    required this.tapped,
    required this.date,
  });

  factory UserOrder.fromMap(Map<String, dynamic> map) {
    return UserOrder(
      id: map['id'],
      user: map['user'],
      vendor: map['vendor'],
      amount: map['amount'],
      tip: map['tip'],
      reason: map['reason'],
      phone: map['phone'],
      orderId: map['orderId'],
      products: map['products'],
      paid: map['paid'],
      served: map['served'],
      rejected: map['rejected'],
      tapped: map['tapped'] ?? false,
      date: map['date'].toDate(),
    );
  }
}
