import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_training/src/services/focus_training_service.dart';
import 'package:focus_training/src/ui/app.dart';

void main() {
  late FocusTrainingService service;

  setUp(() {
    service = FocusTrainingService();
  });

  group('FocusTrainingApp smoke tests', () {
    testWidgets('renders MaterialApp with Scaffold', (tester) async {
      await tester.pumpWidget(FocusTrainingApp(service: service));

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays Focus Training title', (tester) async {
      await tester.pumpWidget(FocusTrainingApp(service: service));

      expect(find.text('Focus Training'), findsOneWidget);
    });

    testWidgets('theme uses Material 3', (tester) async {
      await tester.pumpWidget(FocusTrainingApp(service: service));

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
      expect(app.darkTheme?.useMaterial3, isTrue);
    });

    testWidgets('shows Start Session FAB', (tester) async {
      await tester.pumpWidget(FocusTrainingApp(service: service));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Start Session'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });
  });
}
