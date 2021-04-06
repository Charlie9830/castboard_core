import 'dart:math';
import 'package:castboard_core/layout-canvas/DragBoxLayer.dart';
import 'package:castboard_core/layout-canvas/DragHandles.dart';
import 'package:castboard_core/layout-canvas/GridPainter.dart';
import 'package:castboard_core/layout-canvas/LayoutBlock.dart';
import 'package:castboard_core/layout-canvas/ResizeModifers.dart';
import 'package:castboard_core/layout-canvas/RotateHandle.dart';
import 'package:castboard_core/layout-canvas/consts.dart';
import 'package:castboard_core/layout-canvas/rotatePoint.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'package:flutter/material.dart';

const double _gridSnapDeadZoneRatio = 0.5;
const double _gridSize = 80;

typedef void OnSelectedElementsChangedCallback(Set<String> selectedElements);
typedef void OnElementsChangedCallback(
    Map<String, LayoutBlock> changedElements);
typedef void OnPlaceCallback(double xPos, double yPos);

class LayoutCanvas extends StatefulWidget {
  final bool interactive;
  final bool showGrid;
  final Map<String, LayoutBlock> elements;
  final Set<String> selectedElements;
  final double renderScale;
  final bool placing;
  final OnSelectedElementsChangedCallback onSelectedElementsChanged;
  final OnElementsChangedCallback onElementsChanged;
  final OnPlaceCallback onPlace;

  LayoutCanvas(
      {Key key,
      this.interactive = true,
      this.showGrid = false,
      this.elements = const {},
      this.selectedElements = const {},
      this.placing = false,
      this.renderScale = 1,
      this.onPlace,
      this.onSelectedElementsChanged,
      this.onElementsChanged})
      : super(key: key);

  @override
  _LayoutCanvasState createState() => _LayoutCanvasState();
}

class _LayoutCanvasState extends State<LayoutCanvas> {
  Map<String, LayoutBlock> _activeElements = const {};

  // State
  int _lastPointerId;
  ResizeHandleLocation _logicalResizeHandle;
  Point _pointerPosition;
  bool _isDragSelecting = false;
  Offset _dragSelectAnchorPoint = Offset(0, 0);
  Offset _dragSelectMousePoint = Offset(0, 0);
  Set<String> _dragSelectionPreviews = <String>{};
  double _deltaXSnapAccumulator =
      0.0; // Accumulates Delta Values up until the object or handle is snapped to a grid. In which case Accumulation will start again.
  double _deltaYSnapAccumulator =
      0.0; // Accumulates Delta Values up until the object or handle is snapped to a grid. In which case Accumulation will start again.

