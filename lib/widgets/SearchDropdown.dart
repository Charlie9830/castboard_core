import 'package:castboard_core/utils/is_mobile_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchDropdown extends StatefulWidget {
  final List<SearchDropdownItem> Function(BuildContext context) itemsBuilder;
  final SearchDropdownItem? Function(BuildContext context) selectedItemBuilder;
  final Widget Function(
          BuildContext context, void Function(dynamic value) onSelect)?
      specialOptionsBuilder;
  final bool enabled;
  final void Function(dynamic value) onChanged;

  const SearchDropdown({
    Key? key,
    required this.itemsBuilder,
    required this.selectedItemBuilder,
    required this.onChanged,
    this.specialOptionsBuilder,
    this.enabled = true,
  }) : super(key: key);

  @override
  SearchDropdownState createState() => SearchDropdownState();
}

class SearchDropdownState extends State<SearchDropdown> {
  // Non Flutter Tracked State.
  OverlayEntry? _backdrop;
  OverlayEntry? _entry;

  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.selectedItemBuilder(context);

    return GestureDetector(
      onTap: widget.enabled ? () => _handleOpen(context, selectedItem) : null,
      child: _Closed(
        enabled: widget.enabled,
        child: selectedItem?.child,
      ),
    );
  }

  void _handleOpen(BuildContext context, SearchDropdownItem? selectedItem) {
    if (isMobileLayout(context)) {
      _handleMobileOpen(context, selectedItem);
    } else {
      _handleDesktopOpen(context, selectedItem);
    }
  }

  void _handleMobileOpen(
      BuildContext context, SearchDropdownItem? selectedItem) async {
    await showModalBottomSheet(
        enableDrag: false,
        isScrollControlled: true,
        context: context,
        builder: (_) => _SearchDropdownContent(
              value: selectedItem,
              items: widget.itemsBuilder(context),
              onChanged: _handleValueChanged,
              onCloseButtonPressed: () => _handleClose(),
              specialOptions: widget.specialOptionsBuilder
                  ?.call(context, (value) => _handleValueChanged(value)),
            ));
  }

  void _handleDesktopOpen(
      BuildContext context, SearchDropdownItem? selectedItem) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    const minimumHeight = 200.0;
    const minimumWidth = 300.0;

    _entry = OverlayEntry(builder: (overlayContext) {
      return Positioned(
          left: _ensureHorizontalFit(
            minimumWidth: minimumWidth,
            screenWidth: screenWidth,
            leftOffset: offset.dx,
          ),
          top: _ensureVerticalFit(
              minimumHeight: minimumHeight,
              screenHeight: screenHeight,
              topOffset: offset.dy),
          bottom: 16, // Padding
          child: _SearchDropdownContent(
            value: selectedItem,
            items: widget.itemsBuilder.call(context),
            onChanged: _handleValueChanged,
            onCloseButtonPressed: () => _handleClose(),
            specialOptions: widget.specialOptionsBuilder
                ?.call(context, (value) => _handleValueChanged(value)),
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

    Overlay.of(context).insert(_backdrop!);
    Overlay.of(context).insert(_entry!, above: _backdrop);
  }

  void _handleValueChanged(dynamic newValue) {
    _handleClose();
    widget.onChanged(newValue);
  }

  void _handleClose() {
    if (isMobileLayout(context)) {
      Navigator.of(context).pop();
    } else {
      _entry?.remove();
      _backdrop?.remove();

      _entry = null;
      _backdrop = null;
    }
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
  final void Function()? onCloseButtonPressed;
  final Widget? specialOptions;

  const _SearchDropdownContent({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.onCloseButtonPressed,
    this.specialOptions,
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
  late String _lastTextValue;

  late final _actions;

  @override
  void initState() {
    _actions = {
      DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (intent) => widget.onCloseButtonPressed?.call())
    };

    _controller = TextEditingController()..value = _getFullTextSelection();
    _lastTextValue = _controller.text;

    _controller.addListener(() {
      // Requesting Focus to the textField Triggers this callback. Which messes things up if it runs before any text
      // has actually changed (Causes a premature filtering of items). _initalizing is a check flag to ensure we ignore
      // the first time this listener is called.
      // Additionally moving the carror with the arrow keys will trigger this callback. Therefore we check to see if the actual
      // text value has meaningfully changed.
      if (_initalizing == false && _controller.text != _lastTextValue) {
        final filtered = _filterItems(_controller.text, widget.items);

        // Keep the highlighted Item if it still exists within the filtered results, otherwise null it.
        final highlightedItem =
            filtered.indexWhere((item) => item.value == widget.value?.value) !=
                    -1
                ? widget.value
                : null;

        setState(() {
          _options = filtered;
          _highlightedItem = highlightedItem;
        });
      }

      _initalizing = false;
      _lastTextValue = _controller.text;
    });

    _options = widget.items.toList();
    _highlightedItem = widget.value;

    _keyListenerFocusNode = FocusNode();

    _textFieldFocusNode = FocusNode()
      ..addListener(() {
        if (_textFieldFocusNode.hasPrimaryFocus) {
          _controller.value = _getFullTextSelection();
        }
      });

    super.initState();
  }

  TextEditingValue _getFullTextSelection() {
    return TextEditingValue(
        text: widget.value?.keyword ?? '',
        selection: TextSelection(
            baseOffset: 0, extentOffset: widget.value?.keyword.length ?? 0));
  }

  @override
  void didChangeDependencies() {
    // Don't autofocus the searchfield on Mobile. This is due to a bug when running on iOS, opening the keyboard more then 3 times seems to
    // case Safari to incorrectly report the Keyboard open property. Therefore when opening from the 4th attempt onwards, Flutter adds far to much
    // padding to the bottom of the list, as if it's accounting for two keyboards stacked ontop of eachother.
    // Also don't call isMobileLayout in initState(), it depends on context which isnt' instantiated in time.
    if (isMobileLayout(context) == false) {
      _textFieldFocusNode.requestFocus();
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: _actions,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _withKeyboardListener(
            child: _AdaptiveContentLayout(
          onDialogCloseButtonPressed: widget.onCloseButtonPressed,
          searchField: Column(
            children: [
              if (widget.specialOptions != null) widget.specialOptions!,
              TextField(
                controller: _controller,
                focusNode: _textFieldFocusNode,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                onSubmitted: kIsWeb
                    ? (value) => _handleEnterPress()
                    : null, // For some reason Enter keys on Web don't trigger the RawKeyboardListener.
                onEditingComplete:
                    isMobileLayout(context) ? () => _handleEnterPress() : null,
              ),
            ],
          ),
          listView: ListView.builder(
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final item = _options[index];
              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 36, maxHeight: 48),
                key: ValueKey(item.value),
                child: Container(
                  padding: isMobileLayout(context)
                      ? const EdgeInsets.only(left: 8)
                      : EdgeInsets.zero,
                  color: _highlightedItem?.value == item.value
                      ? Theme.of(context).highlightColor
                      : null,
                  child: ListTile(
                    title: item.child,
                    onTap: item.interactive
                        ? () => widget.onChanged(item.value)
                        : null,
                  ),
                ),
              );
            },
          ),
        )),
      ),
    );
  }

  Widget _withKeyboardListener({required Widget child}) {
    if (isMobileLayout(context)) {
      return child;
    } else {
      return RawKeyboardListener(
        focusNode: _keyListenerFocusNode,
        onKey: _handleDesktopKey,
        child: child,
      );
    }
  }

  void _handleDesktopKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onCloseButtonPressed?.call();
      }

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
      return;
    }

    // If an option is Highlighted and still appears within the List.
    if (_highlightedItem != null &&
        _options
            .where((item) => item.value == _highlightedItem!.value)
            .isNotEmpty) {
      widget.onChanged(_highlightedItem!.value);
    }

    if (_options.isEmpty) {
      // TextField will automatically give up focus on an Enter press, which will block further keyboard input.
      // Therefore if there arent any options available, we request focus so that we stay in focus.
      _textFieldFocusNode.requestFocus();
    }
  }

  List<SearchDropdownItem> _filterItems(
      String searchTerm, List<SearchDropdownItem> items) {
    return items
        .where((item) =>
            item.keyword.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _keyListenerFocusNode.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }
}

