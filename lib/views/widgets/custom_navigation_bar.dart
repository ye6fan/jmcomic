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
  // TickerProviderStateMixin用于动画和需要定时更新UI的场景
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    // Vertical Sync垂直同步vsync、covariant共变的
    controller = AnimationController(
        value: widget.selected ? 1 : 0,
        vsync: this,
        duration: const Duration(milliseconds: 150));
  }

  @override
  void didUpdateWidget(covariant NavigationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // forward是从0到1，reverse是从1到0
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
    // 清理资源
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
  final Icon icon;
  final bool hover;
  final String label;

  // 设置监听animation的行为
  const AnimatedNavigationItem(
      {required Animation<double> animation,
      required this.icon,
      required this.hover,
      required this.label,
      super.key})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
        child: Center(
            child: SizedBox(
                width: 80,
                height: 68,
                child: Stack(children: [
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(32)),
                                  color: value != 0
                                      ? colorScheme.secondaryContainer
                                      : (hover
                                          ? colorScheme.surfaceVariant
                                          : null)),
                              child: Center(child: icon)))),
                  Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      bottom: 4,
                      child: Center(
                          child: Opacity(opacity: value, child: Text(label))))
                ]))));
  }
}

class CustomNavigationBar extends StatefulWidget {
  final List<NavigationItemData> destinations;
  final void Function(int) selectedCallback;
  final int selectedIndex;

  const CustomNavigationBar(
      {required this.destinations,
      required this.selectedCallback,
      required this.selectedIndex,
      super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  late List<bool> hover =
      List<bool>.generate(widget.destinations.length, (index) => false);

  @override
  Widget build(BuildContext context) {
    // cursor光标translucent半透明
    return Material(
        child: SizedBox(
            height: 68 + MediaQuery.of(context).padding.bottom,
            child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                child: Row(
                    children: List<Widget>.generate(
                        widget.destinations.length,
                        (index) => Expanded(
                            child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                onEnter: (details) =>
                                    setState(() => hover[index] = true),
                                onExit: (details) =>
                                    setState(() => hover[index] = false),
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () => widget.selectedCallback(index),
                                    child: NavigationItem(
                                        data: widget.destinations[index],
                                        selected: widget.selectedIndex == index,
                                        hover: hover[index])))))))));
  }
}
