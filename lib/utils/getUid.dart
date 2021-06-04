import 'package:uuid/uuid.dart';

String getUid() {
  return Uuid().v4();
}
