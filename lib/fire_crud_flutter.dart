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

export 'package:fire_crud_flutter/src/data/model_grid.dart';
export 'package:fire_crud_flutter/src/data/model_list.dart';
export 'package:fire_crud_flutter/src/data/model_span.dart';
export 'package:fire_crud_flutter/src/data/model_view.dart';
export 'package:fire_crud_flutter/src/fire_grid.dart';
export 'package:fire_crud_flutter/src/fire_list.dart';

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

  Widget restreamPylon<T extends ModelCrud>(
          BuildContext context, PylonBuilder builder) =>
      pylonStreamSelf<T>(context, builder);

  Widget pylon<T extends ModelCrud>(BuildContext context, String id,
          Widget Function(BuildContext context) builder,
          {Widget? loading}) =>
      build<T>(
          id,
          (v) => Pylon<T>(
                key: ValueKey("p.${v.documentPath}.pylon"),
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
                key: ValueKey("pu.${v.documentPath}.pylon"),
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
                key: ValueKey("ps.${v.documentPath}.pylon"),
                value: v,
                builder: builder,
              ),
          loading: Pylon<T?>(
            value: null,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonMutableStream<T extends ModelCrud>(BuildContext context,
          String id, Widget Function(BuildContext context) builder,
          {Widget? loading, bool rebuildChildren = true}) =>
      buildStream<T>(
          id,
          (v) => MutablePylon<T>(
                rebuildChildren: rebuildChildren,
                key: ValueKey("ps.${v.documentPath}.pylon"),
                value: v,
                builder: builder,
              ),
          loading: MutablePylon<T?>(
            rebuildChildren: rebuildChildren,
            value: null,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonStreamUnique<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading}) =>
      buildStreamUnique<T>(
          (v) => Pylon<T>(
                key: ValueKey("psu.${v.documentPath}.pylon"),
                value: v,
                builder: builder,
              ),
          loading: Pylon<T?>(
            value: null,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonMutableStreamUnique<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading, bool rebuildChildren = true}) =>
      buildStreamUnique<T>(
          (v) => MutablePylon<T>(
                key: ValueKey("psu.${v.documentPath}.pylon"),
                value: v,
                rebuildChildren: rebuildChildren,
                builder: builder,
              ),
          loading: MutablePylon<T?>(
            value: null,
            rebuildChildren: rebuildChildren,
            builder: (context) => loading ?? const SizedBox.shrink(),
          ));

  Widget pylonStreamSelf<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading}) =>
      buildSelfStream<T>(
          (v) => Pylon<T>(
                key: ValueKey("pss.${v.documentPath}.pylon"),
                value: v,
                builder: builder,
              ),
          loading: loading ?? const SizedBox.shrink());

  Widget pylonMutableStreamSelf<T extends ModelCrud>(
          BuildContext context, Widget Function(BuildContext context) builder,
          {Widget? loading, bool rebuildChildren = true}) =>
      buildSelfStream<T>(
          (v) => MutablePylon<T>(
                key: ValueKey("pss.${v.documentPath}.pylon"),
                value: v,
                rebuildChildren: rebuildChildren,
                builder: builder,
              ),
          loading: loading ?? const SizedBox.shrink());

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
          streamFactory: () => streamSelf<T>(),
          builder: (t) => t != null ? builder(t) : loading);

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

extension XBuildContextImplicitModelFireCrud on BuildContext {
  /// Attempts to get a model with a real document path only with a single type and single id. This is complicated because you essentially cant do this at all with firebase documents. Example:
  /// If you have group/GID/user/UID/data/data
  /// Assuming Group() is a model
  /// Assuming User() is a model (childed under group in crud)
  /// Assuming Data() is a model with a unique id of "data" (childed under user in crud)
  ///
  /// calling Data? d = implicitModel<Data>() will try to look for a Pylon<User>() and
  /// steal the collection path, if found, steal that path and
  /// slap on group/realGID/user/realUID/data/data to the end of it
  T? implicitModel<T extends ModelCrud>({String? id, Type? runtime}) {
    // Try to snipe pylon without searching models
    T? real = pylonOr<T>(runtime: runtime);

    // If a pylon is found and it agrees with the input id, use it!
    if (real != null && (id == null || real.documentId == id)) return real;

    // Otherwise find a type model from crud
    T? model = $crud.typeModels[runtime ?? T]?.model as T?;

    // Return null if no crud model is found
    if (model == null) return null;

    // Get the crud needed for parent checking
    FireModel<T> crud = model.getCrud();

    // Get the id from either input or exclusive doc id
    String? identity = id ?? crud.exclusiveDocumentId;

    // Abort if no identity can be found
    if (identity == null) return null;

    // Construct a self path
    String selfPath = "${crud.collection}/$identity";

    // If there is no parent model this is easy
    if (!model.hasParent) {
      // Return a model clone with the provided id or exclusive id path
      return crud.cloneWithPath(selfPath);
    }

    // Get the parent model by re-calling implicit model on parent type using rt types
    ModelCrud? parentModel = implicitModel(runtime: model.parentModelType);

    // If no parent is found, it is impossible to find this document implicitly by only a single id
    if (parentModel == null) return null;

    // Success!
    return crud.cloneWithPath("${parentModel.documentPath!}/$selfPath");
  }
}
