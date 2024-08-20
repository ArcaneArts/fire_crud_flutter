import 'dart:async';

import 'package:fire_api/fire_api.dart';
import 'package:fire_crud/fire_crud.dart';
import 'package:fire_crud_flutter/fire_crud_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pylon/pylon.dart';

class DataView<T extends ModelCrud> extends StatefulWidget {
  final String? id;
  final T? initialData;
  final Widget loading;
  final PylonBuilder builder;
  final bool stream;

  const DataView(
      {super.key,
      this.id,
      this.stream = true,
      this.initialData,
      required this.builder,
      this.loading = const SizedBox.shrink()});

  @override
  State<DataView> createState() => _DataViewState<T>();
}

class _DataViewState<T extends ModelCrud> extends State<DataView<T>> {
  late StreamSubscription<T>? _subscription;
  late Future<T?> _future;
  late T? _value;

  @override
  void initState() {
    super.initState();
    T? t = context.implicitModel<T>();
    assert(t != null,
        "No model found for type $T. Could not find an implicit model for id: ${widget.id}. Remember to define an id and have pylons or data views available for its parent models!");
    _value = widget.initialData ?? context.pylonOr<T>();

    if (widget.stream) {
      _subscription = t!.streamSelf<T>().listen((event) {
        setState(() {
          _value = event;
        });
      });
    } else {
      _future = t!.getSelf<T>().then((i) {
        if (i != null) {
          setState(() {
            _value = i;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _value != null
      ? Pylon<T>(
          value: _value!,
          builder: widget.builder,
        )
      : widget.loading;
}

/// Provides an active collection viewer for a given model type.
class DataListView<T extends ModelCrud> extends StatefulWidget {
  final String? parentModelId;
  final PylonBuilder builder;
  final CollectionReference Function(CollectionReference ref)? query;
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

  const DataListView(
      {super.key,
      this.parentModelId,
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
  State<DataListView> createState() => _DataListViewState();
}

class _DataListViewState<T extends ModelCrud> extends State<DataListView<T>> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => FireList(
      filtered: widget.filtered,
      filter: widget.filter,
      shrinkWrap: widget.shrinkWrap,
      controller: widget.controller,
      padding: widget.padding,
      physics: widget.physics,
      primary: widget.primary,
      clipBehavior: widget.clipBehavior,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      scrollDirection: widget.scrollDirection,
      loading: widget.loading,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      empty: widget.empty,
      failed: widget.failed,
      findChildIndexCallback: widget.findChildIndexCallback,
      itemExtent: widget.itemExtent,
      itemExtentBuilder: widget.itemExtentBuilder,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      onViewerInit: widget.onViewerInit,
      prototypeItem: widget.prototypeItem,
      restorationId: widget.restorationId,
      reverse: widget.reverse,
      semanticChildCount: widget.semanticChildCount,
      viewerBuilder: () {
        T? model = $crud.typeModels[T]?.model as T?;
        assert(model != null,
            "No model found for type $T. Have you defined your crud models?");

        if (!model!.hasParent) {
          return $crud.view<T>(widget.query);
        }

        ModelCrud? parent = context.implicitModel(
            runtime: model.parentModelType, id: widget.parentModelId);
        assert(parent != null,
            "No parent model found for type ${model.parentModelType}. Make sure its available on a data view / pylon or define parentModelId in DataListView");
        return parent!.view<T>(widget.query);
      },
      builder: (context, data) => Pylon<T>(
            value: data,
            builder: widget.builder,
          ));
}
