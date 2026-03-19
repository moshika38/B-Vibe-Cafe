import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppWorkspaceSettings {
  static String workspaceId = "app";

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


/*
==========================================================================

Shortcuts(
  shortcuts: {
    AppWorkspaceSettings.shortcuts.placeOrder:    PlaceOrderIntent(),
    AppWorkspaceSettings.shortcuts.addItem:       AddItemIntent(),
    AppWorkspaceSettings.shortcuts.selectQtyMenu: SelectQtyMenuIntent(),
    AppWorkspaceSettings.shortcuts.openPayment:   OpenPaymentIntent(),
  },
  child: Actions(
    actions: {
      PlaceOrderIntent:    CallbackAction<PlaceOrderIntent>(
                            onInvoke: (_) => placeOrder()),
      AddItemIntent:       CallbackAction<AddItemIntent>(
                            onInvoke: (_) => addItem()),
      SelectQtyMenuIntent: CallbackAction<SelectQtyMenuIntent>(
                            onInvoke: (_) => openQtyMenu()),
      OpenPaymentIntent:   CallbackAction<OpenPaymentIntent>(
                            onInvoke: (_) => openPayment()),
    },
    child: YourPOSWidget(),
  ),
)
==========================================================================
*/