import 'package:animation_wrappers/animations/faded_scale_animation.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/category.dart';
import 'package:icupa_vendor/models/order.dart';
import 'package:icupa_vendor/models/product.dart';
import 'package:icupa_vendor/models/region.dart';
import 'package:icupa_vendor/screens/store/add_products.dart';
import 'package:icupa_vendor/services/category_service.dart';
import 'package:icupa_vendor/services/order_services.dart';
import 'package:icupa_vendor/services/product_services.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/phone_inputs.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Products extends ConsumerWidget {
  final ScrollController scrollController;

  Products({super.key}) : scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocalizations.of(context)!;
    final vendor = ref.watch(vendorProvider)!;
    final region = ref.watch(regionProvider);
    final storeProductsStream = ref.watch(
      ProductServices.storeProductsStream(vendor.id),
    );
    final categoryStream = ref.watch(CategoryServices.categoriesStream);
    final productsStream = ref.watch(ProductServices.productsStream);
    final ordersStream = ref.watch(OrderServices.ordersStream(vendor.id));

    final orders = ordersStream.value ?? [];
    final categories = (categoryStream.value ?? []);
    final products = productsStream.value ?? [];
    final storeProducts = productsStream.isLoading
        ? <StoreProduct>[]
        : (storeProductsStream.value ?? []).map((e) {
            final product =
                products.firstWhere((product) => product.id == e.product);
            return StoreProduct(product: product, vendorProduct: e);
          }).toList();

    final categoryIds = storeProducts
        .map((e) {
          return {...e.product.categories};
        })
        .expand((e) => e)
        .toSet()
        .toList();
    final tabCategories = categoryStream.isLoading
        ? <Category>[]
        : categoryIds.map((e) {
            return categories.firstWhere((c) => c.id == e);
          }).toList();
    final categoryKeys = tabCategories.map((e) {
      return GlobalKey();
    }).toList();

    final isLoading = productsStream.isLoading ||
        categoryStream.isLoading ||
        storeProductsStream.isLoading;

    int activeIndex = 0;

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            centerTitle: true,
            title: Text(
              locale.product,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: unselectedLabelColor,
                      width: 0.3,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: StatefulBuilder(builder: (context, setState) {
                    return Row(
                      children: List.generate(tabCategories.length, (index) {
                        final category = tabCategories[index];
                        final key = categoryKeys[index];
                        bool isSelected = activeIndex == index;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              activeIndex = index;
                            });
                            Scrollable.ensureVisible(
                              key.currentContext!,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            decoration: isSelected
                                ? BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: kMainColor,
                                        width: 2,
                                      ),
                                    ),
                                  )
                                : null,
                            child: Text(
                              category.name[locale.localeName],
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color:
                                        isSelected ? kMainColor : kSimpleText,
                                  ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (storeProducts.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 176.0),
                    child: Center(
                      child: Text(
                        '${locale.no} ${locale.itemsFound}',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: kMainColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              if (storeProducts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 58.0),
                  child: Column(
                    children: List.generate(tabCategories.length, (index) {
                      final category = tabCategories[index];
                      final key = categoryKeys[index];
                      final products = storeProducts.where(((sp) {
                        return sp.product.categories.contains(category.id);
                      })).toList();
                      return Column(
                        key: key,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            child: Text(
                              category.name[locale.localeName],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: kBlack,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.67,
                                    fontSize: 17,
                                  ),
                            ),
                          ),
                          FadedSlideAnimation(
                            beginOffset: const Offset(0, 0.3),
                            endOffset: const Offset(0, 0),
                            slideCurve: Curves.linearToEaseOut,
                            child: Column(
                              children: <Widget>[
                                ...productList(
                                  context,
                                  products,
                                  orders,
                                  region,
                                ),
                                Divider(
                                  color: Theme.of(context).cardColor,
                                  thickness: 6.3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: kMainColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const AddProducts();
                },
              ),
            );
          },
          tooltip: AppLocalizations.of(context)!.add,
          child: FadedScaleAnimation(
            child: const Icon(
              Icons.add,
              size: 15.7,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> productList(
    BuildContext context,
    List<StoreProduct> products,
    List<UserOrder> orders,
    Region region,
  ) {
    return products.map((product) {
      final productOrders = orders.where((e) {
        return e.products.where((p) {
          return p['product'] == product.product.id;
        }).isNotEmpty;
      }).length;
      return Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 16.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 70,
              width: 70,
              child: CachedNetworkImage(
                imageUrl: product.product.image.isNotEmpty
                    ? product.product.image
                    : defaultVendorImg,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => Image.asset(
                  'assets/logo.png',
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Center(
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              width: 16.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.product.name,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Text(
                              '${region.currency}${formatPrice(product.vendorProduct.price)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '  |  $productOrders ordered',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: MaterialButton(
                          textTheme: ButtonTextTheme.accent,
                          onPressed: () {
                            showActionDialogBox(context, product);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.edit,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: kMainColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> showActionDialogBox(BuildContext context, StoreProduct product) {
    final locale = AppLocalizations.of(context)!;
    TextEditingController amountController = TextEditingController(
      text: formatPrice(product.vendorProduct.price),
    );
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhiteColor,
          title: Text(
            locale.editORDelete,
            style: const TextStyle(fontSize: 17.0),
          ),
          content: SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  cursorColor: kMainColor,
                  onChanged: (value) {
                    handlePriceChange(value, amountController);
                  },
                  decoration: inputDecorationWithLabel(
                    locale.enterPrice,
                    locale.price,
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String amount = amountController.text.replaceAll(',', '');
                bool isValid = amount.isNotEmpty;
                if (isValid) {
                  ProductServices.updateProduct(
                    {
                      'price': int.parse(amount),
                    },
                    product.vendorProduct.id,
                  );
                } else {
                  return;
                }
                Navigator.pop(context);
              },
              child: Text(
                locale.update,
                style: TextStyle(
                  color: kMainColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ProductServices.deleteProduct(product.vendorProduct.id);
                Navigator.pop(context);
              },
              child: Text(
                locale.remove,
                style: TextStyle(
                  color: kMainColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
