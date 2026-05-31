import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../pages/auth_pages.dart';
import '../pages/landing_page.dart';
import '../pages/shell_page.dart';

GoRouter buildRouter(
    {required bool authenticated,
    required VoidCallback onLogin,
    required VoidCallback onRegister}) {
  return GoRouter(
    initialLocation: authenticated ? '/dashboard' : '/',
    routes: [
      GoRoute(
          path: '/',
          builder: (context, state) =>
              LandingPage(onLogin: onLogin, onRegister: onRegister)),
      GoRoute(
          path: '/login',
          builder: (context, state) =>
              LoginPage(onRegister: onRegister, onBack: () => context.go('/'))),
      GoRoute(
          path: '/register',
          builder: (context, state) =>
              RegisterPage(onLogin: onLogin, onBack: () => context.go('/'))),
      GoRoute(
          path: '/dashboard', builder: (context, state) => const ShellPage()),
    ],
  );
}
