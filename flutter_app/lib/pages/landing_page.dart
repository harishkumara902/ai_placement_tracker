import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/common.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({
    required this.onLogin,
    required this.onRegister,
    super.key,
  });
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return DotGridBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 42,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.amber),
                    const SizedBox(width: 10),
                    Text(
                      'PLACEMENT.MENTOR',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                        color: AppColors.pearl.withValues(alpha: .9),
                      ),
                    ),
                    const Spacer(),
                    TextButton(onPressed: onLogin, child: const Text('Login')),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: onRegister,
                      child: const Text('Get started'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(26),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Wrap(
                        spacing: 70,
                        runSpacing: 40,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 550,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SkillBadge(
                                  'AI-GUIDED CAREER INTELLIGENCE',
                                  color: AppColors.amber,
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  'Your AI-Powered\nPlacement Coach',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayLarge,
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Analyze your resume, build a preparation roadmap, rehearse real interviews, and predict placement readiness from one focused workspace.',
                                  style: TextStyle(
                                    height: 1.65,
                                    fontSize: 17,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 35),
                                Wrap(
                                  spacing: 14,
                                  runSpacing: 12,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: onRegister,
                                      icon: const Icon(Icons.arrow_forward),
                                      label: const Text('Begin your journey'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: onLogin,
                                      icon: const Icon(Icons.login),
                                      label: const Text('Sign in'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GlassCard(
                            child: SizedBox(
                              width: 330,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PLACEMENT HEALTH',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: AppColors.amber,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  const Center(
                                    child: AnimatedScoreRing(score: 82),
                                  ),
                                  const SizedBox(height: 25),
                                  ...[
                                    'Resume intelligence',
                                    'Company-specific mocks',
                                    'Predictive readiness scoring',
                                  ].map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 9,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: AppColors.success,
                                            size: 17,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(item),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
