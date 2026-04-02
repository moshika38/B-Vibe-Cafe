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
    player.play(AssetSource('sound/error.mp3'));
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(message: message),
    );
  }
}
