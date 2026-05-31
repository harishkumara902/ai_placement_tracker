import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/auth_controller.dart';
import '../widgets/common.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.onRegister, required this.onBack, super.key});
  final VoidCallback onRegister;
  final VoidCallback onBack;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> submit() async {
    final error = await AppScope.of(
      context,
    ).login(email.text.trim(), password.text);
    if (mounted && error != null) showMessage(context, error, error: true);
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(
        title: 'Welcome back',
        subtitle: 'Sign in to continue your placement strategy.',
        fields: [
          TextField(
            controller: email,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
        ],
        submitLabel: 'Login to Dashboard',
        busy: AppScope.of(context).busy,
        onSubmit: submit,
        alternate: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('New here?', style: TextStyle(color: AppColors.muted)),
            TextButton(
              onPressed: widget.onRegister,
              child: const Text('Create an account'),
            ),
          ],
        ),
        onBack: widget.onBack,
      );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({required this.onLogin, required this.onBack, super.key});
  final VoidCallback onLogin;
  final VoidCallback onBack;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> submit() async {
    final error = await AppScope.of(
      context,
    ).register(name.text.trim(), email.text.trim(), password.text);
    if (mounted && error != null) showMessage(context, error, error: true);
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(
        title: 'Create your profile',
        subtitle: 'Turn preparation into measurable placement readiness.',
        fields: [
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          TextField(
            controller: email,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password (8+ characters)',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
        ],
        submitLabel: 'Create Account',
        busy: AppScope.of(context).busy,
        onSubmit: submit,
        alternate: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already registered?',
              style: TextStyle(color: AppColors.muted),
            ),
            TextButton(onPressed: widget.onLogin, child: const Text('Sign in')),
          ],
        ),
        onBack: widget.onBack,
      );
}

class _AuthFrame extends StatelessWidget {
  const _AuthFrame({
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.submitLabel,
    required this.busy,
    required this.onSubmit,
    required this.alternate,
    required this.onBack,
  });
  final String title;
  final String subtitle;
  final List<Widget> fields;
  final String submitLabel;
  final bool busy;
  final VoidCallback onSubmit;
  final Widget alternate;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return DotGridBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: GlassCard(
              padding: const EdgeInsets.all(34),
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 27),
                    ...fields.expand(
                      (field) => [field, const SizedBox(height: 15)],
                    ),
                    LoadingButton(
                      label: submitLabel,
                      loading: busy,
                      onPressed: onSubmit,
                      icon: Icons.arrow_forward,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => showMessage(
                        context,
                        'Google OAuth is available when configured by your administrator.',
                      ),
                      icon: const Icon(Icons.g_mobiledata, size: 30),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 14),
                    alternate,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
