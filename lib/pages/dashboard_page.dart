import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/auth_controller.dart';
import '../widgets/common.dart';
import 'shell_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.onNavigate, super.key});
  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final firstName =
        (AppScope.of(context).user?['full_name'] as String? ?? 'Candidate')
            .split(' ')
            .first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 30,
            runSpacing: 22,
            children: [
              SizedBox(
                width: 540,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkillBadge(
                      'TODAY / PLACEMENT COMMAND CENTER',
                      color: AppColors.amber,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Hello $firstName, here's your placement health",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your interview readiness is improving. Finish today\'s focused tasks to lift your predicted probability.',
                      style: TextStyle(color: AppColors.muted, height: 1.5),
                    ),
                  ],
                ),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScoreRing(score: 76, size: 126),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLACEMENT SCORE',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '+8 this week',
                        style: TextStyle(color: AppColors.success),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 850
                ? (constraints.maxWidth - 48) / 4
                : (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _Stat(
                  'Resume Score',
                  '81%',
                  '+6%',
                  Icons.description_outlined,
                  width,
                ),
                _Stat(
                  'Skills Matched',
                  '14 / 18',
                  '+2',
                  Icons.auto_awesome,
                  width,
                ),
                _Stat(
                  'Interview Readiness',
                  '72%',
                  '+9%',
                  Icons.mic_none,
                  width,
                ),
                _Stat(
                  'Days to Placement',
                  '43',
                  'On track',
                  Icons.calendar_today_outlined,
                  width,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 25),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: constraints.maxWidth > 900
                      ? constraints.maxWidth * .54
                      : constraints.maxWidth,
                  child: const _TodaysFocus(),
                ),
                SizedBox(
                  width: constraints.maxWidth > 900
                      ? constraints.maxWidth * .42
                      : constraints.maxWidth,
                  child: const _Activity(),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 26),
        const SectionHeading('Quick Actions'),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _Action(
              'Analyze Resume',
              Icons.document_scanner_outlined,
              AppSection.resume,
              onNavigate,
            ),
            _Action(
              'Generate Roadmap',
              Icons.route_outlined,
              AppSection.roadmap,
              onNavigate,
            ),
            _Action(
              'Start Mock',
              Icons.record_voice_over_outlined,
              AppSection.interview,
              onNavigate,
            ),
            _Action(
              'Solve a Problem',
              Icons.code,
              AppSection.coding,
              onNavigate,
            ),
            _Action(
              'Predict Placement',
              Icons.query_stats,
              AppSection.predictor,
              onNavigate,
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.change, this.icon, this.width);
  final String label;
  final String value;
  final String change;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.amber),
              const SizedBox(height: 17),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  Text(
                    change,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _TodaysFocus extends StatelessWidget {
  const _TodaysFocus();
  @override
  Widget build(BuildContext context) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Focus",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 18),
            ...[
              ('Solve 3 dynamic programming problems', 'Coding Arena', true),
              ('Record your answer: Why Zoho?', 'Mock Interview', false),
              ('Add metrics to your backend project', 'Resume', false),
            ].map(
              (task) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Icon(
                      task.$3
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.$3 ? AppColors.success : AppColors.amber,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(task.$1)),
                    SkillBadge(task.$2, color: AppColors.amber),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _Activity extends StatelessWidget {
  const _Activity();
  @override
  Widget build(BuildContext context) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activity',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...[
              (
                'ATS analysis completed',
                'Resume score 81%',
                Icons.description_outlined,
              ),
              ('HR mock evaluated', 'Score 7.5 / 10', Icons.mic_none),
              ('Roadmap updated', 'Week 2 complete', Icons.map_outlined),
            ].map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(item.$3, color: AppColors.indigo),
                title: Text(item.$1),
                subtitle: Text(
                  item.$2,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
            ),
          ],
        ),
      );
}

class _Action extends StatelessWidget {
  const _Action(this.label, this.icon, this.section, this.onSelect);
  final String label;
  final IconData icon;
  final AppSection section;
  final ValueChanged<AppSection> onSelect;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () => onSelect(section),
        icon: Icon(icon),
        label: Text(label),
      );
}
