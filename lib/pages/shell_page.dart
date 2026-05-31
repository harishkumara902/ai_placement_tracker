import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/auth_controller.dart';
import '../widgets/common.dart';
import 'coding_arena_page.dart';
import 'company_prep_page.dart';
import 'dashboard_page.dart';
import 'mock_interview_page.dart';
import 'predictor_page.dart';
import 'resume_analyzer_page.dart';
import 'roadmap_page.dart';

enum AppSection {
  dashboard,
  resume,
  roadmap,
  interview,
  coding,
  company,
  predictor,
  settings,
}

class _Destination {
  const _Destination(this.section, this.label, this.icon);
  final AppSection section;
  final String label;
  final IconData icon;
}

const destinations = [
  _Destination(AppSection.dashboard, 'Dashboard', Icons.home_outlined),
  _Destination(
    AppSection.resume,
    'Resume Analyzer',
    Icons.description_outlined,
  ),
  _Destination(AppSection.roadmap, 'Learning Roadmap', Icons.map_outlined),
  _Destination(
    AppSection.interview,
    'Mock Interview',
    Icons.smart_toy_outlined,
  ),
  _Destination(AppSection.coding, 'Coding Arena', Icons.code),
  _Destination(AppSection.company, 'Company Prep', Icons.business_outlined),
  _Destination(
    AppSection.predictor,
    'Placement Predictor',
    Icons.analytics_outlined,
  ),
  _Destination(
    AppSection.settings,
    'Profile / Settings',
    Icons.settings_outlined,
  ),
];

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  AppSection selected = AppSection.dashboard;
  bool collapsed = false;

  Widget content() => switch (selected) {
        AppSection.dashboard => DashboardPage(
            onNavigate: (value) => setState(() => selected = value),
          ),
        AppSection.resume => const ResumeAnalyzerPage(),
        AppSection.roadmap => const RoadmapPage(),
        AppSection.interview => const MockInterviewPage(),
        AppSection.coding => const CodingArenaPage(),
        AppSection.company => const CompanyPrepPage(),
        AppSection.predictor => const PredictorPage(),
        AppSection.settings => const SettingsPage(),
      };

  void choose(AppSection value) {
    setState(() => selected = value);
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 880;
    final destination = destinations.firstWhere(
      (item) => item.section == selected,
    );
    final sidebar = _Sidebar(
      selected: selected,
      collapsed: collapsed && !mobile,
      onChoose: choose,
      onCollapse: () => setState(() => collapsed = !collapsed),
    );
    return DotGridBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: mobile
            ? Drawer(backgroundColor: AppColors.background, child: sidebar)
            : null,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: mobile,
          title: Text(
            destination.label,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            IconButton(
              onPressed: () => showMessage(
                context,
                'No new notifications. Daily focus is ready.',
              ),
              icon: const Icon(Icons.notifications_none),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 22),
              child: CircleAvatar(
                backgroundColor: AppColors.indigo.withValues(alpha: .25),
                child: Text(
                  (AppScope.of(context).user?['full_name'] as String? ??
                      'U')[0],
                ),
              ),
            ),
          ],
        ),
        body: Row(
          children: [
            if (!mobile) sidebar,
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: SingleChildScrollView(
                  key: ValueKey(selected),
                  padding: EdgeInsets.fromLTRB(
                    mobile ? 18 : 30,
                    16,
                    mobile ? 18 : 30,
                    34,
                  ),
                  child: content(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selected,
    required this.collapsed,
    required this.onChoose,
    required this.onCollapse,
  });
  final AppSection selected;
  final bool collapsed;
  final ValueChanged<AppSection> onChoose;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: collapsed ? 82 : 268,
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background, Color(0xFF12123A)],
        ),
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 17 : 22,
                vertical: 24,
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.amber),
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'MENTOR.AI',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: destinations.map((item) {
                  final active = item.section == selected;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      selected: active,
                      selectedTileColor: AppColors.indigo.withValues(
                        alpha: .18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        item.icon,
                        color: active ? AppColors.indigo : AppColors.muted,
                      ),
                      title: collapsed
                          ? null
                          : Text(
                              item.label,
                              style: TextStyle(
                                color:
                                    active ? AppColors.pearl : AppColors.muted,
                              ),
                            ),
                      onTap: () => onChoose(item.section),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (!collapsed)
              Padding(
                padding: const EdgeInsets.all(15),
                child: OutlinedButton.icon(
                  onPressed: () => AppScope.of(context).logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ),
            IconButton(
              onPressed: onCollapse,
              icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          'Profile & Settings',
          subtitle:
              'Keep your mentor workspace aligned to your placement goal.',
        ),
        GlassCard(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.indigo.withValues(alpha: .2),
                      child: Text(
                        (user['full_name'] as String)[0],
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['full_name'],
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          user['email'],
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: TextEditingController(text: user['target_role']),
                  decoration: const InputDecoration(labelText: 'Target role'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(
                    text: user['target_company'],
                  ),
                  decoration: const InputDecoration(labelText: 'Dream company'),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () => showMessage(
                    context,
                    'Profile preferences saved for this session.',
                  ),
                  child: const Text('Save Settings'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
