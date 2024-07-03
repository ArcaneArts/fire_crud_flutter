Fire Lists & Grids with sliver widgets available. Uses [fire_api](https://pub.dev/packages/fire_api) for Firestore access, and [fire_crud](https://pub.dev/packages/fire_crud) for the CRUD operations. Be sure to set those up first.

```dart
import 'package:fire_crud_flutter/fire_crud_flutter.dart';

Widget build(BuildContext context) => FireList(
  viewerBuilder: () => FireCrud.instance().view<User>(),
  builder: (context, user) => ListTile(
      title: Text(user.name),
      subtitle: Text(user.age.toString()),
  ),
);
```