  double _currentBlockWidth = 0.0;
  @override
  Widget build(BuildContext context) {
    final dragSelectRect =
        Rect.fromPoints(_dragSelectAnchorPoint, _dragSelectMousePoint);
    return Listener(
      onPointerDown: widget.interactive ? _handleRootPointerDown : null,
      onPointerUp: widget.interactive ? _handleRootPointerUp : null,
      onPointerMove: widget.interactive ? _handleRootPointerMove : null,
      child: Container(
        color: Colors
            .transparent, // If a color isn't set. Hit testing for the Parent Listener stops working.
        child: CustomPaint(
          painter: widget.showGrid
              ? GridPainter(
                  gridSize: _gridSize, renderScale: widget.renderScale)
              : null,
          child: Stack(
            children: [
              DragBoxLayer(
                interactive: widget.interactive,
                selectedElementIds: Set<String>.from(widget.selectedElements)
                  ..addAll(_dragSelectionPreviews),
                renderScale: widget.renderScale,
                blocks: _buildBlocks(),
                isDragSelecting: _isDragSelecting,
                dragSelectXPos: dragSelectRect.topLeft.dx,
                dragSelectYPos: dragSelectRect.topLeft.dy,
                dragSelectHeight: dragSelectRect.height,
                dragSelectWidth: dragSelectRect.width,
                onDragBoxClick: (elementId, pointerId) {
                  _notifySelection(elementId);
                  setState(() {
                    _lastPointerId = pointerId;
                  });
                },
                onPositionChange: (xPosDelta, yPosDelta, blockId) {
                  _handlePositionChange(blockId, xPosDelta, yPosDelta);
                },
                onDragBoxMouseUp: (blockId, pointerId) {},
                onDragHandleDragged: _handleResizeHandleDragged,
                onResizeDone: _handleResizeDone,
                onResizeStart: _handleResizeStart,
                onRotateStart: _handleRotateStart,
                onRotate: _handleRotate,
                onRotateDone: _handleRotateDone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _handleRootPointerMove(pointerEvent) {
    if (_lastPointerId != null && pointerEvent.pointer > _lastPointerId) {
      final currentPos = pointerEvent.localPosition;
      final delta = pointerEvent.localDelta;

      if (_isDragSelecting == false) {
        _startDragSelection(currentPos, delta);
      } else {
        _updateDragSelection(currentPos);
      }
    }
  }

  _handleRootPointerUp(pointerEvent) {
    if (_activeElements.isNotEmpty) {
      widget.onElementsChanged(_activeElements);
      setState(() {
        _activeElements = const {};
        _deltaXSnapAccumulator = 0.0;
        _deltaYSnapAccumulator = 0.0;
      });
    }

    if (_isDragSelecting == true) {
      _finishDragSelection();
    }
  }

  _handleRootPointerDown(pointerEvent) {
    if (_lastPointerId != null && pointerEvent.pointer > _lastPointerId) {
      // Clear Selections.
      widget.onSelectedElementsChanged?.call(<String>{});
      setState(() {
        _activeElements = <String, LayoutBlock>{};
      });
    }
    if (widget.placing) {
      widget.onPlace
          ?.call(pointerEvent.localPosition.dx / widget.renderScale, pointerEvent.localPosition.dy / widget.renderScale);
    }
  }

  void _finishDragSelection() {
    widget.onSelectedElementsChanged(_dragSelectionPreviews);

    setState(() {
      _isDragSelecting = false;
      _dragSelectionPreviews = <String>{};
      _dragSelectAnchorPoint = const Offset(0, 0);
      _dragSelectMousePoint = const Offset(0, 0);
    });
  }

  void _updateDragSelection(Offset currentPos) {
    setState(() {
      _dragSelectMousePoint = currentPos;
      _dragSelectionPreviews = _hitTestSelectionBox(
        Rect.fromPoints(_dragSelectAnchorPoint / widget.renderScale,
            currentPos / widget.renderScale),
      );
    });
  }

  void _notifySelection(String elementId) {
    if (RawKeyboard.instance.keysPressed
        .contains(LogicalKeyboardKey.shiftLeft)) {
      if (widget.selectedElements.contains(elementId)) {
        widget.onSelectedElementsChanged?.call(
            Set<String>.from(widget.selectedElements)..remove(elementId));
      } else {
        widget.onSelectedElementsChanged
            ?.call(Set<String>.from(widget.selectedElements)..add(elementId));
      }
    } else if (widget.selectedElements.contains(elementId) == false) {
      widget.onSelectedElementsChanged?.call(<String>{elementId});
    }
  }

  Map<String, LayoutBlock> _buildBlocks() {
    return Map<String, LayoutBlock>.from(widget.elements)
      ..addAll(_activeElements);
  }

  void _handleResizeDone(int pointerId) {
    setState(() {
      _logicalResizeHandle = null;
    });
  }

  void _handleResizeStart(
      ResizeHandleLocation position, int pointerId, String elementId) {
    setState(() {
      _lastPointerId = pointerId;
      _pointerPosition = Point(100.0, 100.0);
    });
  }

  Set<String> _hitTestSelectionBox(Rect selectionRect) {
    final hitRects = widget.elements.values
        .map((item) => _HitRect(rect: item.rectangle, blockId: item.id));

    final hits = hitRects
        .where((hitRect) => hitRect.rect.overlaps(selectionRect))
        .map((hitRect) => hitRect.blockId);

    return hits.toSet();
  }

  void _startDragSelection(Offset currentPos, Offset delta) {
    // Initiate Drag Selection.
    setState(() {
      _isDragSelecting = true;
      _dragSelectionPreviews = <String>{};
      _dragSelectAnchorPoint = currentPos;
      _dragSelectMousePoint = currentPos.translate(delta.dx, delta.dy);
    });
  }

  void _handleRotateStart(int pointerId, String elementId) {
    final existing = widget.elements[elementId];

    final rectangle = existing.rectangle;
    final nakedPoint = Point(0, existing.height / 2 + rotateHandleTotalHeight);
    final rotatedPoint = rotatePoint(nakedPoint, existing.rotation);
    final screenSpacePoint = Point(rotatedPoint.x + rectangle.center.dx,
        rotatedPoint.y + rectangle.center.dy);

    setState(() {
      _lastPointerId = pointerId;
      _pointerPosition = screenSpacePoint;
    });
  }

  void _handleRotateDone(String blockId, int pointerId) {
    setState(() {
      _pointerPosition = null;
    });
  }

  void _handleRotate(
      double deltaX, double deltaY, String primaryElementId, int pointerId) {
    // TODO: The PrimaryElementId is the ID of the Element that is actually receiving the Mouse Events. As we iterate through the other elements,
    // we figure out the offset of their center points in relation to the primary element which we then apply as X and Y offsets to the atan2 operation.
    // This stops us getting the 'Googly Eye' issue when rotating multiple elements.
    final primaryElement =
        _activeElements[primaryElementId] ?? widget.elements[primaryElementId];

    final pointerPos = Point(_pointerPosition.x + (deltaX / widget.renderScale),
        _pointerPosition.y + (deltaY / widget.renderScale));

    final updatedActiveElements =
        Map<String, LayoutBlock>.fromEntries(widget.selectedElements.map((id) {
      final existing = _activeElements[id] ?? widget.elements[id];
      final center = existing.rectangle.center;

      final xOffset = center.dx - primaryElement.rectangle.center.dx;
      final yOffset = center.dy - primaryElement.rectangle.center.dy;

      final rotation = atan2((pointerPos.y - center.dy + yOffset),
              (pointerPos.x - center.dx + xOffset)) +
          (pi / 2);

      final deltaRotation = primaryElement.rotation - rotation;

      return MapEntry(
          id, existing.copyWith(rotation: existing.rotation - deltaRotation));
    }));

    setState(() {
      _activeElements = updatedActiveElements;
      _lastPointerId = pointerId;
      _pointerPosition = pointerPos;
    });
  }

  List<Widget> _buildDebugDisplay() {
    return <Widget>[
      Positioned(
          left: _pointerPosition?.x ?? 0,
          top: _pointerPosition?.y ?? 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purpleAccent,
            ),
            width: 8,
            height: 8,
          )),
      Positioned(
        top: 20,
        left: 20,
        child: Column(
          children: [
            Text(_logicalResizeHandle
                    .toString()
                    ?.replaceAll('DragHandlePosition.', '') ??
                'Null'),
            Text(_currentBlockWidth.round().toString() ?? ''),
            Text(
                'Pointer Pos: (${_pointerPosition?.x?.round() ?? null}, ${_pointerPosition?.y?.round() ?? null})')
          ],
        ),
      ),
      Positioned(
        top: 200,
        left: 600,
        child: Container(
          height: 700,
          width: 2,
          color: Colors.blueAccent,
        ),
      ),
    ];
  }

  ResizeHandleLocation _getOpposingResizeHandle(
    ResizeHandleLocation currentHandle,
    bool isXAxisFlipping,
    bool isYAxisFlipping,
  ) {
    if (!isXAxisFlipping && !isYAxisFlipping) {
      // No Flip
      return currentHandle;
    }

    if (isXAxisFlipping && !isYAxisFlipping) {
      // Horizontal Flip
      return horizontallyOpposingResizeHandles[currentHandle];
    }

    if (!isXAxisFlipping && isYAxisFlipping) {
      // Vertical Flip
      return verticallyOpposingResizeHandles[currentHandle];
    }

    if (isXAxisFlipping && isYAxisFlipping) {
      // Dual Axis Flip
      return opposingResizeHandles[currentHandle];
    }

    return currentHandle;
  }

  void _handleResizeHandleDragged(double deltaX, double deltaY,
      ResizeHandleLocation physicalHandle, int pointerId, String blockId) {
    final renderDeltaX = deltaX / widget.renderScale;
    final renderDeltaY = deltaY / widget.renderScale;

    // Get the primaryElement. The PrimaryElement represents the actual element being interacted with, even when other elements are selected.
    final primaryElement = _activeElements[blockId] ?? widget.elements[blockId];

    // Determine if we are going to flip over an Axis on this move.
    final isFlippingLeftToRight =
        primaryElement.leftEdge + renderDeltaX > primaryElement.rightEdge;
    final isFlippingRightToLeft =
        primaryElement.rightEdge + renderDeltaX < primaryElement.leftEdge;
    final isFlippingTopToBottom =
        primaryElement.topEdge + renderDeltaY > primaryElement.bottomEdge;
    final isFlippingBottomToTop =
        primaryElement.bottomEdge + renderDeltaY < primaryElement.topEdge;

    final currentLogicalHandle = _logicalResizeHandle ?? physicalHandle;

    // Update Delta Snap Accumulators, (Will only be refered if snapping is enabled)
    final deltaXSnapAccumulator = _deltaXSnapAccumulator + renderDeltaX;
    final deltaYSnapAccumulator = _deltaYSnapAccumulator + renderDeltaY;

    // Declare a local function to get a snap delta only if snapping is enabled (Saves repeating code in handles switch statement later).
    final maybeGetSnapDeltaX = (double currentPos, double renderDeltaX) {
      if (widget.showGrid == false) {
        return renderDeltaX;
      }

      return _getSnapDelta(
          currentPos, deltaXSnapAccumulator, _gridSize, _gridSnapDeadZoneRatio);
    };

    // Declare a local function to get a snap delta only if snapping is enabled (Saves repeating code in handles switch statement later).
    final maybeGetSnapDeltaY = (double currentPos, double renderDeltaY) {
      if (widget.showGrid == false) {
        return renderDeltaY;
      }

      return _getSnapDelta(
          currentPos, deltaYSnapAccumulator, _gridSize, _gridSnapDeadZoneRatio);
    };

    switch (currentLogicalHandle) {
      // Top Left.
      case ResizeHandleLocation.topLeft:
        final maybeSnappedDeltaX =
            maybeGetSnapDeltaX(primaryElement.leftEdge, renderDeltaX);
        final maybeSnappedDeltaY =
            maybeGetSnapDeltaY(primaryElement.topEdge, renderDeltaY);

        final interimPrimary = primaryElement.combinedWith(
            xComponent: isFlippingLeftToRight
                ? applyLeftCrossoverUpdate(primaryElement, maybeSnappedDeltaX)
                : applyLeftNormalUpdate(primaryElement, maybeSnappedDeltaX),
            yComponent: isFlippingTopToBottom
                ? applyTopCrossoverUpdate(primaryElement, maybeSnappedDeltaY)
                : applyTopNormalUpdate(primaryElement, maybeSnappedDeltaY));

        final offsetVector =
            _getRotationOffsetVector(primaryElement, interimPrimary);

        setState(() {
          // Update DeltaX Snap Accumulator.
          _deltaXSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaX, deltaXSnapAccumulator);

          // Update DeltaX Snap Accumulator.
          _deltaYSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaY, deltaYSnapAccumulator);

          // Update Elements.
          final finalizedPrimaryElement = interimPrimary.copyWith(
            xPos: interimPrimary.xPos - (offsetVector.x / widget.renderScale),
            yPos: interimPrimary.yPos - (offsetVector.y / widget.renderScale),
          );

          final deltas = finalizedPrimaryElement.getDeltas(primaryElement);

          _activeElements = Map<String, LayoutBlock>.fromEntries(
              widget.selectedElements.map((id) {
            if (id == blockId) {
              return MapEntry(id, finalizedPrimaryElement);
            } else {
              final existingSecondary =
                  _activeElements[id] ?? widget.elements[id];
              final scaledDeltas = deltas.scaled(
                  existingSecondary.width / primaryElement.width,
                  existingSecondary.height / primaryElement.height);
              return MapEntry(
                  id,
                  existingSecondary.copyWith(
                    xPos: existingSecondary.xPos + scaledDeltas.xPos,
                    yPos: existingSecondary.yPos + scaledDeltas.yPos,
                    width: existingSecondary.width + scaledDeltas.width,
                    height: existingSecondary.height + scaledDeltas.height,
                  ));
            }
          }));
          _logicalResizeHandle = _getOpposingResizeHandle(currentLogicalHandle,
              isFlippingLeftToRight, isFlippingTopToBottom);
          _lastPointerId = pointerId;
        });
        break;

      // Top Center.
      case ResizeHandleLocation.topCenter:
        final maybeSnappedDeltaY =
            maybeGetSnapDeltaY(primaryElement.topEdge, renderDeltaY);

        final interimPrimary = primaryElement.combinedWith(
            yComponent: isFlippingTopToBottom
                ? applyTopCrossoverUpdate(primaryElement, maybeSnappedDeltaY)
                : applyTopNormalUpdate(primaryElement, maybeSnappedDeltaY));

        final offsetVector =
            _getRotationOffsetVector(primaryElement, interimPrimary);

        setState(() {
          // Update DeltaX Snap Accumulator.
          _deltaYSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaY, deltaYSnapAccumulator);

          // Update Elements.
          // 
          final finalizedPrimaryElement = interimPrimary.copyWith(
            xPos: interimPrimary.xPos - (offsetVector.x / widget.renderScale),
            yPos: interimPrimary.yPos - (offsetVector.y / widget.renderScale),
          );

          final deltas = finalizedPrimaryElement.getDeltas(primaryElement);

          _activeElements = Map<String, LayoutBlock>.fromEntries(
              widget.selectedElements.map((id) {
            if (id == blockId) {
              return MapEntry(id, finalizedPrimaryElement);
            } else {
              final existingSecondary =
                  _activeElements[id] ?? widget.elements[id];
              final scaledDeltas = deltas.scaled(
                  existingSecondary.width / primaryElement.width,
                  existingSecondary.height / primaryElement.height);
              return MapEntry(
                  id,
                  existingSecondary.copyWith(
                    xPos: existingSecondary.xPos + scaledDeltas.xPos,
                    yPos: existingSecondary.yPos + scaledDeltas.yPos,
                    width: existingSecondary.width + scaledDeltas.width,
                    height: existingSecondary.height + scaledDeltas.height,
                  ));
            }
          }));
          _logicalResizeHandle = isFlippingTopToBottom
              ? opposingResizeHandles[currentLogicalHandle]
              : currentLogicalHandle;
          _lastPointerId = pointerId;
        });
        break;

      // Top Right.
      case ResizeHandleLocation.topRight:
        final maybeSnappedDeltaX =
            maybeGetSnapDeltaX(primaryElement.rightEdge, renderDeltaX);
        final maybeSnappedDeltaY =
            maybeGetSnapDeltaY(primaryElement.topEdge, renderDeltaY);

        final interimPrimary = primaryElement.combinedWith(
            xComponent: isFlippingRightToLeft
                ? applyRightCrossoverUpdate(primaryElement, maybeSnappedDeltaX)
                : applyRightNormalUpdate(primaryElement, maybeSnappedDeltaX),
            yComponent: isFlippingTopToBottom
                ? applyTopCrossoverUpdate(primaryElement, maybeSnappedDeltaY)
                : applyTopNormalUpdate(primaryElement, maybeSnappedDeltaY));

        final offsetVector =
            _getRotationOffsetVector(primaryElement, interimPrimary);

        setState(() {
          // Update DeltaX Snap Accumulator.
          _deltaXSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaX, deltaXSnapAccumulator);

          // Update DeltaX Snap Accumulator.
          _deltaYSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaY, deltaYSnapAccumulator);

          // Update Elements.
          final finalizedPrimaryElement = interimPrimary.copyWith(
            xPos: interimPrimary.xPos - (offsetVector.x / widget.renderScale),
            yPos: interimPrimary.yPos + (offsetVector.y / widget.renderScale),
          );

          final deltas = finalizedPrimaryElement.getDeltas(primaryElement);

          _activeElements = Map<String, LayoutBlock>.fromEntries(
              widget.selectedElements.map((id) {
            if (id == blockId) {
              return MapEntry(id, finalizedPrimaryElement);
            } else {
              final existingSecondary =
                  _activeElements[id] ?? widget.elements[id];
              final scaledDeltas = deltas.scaled(
                  existingSecondary.width / primaryElement.width,
                  existingSecondary.height / primaryElement.height);
              return MapEntry(
                  id,
                  existingSecondary.copyWith(
                    xPos: existingSecondary.xPos + scaledDeltas.xPos,
                    yPos: existingSecondary.yPos + scaledDeltas.yPos,
                    width: existingSecondary.width + scaledDeltas.width,
                    height: existingSecondary.height + scaledDeltas.height,
                  ));
            }
          }));

          _logicalResizeHandle = _getOpposingResizeHandle(currentLogicalHandle,
              isFlippingRightToLeft, isFlippingTopToBottom);
          _lastPointerId = pointerId;

          _pointerPosition = Point(
              primaryElement.rectangle.topRight.dx + renderDeltaX,
              primaryElement.rectangle.topRight.dy + renderDeltaY);
        });
        break;

      // Middle Right.
      case ResizeHandleLocation.middleRight:
        final maybeSnappedDeltaX =
            maybeGetSnapDeltaX(primaryElement.rightEdge, renderDeltaX);

        final interimPrimary = primaryElement.combinedWith(
          xComponent: isFlippingRightToLeft
              ? applyRightCrossoverUpdate(primaryElement, maybeSnappedDeltaX)
              : applyRightNormalUpdate(primaryElement, maybeSnappedDeltaX),
        );

        final offsetVector =
            _getRotationOffsetVector(primaryElement, interimPrimary);

        setState(() {
          // Update DeltaX Snap Accumulator.
          _deltaXSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaX, deltaXSnapAccumulator);

          // Update Elements.
          final finalizedPrimaryElement = interimPrimary.copyWith(
            xPos: interimPrimary.xPos + (offsetVector.x / widget.renderScale),
            yPos: interimPrimary.yPos + (offsetVector.y / widget.renderScale),
          );

          final deltas = finalizedPrimaryElement.getDeltas(primaryElement);

          _activeElements = Map<String, LayoutBlock>.fromEntries(
              widget.selectedElements.map((id) {
            if (id == blockId) {
              return MapEntry(id, finalizedPrimaryElement);
            } else {
              final existingSecondary =
                  _activeElements[id] ?? widget.elements[id];
              final scaledDeltas = deltas.scaled(
                  existingSecondary.width / primaryElement.width,
                  existingSecondary.height / primaryElement.height);
              return MapEntry(
                  id,
                  existingSecondary.copyWith(
                    xPos: existingSecondary.xPos + scaledDeltas.xPos,
                    yPos: existingSecondary.yPos + scaledDeltas.yPos,
                    width: existingSecondary.width + scaledDeltas.width,
                    height: existingSecondary.height + scaledDeltas.height,
                  ));
            }
          }));

          _logicalResizeHandle = isFlippingRightToLeft
              ? opposingResizeHandles[currentLogicalHandle]
              : currentLogicalHandle;
          _lastPointerId = pointerId;
        });
        break;

      // Bottom Right.
      case ResizeHandleLocation.bottomRight:
        final maybeSnappedDeltaX =
            maybeGetSnapDeltaX(primaryElement.rightEdge, renderDeltaX);
        final maybeSnappedDeltaY =
            maybeGetSnapDeltaY(primaryElement.bottomEdge, renderDeltaY);

        final interimPrimary = primaryElement.combinedWith(
            xComponent: isFlippingRightToLeft
                ? applyRightCrossoverUpdate(primaryElement, maybeSnappedDeltaX)
                : applyRightNormalUpdate(primaryElement, maybeSnappedDeltaX),
            yComponent: isFlippingBottomToTop
                ? applyBottomCrossoverUpdate(primaryElement, maybeSnappedDeltaY)
                : applyBottomNormalUpdate(primaryElement, maybeSnappedDeltaY));

        final offsetVector =
            _getRotationOffsetVector(primaryElement, interimPrimary);

        setState(() {
          // Update DeltaX Snap Accumulator.
          _deltaXSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaX, deltaXSnapAccumulator);

          // Update DeltaX Snap Accumulator.
          _deltaYSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaY, deltaYSnapAccumulator);

          // Update Elements.
          final finalizedPrimaryElement = interimPrimary.copyWith(
            xPos: interimPrimary.xPos + (offsetVector.x / widget.renderScale),
            yPos: interimPrimary.yPos + (offsetVector.y / widget.renderScale),
          );

          final deltas = finalizedPrimaryElement.getDeltas(primaryElement);

          _activeElements = Map<String, LayoutBlock>.fromEntries(
              widget.selectedElements.map((id) {
            if (id == blockId) {
              return MapEntry(id, finalizedPrimaryElement);
            } else {
              final existingSecondary =
                  _activeElements[id] ?? widget.elements[id];
              final scaledDeltas = deltas.scaled(
                  existingSecondary.width / primaryElement.width,
                  existingSecondary.height / primaryElement.height);
              return MapEntry(
                  id,
                  existingSecondary.copyWith(
                    xPos: existingSecondary.xPos + scaledDeltas.xPos,
                    yPos: existingSecondary.yPos + scaledDeltas.yPos,
                    width: existingSecondary.width + scaledDeltas.width,
                    height: existingSecondary.height + scaledDeltas.height,
                  ));
            }
          }));
          _logicalResizeHandle = _getOpposingResizeHandle(currentLogicalHandle,
              isFlippingRightToLeft, isFlippingBottomToTop);
          _lastPointerId = pointerId;
        });
        break;

      // Bottom Center.
      case ResizeHandleLocation.bottomCenter:
        final maybeSnappedDeltaY =
            maybeGetSnapDeltaY(primaryElement.bottomEdge, renderDeltaY);

        final interimPrimary = primaryElement.combinedWith(
          yComponent: isFlippingBottomToTop
              ? applyBottomCrossoverUpdate(primaryElement, maybeSnappedDeltaY)
              : applyBottomNormalUpdate(primaryElement, maybeSnappedDeltaY),
        );

        final offsetVector =
            _getRotationOffsetVector(primaryElement, interimPrimary);

        setState(() {
          // Update DeltaX Snap Accumulator.
          _deltaYSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaY, deltaYSnapAccumulator);

          // Update Elements.
          final finalizedPrimaryElement = interimPrimary.copyWith(
            xPos: interimPrimary.xPos + (offsetVector.x / widget.renderScale),
            yPos: interimPrimary.yPos + (offsetVector.y / widget.renderScale),
          );

          final deltas = finalizedPrimaryElement.getDeltas(primaryElement);

          _activeElements = Map<String, LayoutBlock>.fromEntries(
              widget.selectedElements.map((id) {
            if (id == blockId) {
              return MapEntry(id, finalizedPrimaryElement);
            } else {
              final existingSecondary =
                  _activeElements[id] ?? widget.elements[id];
              final scaledDeltas = deltas.scaled(
                  existingSecondary.width / primaryElement.width,
                  existingSecondary.height / primaryElement.height);
              return MapEntry(
                  id,
                  existingSecondary.copyWith(
                    xPos: existingSecondary.xPos + scaledDeltas.xPos,
                    yPos: existingSecondary.yPos + scaledDeltas.yPos,
                    width: existingSecondary.width + scaledDeltas.width,
                    height: existingSecondary.height + scaledDeltas.height,
                  ));
            }
          }));
          _logicalResizeHandle = isFlippingBottomToTop
              ? opposingResizeHandles[currentLogicalHandle]
              : currentLogicalHandle;
          _lastPointerId = pointerId;
        });

        break;

      // Bottom Left.
      case ResizeHandleLocation.bottomLeft:
        final maybeSnappedDeltaX =
            maybeGetSnapDeltaX(primaryElement.leftEdge, renderDeltaX);
        final maybeSnappedDeltaY =
            maybeGetSnapDeltaY(primaryElement.bottomEdge, renderDeltaY);

        final interimPrimary = primaryElement.combinedWith(
            xComponent: isFlippingLeftToRight
                ? applyLeftCrossoverUpdate(primaryElement, maybeSnappedDeltaX)
                : applyLeftNormalUpdate(primaryElement, maybeSnappedDeltaX),
            yComponent: isFlippingBottomToTop
                ? applyBottomCrossoverUpdate(primaryElement, maybeSnappedDeltaY)
                : applyBottomNormalUpdate(primaryElement, maybeSnappedDeltaY));

        final offsetVector =
            _getRotationOffsetVector(primaryElement, interimPrimary);

        setState(() {
          // Update DeltaX Snap Accumulator.
          _deltaXSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaX, deltaXSnapAccumulator);

          // Update DeltaX Snap Accumulator.
          _deltaYSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaY, deltaYSnapAccumulator);

          // Update Elements.
          final finalizedPrimaryElement = interimPrimary.copyWith(
            xPos: interimPrimary.xPos + (offsetVector.x / widget.renderScale),
            yPos: interimPrimary.yPos + (offsetVector.y / widget.renderScale),
          );

          final deltas = finalizedPrimaryElement.getDeltas(primaryElement);

          _activeElements = Map<String, LayoutBlock>.fromEntries(
              widget.selectedElements.map((id) {
            if (id == blockId) {
              return MapEntry(id, finalizedPrimaryElement);
            } else {
              final existingSecondary =
                  _activeElements[id] ?? widget.elements[id];
              final scaledDeltas = deltas.scaled(
                  existingSecondary.width / primaryElement.width,
                  existingSecondary.height / primaryElement.height);
              return MapEntry(
                  id,
                  existingSecondary.copyWith(
                    xPos: existingSecondary.xPos + scaledDeltas.xPos,
                    yPos: existingSecondary.yPos + scaledDeltas.yPos,
                    width: existingSecondary.width + scaledDeltas.width,
                    height: existingSecondary.height + scaledDeltas.height,
                  ));
            }
          }));

          _logicalResizeHandle = _getOpposingResizeHandle(currentLogicalHandle,
              isFlippingLeftToRight, isFlippingBottomToTop);
          _lastPointerId = pointerId;
        });
        break;

      // Middle Left.
      case ResizeHandleLocation.middleLeft:
        final maybeSnappedDeltaX =
            maybeGetSnapDeltaX(primaryElement.leftEdge, renderDeltaX);

        final interimPrimary = primaryElement.combinedWith(
          xComponent: isFlippingLeftToRight
              ? applyLeftCrossoverUpdate(primaryElement, maybeSnappedDeltaX)
              : applyLeftNormalUpdate(primaryElement, maybeSnappedDeltaX),
        );

        final offsetVector =
            _getRotationOffsetVector(primaryElement, interimPrimary);

        setState(() {
          // Update DeltaX Snap Accumulator.
          _deltaXSnapAccumulator = _updateDeltaAccumulator(
              maybeSnappedDeltaX, deltaXSnapAccumulator);

          // Update Elements.
          final finalizedPrimaryElement = interimPrimary.copyWith(
            xPos: interimPrimary.xPos - (offsetVector.x / widget.renderScale),
            yPos: interimPrimary.yPos - (offsetVector.y / widget.renderScale),
          );

          final deltas = finalizedPrimaryElement.getDeltas(primaryElement);

          _activeElements = Map<String, LayoutBlock>.fromEntries(
              widget.selectedElements.map((id) {
            if (id == blockId) {
              return MapEntry(id, finalizedPrimaryElement);
            } else {
              final existingSecondary =
                  _activeElements[id] ?? widget.elements[id];
              final scaledDeltas = deltas.scaled(
                  existingSecondary.width / primaryElement.width,
                  existingSecondary.height / primaryElement.height);
              return MapEntry(
                  id,
                  existingSecondary.copyWith(
                    xPos: existingSecondary.xPos + scaledDeltas.xPos,
                    yPos: existingSecondary.yPos + scaledDeltas.yPos,
                    width: existingSecondary.width + scaledDeltas.width,
                    height: existingSecondary.height + scaledDeltas.height,
                  ));
            }
          }));

          _logicalResizeHandle = isFlippingLeftToRight
              ? opposingResizeHandles[currentLogicalHandle]
              : currentLogicalHandle;
          _lastPointerId = pointerId;
        });
        break;
    }
  }

  Matrix4 _getRotationMatrix(double width, double height, double rotation) {
    return Matrix4.identity()
      ..translate(width / 2, height / 2)
      ..rotateZ(rotation)
      ..translate(width / 2 * -1, height / 2 * -1);
  }

  ///
  /// Calculates the delta required to snap the element to the next appropriate gridline. Returns 0 if the element does not need to move.
  ///
  double _getSnapDelta(double currentPos, double deltaSinceLastSnap,
      double gridSize, double deadZoneRatio) {
    if (deltaSinceLastSnap >= gridSize * deadZoneRatio) {
      // Snap to Right or Bottom grid Line. (Increasing value on the X or Y Axis)
      final double nextSnap =
          ((currentPos + deltaSinceLastSnap) / gridSize).round() * gridSize;
      return nextSnap - currentPos;
    }

    if (deltaSinceLastSnap * -1 >= gridSize * deadZoneRatio) {
      // Snap to Left or Top grid line. (Decreasing value on the X or Y Axis)
      final prevSnap =
          ((currentPos + deltaSinceLastSnap) / gridSize).round() * gridSize;
      return currentPos % gridSize == 0 ? gridSize * -1 : prevSnap - currentPos;
    }

    return 0;
  }

  void _handlePositionChange(String uid, double rawDeltaX, double rawDeltaY) {
    final scaledDeltaX = rawDeltaX / widget.renderScale;
    final scaledDeltaY = rawDeltaY / widget.renderScale;

    if (widget.showGrid == true) {
      _handleSnappingPositionChange(uid, widget.selectedElements,
          _activeElements, widget.elements, scaledDeltaX, scaledDeltaY);
    } else {
      _handleStandardPositionChange(uid, widget.selectedElements,
          _activeElements, widget.elements, scaledDeltaX, scaledDeltaY);
    }
  }

  void _handleStandardPositionChange(
      String uid,
      Set<String> selectedElements,
      Map<String, LayoutBlock> activeElements,
      Map<String, LayoutBlock> elements,
      double scaledDeltaX,
      double scaledDeltaY) {
    // Apply new delta values to the active elements.
    final newActiveElements = _applyDeltaPositionUpdates(
        selectedElements, activeElements, elements, scaledDeltaX, scaledDeltaY);

    setState(() {
      _activeElements = newActiveElements;
    });
  }

  /// Returns an Accumulated Delta value. If SnapDelta is 0, signalling that no snap was required, then accumulator is returned as is. Else accumulator is returned with the
  /// snapDelta subtracted from it to account for any leftover delta after a Snap has occurred.
  double _updateDeltaAccumulator(double snapDelta, double accumulator) {
    if (snapDelta == 0) {
      return accumulator;
    } else {
      return accumulator - snapDelta;
    }
  }

  void _handleSnappingPositionChange(
      String uid,
      Set<String> selectedElements,
      Map<String, LayoutBlock> activeElements,
      Map<String, LayoutBlock> elements,
      double scaledDeltaX,
      double scaledDeltaY) {
    final primaryElement = activeElements[uid] ?? elements[uid];
    final double deltaXSnapAccumulator = _deltaXSnapAccumulator +
        scaledDeltaX; // Get updated Delta Accumulators.
    final double deltaYSnapAccumulator = _deltaYSnapAccumulator +
        scaledDeltaY; // Get updated Delta Accumulators.

    // Determine the delta required to snap to the next appropriate gridline (if any).
    final double snapDeltaX = _getSnapDelta(primaryElement.xPos,
        deltaXSnapAccumulator, _gridSize, _gridSnapDeadZoneRatio);
    final double snapDeltaY = _getSnapDelta(primaryElement.yPos,
        deltaYSnapAccumulator, _gridSize, _gridSnapDeadZoneRatio);

    if (snapDeltaX != 0 || snapDeltaY != 0) {
      // Get updated values for the deltaAccumulators.
      final newDeltaXSnapAccumulator =
          _updateDeltaAccumulator(snapDeltaX, deltaXSnapAccumulator);

      final newDeltaYSnapAccumulator =
          _updateDeltaAccumulator(snapDeltaY, deltaYSnapAccumulator);

      // Apply new delta values to the active elements.
      final newActiveElements = _applyDeltaPositionUpdates(
          selectedElements, activeElements, elements, snapDeltaX, snapDeltaY);

      setState(() {
        _deltaXSnapAccumulator = newDeltaXSnapAccumulator;
        _deltaYSnapAccumulator = newDeltaYSnapAccumulator;
        _activeElements = newActiveElements;
      });
    } else {
      // Neither the X-Axis or the Y-Axis required snapping to the next appropriate gridline. So just accumlate our deltaSinceLastSnap values.
      setState(() {
        _deltaXSnapAccumulator = deltaXSnapAccumulator;
        _deltaYSnapAccumulator = deltaYSnapAccumulator;
      });
    }
  }

  /// Applies delta changes to all elements referenced by selectedElements.
  /// Iterates through selectedElements and copies from an activeElement if available otherwise falls back to
  /// copying from elements.
  Map<String, LayoutBlock> _applyDeltaPositionUpdates(
      Set<String> selectedElements,
      Map<String, LayoutBlock> activeElements,
      Map<String, LayoutBlock> elements,
      double deltaX,
      double deltaY) {
    return Map<String, LayoutBlock>.fromEntries(
        selectedElements.map((id) => MapEntry(
            id,
            activeElements[id]?.copyWith(
                  xPos: activeElements[id].xPos + deltaX,
                  yPos: activeElements[id].yPos + deltaY,
                ) ??
                elements[id].copyWith(
                  xPos: elements[id].xPos + deltaX,
                  yPos: elements[id].yPos + deltaY,
                ))));
  }

  Vector3 _getRotationOffsetVector(
      LayoutBlock existing, LayoutBlock updatedElement) {
    final dimensionChangeVector = Vector3(updatedElement.width - existing.width,
        updatedElement.height - existing.height, 0);

    // Represents the Transformation that would have been applied to the existing Shape.
    final Matrix4 existingElementMatrix =
        _getRotationMatrix(existing.width, existing.height, existing.rotation);

    // Represents the Transformation that Will be applied to the updated Shape.
    Matrix4 updatedElementMatrix = _getRotationMatrix(
        updatedElement.width, updatedElement.height, existing.rotation);

    // Pass the DimensionChangeVector through both Matrices.
    final existingTransformedVector =
        existingElementMatrix.transformed3(dimensionChangeVector);
    final updatedTransformedVector =
        updatedElementMatrix.transformed3(dimensionChangeVector);

    // Find the X and Y Difference. Use these to offset the xPos and yPos of the shape ahead of the transformation.
    final xPosDelta = existingTransformedVector.x - updatedTransformedVector.x;
    final yPosDelta = existingTransformedVector.y - updatedTransformedVector.y;

    return Vector3(xPosDelta, yPosDelta, 0);
  }
}

class _HitRect {
  final Rect rect;
  final String blockId;

  _HitRect({this.rect, this.blockId});
}
