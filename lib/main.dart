import 'package:bvibe/routes/app.routes.dart';
import 'package:flutter/material.dart';
import 'package:bvibe/const/theme.dart';
 
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRoutes().router,
      title: 'B-VIBE CAFE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
    );
  }
}
