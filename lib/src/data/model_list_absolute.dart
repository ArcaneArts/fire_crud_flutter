import 'dart:async';

import 'package:fire_crud/fire_crud.dart';
import 'package:fire_crud_flutter/fire_crud_flutter.dart';
import 'package:flutter/material.dart';
import 'package:pylon/pylon.dart';
import 'package:toxic/extensions/future.dart';

class AbsoluteModelList<T extends ModelCrud> extends StatefulWidget {
  final PylonBuilder builder;
  final DataQuery? query;
  final bool stream;
  final List<T>? initialData;
  final Widget loading;

  const AbsoluteModelList({
    super.key,
    this.loading = const SizedBox.shrink(),
    this.initialData,
    this.stream = true,
    required this.builder,
    this.query,
  });

  const AbsoluteModelList.sliver({
    super.key,
    this.loading = const SliverToBoxAdapter(child: SizedBox.shrink()),
    this.initialData,
    this.stream = true,
    required this.builder,
    this.query,
  });

  @override
  State<AbsoluteModelList> createState() => _AbsoluteModelListState<T>();
}

class _AbsoluteModelListState<T extends ModelCrud>
    extends State<AbsoluteModelList<T>> {
  StreamSubscription<List<T>>? _subscription;
  List<T>? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialData ?? context.pylonOr<List<T>>();
    T? model = $crud.typeModels[T]?.model as T?;
    assert(model != null,
        "No model found for type $T. Have you defined your crud models?");

    void push(List<T> t) {
      if (mounted) {
        setState(() {
          _value = t;
        });
      }
    }

    if (widget.stream) {
      if (!model!.hasParent) {
        _subscription = $crud.streamAll<T>(widget.query).listen(push);
      } else {
        ModelCrud? parent =
            context.implicitModel(runtime: model.parentModelType);
        assert(parent != null,
            "No parent model found for type ${model.parentModelType}. Make sure its available on a data view / pylon or define parentModelId in DataListView");
        _subscription = parent!.streamAll<T>(widget.query).listen(push);
      }
    } else {
      if (!model!.hasParent) {
        $crud.getAll<T>(widget.query).thenRun(push);
      } else {
        ModelCrud? parent =
            context.implicitModel(runtime: model.parentModelType);
        assert(parent != null,
            "No parent model found for type ${model.parentModelType}. Make sure its available on a data view / pylon or define parentModelId in DataListView");
        parent!.getAll<T>(widget.query).thenRun(push);
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _value == null
      ? widget.loading
      : Pylon<List<T>>(
          value: _value!,
          builder: widget.builder,
        );
}
