import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/utils/app_initializer.dart';
import 'core/data/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  final hiveService = HiveService(); // Create instance
  await hiveService.init(); // Initialize Hive

  // Load user preferences synchronously before starting the app
  await AppInitializer.initialize();

  runApp(ProviderScope(child: MyApp()));
}
