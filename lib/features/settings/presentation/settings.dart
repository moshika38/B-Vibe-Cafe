import 'package:bvibe/features/settings/pages/business.page.dart';

import 'package:bvibe/features/settings/pages/shortcut.keys.dart';
import 'package:bvibe/features/settings/pages/printer.page.dart';
import 'package:bvibe/features/settings/pages/security.page.dart';
import 'package:bvibe/features/settings/pages/supports.page.dart';
import 'package:bvibe/features/settings/widgets/header.dart';
import 'package:bvibe/features/settings/widgets/settings.items.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int selectedItem = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedItem = index;
    });
  }

  List<Widget> pages = [
    ShortcutKeys(),
    PrinterPage(),
    BusinessPage(),
    SupportsPage(),
    SecurityPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Header(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SettingsItems(
                      onTap0: () => onItemTapped(0),
                      onTap1: () => onItemTapped(1),
                      onTap2: () => onItemTapped(2),
                      onTap3: () => onItemTapped(3),
                      onTap4: () => onItemTapped(4),
                      selectedItem: selectedItem,
                    ),
                  ),
                ),
                VerticalDivider(),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(child: pages[selectedItem]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
