Fire Lists & Grids with sliver widgets available. Uses [fire_api](https://pub.dev/packages/fire_api) for Firestore access, and [fire_crud](https://pub.dev/packages/fire_crud) for the CRUD operations. Be sure to set those up first.

# Usage
First make sure you setup [fire_crud](https://pub.dev/packages/fire_crud) in your project with your data models before continuing. You also may want to familiarize yourself with [pylon](https://pub.dev/packages/pylon) as well.

```dart
import 'package:fire_crud_flutter/fire_crud_flutter.dart';
```

## Model Views
Data views stream a model from firestore and provide a pylon. In these examples we will be using context.user or context.xyz. This assumes you have made an extension class which simply does User get user => pylon<User>(); which just routes to context.pylon<T>().
```dart
ModelView<User>(
  id: "theUserId"
  builder: (context) => Scaffold(
    appBar: AppBar(title: Text(context.user.name)),
  )
)
```

## Model Lists
Model lists stream a list of models from firestore and provide a pylon for each entry. These lists only stream a small subsection of the list at a time and retarget depending on where the list is currently building. For small lists that never blow up in size, you could use a ModelColumn instead. 

```dart
ModelList<User>(
  query: (q) => q.where("age", isGreaterThan: 18),
  builder: (context) => ListTile(
    title: Text(context.user.name),
  )
)
```

## Implicit Models
Because Pylon is used behind the scenes, you can access a model by type alone, the parent model id is found by looking up the context for a previous data provider.

NOTE: This assumes that the "Note" model is in the "notes" collection inside each "User" model (defined in firecrud) such that: 
* User  (eg users/USERID)
  * Note (eg users/USERID/notes/NOTEID)

```dart
class MainScreen extends StatelessWidget{
  const MainScreen({super.key});
  
  Widget build(BuildContext context) => ModelList<User>(
      builder: (context) => ListTile(
          title: Text(context.user.name),
          onTap: () => Pylon.push(context, UserScreen())
      )
  );
}

class UserScreen extends StatelessWidget{
  const UserScreen({super.key});
  
  // Implicitly gets the user model from the context and uses it
  Widget build(BuildContext context) => ModelList<Note>(
      builder: (context) => ListTile(
          title: Text(context.note.title),
          onTap: () => Pylon.push(context, NoteScreen())
      )
  );
}

class NoteScreen extends StatelessWidget{
  const NoteScreen({super.key});
  
  // You dont need the model view unless you need to live stream this note
  // Otherwise you can still access the list entry from the previous screen unchanged
  // Note: We arent defining an id here because its obvious. We're telling ModelView to
  // implicitly find the note model from the context then re-stream it to get updates.
  Widget build(BuildContext context) => ModelView<Note>(
    builder: (context) => Scaffold(
      appBar: AppBar(title: Text(context.note.title)),
    )
  );
}
```