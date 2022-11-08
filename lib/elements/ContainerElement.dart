import 'package:castboard_core/elements/ContainerItem.dart';
import 'package:castboard_core/elements/Dragger.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:castboard_core/layout-canvas/BackstopListener.dart';
import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:castboard_core/layout-canvas/last_tap_down.dart';
import 'package:castboard_core/secondary_context_menu/context_menu_item.dart';
import 'package:castboard_core/secondary_context_menu/secondary_context_menu.dart';
import 'package:castboard_core/secondary_context_menu/shortcut_label.dart';
import 'package:castboard_core/show_overlay.dart';
import 'package:castboard_core/utils/line_breaking.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const ElementRef _kShadowId = ElementRef.shadow();

const Map<MainAxisAlignment, WrapAlignment> _alignmentMapping = {
  MainAxisAlignment.start: WrapAlignment.start,
  MainAxisAlignment.center: WrapAlignment.center,
  MainAxisAlignment.end: WrapAlignment.end,
  MainAxisAlignment.spaceEvenly: WrapAlignment.spaceEvenly,
  MainAxisAlignment.spaceBetween: WrapAlignment.spaceBetween,
  MainAxisAlignment.spaceAround: WrapAlignment.spaceAround,
};

typedef OnOrderChanged = void Function(
    ElementRef id, int oldIndex, int newIndex);

typedef OnItemActionCallback = void Function(ElementRef itemId);

typedef OnItemDoubleClickCallback = void Function(
    PointerEvent event, ElementRef itemId);

const MainAxisAlignment _kDefaultMainAxisAlignment =
    MainAxisAlignment.spaceEvenly;
const CrossAxisAlignment _kDefaultCrossAxisAlignment =
    CrossAxisAlignment.stretch;
const WrapAlignment _kDefaultRunAlignment = WrapAlignment.spaceEvenly;

class ContainerElement extends StatefulWidget {
  final bool isEditing;
  final bool showHighlight;
  final bool showBorder;
  final bool allowWrap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final WrapAlignment runAlignment;
  final Axis axis;
  final ContainerRunLoading runLoading;
  final List<ContainerItem> items;
  final OnOrderChanged? onOrderChanged;
  final OnItemActionCallback? onItemClick;
  final OnItemActionCallback? onItemEvict;
  final OnItemActionCallback? onItemCopy;
  final OnItemActionCallback? onItemPaste;
  final OnItemActionCallback? onItemDelete;
  final OnItemActionCallback? onItemEdit;
  final OnItemDoubleClickCallback? onItemDoubleClick;

  const ContainerElement({
    Key? key,
    this.isEditing = false,
    this.showHighlight = false,
    this.showBorder = false,
    this.mainAxisAlignment = _kDefaultMainAxisAlignment,
    this.crossAxisAlignment = _kDefaultCrossAxisAlignment,
    this.runAlignment = _kDefaultRunAlignment,
    this.runLoading = ContainerRunLoading.topOrLeftHeavy,
    this.allowWrap = false,
    this.axis = Axis.horizontal,
    this.items = const [],
    this.onOrderChanged,
    this.onItemClick,
    this.onItemEvict,
    this.onItemCopy,
    this.onItemPaste,
    this.onItemDelete,
    this.onItemDoubleClick,
    this.onItemEdit,
  }) : super(key: key);

  @override
  ContainerElementState createState() => ContainerElementState();
}

class ContainerElementState extends State<ContainerElement> {
  bool _isDragging = false;
  ElementRef _candidateId = const ElementRef.none();
  int _candidateHomeIndex = -1;
  int _shadowIndex = -1;
  List<ContainerItem> _activeItems = const [];

