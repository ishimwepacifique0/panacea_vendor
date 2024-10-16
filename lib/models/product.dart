class Product {
  String id, name, origin, image, productClass;
  List<dynamic> images;
  Map<String, dynamic> description, ingredients, type;
  String? bottleSize, alcoholPercentage;
  bool isActive;
  List<dynamic> categories;

  Product({
    required this.id,
    required this.categories,
    required this.name,
    required this.image,
    required this.productClass,
    required this.images,
    required this.description,
    required this.ingredients,
    required this.type,
    required this.origin,
    required this.isActive,
    this.bottleSize,
    this.alcoholPercentage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      categories: json['categories'],
      name: json['name'],
      image: json['image'] ?? '',
      productClass: json['class'],
      images: json['images'] ?? [],
      description: json['description'],
      ingredients: json['ingredients'],
      type: json['type'],
      origin: json['origin'],
      bottleSize: json['bottleSize'],
      alcoholPercentage: json['alcoholPercentage'],
      isActive: json['active'],
    );
  }
}

class VendorProduct {
  String id, product, vendor;
  int price, stock;
  DateTime createdOn;
  VendorProduct({
    required this.id,
    required this.product,
    required this.vendor,
    required this.price,
    required this.stock,
    required this.createdOn,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    return VendorProduct(
      id: json['id'],
      product: json['product'],
      vendor: json['vendor'],
      price: json['price'],
      stock: json['stock'],
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
  List<dynamic> categories;
  int stock, price;
  NewProduct(this.product, this.categories, this.stock, this.price);
}

class ProductClass {
  final String label, value;
  ProductClass(this.label, this.value);
}
