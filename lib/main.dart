import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/auth_controller.dart';
import 'pages/auth_pages.dart';
import 'pages/landing_page.dart';
import 'pages/shell_page.dart';
import 'widgets/common.dart';

void main() {
  ErrorWidget.builder = (details) => Material(
        color: AppColors.background,
        child: Center(
          child: Text(
            'This panel could not load.\n${details.exceptionAsString()}',
            textAlign: TextAlign.center,
          ),
        ),
      );
  runApp(const PlacementMentorApp());
}

class PlacementMentorApp extends StatefulWidget {
  const PlacementMentorApp({super.key});

  @override
  State<PlacementMentorApp> createState() => _PlacementMentorAppState();
}

class _PlacementMentorAppState extends State<PlacementMentorApp> {
  final AuthController auth = AuthController();
  AuthView view = AuthView.landing;

  @override
  void initState() {
    super.initState();
    auth.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: auth,
      child: MaterialApp(
        title: 'Placement Mentor AI',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: AnimatedBuilder(
          animation: auth,
          builder: (context, _) {
            if (auth.initializing) {
              return const DotGridBackground(
                child: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (auth.authenticated) return const ShellPage();
            return switch (view) {
              AuthView.landing => LandingPage(
                  onLogin: () => setState(() => view = AuthView.login),
                  onRegister: () => setState(() => view = AuthView.register),
                ),
              AuthView.login => LoginPage(
                  onRegister: () => setState(() => view = AuthView.register),
                  onBack: () => setState(() => view = AuthView.landing),
                ),
              AuthView.register => RegisterPage(
                  onLogin: () => setState(() => view = AuthView.login),
                  onBack: () => setState(() => view = AuthView.landing),
                ),
            };
          },
        ),
      ),
    );
  }
}

enum AuthView { landing, login, register }
