import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hawklap/core/auth/auth_service.dart';
import 'package:hawklap/views/login/login_view.dart';

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
          builder: (_) => LoginView(authService: authService),
        ),
      ),
    );
  }

  group('LoginView', () {
    testWidgets('renders email, password fields and login button',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Login'), findsWidgets);
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('successful login pops the navigator', (tester) async {
      var didPop = false;

      when(() => mockAuth.signInWithPassword(
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
                    builder: (_) => LoginView(authService: authService),
                  ),
                );
                didPop = result == true;
              },
              child: const Text('Go'),
            ),
          ),
        ),
      );

      // Navigate to LoginView
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Fill in fields
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'password123');

      // Tap login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(didPop, isTrue);
    });

    testWidgets('failed login shows error snackbar', (tester) async {
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException(
        'Invalid login credentials',
        statusCode: '400',
      ));

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'bad@example.com');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'wrongpass');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Sign Up link is present', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('Sign Up'),
        ),
        findsOneWidget,
      );
    });
  });
}
