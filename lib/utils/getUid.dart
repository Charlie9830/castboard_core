import 'package:uuid/uuid.dart';

String getUid() {
  return const Uuid().v4();
}
