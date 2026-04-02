import 'package:flutter/material.dart';
import 'package:rummel_blue_theme/rummel_blue_theme.dart';

import 'src/services/focus_training_service.dart';
import 'src/ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FocusTrainingService();
  runApp(FocusTrainingApp(service: service));
}
