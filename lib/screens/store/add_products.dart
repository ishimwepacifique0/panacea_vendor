import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/models/product.dart';
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

  void handleClick(Product product, bool isSelected, NewProduct? data) {
    showActionDialogBox(
      !isSelected,
      (price) {
        setState(() {
          selectedProducts = [
            ...selectedProducts,
            NewProduct(product.id, product.categories, 0, price),
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
      (price) {
        setState(() {
          selectedProducts = selectedProducts.map((e) {
            if (e.product == data?.product) {
              return NewProduct(product.id, product.categories, 0, price);
            } else {
              return e;
            }
          }).toList();
        });
      },
      data?.price.toString() ?? '',
    );
  }

  showActionDialogBox(bool isNew, Function(int) onAdd, Function() onRemove,
      Function(int) onUpdate, String price) {
    final locale = AppLocalizations.of(context)!;
    TextEditingController amountController = TextEditingController(
      text: price.isNotEmpty ? formatPrice(int.parse(price)) : '',
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
                if (isNew) {
                  String amount = amountController.text.replaceAll(',', '');
                  bool isValid = amount.isNotEmpty;
                  if (isValid) {
                    onAdd(int.parse(amount));
                  } else {
                    return;
                  }
                } else {
                  String amount = amountController.text.replaceAll(',', '');
                  bool isValid = amount.isNotEmpty;
                  if (isValid) {
                    onUpdate(int.parse(amount));
                  } else {
                    return;
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
        'categories': product.categories,
        'vendor': vendor.id,
        'price': product.price,
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
    final region = ref.watch(regionProvider);
    final country = getCountry(region.code);

    final storeProductsStream = ref.watch(
      ProductServices.storeProductsStream(vendor.id),
    );
    final products = (productsStream.value ?? []).where((p) {
      final searched = p.name.toLowerCase().contains(query.toLowerCase());
      final notAdded = storeProductsStream.value?.firstWhereOrNull((e) {
            return e.product == p.id;
          }) ==
          null;
      final isDrink = p.productClass == 'Drink';
      return searched && notAdded && p.isActive && isDrink;
    }).toList();

    final foods = (productsStream.value ?? []).where((p) {
      final searched = p.name.toLowerCase().contains(query.toLowerCase());
      final notAdded = storeProductsStream.value?.firstWhereOrNull((e) {
            return e.product == p.id;
          }) ==
          null;
      final isFood = p.productClass == 'Food';
      return searched && notAdded && p.isActive && isFood;
    }).toList();

    List<Tab> tabs = [
      const Tab(text: 'Drinks'),
      const Tab(text: 'Foods'),
    ];

    products.sort((a, b) {
      if (country != null) {
        final r = country.name;
        if (a.origin == r && b.origin != r) {
          return -1;
        } else if (a.origin != r && b.origin == r) {
          return 1;
        }
      }
      return a.origin.compareTo(b.origin);
    });
    List<Widget> productBuilders = [products, foods].map((elements) {
      return ListView.separated(
        itemCount: elements.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final product = elements[index];
          final newProduct = selectedProducts.firstWhereOrNull((p) {
            return product.id == p.product;
          });
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
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 10,
          );
        },
      );
    }).toList();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(100.0),
              child: AppBar(
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back),
                ),
                title: Text(
                  locale.add,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                titleSpacing: 0.0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0.0),
                  child: TabBar(
                    onTap: (v) {
                      setState(() {
                        activeTab = v;
                      });
                    },
                    tabs: tabs,
                    isScrollable: false,
                    labelColor: kMainColor,
                    unselectedLabelColor: kLightTextColor,
                    indicatorColor: kMainColor,
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
                          children: productBuilders,
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