import 'package:castboard_core/elements/ActorElementModel.dart';
import 'package:castboard_core/elements/GroupElementModel.dart';
import 'package:castboard_core/elements/HeadshotElementModel.dart';
import 'package:castboard_core/elements/TrackElementModel.dart';
import 'package:castboard_core/models/CastChangeModel.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';

bool shouldBuildElement(
    LayoutElementModel element, CastChangeModel? castChange) {
  if (castChange == null) {
    return true;
  }

  final child = element.child;
  if (child.canConditionallyRender == false) {
    return true;
  }

  if (child is GroupElementModel) {
    final canAllChildrenConditionallyRender = child.children.values
        .every((item) => item.child.canConditionallyRender == true);

    if (canAllChildrenConditionallyRender == false) {
      return true;
    }

    final shouldBuild = child.children.values
        .every((item) => shouldBuildElement(item, castChange));

    return shouldBuild;
  }

  if (child is HeadshotElementModel) {
    return !castChange.isCut(child.trackRef);
  }

  if (child is TrackElementModel) {
    return !castChange.isCut(child.trackRef);
  }

  if (child is ActorElementModel) {
    return !castChange.isCut(child.trackRef);
  }

  return true;
}
