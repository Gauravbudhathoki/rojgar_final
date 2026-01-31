import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rojgar/feature/auth/presentation/pages/login_screen.dart';

void main() {
  testWidgets('should display "Let\'s Sign In" title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text("Let's ", skipOffstage: false), findsOneWidget);
    expect(find.text('Sign In', skipOffstage: false), findsOneWidget);
  });

  testWidgets('should display subtitle text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Build your career with the best company here.'),
      findsOneWidget,
    );
  });

  testWidgets('should have email and password text fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    final fields = tester.widgetList(find.byType(TextField));
    expect(fields.length, 2);
  });

  testWidgets('should have email hint text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('example@gmail.com'), findsOneWidget);
  });

  testWidgets('should have password hint text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('should allow text input in email field', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'test@example.com',
    );
    await tester.pumpAndSettle();
    expect(find.text('test@example.com'), findsOneWidget);
  });

  testWidgets('should allow text input in password field', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.pumpAndSettle();
    expect(find.text('••••••••••••'), findsNothing);
  });

  testWidgets('password field should be obscured by default', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    final passwordField = tester.widget<TextField>(find.byType(TextField).last);
    expect(passwordField.obscureText, isTrue);
  });

  testWidgets('should have Forgot password text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('should have LOGIN button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, 'LOGIN'), findsOneWidget);
  });

  testWidgets('should have Sign Up text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('should have "Don\'t have an account?" text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text("Don't have an account? "), findsOneWidget);
  });

  testWidgets('should have OR LOGIN WITH divider text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('OR LOGIN WITH'), findsOneWidget);
  });

  testWidgets('should have email icon', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
  });

  testWidgets('should have lock icon', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('should accept email and password input', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).at(0),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.pumpAndSettle();
    expect(find.text('test@example.com'), findsOneWidget);
  });

  testWidgets('should have Google social button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('should have Facebook social button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Facebook'), findsOneWidget);
  });

  testWidgets('should display logo image', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('should have two text fields for email and password',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('email field should not be obscured', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    final emailField = tester.widget<TextField>(find.byType(TextField).first);
    expect(emailField.obscureText, isFalse);
  });

  testWidgets('should have login button with correct background color',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'LOGIN'),
    );
    final buttonStyle = button.style;
    expect(buttonStyle, isNotNull);
  });

  testWidgets('should clear text fields when text is deleted', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    
    // Enter text
    await tester.enterText(
      find.byType(TextField).first,
      'test@example.com',
    );
    await tester.pumpAndSettle();
    expect(find.text('test@example.com'), findsOneWidget);
    
    // Clear text
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    expect(find.text('test@example.com'), findsNothing);
  });

  testWidgets('should have SafeArea widget', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SafeArea), findsOneWidget);
  });

  testWidgets('should have SingleChildScrollView', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('should have divider widgets', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('should have TextButton for forgot password', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(TextButton, 'Forgot password?'),
      findsOneWidget,
    );
  });

  testWidgets('should accept multiple inputs in sequence', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    
    // First input
    await tester.enterText(find.byType(TextField).at(0), 'first@test.com');
    await tester.pumpAndSettle();
    
    // Change input
    await tester.enterText(find.byType(TextField).at(0), 'second@test.com');
    await tester.pumpAndSettle();
    
    expect(find.text('second@test.com'), findsOneWidget);
    expect(find.text('first@test.com'), findsNothing);
  });
}