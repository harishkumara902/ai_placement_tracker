import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/auth_controller.dart';
import '../widgets/common.dart';

class CodingArenaPage extends StatefulWidget {
  const CodingArenaPage({super.key});

  @override
  State<CodingArenaPage> createState() => _CodingArenaPageState();
}

class _CodingArenaPageState extends State<CodingArenaPage> {
  List<Map<String, dynamic>> problems = [];
  Map<String, dynamic>? selected;
  Map<String, dynamic>? verdict;
  Map<String, dynamic>? explanation;
  String difficulty = 'All';
  String tag = 'All';
  String language = 'Python';
  final editor = TextEditingController();
  bool loading = true;
  bool running = false;
  bool explaining = false;

  @override
  void initState() {
    super.initState();
    loadProblems();
  }

  Future<void> loadProblems() async {
    try {
      final response = await AppScope.of(context).api.dio.get('/code/problems');
      setState(() {
        problems = (response.data as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        selectProblem(problems.first);
      });
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

  void selectProblem(Map<String, dynamic> problem) {
    setState(() {
      selected = problem;
      editor.text = problem['starter'];
      verdict = null;
      explanation = null;
    });
  }

  List<Map<String, dynamic>> get filtered => problems.where((problem) {
        final tags = List<String>.from(problem['tags']);
        return (difficulty == 'All' || problem['difficulty'] == difficulty) &&
            (tag == 'All' || tags.contains(tag));
      }).toList();

  Future<void> runCode() async {
    setState(() => running = true);
    try {
      final response = await AppScope.of(context).api.dio.post(
        '/code/run',
        data: {
          'problem_id': selected!['id'],
          'language': language,
          'source': editor.text,
        },
      );
      setState(() => verdict = Map<String, dynamic>.from(response.data));
      if (mounted) {
        showMessage(context, 'Execution complete: ${response.data['verdict']}');
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
      if (mounted) setState(() => running = false);
    }
  }

  Future<void> explain() async {
    setState(() => explaining = true);
    try {
      final response = await AppScope.of(
        context,
      ).api.dio.post('/code/explain', data: {'problem_id': selected!['id']});
      setState(() => explanation = Map<String, dynamic>.from(response.data));
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          AppScope.of(context).api.errorMessage(error),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => explaining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          'Coding Arena',
          subtitle:
              'Solve interview patterns in a focused editor with instant demo verdicts.',
        ),
        Row(
          children: [
            ...['All', 'Easy', 'Medium', 'Hard'].map(
              (level) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SkillBadge(
                  level,
                  selected: difficulty == level,
                  color: AppColors.amber,
                  onTap: () => setState(() => difficulty = level),
                ),
              ),
            ),
            const SizedBox(width: 18),
            DropdownButton<String>(
              value: tag,
              items: ['All', 'Arrays', 'DP', 'Graphs', 'Heap']
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => tag = value!),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 1000;
            final list = _ProblemList(
              problems: filtered,
              selected: selected,
              onSelect: selectProblem,
            );
            final workspace = _Workspace(
              selected: selected!,
              editor: editor,
              language: language,
              onLanguage: (value) => setState(() => language = value),
              running: running,
              explaining: explaining,
              run: runCode,
              explain: explain,
              verdict: verdict,
              explanation: explanation,
            );
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 280, child: list),
                      const SizedBox(width: 16),
                      Expanded(child: workspace),
                    ],
                  )
                : Column(
                    children: [list, const SizedBox(height: 16), workspace],
                  );
          },
        ),
      ],
    );
  }
}

class _ProblemList extends StatelessWidget {
  const _ProblemList({
    required this.problems,
    required this.selected,
    required this.onSelect,
  });
  final List<Map<String, dynamic>> problems;
  final Map<String, dynamic>? selected;
  final ValueChanged<Map<String, dynamic>> onSelect;
  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'PROBLEM SET',
                style:
                    TextStyle(fontFamily: 'monospace', color: AppColors.muted),
              ),
            ),
            ...problems.map(
              (problem) => ListTile(
                selected: selected?['id'] == problem['id'],
                selectedTileColor: AppColors.indigo.withValues(alpha: .14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(problem['title']),
                subtitle: Text(
                  problem['difficulty'],
                  style: TextStyle(
                    color: problem['difficulty'] == 'Hard'
                        ? AppColors.danger
                        : AppColors.amber,
                  ),
                ),
                onTap: () => onSelect(problem),
              ),
            ),
          ],
        ),
      );
}

class _Workspace extends StatelessWidget {
  const _Workspace({
    required this.selected,
    required this.editor,
    required this.language,
    required this.onLanguage,
    required this.running,
    required this.explaining,
    required this.run,
    required this.explain,
    required this.verdict,
    required this.explanation,
  });
  final Map<String, dynamic> selected;
  final TextEditingController editor;
  final String language;
  final ValueChanged<String> onLanguage;
  final bool running;
  final bool explaining;
  final VoidCallback run;
  final VoidCallback explain;
  final Map<String, dynamic>? verdict;
  final Map<String, dynamic>? explanation;
  @override
  Widget build(BuildContext context) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    selected['title'],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SkillBadge(
                  selected['difficulty'],
                  color: selected['difficulty'] == 'Hard'
                      ? AppColors.danger
                      : AppColors.amber,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              selected['statement'],
              style: const TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              children: List<String>.from(
                selected['tags'],
              ).map((item) => SkillBadge(item)).toList(),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EDITOR',
                  style: TextStyle(
                      fontFamily: 'monospace', color: AppColors.muted),
                ),
                DropdownButton<String>(
                  value: language,
                  items: ['Python', 'Java', 'C++', 'JavaScript']
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: (value) => onLanguage(value!),
                ),
              ],
            ),
            TextField(
              controller: editor,
              minLines: 14,
              maxLines: 20,
              style: const TextStyle(
                fontFamily: 'monospace',
                height: 1.45,
                color: Color(0xFFD8E1FF),
              ),
              decoration: const InputDecoration(fillColor: Color(0xFF090C13)),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                LoadingButton(
                  label: 'Run Code',
                  loading: running,
                  onPressed: run,
                  icon: Icons.play_arrow,
                ),
                OutlinedButton.icon(
                  onPressed: explaining ? null : explain,
                  icon: explaining
                      ? const SizedBox.square(
                          dimension: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lightbulb_outline),
                  label: Text(
                      explaining ? 'Explaining...' : 'Explain this problem'),
                ),
              ],
            ),
            if (verdict != null) ...[
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: (verdict!['verdict'] == 'Accepted'
                          ? AppColors.success
                          : AppColors.danger)
                      .withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      verdict!['verdict'] == 'Accepted'
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: verdict!['verdict'] == 'Accepted'
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      verdict!['verdict'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      '${verdict!['tests_passed']} tests | ${verdict!['runtime']}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
            if (explanation != null) ...[
              const SizedBox(height: 15),
              Text('AI Explanation',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 7),
              Text(
                explanation!['explanation'],
                style: const TextStyle(height: 1.5, color: AppColors.muted),
              ),
            ],
          ],
        ),
      );
}
