import 'package:castboard_core/secondary_context_menu/context_menu_item.dart';
import 'package:flutter/material.dart';

class SecondaryContextMenu extends StatefulWidget {
  final List<ContextMenuItemBase> items;
  final Offset offset;

  const SecondaryContextMenu(
      {Key? key, this.items = const [], required this.offset})
      : super(key: key);

  @override
  State<SecondaryContextMenu> createState() => _SecondaryContextMenuState();
}

class _SecondaryContextMenuState extends State<SecondaryContextMenu> {
  @override
  Widget build(BuildContext context) {
    final height = _calculateHeight(widget.items);
    const width = 300.0;

    return Stack(
      children: [
        Positioned(
          top: _ensureVerticalFit(
              minimumHeight: height,
              screenHeight: MediaQuery.of(context).size.height,
              topOffset: widget.offset.dy),
          left: _ensureHorizontalFit(
              minimumWidth: width,
              screenWidth: MediaQuery.of(context).size.width,
              leftOffset: widget.offset.dx),
          child: SizedBox(
            width: width,
            height: height,
            child: Material(
              elevation: 10,
              child: Column(
                children: _mapItems(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _mapItems(BuildContext context) {
    return widget.items.map((item) {
      if (item is ContextMenuItem) {
        return ListTile(
          enabled: item.enabled,
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            item.onTap?.call();
          },
          leading: item.icon == null ? null : Icon(item.icon),
          title: Text(item.label),
          trailing: item.shortcut == null
              ? null
              : Text(item.shortcut!,
                  style: Theme.of(context).textTheme.caption),
          dense: true,
        );
      } else {
        return const SizedBox(
          height: 28,
          child: Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Divider(),
          ),
        );
      }
    }).toList();
  }

  double _calculateHeight(List<ContextMenuItemBase> items) {
    final dividersCount = items.whereType<ContextMenuItemDivider>().length;
    final itemsCount = items.whereType<ContextMenuItem>().length;
    
    return (itemsCount * 40) + (dividersCount * 28);
  }

  _ensureHorizontalFit(
      {required double minimumWidth,
      required double screenWidth,
      required double leftOffset}) {
    final renderedWidth = screenWidth - leftOffset;

    if (renderedWidth < minimumWidth) {
      // Popup isn't going to comfortably fit.
      return leftOffset - minimumWidth > 0 ? leftOffset - minimumWidth : 0;
    }

    return leftOffset;
  }

  double _ensureVerticalFit({
    required double minimumHeight,
    required double screenHeight,
    required double topOffset,
  }) {
    final renderedHeight = screenHeight - topOffset;

    if (renderedHeight < minimumHeight) {
      // Popup isn't going to comfortably fit.
      return topOffset - minimumHeight > 0 ? topOffset - minimumHeight : 0;
    }

    return topOffset;
  }
}
