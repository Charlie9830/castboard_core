import 'package:collection/collection.dart';

const String _separator = '/';

String _generatePath(List<String> ids) {
  return ids.join(_separator);
}

class ElementRef {
  final List<String> _ids;
  final String _path;

  ElementRef(List<String> ids)
      : _ids = ids,
        _path = _generatePath(ids);

  const ElementRef.none()
      : _ids = const [],
        _path = '';

  // Special constructor used in ContainerElement - Dragger.
  const ElementRef.shadow()
      : _ids = const ['shadow'],
        _path = 'shadow';

  ElementRef.fromSingle(String id)
      : _ids = [id],
        _path = id;

  ElementRef withPrefix(String prefix) {
    return ElementRef([prefix, ..._ids]);
  }

  ElementRef withSuffix(String suffix) {
    return ElementRef([..._ids, suffix]);
  }

  ElementRef withRemovedParent(String parentSegment) {
    return ElementRef(_ids.toList()..remove(parentSegment));
  }

  ElementRef reparented(ElementRef newParent) {
    if (newParent == const ElementRef.none()) {
      return ElementRef.fromSingle(lastSegment);
    }
    return ElementRef.fromParent(newParent, lastSegment);
  }

  bool get isEmpty => _ids.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get segments => _ids.length;
  bool get isRoot => segments == 1;
  ElementRef get root =>
      isEmpty ? const ElementRef.none() : ElementRef.fromSingle(_ids.first);
  String get lastSegment => _ids.isNotEmpty ? _ids.last : '';
  Iterable<String> get all => _ids;
  ElementRef get parent => _ids.length >= 2
      ? ElementRef(_ids.take(_ids.length - 1).toList())
      : const ElementRef.none();

  bool isDecendentOf(ElementRef parent) {
    return _path.contains(parent._path);
  }

  List<ElementRef> getSegments() {
    return _ids.fold<List<ElementRef>>(
      [],
      (list, id) => list..add(ElementRef.fromParent(list.lastOrNull, id)),
    );
  }

  List<ElementRef> getParents() {
    if (isRoot) {
      return <ElementRef>[];
    }

    final parents = [
      parent,
    ];

    while (parents.last.isRoot == false) {
      parents.add(parents.last.parent);
    }

    return parents;
  }

  @override
  String toString() {
    return _ids.join(_separator);
  }

  factory ElementRef.fromString(String value) {
    return ElementRef(value.split(_separator));
  }

  factory ElementRef.fromParent(ElementRef? parent, String id) {
    if (parent == null || parent.isEmpty) {
      return ElementRef.fromSingle(id);
    }

    return ElementRef([...parent.all, id]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ElementRef && other._path == _path;
  }

  @override
  int get hashCode => _path.hashCode;
}
