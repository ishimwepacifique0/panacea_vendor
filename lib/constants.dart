import 'package:icupa_vendor/models/product.dart';

class Collections {
  final String users = 'users';
  final String application = 'application';
  final String categories = 'categories';
  final String offers = 'offers';
  final String vendors = 'stores';
  final String products = 'products';
  final String pharmacyProducts = 'pharmacyproducts';
  final String carts = 'carts';
  final String favorites = 'favorites';
  final String orders = 'orders';
  final String reviews = 'reviews';
  final String profiles = 'profiles';
  final String messages = 'messages';
  final String notifications = 'notifications';
  final String regions = 'regions';
  final String imageSamples = 'imageSamples';
}

Collections collections = Collections();

const String bottomHome = 'assets/menu/ic_orders.png';
const String bottomProducts = 'assets/menu/ic_item.png';
const String bottomAccount = 'assets/menu/ic_profile.png';
const String apiKey = 'AIzaSyAHaQx4V7jspYt9jX9k83F1P-24IT3ya1E';
const defaultVendorImg =
    'https://firebasestorage.googleapis.com/v0/b/icupa-396da.appspot.com/o/stores%2Flogo.png?alt=media&token=4bddb3f9-0e16-4e55-b9e5-61dfeedffc16';

final List<ProductClass> pClasses = [
  ProductClass('Drinks', 'Drink'),
  ProductClass('Foods', 'Food'),
];
