import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icupa_vendor/models/order.dart';
import 'package:icupa_vendor/services/messenger_service.dart';
import 'package:icupa_vendor/services/order_services.dart';
import 'package:icupa_vendor/services/product_services.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/themes/style.dart';
import 'package:icupa_vendor/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class Orders extends ConsumerWidget {
  final List<UserOrder> orders;
  const Orders({super.key, required this.orders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersStream = ref.watch(UserService.usersStream);
    final productsStream = ref.watch(ProductServices.productsStream);
    final locale = AppLocalizations.of(context)!;
    final region = ref.watch(regionProvider);

    final users = usersStream.value ?? [];
    final products = productsStream.value ?? [];
    final isLoading = productsStream.isLoading || usersStream.isLoading;

    return Column(
      children: [
        if (!isLoading && orders.isEmpty)
          Expanded(
            child: Center(
              child: Text(locale.noOrder),
            ),
          ),
        if (!isLoading && orders.isNotEmpty)
          Expanded(
            child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final user = users.firstWhereOrNull((e) {
                    return e.id == order.user;
                  });
                  final names = user?.fullName ?? user?.phoneNumber ?? '';
                  String formattedDateTime =
                      formatDateTime(context, order.date);
                  String status =
                      order.paid ? locale.beingPrepared : locale.pending;
                  if (order.served) {
                    status = locale.served;
                  }
                  if (order.rejected) {
                    status = locale.rejected;
                  }
                  return FadedSlideAnimation(
                    beginOffset: const Offset(0, 0.3),
                    endOffset: const Offset(0, 0),
                    slideCurve: Curves.linearToEaseOut,
                    child: Column(
                      children: <Widget>[
                        Divider(
                          color: Theme.of(context).cardColor,
                          thickness: 8.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    names,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                            fontSize: 13.3,
                                            letterSpacing: 0.07),
                                  ),
                                  const SizedBox(width: 10.0),
                                  InkWell(
                                    onTap: () async {
                                      final phone = order.phone;
                                      final String url = 'https://wa.me/$phone';
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    child: const FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: Color(0xFF0ECB6F),
                                      size: 20,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 11.7,
                                      letterSpacing: 0.06,
                                      fontWeight: FontWeight.bold,
                                      color: !order.paid
                                          ? const Color(0xffffa025)
                                          : kMainColor,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '(${order.phone})',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontSize: 13.3,
                                          letterSpacing: 0.07,
                                        ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.orderId,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              fontSize: 11.7,
                                              letterSpacing: 0.06,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        formattedDateTime,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              fontSize: 11.7,
                                              letterSpacing: 0.06,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${region.currency}${formatPrice(order.amount)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              fontSize: 11.7,
                                              letterSpacing: 0.06,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              if (order.tip != null)
                                Row(
                                  children: [
                                    Text(
                                      '${locale.tip}: ${region.currency}${formatPrice(order.tip ?? 0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                              fontSize: 13.3,
                                              letterSpacing: 0.07),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Theme.of(context).cardColor,
                          thickness: 1.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: order.products.map((item) {
                              final product =
                                  products.firstWhereOrNull((element) {
                                return element.id == item['product'];
                              });
                              final total = item['price'] * item['quantity'];
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      '${product?.productName[locale.localeName]} x '
                                      '${item['quantity']}',
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontSize: 11.7,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.06,
                                            color: const Color(0xff393939),
                                          ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${region.currency}${formatPrice(total)}',
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontSize: 11.7,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.06,
                                            color: const Color(0xff393939),
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (!order.paid)
                          Divider(
                            color: Theme.of(context).cardColor,
                            thickness: 8.0,
                          ),
                        const SizedBox(height: 10),
                        if (!order.paid && !order.rejected)
                          Container(
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      showConfirmModal(
                                        context,
                                        locale.confirmOrder,
                                        locale.confirmOrderBody,
                                        locale.confirm,
                                        () {
                                          OrderServices.updateOrder({
                                            'paid': true,
                                          }, order.id)
                                              .then((_) {
                                            MessengerService.orderPrepared(
                                              order,
                                              context,
                                            );
                                          });
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                    child: Text(locale.confirm),
                                  ),
                                ),
                                const SizedBox(
                                  width: 25,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      showRejectModal(
                                        context,
                                        locale.rejectOrder,
                                        locale.rejectOrderBody,
                                        locale.reject,
                                        (data) {
                                          OrderServices.updateOrder({
                                            'rejected': true,
                                            'reason': data,
                                          }, order.id)
                                              .then((_) {
                                            MessengerService.orderRejected(
                                              order,
                                              data,
                                              context,
                                            );
                                          });
                                        },
                                      );
                                    },
                                    child: Text(locale.rejected),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!order.served && order.paid)
                          Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  final cContext = context;
                                  showConfirmModal(
                                    context,
                                    locale.markServed,
                                    locale.markServedBody,
                                    locale.confirm,
                                    () {
                                      OrderServices.updateOrder({
                                        'served': true,
                                      }, order.id);
                                      MessengerService.orderServed(
                                        order,
                                        cContext,
                                      );
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  width: MediaQuery.sizeOf(context).width,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6.0, horizontal: 24.0),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Theme.of(context).cardColor)
                                      ],
                                      borderRadius: BorderRadius.circular(30.0),
                                      color: Theme.of(context).cardColor,
                                      border: Border.all(color: kMainColor)),
                                  alignment: Alignment.center,
                                  child: Text(
                                    locale.markServed,
                                    style: orderMapAppBarTextStyle.copyWith(
                                      color: kTextColor,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: Theme.of(context).dividerColor,
                                thickness: 1.0,
                                endIndent: 20.0,
                                indent: 20.0,
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }),
          ),
      ],
    );
  }
}
