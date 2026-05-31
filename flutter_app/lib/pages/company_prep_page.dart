import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/auth_controller.dart';
import '../widgets/common.dart';

class CompanyPrepPage extends StatefulWidget {
  const CompanyPrepPage({super.key});

  @override
  State<CompanyPrepPage> createState() => _CompanyPrepPageState();
}

class _CompanyPrepPageState extends State<CompanyPrepPage> {
  List<Map<String, dynamic>> companies = [];
  Map<String, dynamic>? detail;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final response = await AppScope.of(context).api.dio.get('/company');
      setState(
        () => companies = (response.data as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
      );
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          AppScope.of(context).api.errorMessage(error),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> openCompany(String name) async {
    setState(() => loading = true);
    try {
      final response = await AppScope.of(context).api.dio.get('/company/$name');
      setState(() => detail = Map<String, dynamic>.from(response.data));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (detail != null) {
      return _Detail(detail!, onBack: () => setState(() => detail = null));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          'Company Prep',
          subtitle:
              'Study hiring patterns and retrieve previous interview experiences.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 950
                ? (constraints.maxWidth - 54) / 4
                : (constraints.maxWidth - 18) / 2;
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: companies
                  .map(
                    (company) => SizedBox(
                      width: width,
                      child: GlassCard(
                        onTap: () => openCompany(company['name']),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.indigo.withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                company['name'].substring(0, 1),
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.amber,
                                ),
                              ),
                            ),
                            const SizedBox(height: 17),
                            Text(
                              company['name'],
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              company['salary_range'],
                              style: const TextStyle(color: AppColors.success),
                            ),
                            const SizedBox(height: 13),
                            Text(
                              (company['rounds'] as List).join('  >  '),
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.company, {required this.onBack});
  final Map<String, dynamic> company;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('All companies'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                company['name'],
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 16),
              SkillBadge(company['salary_range'], color: AppColors.success),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              SizedBox(
                width: 460,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hiring Process',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      ...(company['hiring_process'] as List).map(
                        (round) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.radio_button_checked,
                            color: AppColors.amber,
                          ),
                          title: Text(round['round']),
                          subtitle: Text(
                            round['focus'],
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ),
                      ),
                      const Divider(),
                      Text(
                          'Roles: ${(company['role_types'] as List).join(', ')}'),
                      const SizedBox(height: 8),
                      Text(
                        'Bond: ${company['bond_details']}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 530,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Previous Interview Questions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Retrieved from company knowledge base',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 14),
                      ...(company['previous_questions'] as List).map(
                        (question) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: AppColors.indigo,
                                size: 17,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(question)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => showMessage(
                          context,
                          'Select Mock Interview from navigation for a company-specific session.',
                        ),
                        icon: const Icon(Icons.mic),
                        label: const Text('Start Company-Specific Mock'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}
