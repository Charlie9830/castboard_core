import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchDropdown extends StatefulWidget {
  final List<SearchDropdownItem> Function(BuildContext context) itemsBuilder;
  final SearchDropdownItem? Function(BuildContext context) selectedItemBuilder;
  final bool enabled;
  final void Function(dynamic value) onChanged;

  SearchDropdown({
    Key? key,
    required this.itemsBuilder,
    required this.selectedItemBuilder,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  _SearchDropdownState createState() => _SearchDropdownState();
}

class _SearchDropdownState extends State<SearchDropdown> {
  // Non Flutter Tracked State.
  OverlayEntry? _backdrop;
  OverlayEntry? _entry;

  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.selectedItemBuilder(context);

    return Container(
        child: GestureDetector(
      onTap: widget.enabled ? () => _handleOpen(context, selectedItem) : null,
      child: _Closed(
        enabled: widget.enabled,
        child: selectedItem?.child,
      ),
    ));
  }

  void _handleOpen(BuildContext context, SearchDropdownItem? selectedItem) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    _entry = OverlayEntry(builder: (overlayContext) {
      return Positioned(
          left: offset.dx,
          top: offset.dy,
          bottom: 0,
          child: _SearchDropdownContent(
            value: selectedItem as SearchDropdownItem,
            items: widget.itemsBuilder.call(context),
            onChanged: _handleValueChanged,
          ));
    });

    _backdrop = OverlayEntry(
        builder: (_) => GestureDetector(
            onTap: () => _handleClose(),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: screenHeight,
              width: MediaQuery.of(context).size.width,
            )));

    Overlay.of(context)?.insert(_backdrop!);
    Overlay.of(context)?.insert(_entry!, above: _backdrop);
  }

  void _handleValueChanged(dynamic newValue) {
    _handleClose();
    widget.onChanged(newValue);
  }

  void _handleClose() {
    _entry?.remove();
    _backdrop?.remove();

    _entry = null;
    _backdrop = null;
  }

  @override
  void dispose() {
    _entry?.remove();
    _backdrop?.remove();

    super.dispose();
  }
}

class _SearchDropdownContent extends StatefulWidget {
  final List<SearchDropdownItem> items;
  final SearchDropdownItem? value;
  final void Function(dynamic value) onChanged;

  _SearchDropdownContent({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  __SearchDropdownContentState createState() => __SearchDropdownContentState();
}

class __SearchDropdownContentState extends State<_SearchDropdownContent> {
  late TextEditingController _controller;
  List<SearchDropdownItem> _options = <SearchDropdownItem>[];
  SearchDropdownItem? _highlightedItem;
  late FocusNode _keyListenerFocusNode;
  late FocusNode _textFieldFocusNode;

  // Non Flutter Tracked State.
  bool _initalizing = true;

  @override
  void initState() {
    _controller = TextEditingController()
      ..value = TextEditingValue(
          text: widget.value?.keyword ?? '',
          selection: TextSelection(
              baseOffset: 0, extentOffset: widget.value?.keyword.length ?? 0));

    _controller.addListener(() {
      // Requesting Focus to the textField Triggers this callback. Which messes things up if it runs before any text
      // has actually changed (Causes a premature filtering of items). _initalizing is a check flag to ensure we ignore
      // the first time this listener is called.
      if (_initalizing == false) {
        setState(() {
          _options = _filterItems(_controller.text, widget.items);
        });
      }

      _initalizing = false;
    });

    _options = widget.items.toList();
    _highlightedItem = widget.value;

    _keyListenerFocusNode = FocusNode();
    _textFieldFocusNode = FocusNode()..requestFocus();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKey: _handleKey,
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        width: 400,
        child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8, top: 8, right: 8),
                  child: TextField(
                    controller: _controller,
                    focusNode: _textFieldFocusNode,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _options.length,
                    itemBuilder: (context, index) {
                      final item = _options[index];
                      return ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: 36, maxHeight: 48),
                        key: ValueKey(item.value),
                        child: Container(
                          padding: EdgeInsets.only(left: 8),
                          color: _highlightedItem?.value == item.value
                              ? Theme.of(context).highlightColor
                              : null,
                          child: ListTile(
                            title: item.child,
                            onTap: () => widget.onChanged(item.value),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            )),
      ),
    );
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _handleEnterPress();
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_options.isEmpty) {
          return;
        }

        if (_highlightedItem == null) {
          setState(() => _highlightedItem = _options.first);
        }

        final currentIndex = _options
            .indexWhere(((item) => item.value == _highlightedItem!.value));

        if (currentIndex == -1) {
          return;
        }

        if (currentIndex + 1 < _options.length) {
          setState(() {
            _highlightedItem = _options[currentIndex + 1];
          });
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_options.isEmpty) {
          return;
        }

        if (_highlightedItem == null) {
          setState(() => _highlightedItem = _options.first);
        }

        final currentIndex = _options
            .indexWhere(((item) => item.value == _highlightedItem!.value));

        if (currentIndex == -1) {
          return;
        }

        if (currentIndex > 0) {
          setState(() {
            _highlightedItem = _options[currentIndex - 1];
          });
        }
      }
    }
  }

  void _handleEnterPress() {
    // If only a single Option Left.
    if (_options.length == 1) {
      widget.onChanged(_options.first.value);
    }

    // If an option is Highlighted and still appears within the List.
    if (_highlightedItem != null &&
        _options
            .where((item) => item.value == _highlightedItem!.value)
            .isNotEmpty) {
      widget.onChanged(_highlightedItem!.value);
    }
  }

  List<SearchDropdownItem> _filterItems(
      String searchTerm, List<SearchDropdownItem> items) {
    return items
        .where((item) =>
            item.keyword.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }
}

class _Closed extends StatelessWidget {
  final Widget? child;
  final Widget? hint;
  final bool enabled;

  const _Closed({
    Key? key,
    required this.child,
    this.hint,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final concreteHint = hint ?? _Hint();
    final concreteChild = child ?? concreteHint;

    return Container(
      height: 40,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: Theme.of(context).dividerColor,
        width: 1,
      ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          concreteChild,
          if (enabled) Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Select',
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
              color: Theme.of(context).hintColor,
            ));
  }
}

class SearchDropdownItem {
  final String keyword;
  final Widget child;
  final dynamic value;

  SearchDropdownItem({
    required this.keyword,
    required this.child,
    required this.value,
  });
}
