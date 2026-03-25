import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:kaiiak/data/mock_users.dart';
import 'package:kaiiak/models/kai_event.dart';
import 'package:kaiiak/models/user.dart';
import 'package:kaiiak/theme/app_theme.dart';
import 'package:kaiiak/widgets/like_message_sheet.dart';
import 'package:kaiiak/widgets/user_avatar.dart';

class RateEventScreen extends StatefulWidget {
  const RateEventScreen({super.key, required this.event});
  final KaiEvent event;

  @override
  State<RateEventScreen> createState() => _RateEventScreenState();
}

class _RateEventScreenState extends State<RateEventScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final List<User> _groupMembers;

  int _currentPage = 0;

  // Event + Parcours + Members + ThankYou
  int get _totalPages => _groupMembers.length + 3;

  // Event rating
  int _eventRating = 0;

  // Run ratings
  int _parcoursRating = 0;
  int _groupeRating = 0;
  int _aperoSmoothieRating = 0;

  // Member ratings
  late final List<int> _memberRatings;
  late final List<String> _memberComments;
  late final List<bool> _memberReported;
  late final List<bool> _memberCommentPublic;
  late final List<bool> _memberLiked;

  // Heart pulse animation
  late final AnimationController _heartController;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _groupMembers = mockUsers.take(6).toList();
    _memberRatings = List.filled(_groupMembers.length, 0);
    _memberComments = List.filled(_groupMembers.length, '');
    _memberReported = List.filled(_groupMembers.length, false);
    _memberCommentPublic = List.filled(_groupMembers.length, true);
    _memberLiked = List.filled(_groupMembers.length, false);

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  // -- Navigation --

  void _goNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
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
        title: Text('Quitter la notation?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
          'Tes notes ne seront pas sauvegardées.',
          style: GoogleFonts.dmSans(
              fontSize: 14, color: AppTheme.secondaryText(context), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Rester',
                style: GoogleFonts.dmSans(color: AppTheme.secondaryText(context))),
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

  // -- Step helpers --

  String get _stepLabel {
    if (_currentPage == 0) return 'L\'activité';
    if (_currentPage == 1) return 'L\'expérience';
    if (_currentPage <= _groupMembers.length + 1) {
      return _groupMembers[_currentPage - 2].firstName;
    }
    return 'Merci!';
  }

  bool _canProceed() {
    if (_currentPage == 0) return _eventRating > 0;
    if (_currentPage == 1) {
      return _parcoursRating > 0 ||
          _groupeRating > 0 ||
          _aperoSmoothieRating > 0;
    }
    if (_currentPage <= _groupMembers.length + 1) {
      return _memberRatings[_currentPage - 2] > 0;
    }
    return true;
  }

  double get _progress => (_currentPage + 1) / _totalPages;

  // -- Build --

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppTheme.textColor(context),
                  ),
                  Expanded(
                    child: Text(
                      'Noter l\'activité',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Étape ${_currentPage + 1}/$_totalPages',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryText(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· $_stepLabel',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ocean,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: _progress),
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
                      count: _totalPages,
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
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildEventRatingStep(),
                  _buildRunExperienceStep(),
                  for (var i = 0; i < _groupMembers.length; i++)
                    _buildMemberRatingStep(i),
                  _buildThankYouStep(),
                ],
              ),
            ),
            if (_currentPage < _totalPages - 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canProceed() ? _goNext : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.ocean,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppTheme.slateGrey.withValues(alpha: 0.35),
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                    ),
                    if (_currentPage >= 2 && _currentPage < 2 + _groupMembers.length)
                      TextButton(
                        onPressed: _goNext,
                        child: Text(
                          'Passer',
                          style: GoogleFonts.dmSans(color: AppTheme.secondaryText(context), fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Step 0: Event Rating ───

  Widget _buildEventRatingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fitness_center,
                size: 40, color: AppTheme.warning),
          ),
          const SizedBox(height: 24),
          Text(
            'Comment était cette activité?',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.event.neighborhood,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 32),
          _StarRatingRow(
            rating: _eventRating,
            onChanged: (v) => setState(() => _eventRating = v),
            size: 48,
          ),
          const SizedBox(height: 24),
          TextField(
            maxLines: 3,
            maxLength: 300,
            style: GoogleFonts.dmSans(fontSize: 15),
            decoration: _commentDecoration(
                'Un commentaire sur l\'activité? (optionnel)'),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Run Experience Rating ───

  Widget _buildRunExperienceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '💪',
              style: TextStyle(fontSize: 36),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'L\'expérience',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Note chaque aspect de l\'activité',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 28),
          _buildLabeledStarRow(
            label: 'L\'activité',
            rating: _parcoursRating,
            onChanged: (v) => setState(() => _parcoursRating = v),
          ),
          const SizedBox(height: 18),
          _buildLabeledStarRow(
            label: 'Groupe',
            rating: _groupeRating,
            onChanged: (v) => setState(() => _groupeRating = v),
          ),
          const SizedBox(height: 18),
          _buildLabeledStarRow(
            label: 'Ravito Smoothie',
            rating: _aperoSmoothieRating,
            onChanged: (v) => setState(() => _aperoSmoothieRating = v),
          ),
          const SizedBox(height: 24),
          TextField(
            maxLines: 2,
            maxLength: 200,
            style: GoogleFonts.dmSans(fontSize: 15),
            decoration:
                _commentDecoration('Un commentaire sur l\'expérience? (optionnel)'),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledStarRow({
    required String label,
    required int rating,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor(context),
          ),
        ),
        const SizedBox(height: 8),
        _StarRatingRow(rating: rating, onChanged: onChanged, size: 38),
      ],
    );
  }

  // ─── Steps 2..N: Member Ratings ───

  Widget _buildMemberRatingStep(int index) {
    final user = _groupMembers[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: [
          UserAvatar(
            name: user.firstName,
            photoUrl: user.photoUrl,
            isVerified: user.isVerified,
            xp: user.xp,
            size: 90,
          ),
          const SizedBox(height: 16),
          Text(
            user.firstName,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${user.age} ans · ',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.secondaryText(context),
                ),
              ),
              Image.asset(
                user.badge.assetPath,
                width: 20,
                height: 20,
                errorBuilder: (_, _, _) => Text(
                  user.badge.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Text(
                ' ${user.badge.label}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.secondaryText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _StarRatingRow(
            rating: _memberRatings[index],
            onChanged: (v) => setState(() => _memberRatings[index] = v),
            size: 42,
          ),
          const SizedBox(height: 24),
          TextField(
            maxLines: 2,
            maxLength: 200,
            style: GoogleFonts.dmSans(fontSize: 15),
            onChanged: (v) => _memberComments[index] = v,
            decoration: _commentDecoration(
                'Un mot sur ${user.firstName}? (optionnel)'),
          ),
          const SizedBox(height: 8),
          _buildPublicPrivateToggle(index),
          const SizedBox(height: 16),
          if (!_memberReported[index])
            TextButton.icon(
              onPressed: () => _showReportSheet(context, user, index),
              icon: Icon(Icons.flag_outlined,
                  size: 18, color: AppTheme.error.withValues(alpha: 0.8)),
              label: Text(
                'Signaler ${user.firstName}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.error.withValues(alpha: 0.8),
                ),
              ),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag_rounded,
                      size: 16, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Signalement envoyé',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _buildLikeButton(user, index),
        ],
      ),
    );
  }

  // ─── Public / Private toggle ───

  Widget _buildPublicPrivateToggle(int index) {
    final isPublic = _memberCommentPublic[index];

    final chips = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility,
                  size: 14,
                  color: isPublic ? Colors.white : AppTheme.secondaryText(context)),
              const SizedBox(width: 6),
              Text('Public',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isPublic ? Colors.white : AppTheme.secondaryText(context),
                  )),
            ],
          ),
          selected: isPublic,
          onSelected: (_) =>
              setState(() => _memberCommentPublic[index] = true),
          selectedColor: AppTheme.teal,
          backgroundColor: AppTheme.slateGrey.withValues(alpha: 0.08),
          side: BorderSide.none,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          showCheckmark: false,
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility_off,
                  size: 14,
                  color: !isPublic ? Colors.white : AppTheme.secondaryText(context)),
              const SizedBox(width: 6),
              Text('Privé',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: !isPublic ? Colors.white : AppTheme.secondaryText(context),
                  )),
            ],
          ),
          selected: !isPublic,
          onSelected: (_) =>
              setState(() => _memberCommentPublic[index] = false),
          selectedColor: AppTheme.navy.withValues(alpha: 0.75),
          backgroundColor: AppTheme.slateGrey.withValues(alpha: 0.08),
          side: BorderSide.none,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          showCheckmark: false,
        ),
      ],
    );

    return Column(
      children: [
        chips,
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPublic ? Icons.groups_outlined : Icons.lock_outline,
              size: 14,
              color: AppTheme.slateGrey.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              isPublic
                  ? 'Visible par tous les participants'
                  : 'Envoyé uniquement à cette personne',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.slateGrey.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── "J'aimerais te revoir" button ───

  Widget _buildLikeButton(User user, int index) {
    final liked = _memberLiked[index];

    if (liked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.ocean.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 18, color: AppTheme.ocean),
            const SizedBox(width: 8),
            Text(
              'Demande envoyée',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.ocean.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _heartScale,
      builder: (context, child) {
        final scale =
            _heartController.isAnimating ? _heartScale.value : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: TextButton(
        onPressed: () => _onLikeTapped(user, index),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.ocean,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
                color: AppTheme.ocean.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 18),
            const SizedBox(width: 8),
            Text(
              'J\'aimerais te connaître 💌',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLikeTapped(User user, int index) {
    showLikeMessageBottomSheet(
      context,
      firstName: user.firstName,
      onSend: () => _completeMemberLike(user, index),
    );
  }

  void _completeMemberLike(User user, int index) {
    HapticFeedback.mediumImpact();
    _heartController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() => _memberLiked[index] = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ta demande a été envoyée à ${user.firstName}!',
            style: GoogleFonts.dmSans(fontSize: 14),
          ),
          backgroundColor: AppTheme.teal,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  // ─── Enhanced report bottom sheet ───

  void _showReportSheet(BuildContext context, User user, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ReportSheet(
          user: user,
          onSubmit: () {
            Navigator.of(ctx).pop();
            HapticFeedback.mediumImpact();
            setState(() => _memberReported[index] = true);
          },
        );
      },
    );
  }

  // ─── Thank-you step ───

  Widget _buildThankYouStep() {
    final hasReports = _memberReported.any((r) => r);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                size: 56, color: AppTheme.teal),
          ),
          const SizedBox(height: 28),
          Text(
            'Merci pour tes évaluations!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tes notes nous aident à former de meilleurs groupes pour les prochaines activités.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppTheme.secondaryText(context),
              height: 1.45,
            ),
          ),
          if (hasReports) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded,
                      color: AppTheme.error, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Notre équipe prendra en charge tout signalement dans les plus brefs délais. Merci de contribuer à une communauté saine.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textColor(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.teal.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Text(
                  '💪',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 10),
                Text(
                  'T\'as aimé ce groupe?',
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dis-nous si tu voudrais reparticiper avec eux!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.secondaryText(context),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Préférence enregistrée! On en tiendra compte pour tes prochains groupes 🎉',
                            style: GoogleFonts.dmSans(),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay_rounded, size: 20),
                    label: const Text('Reparticiper avec ce groupe'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.teal,
                      side: const BorderSide(color: AppTheme.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
              },
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
              child: const Text('Terminé'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared input decoration ───

  InputDecoration _commentDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(color: AppTheme.secondaryText(context)),
      filled: true,
      fillColor: AppTheme.cardColor(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.ocean, width: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Report bottom sheet – extracted as a StatefulWidget for local form state
// ─────────────────────────────────────────────────────────────────────────────

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.user, required this.onSubmit});
  final User user;
  final VoidCallback onSubmit;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const _reasons = [
    'Comportement inapproprié',
    'Harcèlement ou intimidation',
    'No-show (absent sans prévenir)',
    'Propos offensants',
    'Autre',
  ];

  int? _selectedReason;
  final _commentController = TextEditingController();

  bool get _canSubmit =>
      _selectedReason != null && _commentController.text.trim().length >= 10;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.slateGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Signaler ${widget.user.firstName}',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.user.firstName} ne sera pas informé(e) de ton signalement.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.secondaryText(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Raison du signalement',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor(context),
                ),
              ),
              const SizedBox(height: 10),
              RadioGroup<int>(
                groupValue: _selectedReason ?? -1,
                onChanged: (v) => setState(() => _selectedReason = v),
                child: Column(
                  children: List.generate(_reasons.length, (i) {
                    return RadioListTile<int>(
                      value: i,
                      title: Text(
                        _reasons[i],
                        style: GoogleFonts.dmSans(
                            fontSize: 14, color: AppTheme.textColor(context)),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppTheme.error,
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 3,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.dmSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Décris la situation (min. 10 caractères)',
                  hintStyle: GoogleFonts.dmSans(color: AppTheme.secondaryText(context)),
                  filled: true,
                  fillColor: AppTheme.cream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: AppTheme.slateGrey.withValues(alpha: 0.25)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: AppTheme.slateGrey.withValues(alpha: 0.25)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppTheme.error, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_in_talk_rounded,
                        color: AppTheme.error, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'En cas de problème grave',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '514 715 1112',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // url_launcher would be used here in production
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppTheme.error),
                        ),
                      ),
                      child: Text('Appeler',
                          style: GoogleFonts.dmSans(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _canSubmit ? widget.onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppTheme.slateGrey.withValues(alpha: 0.35),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  textStyle: GoogleFonts.nunito(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Envoyer le signalement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Star rating row (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────

class _StarRatingRow extends StatelessWidget {
  const _StarRatingRow({
    required this.rating,
    required this.onChanged,
    this.size = 40,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final starNum = i + 1;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(starNum);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedScale(
              scale: rating >= starNum ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                rating >= starNum
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: size,
                color: rating >= starNum
                    ? AppTheme.warning
                    : AppTheme.slateGrey.withValues(alpha: 0.4),
              ),
            ),
          ),
        );
      }),
    );
  }
}
