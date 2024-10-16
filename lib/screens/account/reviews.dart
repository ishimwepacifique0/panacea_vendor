import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/services/profile_service.dart';
import 'package:icupa_vendor/services/review_services.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/utils.dart';

class Reviews extends ConsumerWidget {
  const Reviews({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(vendorProvider)!;
    final reviewsStream = ref.watch(ReviewServices.reviewsStream);
    final usersStream = ref.watch(UserService.usersStream);
    final profilesStream = ref.watch(ProfileServices.profilesStream);
    final reviews = reviewsStream.value ?? [];
    final users = usersStream.value ?? [];
    profilesStream.value ?? [];
    final isLoading = reviewsStream.isLoading || usersStream.isLoading;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  vendor.name,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (reviews.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No Reviews Found!'),
              ),
            ),
          if (reviews.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  final user = users.firstWhere((e) {
                    return e.id == review.user;
                  });
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName ?? user.phoneNumber,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontSize: 15.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: kMainColor,
                                size: 13,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                review.review.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: kMainColor),
                              ),
                              const Spacer(),
                              Text(
                                formatDateTime(context, review.createdOn),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontSize: 11.7,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          review.comments,
                          textAlign: TextAlign.justify,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: const Color(0xff6a6c74),
                                  ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
