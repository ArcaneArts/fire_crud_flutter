import 'package:fire_api/fire_api.dart';
import 'package:fire_crud/fire_crud.dart';
import 'package:fire_crud_flutter/fire_crud_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:pylon/pylon.dart';
import 'package:toxic_flutter/extensions/future.dart';
import 'package:toxic_flutter/extensions/stream.dart';

extension XModelAccessor on ModelAccessor {
  Widget editor<T extends ModelCrud>(
          String id, Widget Function(T model, ValueChanged<T> push) builder) =>
      get<T>(id).then((v) => v ?? model<T>(id)).build(
          (v) => ModelEditor<T>(parent: this, model: v, builder: builder));

  Widget restreamPylon<T extends ModelCrud>(
          BuildContext context, PylonBuilder builder) =>
      pylonStreamSelf<T>(context, builder);

  Widget pylon<T extends ModelCrud>(BuildContext context, String id,
          Widget Function(BuildContext context) builder,
          {Widget? loading, bool local = false}) =>
      build<T>(
          id,
          (v) => Pylon<T>(
                key: ValueKey("p.${v.documentPath}.pylon"),
                value: v,
                local: local,
                builder: builder,
              ),
          loading: Pylon<T?>(
            value: null,
            local: local,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonUnique<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading, bool local = false}) =>
      buildUnique<T>(
          (v) => Pylon<T>(
                local: local,
                key: ValueKey("pu.${v.documentPath}.pylon"),
                value: v,
                builder: builder,
              ),
          loading: Pylon<T?>(
            local: local,
            value: null,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonStream<T extends ModelCrud>(BuildContext context, String id,
          Widget Function(BuildContext context) builder,
          {Widget? loading, bool local = false}) =>
      buildStream<T>(
          id,
          (v) => Pylon<T>(
                local: local,
                key: ValueKey("ps.${v.documentPath}.pylon"),
                value: v,
                builder: builder,
              ),
          loading: Pylon<T?>(
            value: null,
            local: local,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonMutableStream<T extends ModelCrud>(BuildContext context,
          String id, Widget Function(BuildContext context) builder,
          {Widget? loading, bool rebuildChildren = true, bool local = false}) =>
      buildStream<T>(
          id,
          (v) => MutablePylon<T>(
                local: local,
                rebuildChildren: rebuildChildren,
                key: ValueKey("ps.${v.documentPath}.pylon"),
                value: v,
                builder: builder,
              ),
          loading: MutablePylon<T?>(
            local: local,
            rebuildChildren: rebuildChildren,
            value: null,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonStreamUnique<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading, bool local = false}) =>
      buildStreamUnique<T>(
          (v) => Pylon<T>(
                local: local,
                key: ValueKey("psu.${v.documentPath}.pylon"),
                value: v,
                builder: builder,
              ),
          loading: Pylon<T?>(
            value: null,
            local: local,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonMutableStreamUnique<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading, bool rebuildChildren = true, bool local = false}) =>
      buildStreamUnique<T>(
          (v) => MutablePylon<T>(
                local: local,
                key: ValueKey("psu.${v.documentPath}.pylon"),
                value: v,
                rebuildChildren: rebuildChildren,
                builder: builder,
              ),
          loading: MutablePylon<T?>(
            local: local,
            value: null,
            rebuildChildren: rebuildChildren,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonStreamSelf<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading, bool local = false}) =>
      buildSelfStream<T>(
          (v) => Pylon<T>(
                local: local,
                key: ValueKey("pss.${v.documentPath}.pylon"),
                value: v,
                builder: builder,
              ),
          loading: loading ?? const SizedBox.shrink());

  Widget pylonMutableStreamSelf<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading, bool rebuildChildren = true, bool local = false}) =>
      buildSelfStream<T>(
          (v) => MutablePylon<T>(
                key: ValueKey("pss.${v.documentPath}.pylon"),
                value: v,
                local: local,
                rebuildChildren: rebuildChildren,
                builder: builder,
              ),
          loading: loading ?? const SizedBox.shrink());

  Widget pylonList<T extends ModelCrud>(
          {required BuildContext context,
          required Widget Function(BuildContext context) builder,
          CollectionReference Function(CollectionReference ref)? query,
          Widget? loading,
          bool local = false}) =>
      listView<T>(
          context: context,
          builder: (context, data) => Pylon<T>(
                local: local,
                value: data,
                builder: builder,
              ),
          query: query);

  Widget pylonGrid<T extends ModelCrud>(
          {required BuildContext context,
          required Widget Function(BuildContext context) builder,
          required SliverGridDelegate delegate,
          CollectionReference Function(CollectionReference ref)? query,
          Widget? loading,
          bool local = false}) =>
      gridView<T>(
          context: context,
          builder: (context, data) => Pylon<T>(
                value: data,
                local: local,
                builder: builder,
              ),
          delegate: delegate,
          query: query);

  Widget build<T extends ModelCrud>(String id, Widget Function(T t) builder,
          {Widget loading = const SizedBox.shrink()}) =>
      FutureOnce<T?>(
          futureFactory: () => get<T>(id),
          builder: (t) => t != null ? builder(t) : loading);

  Widget buildStream<T extends ModelCrud>(
          String id, Widget Function(T t) builder,
          {Widget loading = const SizedBox.shrink()}) =>
      StreamOnce<T?>(
          loading: loading,
          streamFactory: () => stream<T>(id),
          builder: (t) => t != null ? builder(t) : loading);

  Widget buildUnique<T extends ModelCrud>(Widget Function(T t) builder,
          {Widget loading = const SizedBox.shrink()}) =>
      FutureOnce<T?>(
          futureFactory: () => getUnique<T>(),
          builder: (t) => t != null ? builder(t) : loading);

  Widget buildStreamUnique<T extends ModelCrud>(Widget Function(T t) builder,
          {Widget loading = const SizedBox.shrink()}) =>
      StreamOnce<T?>(
          loading: loading,
          streamFactory: () => streamUnique<T>(),
          builder: (t) => t != null ? builder(t) : loading);

  Widget buildSelfStream<T extends ModelCrud>(Widget Function(T t) builder,
          {Widget loading = const SizedBox.shrink()}) =>
      StreamOnce<T?>(
          loading: loading,
          streamFactory: () => streamSelfRaw<T>(),
          builder: (t) => t != null ? builder(t) : loading);

  /// Shorthand listview for a collection of models. If you need to control the list properties like shrinkwrap
  /// then actually use [FireList] implementation which needs a collection view. Call .view<Type> instead of .listView<Type> for that.
  FireList<T> listView<T extends ModelCrud>(
          {required BuildContext context,
          required Widget Function(BuildContext context, T data) builder,
          CollectionReference Function(CollectionReference ref)? query}) =>
      FireList(
        viewerBuilder: () => view<T>(query),
        builder: builder,
      );

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
