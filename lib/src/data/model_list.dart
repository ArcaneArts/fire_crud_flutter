import 'package:fire_crud/fire_crud.dart';
import 'package:fire_crud_flutter/fire_crud_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pylon/pylon.dart';

class ModelList<T extends ModelCrud> extends StatelessWidget {
  final PylonBuilder builder;
  final DataQuery? query;
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

  const ModelList(
      {super.key,
      required this.builder,
      this.query,
      this.filtered = const SizedBox.shrink(),
      this.filter,
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
  Widget build(BuildContext context) => FireList<T>(
      absoluteBuilder: (context) => AbsoluteModelList<T>(
            query: query,
            loading: loading,
            stream: true,
            builder: (context) => ListView(
              shrinkWrap: shrinkWrap,
              controller: controller,
              padding: padding,
              physics: physics,
              primary: primary,
              clipBehavior: clipBehavior,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              scrollDirection: scrollDirection,
              addRepaintBoundaries: addRepaintBoundaries,
              addSemanticIndexes: addSemanticIndexes,
              cacheExtent: cacheExtent,
              dragStartBehavior: dragStartBehavior,
              itemExtent: itemExtent,
              itemExtentBuilder: itemExtentBuilder,
              keyboardDismissBehavior: keyboardDismissBehavior,
              prototypeItem: prototypeItem,
              restorationId: restorationId,
              reverse: reverse,
              semanticChildCount: semanticChildCount,
              children: [
                ...context.pylon<List<T>>().map((e) => Pylon<T>(
                      value: e,
                      builder: builder,
                    ))
              ],
            ),
          ),
      filtered: filtered,
      filter: filter,
      shrinkWrap: shrinkWrap,
      controller: controller,
      padding: padding,
      physics: physics,
      primary: primary,
      clipBehavior: clipBehavior,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      scrollDirection: scrollDirection,
      loading: loading,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      dragStartBehavior: dragStartBehavior,
      empty: empty,
      failed: failed,
      findChildIndexCallback: findChildIndexCallback,
      itemExtent: itemExtent,
      itemExtentBuilder: itemExtentBuilder,
      keyboardDismissBehavior: keyboardDismissBehavior,
      onViewerInit: onViewerInit,
      prototypeItem: prototypeItem,
      restorationId: restorationId,
      reverse: reverse,
      semanticChildCount: semanticChildCount,
      viewerBuilder: $collectionViewerBuilder<T>(context, query),
      builder: (context, data) => Pylon<T>(
            value: data,
            builder: builder,
          ));
}

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

class ModelSliverList<T extends ModelCrud> extends StatelessWidget {
  final PylonBuilder builder;
  final Widget loading;
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
  final DataQuery? query;

  const ModelSliverList(
      {super.key,
      this.query,
      this.filtered = const SliverToBoxAdapter(child: SizedBox.shrink()),
      this.filter,
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
      this.loading = const ListTile(),
      this.failed = const SliverToBoxAdapter(child: SizedBox.shrink())});

  @override
  Widget build(BuildContext context) => FireSliverList<T>(
      absoluteBuilder: (context) => AbsoluteModelList<T>(
            query: query,
            loading: loading,
            stream: true,
            builder: (context) => SliverList(
              delegate: SliverChildListDelegate(
                context
                    .pylon<List<T>>()
                    .map((e) => Pylon<T>(
                          value: e,
                          builder: builder,
                        ))
                    .toList(),
              ),
            ),
          ),
      filtered: filtered,
      filter: filter,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      loading: loading,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      empty: empty,
      failed: failed,
      findChildIndexCallback: findChildIndexCallback,
      onViewerInit: onViewerInit,
      semanticChildCount: semanticChildCount,
      semanticIndexCallback: semanticIndexCallback,
      semanticIndexOffset: semanticIndexOffset,
      viewerBuilder: $collectionViewerBuilder<T>(context, query),
      builder: (context, data) => Pylon<T>(
            value: data,
            builder: builder,
          ));
}
