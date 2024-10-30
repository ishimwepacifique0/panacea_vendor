class Product {
  final String id, productName,genericName, dosageStrength,dosageForm, packSize,packagingType, shelfLife, manufacturerName, manufacturerCountry;
  final String? image;

  Product({
    required this.id,
    required this.productName,
    required this.genericName,
    required this.dosageStrength,
    required this.dosageForm,
    required this.packSize,
    required this.packagingType,
    required this.shelfLife,
    required this.manufacturerName,
    required this.manufacturerCountry,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:json['id'],
      productName: json['productName'],
      genericName: json['genericName'],
      dosageStrength: json['dosageStrength'],
      dosageForm: json['dosageForm'],
      packSize: json['packSize'],
      packagingType: json['packagingType'],
      shelfLife: json['shelfLife'],
      manufacturerName: json['manufacturerName'],
      manufacturerCountry: json['manufacturerCountry'],
      image: json['image'] ?? '',
    );
  }
}


class PharmacyProduct {
  String id, product, pharmacy ;
  int price;
  DateTime createdOn;
  PharmacyProduct({
    required this.id,
    required this.product,
    required this.pharmacy,
    required this.price,
    required this.createdOn,
  });

  factory PharmacyProduct.fromJson(Map<String, dynamic> json) {
    return PharmacyProduct(
      id: json['id'],
      product: json['product'],
      pharmacy: json['pharmacy'],
      price: json['price'],
      createdOn: json['createdOn'].toDate(),
    );
  }
}

class StoreProduct {
  final Product product;
  final PharmacyProduct vendorProduct;

  StoreProduct({required this.product, required this.vendorProduct});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreProduct &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id && 
          vendorProduct.id == other.vendorProduct.id; 

  @override
  int get hashCode => product.id.hashCode ^ vendorProduct.id.hashCode;
}


class NewProduct {
  String product;
  int price;
  NewProduct(this.product,this.price);
}

class ProductClass {
  final String label, value;
  ProductClass(this.label, this.value);
}
