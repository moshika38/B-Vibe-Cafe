import 'package:flutter/material.dart';

class ScreenProvider extends ChangeNotifier {
  bool isOrder = false;

  void updateScreenStatus(bool status) {
    isOrder = status;
    notifyListeners();
  }
}
