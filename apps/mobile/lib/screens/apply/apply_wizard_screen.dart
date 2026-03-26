import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:rundate/data/mock_users.dart';
import 'package:rundate/models/kai_event.dart';
import 'package:rundate/models/user.dart';
import 'package:rundate/screens/profile/user_profile_sheet.dart';
import 'package:rundate/screens/home/main_shell.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/widgets/pace_label_icon.dart';

class ApplyWizardScreen extends StatefulWidget {
  const ApplyWizardScreen({super.key, this.event});
  final KaiEvent? event;

  @override
  State<ApplyWizardScreen> createState() => _ApplyWizardScreenState();
}

class _ApplyWizardScreenState extends State<ApplyWizardScreen> {
  final PageController _pageController = PageController();

  static const int _totalSteps = 5;

  IntensityLevel? _intensityLevel;
  DistanceLabel? _distanceLabel;
  final Set<String> _preferredParticipants = {};
  String? _bringsCompanion;
  bool _isAutoAdvancing = false;

  int get _currentPage {
    if (!_pageController.hasClients) return 0;
    final p = _pageController.page;
    if (p == null) return _pageController.initialPage;
    return p.round().clamp(0, _totalSteps - 1);
  }

  double get _progressFraction => (_currentPage + 1) / _totalSteps;

