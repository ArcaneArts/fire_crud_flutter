import 'dart:async';

import 'package:fire_api/fire_api.dart';
import 'package:fire_crud/fire_crud.dart';
import 'package:fire_crud_flutter/src/x_context.dart';
import 'package:flutter/material.dart';
import 'package:pylon/pylon.dart';

typedef DataQuery = CollectionReference Function(CollectionReference ref);

class ModelView<T extends ModelCrud> extends StatefulWidget {
  final String? id;
  final T? initialData;
  final Widget loading;
  final PylonBuilder builder;
  final bool stream;

  const ModelView(
      {super.key,
      this.id,
      this.stream = true,
      this.initialData,
      required this.builder,
      this.loading = const SizedBox.shrink()});

  @override
  State<ModelView> createState() => _ModelViewState<T>();
}

class _ModelViewState<T extends ModelCrud> extends State<ModelView<T>> {
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
      _subscription = t!.streamSelfRaw<T>().listen((event) {
        setState(() {
          _value = event;
        });
      });
    } else {
      _future = t!.getSelfRaw<T>().then((i) {
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

CollectionViewer<T> Function() $collectionViewerBuilder<T extends ModelCrud>(
        BuildContext context, DataQuery? query) =>
    () {
      T? model = $crud.typeModels[T]?.model as T?;
      assert(model != null,
          "No model found for type $T. Have you defined your crud models?");

      if (!model!.hasParent) {
        return $crud.view<T>(query);
      }

      ModelCrud? parent = context.implicitModel(runtime: model.parentModelType);
      assert(parent != null,
          "No parent model found for type ${model.parentModelType}. Make sure its available on a data view / pylon or define parentModelId in DataListView");
      return parent!.view<T>(query);
    };
