import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../core/app_theme.dart';
import '../core/auth_controller.dart';
import '../widgets/common.dart';

class RoadmapPage extends StatefulWidget {
  const RoadmapPage({super.key});

  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> {
  final company = TextEditingController(text: 'Accenture');
  final role = TextEditingController(text: 'Software Developer');
  double weeks = 8;
  bool loading = false;
  String? roadmapKey;
  List<Map<String, dynamic>> roadmap = [];

  Future<void> generate() async {
    setState(() => loading = true);
    try {
      final response = await AppScope.of(context).api.dio.post(
        '/roadmap/generate',
        data: {
          'company': company.text,
          'role': role.text,
          'weeks': weeks.round(),
        },
      );
      setState(() {
        roadmapKey = response.data['roadmap_key'];
        roadmap = (response.data['weeks'] as List)
            .map((week) => Map<String, dynamic>.from(week))
            .toList();
      });
      if (mounted) showMessage(context, 'Your learning roadmap is ready.');
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

  Future<void> toggle(int index, bool value) async {
    setState(() => roadmap[index]['complete'] = value);
    try {
      await AppScope.of(context).api.dio.post(
        '/roadmap/progress',
        data: {
          'roadmap_key': roadmapKey,
          'week_number': roadmap[index]['number'],
          'complete': value,
        },
      );
    } catch (error) {
      setState(() => roadmap[index]['complete'] = !value);
      if (mounted) {
        showMessage(context, 'Progress could not be saved.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          'Learning Roadmap',
          subtitle: 'Build a focused timeline and persist weekly progress.',
        ),
        GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: company,
                      decoration: const InputDecoration(
                        labelText: 'Target Company',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: role,
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text(
                    'Available weeks',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  Expanded(
                    child: Slider(
                      value: weeks,
                      min: 2,
                      max: 24,
                      divisions: 22,
                      label: weeks.round().toString(),
                      onChanged: (value) => setState(() => weeks = value),
                    ),
                  ),
                  SkillBadge('${weeks.round()} weeks', color: AppColors.amber),
                  const SizedBox(width: 18),
                  LoadingButton(
                    label: 'Generate',
                    loading: loading,
                    onPressed: generate,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (roadmap.isNotEmpty) ...[
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preparation Timeline',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              OutlinedButton.icon(
                onPressed: () => web.window.print(),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Export PDF'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...roadmap.asMap().entries.map((entry) {
            final week = entry.value;
            final done = week['complete'] == true;
            final inProgress = !done &&
                entry.key ==
                    roadmap.indexWhere((item) => item['complete'] != true);
            final color = done
                ? AppColors.success
                : (inProgress ? AppColors.amber : AppColors.muted);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: done,
                      onChanged: (value) => toggle(entry.key, value ?? false),
                      activeColor: AppColors.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Week ${week['number']}: ${week['title']}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 12),
                              SkillBadge(
                                done
                                    ? 'COMPLETED'
                                    : (inProgress ? 'IN PROGRESS' : 'UPCOMING'),
                                color: color,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List<String>.from(week['topics'])
                                .map(
                                  (topic) => SkillBadge(
                                    topic,
                                    color: AppColors.indigo,
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${week['daily_tasks']} daily tasks  |  Resources: ${(week['resources'] as List).join(' / ')}',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
