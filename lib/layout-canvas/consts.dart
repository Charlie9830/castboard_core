

import 'package:castboard_core/layout-canvas/DragHandles.dart';

const Map<ResizeHandleLocation, ResizeHandleLocation> opposingResizeHandles = {
  ResizeHandleLocation.topLeft: ResizeHandleLocation.bottomRight,
  ResizeHandleLocation.topCenter: ResizeHandleLocation.bottomCenter,
  ResizeHandleLocation.topRight: ResizeHandleLocation.bottomLeft,
  ResizeHandleLocation.middleRight: ResizeHandleLocation.middleLeft,
  ResizeHandleLocation.bottomRight: ResizeHandleLocation.topLeft,
  ResizeHandleLocation.bottomCenter: ResizeHandleLocation.topCenter,
  ResizeHandleLocation.bottomLeft: ResizeHandleLocation.topRight,
  ResizeHandleLocation.middleLeft: ResizeHandleLocation.middleRight,
};

const Map<ResizeHandleLocation, ResizeHandleLocation>
    verticallyOpposingResizeHandles = {
  ResizeHandleLocation.topLeft: ResizeHandleLocation.bottomLeft,
  ResizeHandleLocation.topCenter: ResizeHandleLocation.bottomCenter,
  ResizeHandleLocation.topRight: ResizeHandleLocation.bottomRight,
  ResizeHandleLocation.middleRight: ResizeHandleLocation.middleRight,
  ResizeHandleLocation.bottomRight: ResizeHandleLocation.topRight,
  ResizeHandleLocation.bottomCenter: ResizeHandleLocation.topCenter,
  ResizeHandleLocation.bottomLeft: ResizeHandleLocation.topLeft,
  ResizeHandleLocation.middleLeft: ResizeHandleLocation.middleLeft,
};

const Map<ResizeHandleLocation, ResizeHandleLocation>
    horizontallyOpposingResizeHandles = {
  ResizeHandleLocation.topLeft: ResizeHandleLocation.topRight,
  ResizeHandleLocation.topCenter: ResizeHandleLocation.topCenter,
  ResizeHandleLocation.topRight: ResizeHandleLocation.topLeft,
  ResizeHandleLocation.middleRight: ResizeHandleLocation.middleLeft,
  ResizeHandleLocation.bottomRight: ResizeHandleLocation.bottomLeft,
  ResizeHandleLocation.bottomCenter: ResizeHandleLocation.bottomCenter,
  ResizeHandleLocation.bottomLeft: ResizeHandleLocation.bottomRight,
  ResizeHandleLocation.middleLeft: ResizeHandleLocation.middleRight,
};
