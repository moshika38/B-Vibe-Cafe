import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AppSnack {
  static final player = AudioPlayer();
  static void successSnack(BuildContext context, message) {
     
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(message: message),
    );
  }

  static void errorSnack(BuildContext context, message) {
    try {
      player.play(AssetSource('sound/error.mp3'));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(message: message),
    );
  }
}
