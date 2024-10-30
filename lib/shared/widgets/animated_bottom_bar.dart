import 'package:flutter/material.dart';
import 'package:icupa_vendor/themes/colors.dart';

class AnimatedBottomBar extends StatefulWidget {
  final List<BarItem> barItems;
  final Function? onBarTap;

  const AnimatedBottomBar({
    super.key,
    required this.barItems,
    this.onBarTap,
  });

  @override
  AnimatedBottomBarState createState() => AnimatedBottomBarState();
}

class AnimatedBottomBarState extends State<AnimatedBottomBar>
    with TickerProviderStateMixin {
  int selectedBarIndex = 0;
  Duration duration = const Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildBarItems(),
        ),
      ),
    );
  }

  List<Widget> _buildBarItems() {
    List<Widget> barItems = [];
    for (int i = 0; i < widget.barItems.length; i++) {
      BarItem item = widget.barItems[i];
      bool isSelected = selectedBarIndex == i;
      barItems.add(InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            selectedBarIndex = i;
            widget.onBarTap!(selectedBarIndex);
          });
        },
        child: AnimatedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          duration: duration,
          decoration: BoxDecoration(
            color:
                isSelected ? lavenderColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: const BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: Row(
            children: <Widget>[
              ImageIcon(
                AssetImage(item.image),
                color: isSelected
                    ? lavenderColor
                    : Theme.of(context).secondaryHeaderColor,
              ),
              const SizedBox(
                width: 10.0,
              ),
              AnimatedSize(
                duration: duration,
                curve: Curves.easeInOut,
                child: Text(
                  isSelected ? item.text : '',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return barItems;
  }
}

class BarItem {
  String text;
  String image;

  BarItem(
    this.text,
    this.image,
  );
}
