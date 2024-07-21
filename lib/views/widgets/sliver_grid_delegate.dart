import 'package:flutter/src/rendering/sliver.dart';
import 'package:flutter/src/rendering/sliver_grid.dart';

class SliverGridDelegateWithComics extends SliverGridDelegate {
  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    return getDetailedModeLayout(constraints);
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) {
    return false;
  }

  SliverGridLayout getDetailedModeLayout(SliverConstraints constraints) {
    const maxCrossAxisExtent = 650;
    const itemHeight = 164 * 1.0;
    final width = constraints.crossAxisExtent;
    var crossItems = width ~/ maxCrossAxisExtent;
    if (width % maxCrossAxisExtent != 0) crossItems += 1;
    return SliverGridRegularTileLayout(
        crossAxisCount: crossItems,
        mainAxisStride: itemHeight,
        crossAxisStride: width / crossItems,
        childMainAxisExtent: itemHeight,
        childCrossAxisExtent: width / crossItems,
        reverseCrossAxis: false);
  }
}

class SliverGridDelegateWithFixedHeight extends SliverGridDelegate {
  final double itemHeight;
  final double maxCrossAxisExtent;

  SliverGridDelegateWithFixedHeight(this.itemHeight, this.maxCrossAxisExtent);

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final width = constraints.crossAxisExtent;
    var crossItems = width ~/ maxCrossAxisExtent;
    if (width % maxCrossAxisExtent != 0) crossItems += 1;
    return SliverGridRegularTileLayout(
        crossAxisCount: crossItems,
        mainAxisStride: itemHeight,
        crossAxisStride: width / crossItems,
        childMainAxisExtent: itemHeight,
        childCrossAxisExtent: width / crossItems,
        reverseCrossAxis: false);
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) {
    return false;
  }
}

class SliverGridDelegateWithYe
    extends SliverGridDelegateWithFixedCrossAxisCount {
  SliverGridDelegateWithYe({required super.crossAxisCount});

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) {
    return false;
  }
}
