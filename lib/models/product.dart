class Product {
  String id;
  Map<String, dynamic> productName;
  Map<String, dynamic> country;
  String category;
  List<dynamic> tags;
  String image;
  bool isActive;

  Product({
    required this.id,
    required this.productName,
    required this.category,
    required this.image,
    required this.tags,
    required this.country,
    required this.isActive,
  });

  static Map<String, dynamic> castToMap(dynamic value) {
    if (value is String) {
      return {}; 
    } else if (value is Map<String, dynamic>) {
      return value;
    } else {
      return {};
    }
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productName: castToMap(json['productName']),  
      country: castToMap(json['country']),
      category: json['category'] ?? '',                      
      image: json['image'] ?? '', 
      tags: json['tags'] ?? [],  
      isActive: json['isActive'] ?? false,               
    );
  }
}


class VendorProduct {
  String id, product, store ,category;
  int price;
  DateTime createdOn;
  int? quantity;
  VendorProduct({
    required this.id,
    required this.product,
    required this.store,
    required this.category, 
    required this.price,
    this.quantity,
    required this.createdOn,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    return VendorProduct(
      id: json['id'],
      product: json['product'],
      store: json['store'],
      category: json['category'], 
      price: json['price'],
      quantity: json['quantity'] ?? 0,
      createdOn: json['createdOn'].toDate(),
    );
  }
}

class StoreProduct {
  final Product product;
  final VendorProduct vendorProduct;

  StoreProduct({
    required this.product,
    required this.vendorProduct,
  });
}

class NewProduct {
  String product;
  String category;
  int price, quantity;
  NewProduct(this.product, this.category,this.price, this.quantity);
}

class ProductClass {
  final String label, value;
  ProductClass(this.label, this.value);
}
