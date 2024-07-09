library fire_crud_flutter;

import 'dart:async';

import 'package:fire_api/fire_api.dart';
import 'package:fire_crud/fire_crud.dart';
import 'package:fire_crud_flutter/src/fire_grid.dart';
import 'package:fire_crud_flutter/src/fire_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:pylon/pylon.dart';
import 'package:throttled/throttled.dart';
import 'package:toxic_flutter/extensions/future.dart';
import 'package:toxic_flutter/extensions/stream.dart';

export 'package:fire_crud_flutter/src/fire_grid.dart';
export 'package:fire_crud_flutter/src/fire_list.dart';
// todo fire_page_view

class ModelEditor<T extends ModelCrud> extends StatefulWidget {
  final bool unique;
  final ModelAccessor parent;
  final T model;
  final Widget Function(T model, ValueChanged<T> push) builder;
  final bool stream;

  const ModelEditor(
      {super.key,
      this.stream = false,
      this.unique = false,
      required this.parent,
      required this.model,
      required this.builder});

  @override
  State<ModelEditor<T>> createState() => _ModelEditorState<T>();
}

class _ModelEditorState<T extends ModelCrud> extends State<ModelEditor<T>> {
  late T model;
  late StreamSubscription<T> sub;

  @override
  void initState() {
    model = widget.model;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ModelEditor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      model = widget.model;
    }
  }

  void write() {
    throttle("editor.${model.documentPath}", () {
      if (widget.unique) {
        widget.parent.setUnique<T>(model);
      } else {
        widget.parent.set<T>(model.documentId!, model);
      }
    }, cooldown: const Duration(seconds: 1), leaky: true);
  }

  @override
  Widget build(BuildContext context) => widget.builder(model, (v) {
        setState(() {
          model = v;
        });
        write();
      });
}

extension XModelAccessor on ModelAccessor {
  Widget editor<T extends ModelCrud>(
          String id, Widget Function(T model, ValueChanged<T> push) builder) =>
      get<T>(id).then((v) => v ?? model<T>(id)).build(
          (v) => ModelEditor<T>(parent: this, model: v, builder: builder));

  Widget pylon<T extends ModelCrud>(BuildContext context, String id,
          Widget Function(BuildContext context) builder,
          {Widget? loading}) =>
      build<T>(
          id,
          (v) => Pylon<T>(
                value: v,
                builder: builder,
              ),
          loading: Pylon<T?>(
            value: null,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonUnique<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading}) =>
      buildUnique<T>(
          (v) => Pylon<T>(
                value: v,
                builder: builder,
              ),
          loading: Pylon<T?>(
            value: null,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonStream<T extends ModelCrud>(BuildContext context, String id,
          Widget Function(BuildContext context) builder,
          {Widget? loading}) =>
      buildStream<T>(
          id,
          (v) => Pylon<T>(
                value: v,
                builder: builder,
              ),
          loading: Pylon<T?>(
            value: null,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonStreamUnique<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading}) =>
      buildStreamUnique<T>(
          (v) => Pylon<T>(
                value: v,
                builder: builder,
              ),
          loading: Pylon<T?>(
            value: null,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonList<T extends ModelCrud>(
          {required BuildContext context,
          required Widget Function(BuildContext context) builder,
          CollectionReference Function(CollectionReference ref)? query,
          Widget? loading}) =>
      listView<T>(
          context: context,
          builder: (context, data) => Pylon<T>(
                value: data,
                builder: builder,
              ),
          query: query);

  Widget pylonGrid<T extends ModelCrud>(
          {required BuildContext context,
          required Widget Function(BuildContext context) builder,
          required SliverGridDelegate delegate,
          CollectionReference Function(CollectionReference ref)? query,
          Widget? loading}) =>
      gridView<T>(
          context: context,
          builder: (context, data) => Pylon<T>(
                value: data,
                builder: builder,
              ),
          delegate: delegate,
          query: query);

  Widget build<T extends ModelCrud>(String id, Widget Function(T t) builder,
          {Widget? loading}) =>
      FutureOnce<T?>(
          futureFactory: () => get<T>(id),
          builder: (t) =>
              t != null ? builder(t) : loading ?? const SizedBox.shrink());

  Widget buildStream<T extends ModelCrud>(
          String id, Widget Function(T t) builder, {Widget? loading}) =>
      StreamOnce<T?>(
          streamFactory: () => stream<T>(id),
          builder: (t) =>
              t != null ? builder(t) : loading ?? const SizedBox.shrink());

  Widget buildUnique<T extends ModelCrud>(Widget Function(T t) builder,
          {Widget? loading}) =>
      FutureOnce<T?>(
          futureFactory: () => getUnique<T>(),
          builder: (t) =>
              t != null ? builder(t) : loading ?? const SizedBox.shrink());

  Widget buildStreamUnique<T extends ModelCrud>(Widget Function(T t) builder,
          {Widget? loading}) =>
      StreamOnce<T?>(
          streamFactory: () => streamUnique<T>(),
          builder: (t) =>
              t != null ? builder(t) : loading ?? const SizedBox.shrink());

  /// Shorthand listview for a collection of models. If you need to control the list properties like shrinkwrap
  /// then actually use [FireList] implementation which needs a collection view. Call .view<Type> instead of .listView<Type> for that.
  FireList<T> listView<T extends ModelCrud>(
          {required BuildContext context,
          required Widget Function(BuildContext context, T data) builder,
          CollectionReference Function(CollectionReference ref)? query}) =>
      FireList(viewerBuilder: () => view<T>(query), builder: builder);

  /// Shorthand grid view for a collection of models. If you need to control the grid properties like shrinkwrap
  /// then actually use [FireGrid] implementation which needs a collection view. Call .view<Type> instead of .gridView<Type> for that.
  FireGrid<T> gridView<T extends ModelCrud>(
          {required BuildContext context,
          required Widget Function(BuildContext context, T data) builder,
          required SliverGridDelegate delegate,
          CollectionReference Function(CollectionReference ref)? query}) =>
      FireGrid(
          viewerBuilder: () => view<T>(query),
          gridDelegate: delegate,
          builder: builder);
}
