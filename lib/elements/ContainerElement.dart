import 'package:castboard_core/elements/ContainerItem.dart';
import 'package:castboard_core/elements/Dragger.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:castboard_core/layout-canvas/BackstopListener.dart';
import 'package:castboard_core/layout-canvas/last_tap_down.dart';
import 'package:castboard_core/secondary_context_menu/context_menu_item.dart';
import 'package:castboard_core/secondary_context_menu/secondary_context_menu.dart';
import 'package:castboard_core/secondary_context_menu/shortcut_label.dart';
import 'package:castboard_core/show_overlay.dart';
import 'package:flutter/gestures.dart';
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

typedef OnOrderChanged = void Function(
    String? dragId, int oldIndex, int newIndex);

typedef OnItemActionCallback = void Function(String itemId);

typedef OnItemDoubleClickCallback = void Function(
    PointerEvent event, String itemId);

class ContainerElement extends StatefulWidget {
  final bool isEditing;
  final bool showHighlight;
  final bool showBorder;
  final bool allowWrap;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final WrapAlignment? runAlignment;
  final Axis axis;
  final ContainerRunLoading runLoading;
  final List<ContainerItem>? items;
  final OnOrderChanged? onOrderChanged;
  final dynamic onItemClick;
  final OnItemActionCallback? onItemEvict;
  final OnItemActionCallback? onItemCopy;
  final OnItemActionCallback? onItemPaste;
  final OnItemActionCallback? onItemDelete;
  final OnItemDoubleClickCallback? onItemDoubleClick;

  const ContainerElement({
    Key? key,
    this.isEditing = false,
    this.showHighlight = false,
    this.showBorder = false,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.runAlignment,
    this.runLoading = ContainerRunLoading.topOrLeftHeavy,
    this.allowWrap = false,
    this.axis = Axis.horizontal,
    this.items,
    this.onOrderChanged,
    this.onItemClick,
    this.onItemEvict,
    this.onItemCopy,
    this.onItemPaste,
    this.onItemDelete,
    this.onItemDoubleClick,
  }) : super(key: key);

  @override
  ContainerElementState createState() => ContainerElementState();
}

class ContainerElementState extends State<ContainerElement> {
  bool _isDragging = false;
  String? _candidateId = '';
  int _candidateHomeIndex = -1;
  int _shadowIndex = -1;
  List<ContainerItem> _activeItems = const [];

