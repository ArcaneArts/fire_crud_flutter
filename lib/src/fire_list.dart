import 'package:fire_crud/fire_crud.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pylon/pylon.dart';
import 'package:toxic_flutter/extensions/future.dart';
import 'package:toxic_flutter/extensions/stream.dart';

class FireList<T extends ModelCrud> extends StatefulWidget {
  final CollectionViewer<T> Function() viewerBuilder;
  final Widget Function(BuildContext context, T data) builder;
  final Widget loading;
  final Widget failed;
  final Widget empty;
  final Function(CollectionViewer<T>)? onViewerInit;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool reverse;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double cacheExtent;
  final Clip clipBehavior;
  final DragStartBehavior dragStartBehavior;
  final ChildIndexGetter? findChildIndexCallback;
  final double? itemExtent;
  final ItemExtentBuilder? itemExtentBuilder;
  final String? restorationId;
  final Axis scrollDirection;
  final int? semanticChildCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool? primary;
  final Widget? prototypeItem;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Widget filtered;
  final bool Function(T item)? filter;
  final int absoluteListThreshold;
  final PylonBuilder? absoluteBuilder;

  const FireList(
      {super.key,
      this.absoluteListThreshold = 32,
      this.absoluteBuilder,
      this.filtered = const SizedBox.shrink(),
      this.filter,
      required this.viewerBuilder,
      required this.builder,
      this.empty = const SizedBox.shrink(),
      this.padding,
      this.reverse = false,
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.cacheExtent = 250.0,
      this.clipBehavior = Clip.hardEdge,
      this.dragStartBehavior = DragStartBehavior.start,
      this.findChildIndexCallback,
      this.itemExtent,
      this.itemExtentBuilder,
      this.restorationId,
      this.scrollDirection = Axis.vertical,
      this.semanticChildCount,
      this.shrinkWrap = false,
      this.physics,
      this.primary,
      this.prototypeItem,
      this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
      this.controller,
      this.onViewerInit,
      this.loading = const ListTile(),
      this.failed = const SizedBox.shrink()});

  @override
  State<FireList<T>> createState() => _FireListState<T>();
}

class _FireListState<T extends ModelCrud> extends State<FireList<T>> {
  late CollectionViewer<T> viewer;

  @override
  void initState() {
    viewer = widget.viewerBuilder();
    widget.onViewerInit?.call(viewer);
    super.initState();
  }

  @override
  void dispose() {
    viewer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      viewer.stream.build((viewer) => viewer.getSize().build((size) => size == 0
          ? widget.empty
          : size <= widget.absoluteListThreshold &&
                  widget.absoluteBuilder != null
              ? widget.absoluteBuilder!(context)
              : ListView.builder(
                  controller: widget.controller,
                  padding: widget.padding,
                  reverse: widget.reverse,
                  addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                  addRepaintBoundaries: widget.addRepaintBoundaries,
                  addSemanticIndexes: widget.addSemanticIndexes,
                  cacheExtent: widget.cacheExtent,
                  clipBehavior: widget.clipBehavior,
                  dragStartBehavior: widget.dragStartBehavior,
                  findChildIndexCallback: widget.findChildIndexCallback,
                  itemExtent: widget.itemExtent,
                  itemExtentBuilder: widget.itemExtentBuilder,
                  keyboardDismissBehavior: widget.keyboardDismissBehavior,
                  physics: widget.physics,
                  primary: widget.primary,
                  prototypeItem: widget.prototypeItem,
                  restorationId: widget.restorationId,
                  scrollDirection: widget.scrollDirection,
                  semanticChildCount: widget.semanticChildCount,
                  shrinkWrap: widget.shrinkWrap,
                  itemCount: size,
                  itemBuilder: (context, index) => viewer.getAt(index).build(
                      (item) => item == null
                          ? widget.failed
                          : (widget.filter?.call(item) ?? true)
                              ? widget.builder(context, item)
                              : widget.filtered,
                      loading: widget.loading))));
}

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

class FireSliverList<T extends ModelCrud> extends StatefulWidget {
  final CollectionViewer<T> Function() viewerBuilder;
  final Widget Function(BuildContext context, T data) builder;
  final Widget loading;
  final Widget loadingSliver;
  final Widget failed;
  final Widget empty;
  final Function(CollectionViewer<T>)? onViewerInit;
  final SemanticIndexCallback semanticIndexCallback;
  final int semanticIndexOffset;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final int? semanticChildCount;
  final ChildIndexGetter? findChildIndexCallback;
  final Widget filtered;
  final bool Function(T item)? filter;
  final int absoluteListThreshold;
  final PylonBuilder? absoluteBuilder;

  const FireSliverList(
      {super.key,
      this.absoluteListThreshold = 32,
      this.absoluteBuilder,
      this.filtered = const SliverToBoxAdapter(child: SizedBox.shrink()),
      this.filter,
      required this.viewerBuilder,
      required this.builder,
      this.empty = const SliverToBoxAdapter(child: SizedBox.shrink()),
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.findChildIndexCallback,
      this.semanticChildCount,
      this.semanticIndexOffset = 0,
      this.semanticIndexCallback = _kDefaultSemanticIndexCallback,
      this.onViewerInit,
      this.loadingSliver = const SliverToBoxAdapter(child: SizedBox.shrink()),
      this.loading = const SizedBox.shrink(),
      this.failed = const SizedBox.shrink()});

  @override
  State<FireSliverList<T>> createState() => _FireSliverListState();
}

class _FireSliverListState<T extends ModelCrud>
    extends State<FireSliverList<T>> {
  late CollectionViewer<T> viewer;

  @override
  void initState() {
    viewer = widget.viewerBuilder();
    widget.onViewerInit?.call(viewer);
    super.initState();
  }

  @override
  void dispose() {
    viewer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => viewer.stream.build(
      (viewer) => viewer.getSize().build(
          (size) => size == 0
              ? widget.empty
              : size <= widget.absoluteListThreshold &&
                      widget.absoluteBuilder != null
                  ? widget.absoluteBuilder!(context)
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                      (context, index) => viewer.getAt(index).build(
                          (item) => item == null
                              ? widget.failed
                              : (widget.filter?.call(item) ?? true)
                                  ? widget.builder(context, item)
                                  : widget.filtered,
                          loading: widget.loading),
                      childCount: size,
                      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                      addRepaintBoundaries: widget.addRepaintBoundaries,
                      addSemanticIndexes: widget.addSemanticIndexes,
                      findChildIndexCallback: widget.findChildIndexCallback,
                      semanticIndexCallback: widget.semanticIndexCallback,
                      semanticIndexOffset: widget.semanticIndexOffset,
                    )),
          loading: widget.loadingSliver),
      loading: widget.loadingSliver);
}
