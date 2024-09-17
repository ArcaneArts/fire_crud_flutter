import 'package:fire_crud/fire_crud.dart';
import 'package:fire_crud_flutter/fire_crud_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pylon/pylon.dart';

class ModelGrid<T extends ModelCrud> extends StatelessWidget {
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
  final String? restorationId;
  final Axis scrollDirection;
  final int? semanticChildCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool? primary;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Widget filtered;
  final bool Function(T item)? filter;
  final SliverGridDelegate gridDelegate;

  const ModelGrid(
      {super.key,
      this.gridDelegate = const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300),
      this.filtered = const SizedBox.shrink(),
      this.filter,
      this.query,
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
      this.restorationId,
      this.scrollDirection = Axis.vertical,
      this.semanticChildCount,
      this.shrinkWrap = false,
      this.physics,
      this.primary,
      this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
      this.controller,
      this.onViewerInit,
      this.loading = const ListTile(),
      this.failed = const SizedBox.shrink()});

  @override
  Widget build(BuildContext context) => FireGrid(
      absoluteBuilder: (context) => AbsoluteModelList(
          stream: true,
          loading: loading,
          query: query,
          builder: (context) => GridView(
                gridDelegate: gridDelegate,
                semanticChildCount: semanticChildCount,
                reverse: reverse,
                restorationId: restorationId,
                keyboardDismissBehavior: keyboardDismissBehavior,
                dragStartBehavior: dragStartBehavior,
                cacheExtent: cacheExtent,
                addSemanticIndexes: addSemanticIndexes,
                addRepaintBoundaries: addRepaintBoundaries,
                scrollDirection: scrollDirection,
                addAutomaticKeepAlives: addAutomaticKeepAlives,
                clipBehavior: clipBehavior,
                primary: primary,
                physics: physics,
                padding: padding,
                controller: controller,
                shrinkWrap: shrinkWrap,
                children: [
                  ...context.pylon<List<T>>().map((e) => Pylon<T>(
                        value: e,
                        builder: builder,
                      ))
                ],
              )),
      gridDelegate: gridDelegate,
      loading: loading,
      empty: empty,
      semanticChildCount: semanticChildCount,
      reverse: reverse,
      restorationId: restorationId,
      keyboardDismissBehavior: keyboardDismissBehavior,
      findChildIndexCallback: findChildIndexCallback,
      failed: failed,
      dragStartBehavior: dragStartBehavior,
      cacheExtent: cacheExtent,
      addSemanticIndexes: addSemanticIndexes,
      addRepaintBoundaries: addRepaintBoundaries,
      scrollDirection: scrollDirection,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      clipBehavior: clipBehavior,
      primary: primary,
      physics: physics,
      padding: padding,
      controller: controller,
      shrinkWrap: shrinkWrap,
      filter: filter,
      filtered: filtered,
      onViewerInit: onViewerInit,
      viewerBuilder: $collectionViewerBuilder<T>(context, query),
      builder: (context, data) => Pylon<T>(
            value: data,
            builder: builder,
          ));
}

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

class ModelSliverGrid<T extends ModelCrud> extends StatelessWidget {
  final PylonBuilder builder;
  final DataQuery? query;
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
  final SliverGridDelegate gridDelegate;

  const ModelSliverGrid(
      {super.key,
      this.gridDelegate = const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300),
      this.filtered = const SliverToBoxAdapter(child: SizedBox.shrink()),
      this.filter,
      this.query,
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
      this.loading = const SizedBox.shrink(),
      this.failed = const SliverToBoxAdapter(child: SizedBox.shrink())});

  @override
  Widget build(BuildContext context) => FireSliverGrid<T>(
      absoluteBuilder: (context) => AbsoluteModelList(
          stream: true,
          loading: loading,
          query: query,
          builder: (context) => SliverGrid(
                gridDelegate: gridDelegate,
                delegate: SliverChildListDelegate([
                  ...context.pylon<List<T>>().map((e) => Pylon<T>(
                        value: e,
                        builder: builder,
                      ))
                ]),
              )),
      gridDelegate: gridDelegate,
      filtered: filtered,
      filter: filter,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      failed: failed,
      findChildIndexCallback: findChildIndexCallback,
      semanticChildCount: semanticChildCount,
      empty: empty,
      loading: loading,
      semanticIndexOffset: semanticIndexOffset,
      semanticIndexCallback: semanticIndexCallback,
      onViewerInit: onViewerInit,
      viewerBuilder: $collectionViewerBuilder<T>(context, query),
      builder: (context, data) => Pylon<T>(
            value: data,
            builder: builder,
          ));
}
