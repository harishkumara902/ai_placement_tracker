import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/auth_controller.dart';
import '../widgets/common.dart';

class ResumeAnalyzerPage extends StatefulWidget {
  const ResumeAnalyzerPage({super.key});

  @override
  State<ResumeAnalyzerPage> createState() => _ResumeAnalyzerPageState();
}

class _ResumeAnalyzerPageState extends State<ResumeAnalyzerPage> {
  final resume = TextEditingController();
  final company = TextEditingController(text: 'Zoho');
  final role = TextEditingController(text: 'Software Developer');
  PlatformFile? selectedFile;
  Map<String, dynamic>? result;
  bool loading = false;

  Future<void> pickFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
      withData: true,
    );
    if (picked != null) setState(() => selectedFile = picked.files.single);
  }

  Future<void> analyze() async {
    if (selectedFile == null && resume.text.trim().length < 20) {
      showMessage(
        context,
        'Paste at least a short resume or upload a file.',
        error: true,
      );
      return;
    }
    setState(() => loading = true);
    try {
      final api = AppScope.of(context).api.dio;
      late final Response response;
      if (selectedFile != null && resume.text.trim().isEmpty) {
        response = await api.post(
          '/resume/analyze-file',
          data: FormData.fromMap({
            'dream_company': company.text,
            'target_role': role.text,
            'file': MultipartFile.fromBytes(
              selectedFile!.bytes!,
              filename: selectedFile!.name,
            ),
          }),
        );
      } else {
        response = await api.post(
          '/resume/analyze',
          data: {
            'resume_text': resume.text,
            'dream_company': company.text,
            'target_role': role.text,
          },
        );
      }
      setState(() => result = Map<String, dynamic>.from(response.data));
      if (mounted) showMessage(context, 'ATS analysis completed.');
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
          'Resume Analyzer',
          subtitle:
              'Score your profile against the role and close keyword gaps.',
        ),
        GlassCard(
          child: Column(
            children: [
              InkWell(
                onTap: pickFile,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.indigo.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedFile == null
                          ? AppColors.indigo
                          : AppColors.success,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selectedFile == null
                            ? Icons.cloud_upload_outlined
                            : Icons.check_circle_outline,
                        color: selectedFile == null
                            ? AppColors.indigo
                            : AppColors.success,
                        size: 37,
                      ),
                      const SizedBox(height: 9),
                      Text(
                        selectedFile?.name ??
                            'Drop or select your PDF / DOCX resume',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        'Maximum 10 MB',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'OR PASTE TEXT',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ),
              TextField(
                controller: resume,
                minLines: 6,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText:
                      'Paste resume content for the most accurate skills and ATS analysis...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: company,
                      decoration: const InputDecoration(
                        labelText: 'Dream Company',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: role,
                      decoration: const InputDecoration(
                        labelText: 'Target Role',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: LoadingButton(
                  label: 'Analyze Resume',
                  loading: loading,
                  onPressed: analyze,
                ),
              ),
            ],
          ),
        ),
        if (result != null) ...[
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ATS Match Score',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${result!['ats_score']}%',
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: (result!['ats_score'] as num).toDouble() / 100,
                  ),
                  duration: const Duration(milliseconds: 850),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.indigo,
                    backgroundColor: Colors.white10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, size) {
              final panelWidth = size.maxWidth > 980
                  ? (size.maxWidth - 36) / 3
                  : size.maxWidth;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  _Panel(
                    'Strengths found',
                    Icons.check_circle_outline,
                    AppColors.success,
                    List<String>.from(result!['strengths']),
                    panelWidth,
                  ),
                  _Panel(
                    'Missing skills',
                    Icons.cancel_outlined,
                    AppColors.danger,
                    List<String>.from(result!['missing_skills']),
                    panelWidth,
                    badges: true,
                  ),
                  _Panel(
                    'Suggestions',
                    Icons.lightbulb_outline,
                    AppColors.amber,
                    List<String>.from(result!['suggestions']),
                    panelWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel(
    this.title,
    this.icon,
    this.color,
    this.items,
    this.width, {
    this.badges = false,
  });
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  final double width;
  final bool badges;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 9),
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 18),
              if (badges)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map((text) => SkillBadge(text, color: color))
                      .toList(),
                )
              else
                ...items.asMap().entries.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.key + 1}.',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.value,
                                style: const TextStyle(height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
}