  TextStyle _titleStyle(BuildContext context) => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppTheme.textColor(context),
      );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  /// Select option and auto-advance after a brief visual feedback delay.
  void _selectAndAdvance(VoidCallback setSelection) {
    if (_isAutoAdvancing) return;
    HapticFeedback.selectionClick();
    setState(() {
      setSelection();
      _isAutoAdvancing = true;
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _goNext();
      setState(() => _isAutoAdvancing = false);
    });
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _showExitConfirmation();
    }
  }

  void _showExitConfirmation() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Quitter l\'inscription?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
          'Tes réponses ne seront pas sauvegardées.',
          style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(ctx),
              height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Rester',
                style: GoogleFonts.dmSans(color: AppTheme.secondaryText(ctx))),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _intensityLevel != null;
      case 1:
        return _distanceLabel != null;
      case 2:
        return true;
      case 3:
        return _bringsCompanion != null;
      default:
        return true;
    }
  }

  void _onConfirm() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PostRegistrationInviteScreen(
          event: widget.event,
        ),
      ),
    );
  }

  String _distanceDisplayLabel() {
    if (_distanceLabel == null) return '—';
    return '${_distanceLabel!.emoji} ${_distanceLabel!.label}';
  }

  String _preferencesDisplayLabel() {
    if (_preferredParticipants.isEmpty) return 'Aucune préférence';
    final names = mockUsers
        .where((u) => _preferredParticipants.contains(u.id))
        .map((u) => u.firstName)
        .toList();
    if (names.isEmpty) return 'Aucune préférence';
    return names.join(', ');
  }

  void _togglePreferredParticipant(String userId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_preferredParticipants.contains(userId)) {
        _preferredParticipants.remove(userId);
      } else {
        _preferredParticipants.add(userId);
      }
    });
  }

  Widget _optionCard({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.ocean.withValues(alpha: 0.08)
                : AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppTheme.ocean
                  : AppTheme.slateGrey.withValues(alpha: 0.25),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.navy.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(child: child),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.ocean, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepIntensity() {
    return _StepScaffold(
      title: 'Quel niveau d\'intensité?',
      subtitle: 'On affichera tes compagnons de groupe — les autres inscrits à ton niveau',
      titleStyle: _titleStyle(context),
      child: Column(
        children: IntensityLevel.values.map((level) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _optionCard(
              selected: _intensityLevel == level,
              onTap: () => _selectAndAdvance(() => _intensityLevel = level),
              child: Row(
                children: [
                  intensityLevelIcon(level),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(level.label,
                            style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor(context))),
                        const SizedBox(height: 2),
                        Text(level.description,
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppTheme.secondaryText(context))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _stepDistance() {
    return _StepScaffold(
      title: 'Quelle distance?',
      subtitle: 'Choisis ta distance idéale',
      titleStyle: _titleStyle(context),
      child: Column(
        children: DistanceLabel.values.map((dist) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _optionCard(
              selected: _distanceLabel == dist,
              onTap: () => _selectAndAdvance(() => _distanceLabel = dist),
              child: Row(
                children: [
                  Text(dist.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dist.label,
                            style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor(context))),
                        const SizedBox(height: 2),
                        Text(dist.description,
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppTheme.secondaryText(context))),
                        Text('${dist.emoji} ${dist.label}',
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.navy)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _stepPreferredParticipants() {
    final others =
        mockUsers.where((u) => u.id != currentUser.id).toList();
    return _StepScaffold(
      title: 'Avec qui tu voudrais bouger?',
      subtitle:
          'Sélectionne les personnes avec qui tu aimerais être (optionnel)\nAppuie longuement pour voir le profil',
      titleStyle: _titleStyle(context),
      child: Wrap(
        spacing: 12,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: others.map((u) {
          final selected = _preferredParticipants.contains(u.id);
          final initials =
              '${u.firstName.isNotEmpty ? u.firstName[0] : ''}${u.lastName.isNotEmpty ? u.lastName[0] : ''}'
                  .toUpperCase();
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _togglePreferredParticipant(u.id),
              onLongPress: () => UserProfileSheet.show(context, u),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? AppTheme.ocean
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.navy.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          AppTheme.ocean.withValues(alpha: 0.2),
                      backgroundImage: u.photoUrl != null
                          ? NetworkImage(u.photoUrl!)
                          : null,
                      child: u.photoUrl == null
                          ? Text(
                              initials,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textColor(context),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 88,
                      child: Text(
                        u.firstName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _stepToutou() {
    return _StepScaffold(
      title: 'Tu amènes quelqu\'un? 🐕',
      subtitle: 'On est curieux... tu viens avec qui?',
      titleStyle: _titleStyle(context),
      child: Column(
        children: [
          _optionCard(
            selected: _bringsCompanion == 'dog',
            onTap: () => _selectAndAdvance(() => _bringsCompanion = 'dog'),
            child: Row(
              children: [
                Image.asset('assets/companions/toutou.png', width: 36, height: 36, errorBuilder: (_, __, ___) => const Text('🐕', style: TextStyle(fontSize: 28))),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mon toutou vient avec moi!',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor(context))),
                    Text('Ça va me donner des points supplémentaires',
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppTheme.secondaryText(context))),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _optionCard(
            selected: _bringsCompanion == 'mom',
            onTap: () => _selectAndAdvance(() => _bringsCompanion = 'mom'),
            child: Row(
              children: [
                Image.asset('assets/companions/maman.png', width: 36, height: 36, errorBuilder: (_, __, ___) => const Text('👩‍🦳', style: TextStyle(fontSize: 28))),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ma mère! Elle veut me matcher',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor(context))),
                    Text('Elle va encourager tout le monde',
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppTheme.secondaryText(context))),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _optionCard(
            selected: _bringsCompanion == 'stroller',
            onTap: () => _selectAndAdvance(() => _bringsCompanion = 'stroller'),
            child: Row(
              children: [
                Image.asset('assets/companions/poussette.png', width: 36, height: 36, errorBuilder: (_, __, ___) => const Text('👶', style: TextStyle(fontSize: 28))),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mon enfant dans la poussette!',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor(context))),
                    Text('Futur champion de course',
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppTheme.secondaryText(context))),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _optionCard(
            selected: _bringsCompanion == 'solo',
            onTap: () => _selectAndAdvance(() => _bringsCompanion = 'solo'),
            child: Row(
              children: [
                Image.asset('assets/companions/solo.png', width: 36, height: 36, errorBuilder: (_, __, ___) => const Text('🏃', style: TextStyle(fontSize: 28))),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Juste moi, c\'est déjà assez',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor(context))),
                    Text('Loup solitaire assumé',
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppTheme.secondaryText(context))),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 7: Confirmation
  Widget _stepConfirm() {
    return _StepScaffold(
      title: 'T\'es prêt(e)!',
      titleStyle: _titleStyle(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppTheme.slateGrey.withValues(alpha: .2)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.navy.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.event != null) ...[
                  _summaryRow(
                    'Événement',
                    Text(
                      '${widget.event!.neighborhood} · ${widget.event!.date.day}/${widget.event!.date.month}',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppTheme.textColor(context)),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                _summaryRow('Intensité', _intensitySummaryValue(), editStep: 0),
                _summaryRow(
                  'Distance',
                  Text(
                    _distanceDisplayLabel(),
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textColor(context)),
                  ),
                  editStep: 1,
                ),
                _summaryRow(
                  'Préférences',
                  Text(
                    _preferencesDisplayLabel(),
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textColor(context)),
                  ),
                  editStep: 2,
                ),
                _summaryRow(
                  'Compagnon',
                  Text(
                    _bringsCompanion == 'dog'
                        ? 'Mon toutou 🐕'
                        : _bringsCompanion == 'mom'
                            ? 'Ma mère 👩‍🦳'
                            : _bringsCompanion == 'stroller'
                                ? 'Bébé en poussette 👶'
                                : 'Solo 🏃',
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textColor(context)),
                  ),
                  editStep: 3,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_run_rounded,
                          color: AppTheme.teal, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Retrouve-toi sur place avec tout le monde — des sous-groupes se forment naturellement selon les rythmes',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppTheme.textColor(context),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ocean,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: GoogleFonts.nunito(
                    fontSize: 17, fontWeight: FontWeight.w700),
              ),
              child: const Text('Confirmer mon inscription'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tu es inscrit(e)! Rendez-vous sur place.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _intensitySummaryValue() {
    if (_intensityLevel == null) {
      return Text(
        '—',
        style: GoogleFonts.dmSans(
            fontSize: 14, color: AppTheme.textColor(context)),
      );
    }
    final level = _intensityLevel!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        intensityLevelIcon(level),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            level.label,
            style: GoogleFonts.dmSans(
                fontSize: 14, color: AppTheme.textColor(context)),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String k, Widget value, {int? editStep}) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ),
          Expanded(child: value),
          if (editStep != null)
            Icon(Icons.edit_outlined,
                size: 16,
                color: AppTheme.slateGrey.withValues(alpha: 0.6)),
        ],
      ),
    );

    if (editStep != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          HapticFeedback.selectionClick();
          _pageController.animateToPage(
            editStep,
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeInOutCubic,
          );
        },
        child: content,
      );
    }
    return content;
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Étape ${_currentPage + 1}/$_totalSteps',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: _progressFraction),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  backgroundColor:
                      AppTheme.slateGrey.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.ocean),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _totalSteps,
              effect: ExpandingDotsEffect(
                dotColor: AppTheme.slateGrey.withValues(alpha: 0.25),
                activeDotColor: AppTheme.ocean,
                dotHeight: 6,
                dotWidth: 6,
                expansionFactor: 3,
                spacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _showNextButton {
    if (_currentPage == _totalSteps - 1) return false;
    // Steps 0, 1 and 3 (toutou) auto-advance
    if (_currentPage == 0 || _currentPage == 1 || _currentPage == 3) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppTheme.textColor(context),
                  ),
                  Expanded(
                    child: Text(
                      'Inscription',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                physics: const BackwardOnlyPageScrollPhysics(
                  parent: PageScrollPhysics(),
                ),
                controller: _pageController,
                onPageChanged: (_) => setState(() {}),
                children: [
                  _stepIntensity(),
                  _stepDistance(),
                  _stepPreferredParticipants(),
                  _stepToutou(),
                  _stepConfirm(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _showNextButton
                    ? SizedBox(
                        key: const ValueKey('next-btn'),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canProceed() ? _goNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.ocean,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppTheme.slateGrey.withValues(alpha: 0.35),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            textStyle: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Suivant'),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no-next')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.title,
    required this.titleStyle,
    required this.child,
    this.subtitle,
  });

  final String title;
  final TextStyle titleStyle;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: constraints.maxHeight - 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, textAlign: TextAlign.center, style: titleStyle),
                if (subtitle != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: AppTheme.secondaryText(context),
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                child,
              ],
            ),
          ),
        );
      },
    );
  }
}

class BackwardOnlyPageScrollPhysics extends PageScrollPhysics {
  const BackwardOnlyPageScrollPhysics({super.parent});

  @override
  BackwardOnlyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BackwardOnlyPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (offset < 0) {
      return 0;
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }
}

// ===========================================================================
// Post-Registration Invite Screen
// ===========================================================================

class PostRegistrationInviteScreen extends StatefulWidget {
  const PostRegistrationInviteScreen({
    super.key,
    this.event,
  });

  final KaiEvent? event;

  @override
  State<PostRegistrationInviteScreen> createState() =>
      _PostRegistrationInviteScreenState();
}

class _PostRegistrationInviteScreenState
    extends State<PostRegistrationInviteScreen> {
  final Set<String> _invitedIds = {};
  final Map<String, TextEditingController> _messageControllers = {};

  @override
  void dispose() {
    for (final c in _messageControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _continue() {
    _showRegistrationConfirmation();
  }

  void _showRegistrationConfirmation() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppTheme.cardColor(ctx),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/inscription_confirmee.png',
              width: 64,
              height: 64,
              errorBuilder: (_, _, _) =>
                  const Text('🎉', style: TextStyle(fontSize: 56)),
            ),
            const SizedBox(height: 16),
            Text(
              'Inscription confirmée!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(ctx),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Le processus de formation de groupe se fera très prochainement. '
              'Tu recevras une notification dès que ton groupe sera prêt!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(ctx),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const MainShell(initialTabIndex: 0),
                  ),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ocean,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Retour à l\'accueil',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _invite(User u) {
    final controller = _messageControllers.putIfAbsent(
      u.id,
      () => TextEditingController(),
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Inviter ${u.firstName}',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(ctx),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Message optionnel...',
                hintStyle:
                    GoogleFonts.dmSans(color: AppTheme.secondaryText(ctx)),
                filled: true,
                fillColor: AppTheme.cardColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppTheme.slateGrey.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppTheme.slateGrey.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.teal, width: 2),
                ),
              ),
              style: GoogleFonts.dmSans(fontSize: 15),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _invitedIds.add(u.id));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Invitation envoyée à ${u.firstName}! 🎉',
                      style: GoogleFonts.dmSans(),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(milliseconds: 1800),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Envoyer l\'invitation',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pastPartners = mockUsers.skip(1).take(6).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/icons/inscription_confirmee.png',
                  width: 64,
                  height: 64,
                  errorBuilder: (_, _, _) =>
                      const Text('🎉', style: TextStyle(fontSize: 56)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Inscription confirmée!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Invite tes anciens partenaires d\'activité à se joindre!',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppTheme.secondaryText(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: pastPartners.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final u = pastPartners[i];
                    final invited = _invitedIds.contains(u.id);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: invited
                              ? AppTheme.teal.withValues(alpha: 0.4)
                              : AppTheme.slateGrey.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                AppTheme.ocean.withValues(alpha: 0.2),
                            backgroundImage: u.photoUrl != null
                                ? NetworkImage(u.photoUrl!)
                                : null,
                            child: u.photoUrl == null
                                ? Text(
                                    u.firstName[0],
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textColor(context),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.firstName,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textColor(context),
                                  ),
                                ),
                                u.activities.isNotEmpty
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(u.activities.first.category.emoji, style: const TextStyle(fontSize: 20)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              u.activities.map((a) => a.category.label).join(', '),
                                              style: GoogleFonts.dmSans(
                                                fontSize: 14,
                                                color: AppTheme.secondaryText(
                                                    context),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Rythme non défini',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          color: AppTheme.secondaryText(
                                              context),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          if (invited)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.teal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Invité ✓',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.teal,
                                ),
                              ),
                            )
                          else
                            OutlinedButton(
                              onPressed: () => _invite(u),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.teal,
                                side: const BorderSide(
                                  color: AppTheme.teal, width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Inviter',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ocean,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  textStyle: GoogleFonts.nunito(
                    fontSize: 17, fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Continuer'),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _continue,
                  child: Text(
                    'Passer cette étape',
                    style: GoogleFonts.dmSans(
                        color: AppTheme.secondaryText(context)),
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
