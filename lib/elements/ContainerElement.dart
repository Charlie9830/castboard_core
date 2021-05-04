import 'package:castboard_core/elements/ContainerItem.dart';
import 'package:castboard_core/elements/Dragger.dart';
import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:castboard_core/layout-canvas/MultiChildCanvasItem.dart';
import 'package:flutter/material.dart';

const String _shadowId = 'shadow';

const Map<MainAxisAlignment, WrapAlignment> _alignmentMapping = {
  MainAxisAlignment.start: WrapAlignment.start,
  MainAxisAlignment.center: WrapAlignment.center,
  MainAxisAlignment.end: WrapAlignment.end,
  MainAxisAlignment.spaceEvenly: WrapAlignment.spaceEvenly,
  MainAxisAlignment.spaceBetween: WrapAlignment.spaceBetween,
  MainAxisAlignment.spaceAround: WrapAlignment.spaceAround,
};

typedef void OnOrderChanged(String dragId, int oldIndex, int newIndex);

class ContainerElement extends StatefulWidget {
  final bool isEditing;
  final bool showHighlight;
  final bool showBorder;
  final bool allowWrap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final WrapAlignment runAlignment;
  final Axis axis;
  final List<ContainerItem> items;
  final OnOrderChanged onOrderChanged;
  final dynamic onItemClick;

  const ContainerElement({
    Key key,
    this.isEditing,
    this.showHighlight = false,
    this.showBorder = false,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.runAlignment,
    this.allowWrap = false,
    this.axis = Axis.horizontal,
    this.items,
    this.onOrderChanged,
    this.onItemClick,
  }) : super(key: key);

  @override
  _ContainerElementState createState() => _ContainerElementState();
}

