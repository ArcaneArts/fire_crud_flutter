import 'dart:async';

import 'package:fire_crud/fire_crud.dart';
import 'package:flutter/widgets.dart';
import 'package:throttled/throttled.dart';

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
