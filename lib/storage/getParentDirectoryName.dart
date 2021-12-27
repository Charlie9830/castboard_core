import 'package:path/path.dart' as p;

String getParentDirectoryName(String entityName) {
  // Split the path by the file system separator, then return the first path element, else nothing.
  return p.split(entityName).isNotEmpty ? p.split(entityName).first : '';
}
