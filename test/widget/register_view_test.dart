import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hawklap/core/auth/auth_service.dart';
import 'package:hawklap/views/register/register_view.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late AuthService authService;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    authService = AuthService(client: mockClient);
  });

  Widget buildWidget() {
    return MaterialApp(
      home: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => RegisterView(authService: authService),
        ),
      ),
    );
  }

  group('RegisterView', () {
    testWidgets('renders email, password, confirm password fields and button',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(
          find.widgetWithText(TextField, 'Confirm Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('shows snackbar when passwords do not match', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm Password'), 'different');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
      verifyNever(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    testWidgets('successful register shows success snackbar and pops',
        (tester) async {
      var didPop = false;

      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => AuthResponse(session: null, user: null));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterView(authService: authService),
                  ),
                );
                didPop = result == true;
              },
              child: const Text('Go'),
            ),
          ),
        ),
      );

      // Navigate to RegisterView
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Fill in fields
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'new@example.com');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      // Tap sign up
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pumpAndSettle();

      expect(didPop, isTrue);
    });

    testWidgets('failed register shows error snackbar', (tester) async {
      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException(
        'User already registered',
        statusCode: '400',
      ));

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'existing@example.com');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Login link is present', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              w.text.toPlainText().contains('Already have an account?') &&
              w.text.toPlainText().contains('Login'),
        ),
        findsOneWidget,
      );
    });
  });
}
