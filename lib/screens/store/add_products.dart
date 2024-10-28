import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/models/category.dart';
import 'package:icupa_vendor/models/product.dart';
import 'package:icupa_vendor/services/category_service.dart';
import 'package:icupa_vendor/services/product_services.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/bottom_bar.dart';
import 'package:icupa_vendor/shared/widgets/product_widget.dart';
import 'package:collection/collection.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddProducts extends ConsumerStatefulWidget {
  const AddProducts({super.key});

  @override
  AddProductsState createState() => AddProductsState();
}

class AddProductsState extends ConsumerState<AddProducts> {
  List<NewProduct> selectedProducts = [];
  String query = '';
  bool isLoading = false;
  String? selectedVendor;
  int activeTab = 0;
  List<Category> tabCategories = [];
  List<Widget> productBuilders = [];

  void handleClick(Product product, bool isSelected, NewProduct? data) {
    showActionDialogBox(
      !isSelected,
      (price, quantity) {
        setState(() {
          selectedProducts = [
            ...selectedProducts,
            NewProduct(
              product.id,
              product.category,
              price,
              quantity,
            ),
          ];
        });
      },
      () {
        setState(() {
          selectedProducts = selectedProducts.where((e) {
            return e.product != data?.product;
          }).toList();
        });
      },
      (price, quantity) {
        setState(() {
          selectedProducts = selectedProducts.map((e) {
            if (e.product == data?.product) {
              return NewProduct(
                product.id,
                product.category,
                price,
                quantity,
              );
            } else {
              return e;
            }
          }).toList();
        });
      },
      data?.price.toString() ?? '',
      data?.quantity.toString() ?? '',
    );
  }

  showActionDialogBox(
    bool isNew,
    Function(int price, int quantity) onAdd,
    Function() onRemove,
    Function(int price, int quantity) onUpdate,
    String price,
    String quantity,
  ) {
    final locale = AppLocalizations.of(context)!;
    TextEditingController amountController = TextEditingController(
      text: price.isNotEmpty ? formatPrice(int.parse(price)) : '',
    );
    TextEditingController quantityController = TextEditingController(
      text: quantity.isNotEmpty ? quantity : '',
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhiteColor,
          title: Text(
            isNew ? locale.wantAddProduct : locale.editORDelete,
            style: const TextStyle(fontSize: 17.0),
          ),
          content: SizedBox(
            height: 140,
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
                ),
                const SizedBox(height: 20.0),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: quantityController,
                  cursorColor: kMainColor,
                  decoration: inputDecorationWithLabel(
                    'Enter quantity',
                    'Quantity',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (isNew) {
                  String amount = amountController.text.replaceAll(',', '');
                  String qty = quantityController.text;
                  bool isValid = amount.isNotEmpty && qty.isNotEmpty;
                  if (isValid) {
                    onAdd(int.parse(amount), int.parse(qty));
                  }
                } else {
                  String amount = amountController.text.replaceAll(',', '');
                  String qty = quantityController.text;
                  bool isValid = amount.isNotEmpty && qty.isNotEmpty;
                  if (isValid) {
                    onUpdate(int.parse(amount), int.parse(qty));
                  }
                }
                Navigator.pop(context);
              },
              child: Text(
                isNew ? locale.add : locale.update,
                style: TextStyle(
                  color: kMainColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (!isNew) {
                  onRemove();
                }
                Navigator.pop(context);
              },
              child: Text(
                !isNew ? locale.remove : locale.cancel,
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

  Future<void> handleAddProducts() async {
    setState(() {
      isLoading = true;
    });

    final vendor = ref.read(vendorProvider)!;
    for (var product in selectedProducts) {
      final data = {
        'product': product.product,
        'category': product.category,
        'store': vendor.id,
        'price': product.price,
        'quantity': product.quantity,
        'stock': 0,
        'createdOn': Timestamp.now(),
      };
      await ProductServices.addProduct(data);
    }
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final productsStream = ref.watch(ProductServices.productsStream);
    final vendor = ref.watch(vendorProvider)!;
    final categoryStream = ref.watch(CategoryServices.categoriesStream);
    final categoryValue = categoryStream.value ?? [];

    final storeProductsStream = ref.watch(
      ProductServices.storeProductsStream(vendor.id),
    );

    final productss = productsStream.value ?? [];

    final categoryIds = productss
        .map((e) {
          return e.category;
        })
        .toSet()
        .toList();

    final tabCategories = categoryStream.isLoading
        ? <Category>[]
        : categoryIds.map((e) {
            return categoryValue.firstWhere((c) => c.id == e);
          }).toList();

    final filteredProducts = productss.where((p) {
      final searched = p.productName[locale.localeName].toLowerCase().contains(query.toLowerCase());
      final notAdded = storeProductsStream.value
              ?.firstWhereOrNull((e) => e.product == p.id) ==
          null;
      // final isInCategory = p.category == tabCategories[activeTab].id;
      return searched && notAdded && p.isActive ;
    }).toList();


    List<Widget> productBuilders = [
      ListView.separated(
        itemCount: filteredProducts.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final product = filteredProducts[index];
          final newProduct =
              selectedProducts.firstWhereOrNull((p) => product.id == p.product);
          final isSelected = newProduct != null;
          return FadedSlideAnimation(
            beginOffset: const Offset(0, 0.3),
            endOffset: const Offset(0, 0),
            slideCurve: Curves.linearToEaseOut,
            child: ProductWidget(
              product: product,
              selected: isSelected,
              newProduct: newProduct,
              onTap: () {
                handleClick(product, isSelected, newProduct);
              },
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      ),
    ];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: DefaultTabController(
          length: tabCategories.length,
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
                    child: TabBar(
                       indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: (index) {
                        setState(() {
                          activeTab = index;
                        });
                      },
                      isScrollable: true,
                      indicatorColor: kMainColor,
                      labelColor: kMainColor,
                      labelStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600
                      ),
                      tabAlignment:TabAlignment.start ,
                       unselectedLabelColor: Colors.black,
                      tabs: tabCategories.map((category) {
                        return Tab(
                          text: category.name[locale.localeName] ?? 'Category',
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            body: FadedSlideAnimation(
              beginOffset: const Offset(0, 0.3),
              endOffset: const Offset(0, 0),
              slideCurve: Curves.linearToEaseOut,
              child: Stack(
                children: [
                  Column(
                    children: [
                      if (activeTab == 1 && 2 != 2)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  height: 55,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.rectangle,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    onChanged: (val) {
                                      setState(() {
                                        query = val;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      hintText: locale.searchHere,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.only(
                                        left: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: Theme.of(context).cardColor,
                                thickness: 6.3,
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  onChanged: (val) {
                                    setState(() {
                                      query = val;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    hintText: locale.searchHere,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(
                                      left: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: Theme.of(context).cardColor,
                              thickness: 6.3,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Theme.of(context).cardColor,
                        thickness: 6.3,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: productBuilders.isNotEmpty
                              ? productBuilders
                              : List.generate(
                                  tabCategories.length,
                                  (index) => const Center(child: Text('No Products')),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomBar(
              text: locale.addProduct,
              isValid: selectedProducts.isNotEmpty,
              onTap: () async {
                if (selectedProducts.isNotEmpty) {
                  await handleAddProducts();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