class _Closed extends StatelessWidget {
  final Widget? child;
  final bool enabled;

  const _Closed({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final concreteChild = child ?? const _Hint();

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
          Expanded(child: concreteChild),
          if (enabled) const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).hintColor,
            ));
  }
}

class SearchDropdownItem {
  final String keyword;
  final Widget child;
  final dynamic value;
  final bool interactive;

  SearchDropdownItem({
    required this.keyword,
    required this.child,
    required this.value,
    this.interactive = true,
  });
}

class _AdaptiveContentLayout extends StatelessWidget {
  final Widget listView;
  final Widget searchField;
  final void Function()? onDialogCloseButtonPressed;

  const _AdaptiveContentLayout({
    Key? key,
    required this.listView,
    required this.searchField,
    this.onDialogCloseButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobileLayout(context)) {
      return Container(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DialogTitle(
                  showCloseButton: isMobileLayout(context),
                  onCloseButtonPressed: onDialogCloseButtonPressed,
                ),
                Expanded(child: listView),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
                  child: searchField,
                ),
              ],
            )),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        width: 400,
        child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 16,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    top: 8,
                    right: 8,
                  ),
                  child: searchField,
                ),
                Expanded(child: listView)
              ],
            )),
      );
    }
  }
}

class _DialogTitle extends StatelessWidget {
  final bool showCloseButton;
  final void Function()? onCloseButtonPressed;
  const _DialogTitle({
    Key? key,
    required this.showCloseButton,
    this.onCloseButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title =
        Padding(padding: EdgeInsets.all(8), child: Text('Select Artist'));

    if (showCloseButton) {
      // Wrap [title] with a stack to position the 'Close' button next to it.
      return Stack(
        alignment: Alignment.center,
        children: [
          const Padding(padding: EdgeInsets.only(top: 12), child: title),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => onCloseButtonPressed?.call(),
            ),
          ),
        ],
      );
    }

    // Otherwise just return the title as is.
    return title;
  }
}
