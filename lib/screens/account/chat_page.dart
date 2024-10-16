import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/models/message.dart';
import 'package:icupa_vendor/models/order.dart';
import 'package:icupa_vendor/models/user.dart';
import 'package:icupa_vendor/services/message_service.dart';
import 'package:icupa_vendor/shared/widgets/custom_appbar.dart';
import 'package:icupa_vendor/shared/widgets/entry_field.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/themes/style.dart';
import 'package:icupa_vendor/utils.dart';

class ChatPage extends ConsumerStatefulWidget {
  final User user;
  final UserOrder order;
  const ChatPage({
    super.key,
    required this.user,
    required this.order,
  });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends ConsumerState<ChatPage> {
  final controller = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> handleSent() async {
    if (controller.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      final data = {
        'text': controller.text,
        'order': widget.order.id,
        'user': widget.user.id,
        'sender': 'vendor',
        'isRead': false,
        'time': Timestamp.now(),
      };
      controller.clear();
      await MessageServices.sendMessage(data);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(144.0),
            child: CustomAppBar(
              leading: IconButton(
                icon: const Hero(
                  tag: 'arrow',
                  child: Icon(Icons.keyboard_arrow_down),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.0),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(44)),
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CachedNetworkImage(
                          imageUrl: widget.user.profilePicture ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) {
                            return SizedBox(
                              width: 30,
                              height: 30,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/logo.png',
                            height: 150.0,
                            fit: BoxFit.cover,
                            width: MediaQuery.sizeOf(context).width * 0.65,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      widget.user.fullName ?? widget.user.phoneNumber,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    subtitle: Text(
                      'Customer Service',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 11.7,
                          color: const Color(0xffc2c2c2),
                          fontWeight: FontWeight.w500),
                    ),
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MessageStream(order: widget.order),
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: EntryField(
                        readOnly: isLoading,
                        controller: controller,
                        hint: AppLocalizations.of(context)!.enterMessage,
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: kMainColor,
                          ),
                          onPressed: () async {
                            await handleSent();
                          },
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class MessageStream extends ConsumerWidget {
  final UserOrder order;

  const MessageStream({
    super.key,
    required this.order,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesStream = ref.watch(
      MessageServices.orderMessagesStream(order.id),
    );
    final messages = messagesStream.value ?? [];
    return Expanded(
      child: ListView(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        children: messages.map((e) {
          return MessageBubble(message: e);
        }).toList(),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == 'vendor';
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            elevation: 4.0,
            color:
                isMe ? kMainColor : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(6.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message.text,
                    style: isMe
                        ? bottomBarTextStyle
                        : Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 15.0),
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        formatDateTime(context, message.time),
                        style: TextStyle(
                          fontSize: 10.0,
                          color: isMe
                              ? kWhiteColor.withOpacity(0.75)
                              : kLightTextColor,
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      isMe
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                              size: 12.0,
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
