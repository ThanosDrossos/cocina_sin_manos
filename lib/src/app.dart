// src/app.dart

import 'package:flutter/material.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'views/home_view.dart';

class MyApp extends StatelessWidget {
  final SettingsController settingsController;

  const MyApp({Key? key, required this.settingsController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, child) {
        return MaterialApp(
          title: 'Recipe App',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          home: HomeView(),
          routes: {
            SettingsView.routeName: (context) => SettingsView(controller: settingsController),
          },
        );
      },
    );
  }
}