  // Untracked State.
  LastTapDown? _lastTapDown;

  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: _getForegroundDecoration(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackstopListener(
            onPointerDown: widget.isEditing ? _handleBackstopPointerDown : null,
          ),
          _getChild(context),
          if (widget.showBorder)
            const Positioned(
              top: 2,
              right: 2,
              child: _EditingLabel(),
            ),
        ],
      ),
    );
  }

  BoxDecoration? _getForegroundDecoration() {
    if (widget.showHighlight == true) {
      // Highlight Border.
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
    final renderScale = RenderScale.of(context)!.scale;

    switch (widget.axis) {
      case Axis.horizontal:
        return _HorizontalContainer(
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          allowWrap: widget.allowWrap,
          runAlignment: widget.runAlignment,
          runLoading: widget.runLoading,
          children: items!.map((item) {
            final scaledItemSize = item.size * renderScale!;
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
          runLoading: widget.runLoading,
          children: items!.map((item) {
            final scaledItemSize = item.size * renderScale!;
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
  Widget _wrapDragger(
    bool isEditing, {
    required ContainerItem item,
    required double renderScale,
    required Widget child,
    required Axis axis,
  }) {
    if (isEditing) {
      return Listener(
        onPointerDown: (event) => _handleDraggerPointerDown(event, item.dragId),
        child: Container(
          color: item.selected ? Colors.grey.withAlpha(64) : null,
          foregroundDecoration: BoxDecoration(
            border: item.selected
                ? Border.all(color: Theme.of(context).colorScheme.secondary)
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
            onDragEnd: (_) => _handleDragEnd(),
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
    ContainerItem? item,
    bool visible = true,
    required Widget child,
  }) {
    if (isEditing) {
      return Visibility(
        key: Key(item!.dragId),
        visible: visible,
        maintainState: true,
        child: child,
      );
    } else {
      return child;
    }
  }

  void _handleBackstopPointerDown(PointerDownEvent event) async {
    if (event.buttons == kSecondaryMouseButton) {
      await showOverlay(
          context: context,
          builder: (context) {
            return SecondaryContextMenu(
              offset: event.position,
              items: [
                ContextMenuItem(
                  label: 'Paste',
                  shortcut: ShortcutLabel.paste,
                  onTap: () => widget.onItemPaste?.call(
                      ''), // We don't actually use the itemId for Pasteing so an empty string is fine.
                ),
              ],
            );
          });
    }
  }

  void _handleDraggerPointerDown(PointerDownEvent event, String itemId) async {
    if (event.buttons == kSecondaryMouseButton) {
      await showOverlay(
          context: context,
          builder: (context) {
            return SecondaryContextMenu(
              offset: event.position,
              items: [
                ContextMenuItem(
                  label: 'Evict Item',
                  onTap: () => widget.onItemEvict?.call(itemId),
                ),
                ContextMenuItemDivider(),
                ContextMenuItem(
                  label: 'Copy',
                  shortcut: ShortcutLabel.copy,
                  onTap: () => widget.onItemCopy?.call(itemId),
                ),
                ContextMenuItem(
                  label: 'Paste',
                  shortcut: ShortcutLabel.paste,
                  onTap: () => widget.onItemPaste?.call(itemId),
                ),
                ContextMenuItemDivider(),
                ContextMenuItem(
                  label: 'Delete',
                  shortcut: ShortcutLabel.delete,
                  onTap: () => widget.onItemDelete?.call(itemId),
                )
              ],
            );
          });
    }

    if (event.buttons == kPrimaryButton) {
      if (_lastTapDown != null && _lastTapDown!.itemId == itemId) {
        final now = DateTime.now();
        if (now.difference(_lastTapDown!.timestamp).inMilliseconds < 500) {
          widget.onItemDoubleClick?.call(event, itemId);
          _lastTapDown = LastTapDown(itemId, DateTime.now());
          return;
        }
      }
      _lastTapDown = LastTapDown(itemId, DateTime.now());
    }

    widget.onItemClick?.call(itemId);
  }

  Widget _buildFeedback(double? renderScale, Size itemSize, Widget child) {
    return SizedBox(
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

  void _handleHover(HoverSide side, String? underItemId, int underItemIndex,
      DraggerDetails? candidateDetails) {
    if (candidateDetails == null) {
      return;
    }

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
      return items[targetIndex].dragId == _shadowId;
    } else {
      return false;
    }
  }

  void _handleDragStart(
      String? candidateId, int candidateHomeIndex, Size candidateSize) {
    setState(() {
      _isDragging = true;
      _activeItems = _withRebuiltIndices(
        widget.items!.toList()
          ..insert(candidateHomeIndex,
              _buildShadow(candidateHomeIndex, candidateSize)),
      );
      _shadowIndex = candidateHomeIndex;
      _candidateHomeIndex = candidateHomeIndex;
      _candidateId = candidateId;
    });
  }

  void _handleDragEnd() {
    final oldIndex = _candidateHomeIndex;
    final newIndex =
        _candidateHomeIndex < _shadowIndex ? _shadowIndex - 1 : _shadowIndex;
    if (oldIndex != newIndex) {
      final newIndexOffset = newIndex > oldIndex
          ? 1
          : 0; // Huh? because List.insert() inserts items Before the existing items,
      // we need to conditionally offset our newIndex. We do this here so that the behaviour is consitent with
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
      dragId: _shadowId,
      index: index,
      size: size,
      child: const _ItemShadow(),
    );
  }

  List<ContainerItem> _withRebuiltIndices(List<ContainerItem> items) {
    int index = 0;
    return items.map((item) => item.copyWith(index: index++)).toList()
      ..sort((a, b) => a.index - b.index);
  }
}

class _ItemShadow extends StatelessWidget {
  const _ItemShadow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}

class _HorizontalContainer extends StatelessWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final WrapAlignment? runAlignment;
  final ContainerRunLoading? runLoading;
  final bool allowWrap;

  final List<Widget> children;

  const _HorizontalContainer({
    Key? key,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.runAlignment,
    this.runLoading,
    this.allowWrap = false,
    this.children = const <Widget>[],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (allowWrap) {
      final concreteRunLoading =
          runLoading ?? ContainerRunLoading.bottomOrRightHeavy;

      return Wrap(
        alignment: _alignmentMapping[mainAxisAlignment!]!,
        runAlignment: runAlignment ?? WrapAlignment.start,
        direction: Axis.horizontal,
        verticalDirection: getVerticalDirection(concreteRunLoading),
        textDirection: getTextDirection(concreteRunLoading),
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _VerticalContainer extends StatelessWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final List<Widget?>? children;
  final WrapAlignment? runAlignment;
  final ContainerRunLoading? runLoading;
  final bool allowWrap;

  const _VerticalContainer(
      {Key? key,
      this.mainAxisAlignment,
      this.crossAxisAlignment,
      this.runAlignment,
      this.allowWrap = false,
      this.runLoading,
      this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (allowWrap) {
      final concreteRunLoading =
          runLoading ?? ContainerRunLoading.bottomOrRightHeavy;

      return Wrap(
        alignment: _alignmentMapping[mainAxisAlignment!]!,
        runAlignment: runAlignment ?? WrapAlignment.start,
        direction: Axis.vertical,
        verticalDirection: getVerticalDirection(concreteRunLoading),
        textDirection: getTextDirection(concreteRunLoading),
        children: children as List<Widget>? ?? const [],
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: children as List<Widget>? ?? const [],
    );
  }
}

VerticalDirection getVerticalDirection(ContainerRunLoading runLoading) {
  switch (runLoading) {
    case ContainerRunLoading.topOrLeftHeavy:
      return VerticalDirection.down;
    case ContainerRunLoading.bottomOrRightHeavy:
      return VerticalDirection.up;
  }
}

TextDirection getTextDirection(ContainerRunLoading runLoading) {
  switch (runLoading) {
    case ContainerRunLoading.topOrLeftHeavy:
      return TextDirection.ltr;
    case ContainerRunLoading.bottomOrRightHeavy:
      return TextDirection.rtl;
  }
}

class _EditingLabel extends StatelessWidget {
  const _EditingLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final renderScale = RenderScale.of(context)?.scale ?? 1;

    return Container(
      padding: EdgeInsets.all(4 * renderScale),
      color: const Color(0x88FFFFFF),
      child: Text('Auto Layout',
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(color: Colors.black, fontSize: 24 * renderScale)),
    );
  }
}
