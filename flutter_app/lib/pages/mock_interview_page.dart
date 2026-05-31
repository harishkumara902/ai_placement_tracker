import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/auth_controller.dart';
import '../widgets/common.dart';

class MockInterviewPage extends StatefulWidget {
  const MockInterviewPage({super.key});

  @override
  State<MockInterviewPage> createState() => _MockInterviewPageState();
}

class _MockInterviewPageState extends State<MockInterviewPage>
    with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 3, vsync: this);
  String difficulty = 'Medium';
  String technicalCategory = 'DSA';
  bool loading = false;
  List<Map<String, dynamic>> questions = [];
  int activeQuestion = 0;
  final answer = TextEditingController();
  Map<String, dynamic>? evaluation;
  final List<double> scores = [];

  String get round => switch (tabs.index) {
        0 => 'hr',
        1 => 'technical',
        _ => 'system-design',
      };

  Future<void> start() async {
    setState(() {
      loading = true;
      evaluation = null;
      scores.clear();
      activeQuestion = 0;
      questions.clear();
      answer.clear();
    });
    try {
      final response = await AppScope.of(context).api.dio.post(
        '/interview/start',
        data: {
          'round': round,
          'difficulty': difficulty,
          'category': round == 'technical' ? technicalCategory : null,
        },
      );
      setState(
        () => questions = (response.data as List)
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

  Future<void> evaluate() async {
    if (answer.text.trim().isEmpty) {
      showMessage(context, 'Type an answer before submitting.', error: true);
      return;
    }
    setState(() => loading = true);
    try {
      final response = await AppScope.of(context).api.dio.post(
        '/interview/evaluate',
        data: {
          'question': questions[activeQuestion]['prompt'],
          'answer': answer.text,
          'round': round,
        },
      );
      setState(() {
        evaluation = Map<String, dynamic>.from(response.data);
        scores.add((response.data['score'] as num).toDouble());
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

  void nextQuestion() {
    setState(() {
      activeQuestion++;
      evaluation = null;
      answer.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final complete = questions.isNotEmpty && scores.length == questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          'Mock Interview',
          subtitle:
              'Practice under pressure, receive structured feedback, improve fast.',
        ),
        GlassCard(
          child: Column(
            children: [
              TabBar(
                controller: tabs,
                onTap: (_) => setState(() {
                  questions.clear();
                  evaluation = null;
                  scores.clear();
                }),
                tabs: const [
                  Tab(text: 'HR Round'),
                  Tab(text: 'Technical Round'),
                  Tab(text: 'System Design'),
                ],
              ),
              const SizedBox(height: 21),
              Row(
                children: [
                  const Text(
                    'Difficulty: ',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  ...['Easy', 'Medium', 'Hard'].map(
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
                  if (tabs.index == 1) ...[
                    const SizedBox(width: 20),
                    ...['SQL', 'DSA', 'Aptitude'].map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SkillBadge(
                          category,
                          selected: technicalCategory == category,
                          onTap: () =>
                              setState(() => technicalCategory = category),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  LoadingButton(
                    label: 'Start Interview',
                    loading: loading && questions.isEmpty,
                    onPressed: start,
                    icon: Icons.play_arrow,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (questions.isNotEmpty && !complete) ...[
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkillBadge(
                      'QUESTION ${activeQuestion + 1} / ${questions.length}',
                      color: AppColors.amber,
                    ),
                    Text(
                      questions[activeQuestion]['category'],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  questions[activeQuestion]['prompt'],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: answer,
                  minLines: 6,
                  maxLines: 10,
                  enabled: evaluation == null,
                  decoration: const InputDecoration(
                    labelText: 'Your answer',
                    hintText:
                        'Structure your reasoning and support it with evidence...',
                  ),
                ),
                const SizedBox(height: 16),
                if (evaluation == null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: LoadingButton(
                      label: 'Submit Answer',
                      loading: loading,
                      onPressed: evaluate,
                      icon: Icons.send_outlined,
                    ),
                  )
                else ...[
                  _Feedback(evaluation!),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: activeQuestion + 1 == questions.length
                          ? () => setState(() {})
                          : nextQuestion,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        activeQuestion + 1 == questions.length
                            ? 'View Summary'
                            : 'Next Question',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (complete) ...[
          const SizedBox(height: 20),
          GlassCard(
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 46,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Session Complete',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(1)} / 10',
                    style: const TextStyle(
                      fontSize: 39,
                      color: AppColors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Average evaluation score',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: start,
                    icon: const Icon(Icons.replay),
                    label: const Text('Practice Again'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback(this.evaluation);
  final Map<String, dynamic> evaluation;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.indigo.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'AI Evaluation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                SkillBadge('${evaluation['score']} / 10',
                    color: AppColors.amber),
              ],
            ),
            const SizedBox(height: 12),
            Text(evaluation['feedback']),
            const SizedBox(height: 14),
            const Text(
              'IDEAL ANSWER STRUCTURE',
              style: TextStyle(
                fontFamily: 'monospace',
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              evaluation['ideal_answer'],
              style: const TextStyle(color: AppColors.pearl, height: 1.45),
            ),
          ],
        ),
      );
}
