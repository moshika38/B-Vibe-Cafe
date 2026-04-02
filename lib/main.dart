import 'package:bvibe/provider/analytics.provider.dart';
import 'package:bvibe/provider/printer.provider.dart';
import 'package:bvibe/provider/bill.history.provider.dart';
import 'package:bvibe/provider/business.info.dart';
 import 'package:bvibe/provider/screen.provider.dart';
import 'package:bvibe/routes/app.routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bvibe/provider/categories.helper.dart';
import 'package:bvibe/provider/item.provider.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:bvibe/data/helper/database.helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseHelper.instance.initializeAppDatabase();

  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow(null, () async {
    await windowManager.show();
    await windowManager.maximize();
    await windowManager.setMaximizable(false);
    await windowManager.setResizable(false);
    await windowManager.focus();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: CategoriesProvider.instance),
        ChangeNotifierProvider.value(value: ItemProvider.instance),
        ChangeNotifierProvider(create: (_) => ReceiptProvider()),
        ChangeNotifierProvider(create: (_) => ScreenProvider()),
        ChangeNotifierProvider(create: (_) => BusinessInfoProvider()),
        ChangeNotifierProvider(create: (_) => BillHistoryProvider()),
        ChangeNotifierProvider(create: (_) => PrinterProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRoutes.router,
      title: 'B-VIBE CAFE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
    );
  }
}
