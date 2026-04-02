import 'package:flutter/material.dart';
import 'package:rummel_blue_theme/rummel_blue_theme.dart';

import '../services/focus_training_service.dart';
import 'screens/home_screen.dart';

class FocusTrainingApp extends StatelessWidget {
  final FocusTrainingService service;

  const FocusTrainingApp({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Training',
      theme: RummelBlueTheme.light(),
      darkTheme: RummelBlueTheme.dark(),
      home: HomeScreen(service: service),
      debugShowCheckedModeBanner: false,
    );
  }
}
