import 'package:flutter/material.dart';

typedef OnTapCallback = void Function();

class ContextMenuItemBase {}

class ContextMenuItem extends ContextMenuItemBase {
  final String label;
  final String? shortcut;
  final IconData? icon;
  final OnTapCallback? onTap;
  final bool enabled;
  final String disabledTooltip;

  ContextMenuItem({
    required this.label,
    this.shortcut,
    this.icon,
    this.onTap,
    this.enabled = true,
    this.disabledTooltip = '',
  });
}

class ContextMenuItemDivider extends ContextMenuItemBase {}
