import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaiiak/data/mock_questions.dart';
import 'package:kaiiak/models/kai_event.dart';
import 'package:kaiiak/models/waiting_question.dart';
import 'package:kaiiak/screens/waiting/match_reveal_screen.dart';
import 'package:kaiiak/theme/app_theme.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key, this.event, this.buddyUserId});
  final KaiEvent? event;
  final String? buddyUserId;

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen>
    with TickerProviderStateMixin {
  static const int _basePercent = 60;
  static const int _stepPercent = 5;

  static const List<String> _tips = [
    'Hydrate-toi avant! 💧',
    'Étire-toi le matin — tes genoux te remercieront 🧘',
    'N\'oublie pas ta gourde!',
    'Arrive 5 min avant au point de départ 📍',
    'Le rythme du groupe, c\'est le rythme de jasette 💬',
    '85% des participants kaiiak reviennent la semaine suivante 🔁',
    'Les 15 premières minutes sont les meilleures pour briser la glace ❄️',
    '67% des connexions se font pendant le Ravito Smoothie 🥤',
  ];

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  int _answeredCount = 0;
  int _questionIndex = 0;
  int _tipIndex = 0;
  Timer? _tipTimer;

  List<WaitingQuestion> get _questions => mockWaitingQuestions;

  int get _completionPercent =>
      (_basePercent + _answeredCount * _stepPercent).clamp(0, 100);

  WaitingQuestion get _currentQuestion =>
      _questions[_questionIndex % _questions.length];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.45, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _tipTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _onOptionSelected() {
    setState(() {
      _answeredCount++;
      _questionIndex = (_questionIndex + 1) % _questions.length;
    });
  }

  void _goToMatchReveal() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchRevealScreen(
          event: widget.event,
          buddyUserId: widget.buddyUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ev = widget.event;
    final showThreshold = ev != null && !ev.isConfirmed;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'En attente de ton groupe...',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _pulseAnimation,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppTheme.teal,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.teal,
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _completionPercent / 100,
                          strokeWidth: 6,
                          backgroundColor:
                              AppTheme.slateGrey.withValues(alpha: 0.2),
                          color: AppTheme.teal,
                          strokeCap: StrokeCap.round,
                        ),
                        Text(
                          '$_completionPercent%',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navyIcon(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Profil complété à $_completionPercent%',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showThreshold)
              _ThresholdGauge(
                registered: ev.totalRegistered,
                threshold: ev.minThreshold,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offset,
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<String>(_currentQuestion.id),
                    child: _QuizQuestionCard(
                      question: _currentQuestion,
                      onOptionTap: _onOptionSelected,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _tips[_tipIndex],
                  key: ValueKey<int>(_tipIndex),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    height: 1.35,
                    color: AppTheme.secondaryText(context),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                onPressed: _goToMatchReveal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ocean,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Simuler la formation du groupe 🎯',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Threshold gauge showing progress toward the minimum runner count.
class _ThresholdGauge extends StatelessWidget {
  const _ThresholdGauge({
    required this.registered,
    required this.threshold,
  });

  final int registered;
  final int threshold;

  @override
  Widget build(BuildContext context) {
    final ratio = (registered / threshold).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_run_rounded,
                    color: AppTheme.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$registered/$threshold participants — On y est presque!',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: AppTheme.slateGrey.withValues(alpha: 0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.warning),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestionCard extends StatelessWidget {
  const _QuizQuestionCard({
    required this.question,
    required this.onOptionTap,
  });

  final WaitingQuestion question;
  final VoidCallback onOptionTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppTheme.slateGrey.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.navy.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (question.category != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.teal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      question.category!,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.navyIcon(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                question.question,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: AppTheme.textColor(context),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final option in question.options)
                    ActionChip(
                      label: Text(option),
                      onPressed: onOptionTap,
                      backgroundColor: AppTheme.cream,
                      disabledColor:
                          AppTheme.cream.withValues(alpha: 0.7),
                      side: BorderSide(
                          color: AppTheme.navy.withValues(alpha: 0.15)),
                      labelStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.navyIcon(context),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
