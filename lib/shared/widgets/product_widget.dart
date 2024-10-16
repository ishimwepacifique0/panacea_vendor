import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/product.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/utils.dart';

class ProductWidget extends ConsumerWidget {
  final Product product;
  final bool selected;
  final NewProduct? newProduct;
  final Function() onTap;
  const ProductWidget({
    super.key,
    required this.product,
    required this.selected,
    required this.newProduct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocalizations.of(context)!;
    final region = ref.watch(regionProvider);
    return Row(
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
            child: CachedNetworkImage(
              imageUrl:
                  product.image.isNotEmpty ? product.image : defaultVendorImg,
              width: 70.0,
              height: 70.0,
              fit: BoxFit.contain,
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return Center(
                  child: SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
                );
              },
              errorWidget: (context, url, error) {
                return Image.asset(
                  'assets/logo.png',
                  width: 70.0,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  newProduct != null
                      ? Row(
                          children: [
                            Text(
                              '${region.currency}${formatPrice(newProduct!.price)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 16),
                            ),
                          ],
                        )
                      : Container(),
                  Container(
                    color: Colors.transparent,
                    height: 30.0,
                    child: Container(
                      height: 30.0,
                      margin: const EdgeInsets.only(right: 10.0),
                      child: MaterialButton(
                        textTheme: ButtonTextTheme.accent,
                        onPressed: onTap,
                        child: Text(
                          selected ? locale.edit : locale.add,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: kMainColor,
                                    fontWeight: FontWeight.bold,
                                  ),
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
    );
    // return Column(
    // children: [
    // ListTile(
    //   leading: ClipRRect(
    //     borderRadius: const BorderRadius.all(
    //       Radius.circular(10.0),
    //     ),
    //     child: CachedNetworkImage(
    //         imageUrl: product.image.isNotEmpty
    //             ? product.image
    //             : defaultVendorImg,
    //         width: 70.0,
    //         height: 70.0,
    //         fit: BoxFit.contain,
    //         progressIndicatorBuilder: (context, url, downloadProgress) {
    //           return Center(
    //             child: SizedBox(
    //               height: 40,
    //               width: 40,
    //               child: CircularProgressIndicator(
    //                 value: downloadProgress.progress,
    //                 strokeWidth: 2,
    //               ),
    //             ),
    //           );
    //         },
    //         errorWidget: (context, url, error) {
    //           return Image.asset(
    //             'assets/logo.png',
    //             width: 70.0,
    //             height: 70.0,
    //           );
    //         }),
    //   ),
    //   horizontalTitleGap: 10.0,
    //   title: Text(
    //     product.name,
    //     style: Theme.of(context).textTheme.displayMedium!.copyWith(
    //           fontSize: 18,
    //           fontWeight: FontWeight.w600,
    //         ),
    //   ),
    //   subtitle: Padding(
    //     padding: const EdgeInsets.only(top: 5.0),
    // child: newProduct != null
    //     ? Row(
    //         children: [
    //           Text(
    //             '${region.currency}${formatPrice(newProduct!.price)}',
    //             style: Theme.of(context)
    //                 .textTheme
    //                 .bodySmall!
    //                 .copyWith(fontSize: 16),
    //           ),
    //         ],
    //       )
    //     : Container(),
    //   ),
    // trailing: Container(
    //   color: Colors.transparent,
    //   height: 30.0,
    //   child: Container(
    //     height: 30.0,
    //     margin: const EdgeInsets.only(right: 10.0),
    //     child: MaterialButton(
    //       textTheme: ButtonTextTheme.accent,
    //       onPressed: onTap,
    //       child: Text(
    //         selected ? locale.edit : locale.add,
    //         style: Theme.of(context).textTheme.bodySmall!.copyWith(
    //               color: kMainColor,
    //               fontWeight: FontWeight.bold,
    //             ),
    //       ),
    //     ),
    //   ),
    //   ),
    // ),
    // ],
    // );
  }
}
