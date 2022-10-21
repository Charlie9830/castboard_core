import 'package:castboard_core/widgets/hover_action_list_tile/HoverRegion.dart';
import 'package:flutter/material.dart';

class HoverActionListTile extends StatefulWidget {
  final Widget? leading;
  final bool? selected;
  final Widget? title;
  final Widget? subtitle;
  final void Function()? onTap;
  final List<Widget>? actions;

  const HoverActionListTile(
      {Key? key,
      this.selected,
      this.leading,
      this.title,
      this.subtitle,
      this.onTap,
      this.actions})
      : super(key: key);

  @override
  _HoverActionListTileState createState() => _HoverActionListTileState();
}

class _HoverActionListTileState extends State<HoverActionListTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return HoverRegion(
      onHoverChanged: (hovering) => setState(() => _hovering = hovering),
      child: ListTile(
        minLeadingWidth: 16,
        selected: widget.selected ?? false,
        onTap: widget.onTap,
        dense: true,
        leading: widget.leading,
        title: widget.title != null
            ? DefaultTextStyle.merge(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: widget.title!)
            : null,
        subtitle: widget.subtitle != null
            ? DefaultTextStyle.merge(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: widget.subtitle!)
            : null,
        trailing: _hovering
            ? _ActionPanel(
                actions: widget.actions ?? const [],
              )
            : null,
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final List<Widget> actions;
  const _ActionPanel({Key? key, this.actions = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: actions,
    );
  }
}
