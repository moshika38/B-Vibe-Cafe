import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserWorkspaceSettings {
  static String workspaceId = "user";

  // Shortcut Keys
  static final ShortcutKeys shortcuts = ShortcutKeys();
}

class ShortcutKeys {
  final LogicalKeySet placeOrder    = LogicalKeySet(LogicalKeyboardKey.numpadEnter);
  final LogicalKeySet addItem       = LogicalKeySet(LogicalKeyboardKey.enter);
  final LogicalKeySet selectQtyMenu = LogicalKeySet(
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.enter,
  );
  final LogicalKeySet searchProduct = LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyF,
  );
  final LogicalKeySet openPayment   = LogicalKeySet(LogicalKeyboardKey.f2);
  final LogicalKeySet cancelItem    = LogicalKeySet(LogicalKeyboardKey.delete);
  final LogicalKeySet holdOrder     = LogicalKeySet(LogicalKeyboardKey.f4);
  final LogicalKeySet printReceipt  = LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyP,
  );
}
 