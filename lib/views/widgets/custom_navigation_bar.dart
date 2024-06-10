import "package:flutter/material.dart";

class NavigationItemData {
  const NavigationItemData(
      {required this.icon, required this.selectedIcon, required this.label});

  final Icon icon;

  final Icon selectedIcon;

  final String label;
}

class NavigationItem extends StatefulWidget {
  final NavigationItemData data;
  final bool selected;
  final bool hover;

  const NavigationItem(
      {required this.data,
      required this.selected,
      required this.hover,
      super.key});

  get icon => data.icon;

  get selectedIcon => data.selectedIcon;

  get label => data.label;

  @override
  State<NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        value: widget.selected ? 1 : 0,
        vsync: this,
        duration: const Duration(milliseconds: 150));
  }

  @override
  void didUpdateWidget(covariant NavigationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedNavigationItem(
        animation: controller,
        icon: widget.selected ? widget.selectedIcon : widget.icon,
        hover: widget.hover,
        label: widget.label);
  }
}

class AnimatedNavigationItem extends AnimatedWidget {
  const AnimatedNavigationItem(
      {required Animation<double> animation,
      required this.icon,
      required this.hover,
      required this.label,
      super.key})
      : super(listenable: animation);

  final Icon icon;
  final bool hover;
  final String label;

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      child: Center(
        child: SizedBox(
          width: 80,
          height: 68,
          child: Stack(
            children: [
              Positioned(
                top: 10 * value,
                left: 0,
                right: 0,
                bottom: 28 * value,
                child: Center(
                  child: Container(
                    width: 64,
                    height: 28,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32)),
                        color: value != 0
                            ? colorScheme.secondaryContainer
                            : (hover ? colorScheme.surfaceVariant : null)),
                    child: Center(child: icon),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                bottom: 4,
                child: Center(
                  child: Opacity(
                    opacity: value,
                    child: Text(label),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef SelectedCallback = void Function(int);

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar(
      {required this.destinations,
      required this.onDestinationSelected,
      required this.selectedIndex,
      super.key});

  final SelectedCallback onDestinationSelected;

  final List<NavigationItemData> destinations;

  final int selectedIndex;

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  late List<bool> hover =
      List<bool>.generate(widget.destinations.length, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SizedBox(
      height: 68 + MediaQuery.of(context).padding.bottom,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          children: List<Widget>.generate(
              widget.destinations.length,
              (index) => Expanded(
                      child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (details) => setState(() => hover[index] = true),
                    onExit: (details) => setState(() => hover[index] = false),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => widget.onDestinationSelected(index),
                      child: NavigationItem(
                        data: widget.destinations[index],
                        selected: widget.selectedIndex == index,
                        hover: hover[index],
                      ),
                    ), //behavior的作用就是：允许底层的手势识别器也接收到这些手势，实现像“穿透”这样的效果，手势可以同时被多个叠加的手势识别器捕捉到
                  ))),
        ), //自动生成导航栏中的内容
      ), //主要填充底部多余部分
    )); //设置导航栏高度68，之所以在底部因为它上面有个Expanded
  }
}
