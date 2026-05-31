import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/auth_controller.dart';
import '../widgets/common.dart';

class PredictorPage extends StatefulWidget {
  const PredictorPage({super.key});

  @override
  State<PredictorPage> createState() => _PredictorPageState();
}

class _PredictorPageState extends State<PredictorPage> {
  double cgpa = 7.4;
  double projects = 3;
  double internships = 1;
  bool backlogs = false;
  String domain = 'Software Dev';
  final allSkills = [
    'Python',
    'SQL',
    'Java',
    'DSA',
    'Communication',
    'React',
    'Cloud',
  ];
  final selectedSkills = <String>{'Python', 'SQL', 'DSA'};
  final selectedCerts = <String>{};
  bool loading = false;
  Map<String, dynamic>? result;

  Future<void> predict() async {
    setState(() => loading = true);
    try {
      final response = await AppScope.of(context).api.dio.post(
        '/predict/placement',
        data: {
          'cgpa': cgpa,
          'projects': projects.round(),
          'internships': internships.round(),
          'skills': selectedSkills.toList(),
          'certifications': selectedCerts.toList(),
          'backlogs': backlogs,
          'domain': domain,
        },
      );
      setState(() => result = Map<String, dynamic>.from(response.data));
      if (mounted) {
        showMessage(context, 'Prediction generated from your profile signals.');
      }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          'Placement Predictor',
          subtitle:
              'Use the trained ML model to identify readiness gaps and highest-impact next steps.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 1000;
            final form = _form(context);
            final output = result == null ? _EmptyResult() : _Result(result!);
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: form),
                      const SizedBox(width: 20),
                      Expanded(child: output),
                    ],
                  )
                : Column(children: [form, const SizedBox(height: 20), output]);
          },
        ),
      ],
    );
  }

  Widget _form(BuildContext context) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Candidate Signals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _SliderRow(
              label: 'CGPA',
              value: cgpa,
              valueText: cgpa.toStringAsFixed(1),
              max: 10,
              divisions: 100,
              onChanged: (value) => setState(() => cgpa = value),
            ),
            _SliderRow(
              label: 'Projects',
              value: projects,
              valueText: projects.round().toString(),
              max: 10,
              divisions: 10,
              onChanged: (value) => setState(() => projects = value),
            ),
            _SliderRow(
              label: 'Internships',
              value: internships,
              valueText: internships.round().toString(),
              max: 3,
              divisions: 3,
              onChanged: (value) => setState(() => internships = value),
            ),
            const SizedBox(height: 12),
            const Text('Skills', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allSkills
                  .map(
                    (skill) => SkillBadge(
                      skill,
                      selected: selectedSkills.contains(skill),
                      onTap: () => setState(
                        () => selectedSkills.contains(skill)
                            ? selectedSkills.remove(skill)
                            : selectedSkills.add(skill),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const Text('Certifications',
                style: TextStyle(color: AppColors.muted)),
            ...['Cloud Fundamentals', 'SQL Advanced', 'Agile / Scrum'].map(
              (cert) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(cert),
                value: selectedCerts.contains(cert),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) => setState(
                  () => value == true
                      ? selectedCerts.add(cert)
                      : selectedCerts.remove(cert),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: domain,
                    decoration:
                        const InputDecoration(labelText: 'Target domain'),
                    items: [
                      'Software Dev',
                      'Data Analyst',
                      'DevOps',
                      'Digital Marketing',
                    ]
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => domain = value!),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Backlogs'),
                    value: backlogs,
                    onChanged: (value) => setState(() => backlogs = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: LoadingButton(
                label: 'Predict Placement',
                loading: loading,
                onPressed: predict,
                icon: Icons.query_stats,
              ),
            ),
          ],
        ),
      );
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.valueText,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });
  final String label;
  final double value;
  final String valueText;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            SizedBox(width: 90, child: Text(label)),
            Expanded(
              child: Slider(
                value: value,
                min: 0,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 42,
              child: Text(
                valueText,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
}

class _EmptyResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GlassCard(
        child: SizedBox(
          height: 410,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.query_stats,
                    color: AppColors.indigo, size: 52),
                const SizedBox(height: 14),
                Text(
                  'Awaiting profile data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Submit the form to calculate your probability.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      );
}

class _Result extends StatelessWidget {
  const _Result(this.result);
  final Map<String, dynamic> result;
  @override
  Widget build(BuildContext context) {
    final probability = (result['probability'] as num).toDouble();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prediction Result',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: probability),
              duration: const Duration(milliseconds: 900),
              builder: (context, value, _) => Column(
                children: [
                  Gauge(value),
                  const SizedBox(height: 6),
                  const Text(
                    'Placement Probability',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'WEAK AREAS',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          ...(result['weak_areas'] as List).map(
            (area) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: AppColors.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(area)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'TOP RECOMMENDED ACTIONS',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          ...(result['actions'] as List).map(
            (action) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SkillBadge(
                action['priority'],
                color: action['priority'] == 'High'
                    ? AppColors.danger
                    : AppColors.amber,
              ),
              title: Text(
                action['action'],
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
