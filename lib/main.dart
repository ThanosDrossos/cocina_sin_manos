// main.dart

import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Ensure Flutter binding is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Set up the SettingsController.
  final settingsController = SettingsController(SettingsService());

  // Load user settings before the app starts.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController.
  runApp(MyApp(settingsController: settingsController));
}