  // Untracked State.
  LastTapDown? _lastTapDown;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        foregroundDecoration: _getForegroundDecoration(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            BackstopListener(
              onPointerDown:
                  widget.isEditing ? _handleBackstopPointerDown : null,
            ),
            _getChild(context, constraints),
            if (widget.showBorder)
              const Positioned(
                top: 2,
                right: 2,
                child: _EditingLabel(),
              ),
          ],
        ),
      );
    });
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

  Widget _getChild(BuildContext context, BoxConstraints constraints) {
    final items = _isDragging ? _activeItems : widget.items;
    final renderScale = RenderScale.of(context)!.scale!;

    // Delegate to fetch the Item Width or Height depending on the provdied axis.
    double getItemLength(ContainerItem item) => item.id == _kShadowId
        ? 0
        : widget.axis == Axis.horizontal
            ? item.size.width
            : item.size.height;

    // Use the 'Minimum Raggedness Divide and Conquer' algorithm to determine how to layout each item into run.
    final layoutIndexes = MinimumRaggedness.divide(
        items.map((item) => getItemLength(item) * renderScale).toList(),
        widget.axis == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight);

    // Take the List<List<int>> type returned by the layout algorithm and convert that to widgets.
    List<List<Widget>> children = layoutIndexes
        .map((run) => run.map((itemIndex) {
              final item = items[itemIndex];
              final scaledItemSize = item.size * renderScale;

              return _wrapVisibility(
                widget.isEditing,
                item: item,
                visible: item.id != _candidateId,
                child: Container(
                  alignment: Alignment.center,
                  width: scaledItemSize.width,
                  height: scaledItemSize.height,
                  child: _wrapDragger(
                    widget.isEditing,
                    item: item,
                    axis: Axis.horizontal,
                    renderScale: renderScale,
                    deferHitTestingToChild: item.deferHitTestingToChild,
                    child: item.child,
                  ),
                ),
              );
            }).toList())
        .toList();

    children = widget.runLoading == ContainerRunLoading.bottomOrRightHeavy
        ? children.reversed.toList()
        : children;

    switch (widget.axis) {
      case Axis.horizontal:
        return OverflowBox(
          maxHeight: double.infinity,
          child: _HorizontalContainer(
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            allowWrap: widget.allowWrap,
            runAlignment: widget.runAlignment,
            runLoading: widget.runLoading,
            children: children,
          ),
        );

      case Axis.vertical:
        return OverflowBox(
          maxWidth: double.infinity,
          child: _VerticalContainer(
              mainAxisAlignment: widget.mainAxisAlignment,
              crossAxisAlignment: widget.crossAxisAlignment,
              allowWrap: widget.allowWrap,
              runAlignment: widget.runAlignment,
              runLoading: widget.runLoading,
              children: children),
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
    required deferHitTestingToChild,
  }) {
    if (isEditing) {
      return Listener(
        onPointerDown: deferHitTestingToChild
            ? null
            : (event) => _handleDraggerPointerDown(event, item.id),
        child: Container(
          color: item.selected
              ? Colors.grey.withAlpha(64)
              : Colors
                  .transparent, // Colors.transparent is used so the container
          // will expand to fill, otherwise it will shirink and break the behaviour of the Pointer Listeners.
          foregroundDecoration: BoxDecoration(
            border: item.selected
                ? Border.all(color: Theme.of(context).colorScheme.secondary)
                : Border.all(
                    color: Colors.grey.withAlpha(50),
                  ),
          ),
          child: Dragger(
            id: item.id,
            deferHitTestingToChild: item.deferHitTestingToChild,
            axis: axis,
            targetOnly: item.id == _kShadowId,
            feedbackBuilder: (_) => _buildFeedback(
                renderScale, item.size * renderScale, item.child),
            onDragStart: () => _handleDragStart(item.id, item.index, item.size),
            onDragEnd: (_) => _handleDragEnd(),
            onHover: (side, candidateDetails) =>
                _handleHover(side, item.id, item.index, candidateDetails),
            dragData: DraggerDetails(item.id, item.index),
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
    required ContainerItem item,
    bool visible = true,
    required Widget child,
  }) {
    if (isEditing) {
      return Visibility(
        key: ValueKey(item.id),
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
                  onTap: () => widget.onItemPaste?.call(const ElementRef
                      .none()), // We don't actually use the itemId for Pasteing so an empty value is fine.
                ),
              ],
            );
          });
    }
  }

  void _handleDraggerPointerDown(
      PointerDownEvent event, ElementRef itemId) async {
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
                ),
                ContextMenuItemDivider(),
                ContextMenuItem(
                  label: 'Edit Item',
                  onTap: () => widget.onItemEdit?.call(itemId),
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

  void _handleHover(HoverSide side, ElementRef underItemId, int underItemIndex,
      DraggerDetails? candidateDetails) {
    if (candidateDetails == null) {
      return;
    }

    if (candidateDetails.index == underItemIndex) {
      // Candidate is hovering over it's Home Position.
      return;
    }

    if (underItemId == _kShadowId) {
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
      return items[targetIndex].id == _kShadowId;
    } else {
      return false;
    }
  }

  void _handleDragStart(
      ElementRef candidateId, int candidateHomeIndex, Size candidateSize) {
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
      _candidateId = const ElementRef.none();
      _candidateHomeIndex = -1;
      _shadowIndex = -1;
    });
  }

  ContainerItem _buildShadow(int index, Size size) {
    return ContainerItem(
      id: _kShadowId,
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

class _BalancedContainer extends StatelessWidget {
  final List<List<Widget>> children;

  const _BalancedContainer({Key? key, required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children
          .map((rowChildren) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: rowChildren,
              ))
          .toList(),
    );
  }
}

class _HorizontalContainer extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final WrapAlignment runAlignment;
  final ContainerRunLoading runLoading;
  final bool allowWrap;
  final List<List<Widget>> children;

  const _HorizontalContainer({
    Key? key,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.runAlignment = WrapAlignment.spaceEvenly,
    this.runLoading = ContainerRunLoading.bottomOrRightHeavy,
    this.allowWrap = true,
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (allowWrap) {
      return Column(
        mainAxisAlignment: _convertToMainAxisAlignment(runAlignment),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((row) {
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            verticalDirection: getVerticalDirection(runLoading),
            textDirection: getTextDirection(runLoading),
            children: row.map((child) => child).toList(),
          );
        }).toList(),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children.expand((element) => element).toList(),
    );
  }
}

class _VerticalContainer extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final WrapAlignment runAlignment;
  final ContainerRunLoading runLoading;
  final bool allowWrap;
  final List<List<Widget>> children;

  const _VerticalContainer({
    Key? key,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.runAlignment = WrapAlignment.spaceEvenly,
    this.runLoading = ContainerRunLoading.bottomOrRightHeavy,
    this.allowWrap = true,
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (allowWrap) {
      return Row(
        mainAxisAlignment: _convertToMainAxisAlignment(runAlignment),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((row) {
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            verticalDirection: getVerticalDirection(runLoading),
            textDirection: getTextDirection(runLoading),
            children: row.map((child) => child).toList(),
          );
        }).toList(),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children.expand((element) => element).toList(),
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

MainAxisAlignment _convertToMainAxisAlignment(WrapAlignment wrapAlignment) {
  switch (wrapAlignment) {
    case WrapAlignment.start:
      return MainAxisAlignment.start;
    case WrapAlignment.end:
      return MainAxisAlignment.end;
    case WrapAlignment.center:
      return MainAxisAlignment.center;
    case WrapAlignment.spaceBetween:
      return MainAxisAlignment.spaceBetween;
    case WrapAlignment.spaceAround:
      return MainAxisAlignment.spaceAround;
    case WrapAlignment.spaceEvenly:
      return MainAxisAlignment.spaceEvenly;
  }
}