class _ContainerElementState extends State<ContainerElement> {
  bool _isDragging = false;
  String _candidateId = '';
  int _candidateHomeIndex = -1;
  int _shadowIndex = -1;
  List<ContainerItem> _activeItems = const [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _getChild(context),
      foregroundDecoration: _getForegroundDecoration(),
    );
  }

  BoxDecoration _getForegroundDecoration() {
    if (widget.showHighlight == true) {
      //Highlight Border.
      return BoxDecoration(
        border: Border.all(color: Theme.of(context).indicatorColor, width: 2),
      );
    }

    if (widget.showBorder == true) {
      // Editor Guide Border.
      return BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(128), width: 2),
      );
    }

    // Show nothing. (For running in Presentation).
    return null;
  }

  Widget _getChild(BuildContext context) {
    final items = _isDragging ? _activeItems : widget.items;
    final renderScale = RenderScale.of(context).scale;

    switch (widget.axis) {
      case Axis.horizontal:
        return _HorizontalContainer(
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          allowWrap: widget.allowWrap,
          runAlignment: widget.runAlignment,
          children: items.map((item) {
            final scaledItemSize = item.size * renderScale;
            return _wrapVisibility(
              widget.isEditing,
              item: item,
              visible: item.dragId != _candidateId,
              child: Container(
                alignment: Alignment.center,
                width: scaledItemSize.width,
                height: scaledItemSize.height,
                child: _wrapDragger(
                  widget.isEditing,
                  item: item,
                  axis: Axis.horizontal,
                  renderScale: renderScale,
                  child: item.child,
                ),
              ),
            );
          }).toList(),
        );

      case Axis.vertical:
        return _VerticalContainer(
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          allowWrap: widget.allowWrap,
          runAlignment: widget.runAlignment,
          children: items.map((item) {
            final scaledItemSize = item.size * renderScale;
            return _wrapVisibility(
              widget.isEditing,
              item: item,
              visible: item.dragId != _candidateId,
              child: Container(
                alignment: Alignment.center,
                width: scaledItemSize.width,
                height: scaledItemSize.height,
                child: _wrapDragger(
                  widget.isEditing,
                  item: item,
                  axis: Axis.vertical,
                  renderScale: renderScale,
                  child: item.child,
                ),
              ),
            );
          }).toList(),
        );

      default:
        throw Exception('Unknown Axis value. Value is ${widget.axis}');
    }
  }

  ///
  /// Conditionally wraps a Dragger Element around child based on the value of isEditing.
  ///
  Widget _wrapDragger(bool isEditing,
      {ContainerItem item, double renderScale, Widget child, Axis axis}) {
    if (isEditing) {
      return Listener(
        onPointerDown: (event) => _handleDraggerPointerDown(item.dragId),
        child: Container(
          color: item.selected ? Colors.grey.withAlpha(64) : null,
          foregroundDecoration: BoxDecoration(
            border: item.selected
                ? Border.all(color: Theme.of(context).accentColor)
                : Border.all(
                    color: Colors.grey.withAlpha(50),
                  ),
          ),
          child: Dragger(
            axis: axis,
            targetOnly: item.dragId == _shadowId,
            feedbackBuilder: (_) => _buildFeedback(
                renderScale, item.size * renderScale, item.child),
            onDragStart: () =>
                _handleDragStart(item.dragId, item.index, item.size),
            onDragEnd: (candidateDetails) => _handleDragEnd(candidateDetails),
            onHover: (side, candidateDetails) =>
                _handleHover(side, item.dragId, item.index, candidateDetails),
            dragData: DraggerDetails(item.dragId, item.index),
            child: child,
          ),
        ),
      );
    } else {
      return child;
    }
  }

  ///
  /// Conditionally wraps a Visibility Widget around child based on the value of isEditing.
  ///
  Widget _wrapVisibility(
    bool isEditing, {
    ContainerItem item,
    bool visible = true,
    Widget child,
  }) {
    if (isEditing) {
      return Visibility(
        key: Key(item.dragId),
        visible: visible,
        maintainState: true,
        child: child,
      );
    } else {
      return child;
    }
  }

  void _handleDraggerPointerDown(String itemId) {
    widget.onItemClick?.call(itemId);
  }

  Widget _buildFeedback(double renderScale, Size itemSize, Widget child) {
    return Container(
      width: itemSize.width,
      height: itemSize.height,
      child: RenderScale(
        scale: renderScale,
        child: Transform.translate(
            offset:
                Offset((itemSize.width / 2) * -1, (itemSize.height / 2) * -1),
            child: Opacity(opacity: 0.5, child: child)),
      ),
    );
  }

  void _handleHover(HoverSide side, String underItemId, int underItemIndex,
      DraggerDetails candidateDetails) {
    if (candidateDetails.index == underItemIndex) {
      // Candidate is hovering over it's Home Position.
      return;
    }

    if (underItemId == _shadowId) {
      // Candidate is hovering above it's own Shadow.
      return;
    }

    if (_activeItems.isEmpty || _activeItems.length == 1) {
      // No Dragging allowed.
      return;
    }

    final newItems = _activeItems.toList();

    switch (side) {
      case HoverSide.start:
        // Relocate Shadow
        if (_isShadowAlreadyInPlace(_activeItems, underItemIndex - 1)) {
          // Shadow is already in correct position. No need to do anything.
          break;
        }

        // Relocate Shadow.
        _relocateShadowToStartSide(underItemIndex, newItems);

        break;
      case HoverSide.end:
        if (_isShadowAlreadyInPlace(_activeItems, underItemIndex + 1)) {
          // Shadow is already in correct position. No need to do anything.
          break;
        }

        // Relocate Shadow
        _relocateShadowToEndSide(underItemIndex, newItems);

        break;
    }
  }

  ///
  /// Relocates the Shadow to the End (Right or Bottom) side of the item at underItemIndex.
  ///
  void _relocateShadowToEndSide(
      int underItemIndex, List<ContainerItem> newItems) {
    // To avoid getting into list index offsetting and edge cases. We check for and perform the mutations in the following
    // sequence.
    // 1. Check if the underItem is the first item in the list.
    // 2. Check if the underItem is the last item in the list.
    // 3. Check if the underItem is higher in the list then the current shadow, therefore we need to adjust the index after
    //    removing the shadow.
    // 4. Check if the underItem is below the shadow in the index, no index offsetting is required for this.

    if (underItemIndex == 0) {
      // Relocate the shadow to just after the first item (Because this is an End Side)
      final shadow = newItems.removeAt(_shadowIndex);

      newItems.insert(1, shadow);

      setState(() {
        _activeItems = _withRebuiltIndices(newItems);
        _shadowIndex = 1;
      });

      return;
    }

    if (underItemIndex == newItems.length - 1) {
      // Relocate the Shadow to the very end of the List (Because this is an End Side)
      final shadow = newItems.removeAt(_shadowIndex);
      newItems.add(shadow);

      setState(() {
        _activeItems = _withRebuiltIndices(newItems);
        _shadowIndex = newItems.length - 1;
      });

      return;
    }

    if (underItemIndex > _shadowIndex) {
      // Relocate the shadow to after the UnderItemIndex (Because this is an End Side)
      final shadow = newItems.removeAt(_shadowIndex);
      newItems.insert(underItemIndex, shadow);

      setState(() {
        _activeItems = _withRebuiltIndices(newItems);
        _shadowIndex = underItemIndex;
      });

      return;
    }

    if (underItemIndex < _shadowIndex) {
      // Relocate the shadow to just after the underItem (Because this is an End Side).
      // Different case to the above because underItemIndex is less then _shadowIndex. we don't have to offset
      // the index after removing the shadow.
      final shadow = newItems.removeAt(_shadowIndex);
      newItems.insert(underItemIndex + 1, shadow);

      setState(() {
        _activeItems = _withRebuiltIndices(newItems);
        _shadowIndex = underItemIndex + 1;
      });

      return;
    }
  }

  ///
  /// Relocates the Shadow to the Start (Left or Top) side of the item at underItemIndex.
  ///
  void _relocateShadowToStartSide(
      int underItemIndex, List<ContainerItem> newItems) {
    // To avoid getting into list index offsetting and edge cases. We check for and perform the mutations in the following
    // sequence.
    // 1. Check if the underItem is the first item in the list.
    // 2. Check if the underItem is the last item in the list.
    // 3. Check if the underItem is higher in the list then the current shadow, therefore we need to adjust the index after
    //    removing the shadow.
    // 4. Check if the underItem is below the shadow in the index, no index offsetting is required for this.
    if (underItemIndex == 0) {
      // Relocate the Shadow to the begining of the List.
      final shadow = newItems.removeAt(_shadowIndex);
      newItems.insert(0, shadow);

      setState(() {
        _activeItems = _withRebuiltIndices(newItems);
        _shadowIndex = 0;
      });

      return;
    }

    if (underItemIndex == newItems.length - 1) {
      // Relocate the shadow to just before the last Element (Because this is a Start Side).
      final shadow = newItems.removeAt(_shadowIndex);
      newItems.insert(newItems.indexOf(newItems.last), shadow);

      setState(() {
        _activeItems = _withRebuiltIndices(newItems);
        _shadowIndex = newItems.length -
            2; // Why the -2? Because we inserted the shadow at the second to last position in the array
      });

      return;
    }

    if (underItemIndex > _shadowIndex) {
      // Relocate the shadow to just before the underItem (Because this is a Start Side)
      final shadow = newItems.removeAt(_shadowIndex);
      newItems.insert(underItemIndex - 1, shadow);

      setState(() {
        _activeItems = _withRebuiltIndices(newItems);
        _shadowIndex = underItemIndex - 1;
      });
      return;
    }

    if (underItemIndex < _shadowIndex) {
      // Relocate the shadow to just before the underItem (Because this is a start side).
      // Different case to the above because underItemIndex is less then _shadowIndex. we don't have to offset
      // the index after removing the shadow.
      final shadow = newItems.removeAt(_shadowIndex);
      newItems.insert(underItemIndex, shadow);

      setState(() {
        _activeItems = _withRebuiltIndices(newItems);
        _shadowIndex = underItemIndex;
      });
      return;
    }
  }

  bool _isShadowAlreadyInPlace(List<ContainerItem> items, int targetIndex) {
    if (targetIndex >= 0 && targetIndex < items.length) {
      return items[targetIndex]?.dragId == _shadowId;
    } else {
      return false;
    }
  }

  void _handleDragStart(
      String candidateId, int candidateHomeIndex, Size candidateSize) {
    setState(() {
      _isDragging = true;
      _activeItems = _withRebuiltIndices(
        widget.items.toList()
          ..insert(candidateHomeIndex,
              _buildShadow(candidateHomeIndex, candidateSize)),
      );
      _shadowIndex = candidateHomeIndex;
      _candidateHomeIndex = candidateHomeIndex;
      _candidateId = candidateId;
    });
  }

  void _handleDragEnd(DraggerDetails candidateDetails) {
    final oldIndex = _candidateHomeIndex;
    final newIndex =
        _candidateHomeIndex < _shadowIndex ? _shadowIndex - 1 : _shadowIndex;
    if (oldIndex != newIndex) {
      final newIndexOffset = newIndex > oldIndex
          ? 1
          : 0; // Huh? because List.insert() inserts items Before the existing items,
      // we need to conditionally offset our newIndex. We do this hear so that the behaviour is consitent with
      // ReorderableListView.

      // Notify.
      widget.onOrderChanged
          ?.call(_candidateId, oldIndex, newIndex + newIndexOffset);
    }

    setState(() {
      _isDragging = false;
      _activeItems = const [];
      _candidateId = '';
      _candidateHomeIndex = -1;
      _shadowIndex = -1;
    });
  }

  ContainerItem _buildShadow(int index, Size size) {
    return ContainerItem(
      child: _ItemShadow(),
      dragId: _shadowId,
      index: index,
      size: size,
    );
  }

  List<ContainerItem> _withRebuiltIndices(List<ContainerItem> items) {
    int index = 0;
    return items.map((item) => item.copyWith(index: index++)).toList()
      ..sort((a, b) => a.index - b.index);
  }
}

class _ItemShadow extends StatelessWidget {
  const _ItemShadow({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand();
  }
}

class _HorizontalContainer extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final WrapAlignment runAlignment;
  final bool allowWrap;

  final List<Widget> children;

  const _HorizontalContainer(
      {Key key,
      this.mainAxisAlignment,
      this.crossAxisAlignment,
      this.runAlignment,
      this.allowWrap = false,
      this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (allowWrap) {
      return Wrap(
        alignment: _alignmentMapping[mainAxisAlignment],
        runAlignment: runAlignment ?? WrapAlignment.start,
        direction: Axis.horizontal,
        children: children ?? const [],
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: children ?? const [],
    );
  }
}

class _VerticalContainer extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;
  final WrapAlignment runAlignment;
  final bool allowWrap;

  const _VerticalContainer(
      {Key key,
      this.mainAxisAlignment,
      this.crossAxisAlignment,
      this.runAlignment,
      this.allowWrap = false,
      this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (allowWrap) {
      return Wrap(
        alignment: _alignmentMapping[mainAxisAlignment],
        runAlignment: runAlignment ?? WrapAlignment.start,
        direction: Axis.vertical,
        children: children ?? const [],
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: children ?? const [],
    );
  }
}
