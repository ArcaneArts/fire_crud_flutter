import 'package:fire_crud/fire_crud.dart';
import 'package:flutter/widgets.dart';
import 'package:pylon/pylon.dart';

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
