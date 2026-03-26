import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rundate/data/mock_event_photos.dart';
import 'package:rundate/data/mock_meeting_points.dart';
import 'package:rundate/data/mock_users.dart';
import 'package:rundate/data/mock_weather.dart';
import 'package:rundate/models/meeting_point.dart';
import 'package:rundate/models/kai_event.dart';
import 'package:rundate/data/mock_messages.dart';
import 'package:rundate/screens/apply/apply_wizard_screen.dart';
import 'package:rundate/screens/profile/invite_friend_screen.dart';
import 'package:rundate/screens/payment/payment_checkout_screen.dart';
import 'package:rundate/widgets/cancellation_policy_sheet.dart';
import 'package:rundate/screens/messages/chat_screen.dart';
import 'package:rundate/screens/profile/contact_form_screen.dart';
import 'package:rundate/screens/profile/user_profile_sheet.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/utils/neighborhood_assets.dart';
import 'package:rundate/widgets/add_photo_sheet.dart';
import 'package:rundate/widgets/meeting_point_card.dart';
import 'package:rundate/widgets/photo_gallery_viewer.dart';
import 'package:rundate/widgets/pace_label_icon.dart' show intensityLevelIcon;
import 'package:rundate/widgets/distance_label_icon.dart';
import 'package:rundate/widgets/user_avatar.dart';
import 'package:rundate/widgets/tip_organizer_sheet.dart';
import 'package:rundate/widgets/weather_badge.dart';

String _frenchWeekday(int weekday) {
  const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  return days[(weekday - 1).clamp(0, 6)];
}

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.event});

  final KaiEvent event;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Timer? _countdownTimer;
  Duration _timeUntilEvent = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    if (!widget.event.isPast) {
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _updateCountdown(),
      );
    }
  }

  void _updateCountdown() {
    final diff = widget.event.date.difference(DateTime.now());
    if (mounted) {
      setState(() => _timeUntilEvent = diff.isNegative ? Duration.zero : diff);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _showUnsubscribeSheet(BuildContext context, KaiEvent event) {
    String? selectedReason;
    final otherController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final reasons = [
              'J\'ai un empêchement',
              'Je ne suis plus intéressé(e)',
              'J\'ai trouvé autre chose',
              'Autre raison',
            ];
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardColor(ctx),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.slateGrey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Se désinscrire',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textColor(ctx),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dis-nous pourquoi tu te désinscris',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppTheme.secondaryText(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...reasons.map((r) {
                        final selected = selectedReason == r;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () =>
                                  setLocal(() => selectedReason = r),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.error
                                        : AppTheme.slateGrey
                                            .withValues(alpha: 0.25),
                                    width: selected ? 2 : 1,
                                  ),
                                  color: selected
                                      ? AppTheme.error
                                          .withValues(alpha: 0.06)
                                      : AppTheme.cardColor(ctx),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: selected
                                          ? AppTheme.error
                                          : AppTheme.slateGrey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        r,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          color: AppTheme.textColor(ctx),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      if (selectedReason == 'Autre raison') ...[
                        const SizedBox(height: 4),
                        TextField(
                          controller: otherController,
                          maxLines: 2,
                          style: GoogleFonts.dmSans(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Précise ta raison...',
                            hintStyle: GoogleFonts.dmSans(
                                color: AppTheme.secondaryText(context)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: selectedReason != null
                            ? () {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Tu as été désinscrit(e) de ${event.neighborhood}',
                                      style: GoogleFonts.dmSans(),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppTheme.slateGrey.withValues(alpha: 0.3),
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
                        child: const Text('Confirmer la désinscription'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final total = e.totalRegistered;
    final menPct = (e.menRatio * 100).round();
    final womenPct = (e.womenRatio * 100).round();
    final otherPct = (e.otherCount / (total > 0 ? total : 1) * 100).round();

    final photos = mockEventPhotos.where((p) => p.eventId == e.id).toList();

    MeetingPoint? meetingPoint;
    if (e.meetingPointId != null) {
      meetingPoint = mockMeetingPoints.firstWhere(
        (p) => p.id == e.meetingPointId,
        orElse: () => mockMeetingPoints.first,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: AppTheme.textColor(context),
        elevation: 0,
        title: Text(
          'Détail de l\'activité',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            tooltip: 'Partager',
            onPressed: () {
              final day = _frenchWeekday(e.date.weekday);
              final time = '${e.date.hour}h${e.date.minute.toString().padLeft(2, '0')}';
              Share.share(
                'Viens bouger avec moi! 💪\n\n'
                '${e.neighborhood} — $day $time\n'
                '${e.distanceLabel.label}\n\n'
                'Inscris-toi sur rundate.app',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  NeighborhoodBanner(
                    neighborhood: e.neighborhood,
                    height: 160,
                    borderRadius: BorderRadius.circular(16),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1), duration: 400.ms),
                  const SizedBox(height: 12),
                  Text(
                    e.neighborhood,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textColor(context),
                      height: 1.15,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 6),
                  Text(
                    e.city,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.secondaryText(context),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 150.ms),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(e.category.emoji,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          e.category.label,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.teal,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 175.ms),
                  const SizedBox(height: 8),
                  Text(
                    '${_frenchWeekday(e.date.weekday)} · '
                    '${e.date.hour}h${e.date.minute.toString().padLeft(2, '0')}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ocean,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms),
                  if (!e.isPast && _timeUntilEvent > Duration.zero)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _EventCountdown(remaining: _timeUntilEvent),
                    ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: e.isFree
                                ? AppTheme.teal.withValues(alpha: 0.12)
                                : AppTheme.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: e.isFree
                                  ? AppTheme.teal.withValues(alpha: 0.35)
                                  : AppTheme.warning.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                e.isFree ? '🎉' : '💰',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.isFree ? 'Gratuit' : e.priceLabel,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: e.isFree ? AppTheme.teal : AppTheme.warning,
                                    ),
                                  ),
                                  if (!e.isFree)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.lock_outline_rounded,
                                            size: 12,
                                            color: AppTheme.secondaryText(context)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Paiement en ligne sécurisé',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: AppTheme.secondaryText(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (e.isRecurring)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.navy.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.navy.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔁', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  e.recurrenceLabel,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.navyIcon(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!e.isFree)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => CancellationPolicySheet.show(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.policy_outlined,
                                  size: 14, color: AppTheme.ocean),
                              const SizedBox(width: 6),
                              Text(
                                'Politique d\'annulation',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.ocean,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppTheme.ocean,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // === PAST EVENT: Photos, Rating & Tip ===
                  if (e.isPast) ...[
                    const SizedBox(height: 20),
                    if (photos.isNotEmpty) ...[
                      Row(
                        children: [
                          Text(
                            'Photos de l\'activité 📸',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textColor(context),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => AddPhotoSheet(preselectedEventId: e.id),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.ocean.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 16, color: AppTheme.ocean),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ajouter',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.ocean,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: photos.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PhotoGalleryViewer(
                                      photos: photos,
                                      initialIndex: i,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  photos[i].photoUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    width: 100,
                                    height: 100,
                                    color: AppTheme.slateGrey.withValues(alpha: 0.1),
                                    child: Icon(Icons.image_outlined, color: AppTheme.secondaryText(context)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => AddPhotoSheet(preselectedEventId: e.id),
                            );
                          },
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Ajouter des photos de l\'activité'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.ocean,
                            side: const BorderSide(color: AppTheme.ocean),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _RateEventCard(event: e),
                    if (e.isRegistered) ...[
                      const SizedBox(height: 12),
                      _RateMembersCard(event: e),
                    ],
                    if (e.hasOrganizers) ...[
                      const SizedBox(height: 12),
                      _TipOrganizerCard(event: e),
                    ],
                  ],

                  if (!e.isPast && mockWeatherByEventId.containsKey(e.id)) ...[
                    const SizedBox(height: 16),
                    WeatherBadge(forecast: mockWeatherByEventId[e.id]!),
                  ],

                  if (!e.isPast) ...[
                    const SizedBox(height: 16),
                    _RegistrationGauge(event: e),
                  ],

                  // Pace & Distance
                  const SizedBox(height: 12),
                  _StatCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Intensité & Distance',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textColor(context),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            intensityLevelIcon(e.intensityLevel),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.intensityLevel.label,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textColor(context),
                                    ),
                                  ),
                                  Text(
                                    e.intensityLevel.description,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: AppTheme.secondaryText(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            distanceLabelIcon(e.distanceLabel, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.distanceLabel.label,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textColor(context),
                                    ),
                                  ),
                                  Text(
                                    e.distanceLabel.description,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: AppTheme.secondaryText(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- SECTION: Organisateur ou autogéré ---
                  const SizedBox(height: 12),
                  if (e.hasOrganizers)
                    Builder(builder: (_) {
                      final organizers = mockUsers
                          .where((u) => e.organizerIds.contains(u.id))
                          .toList();
                      if (organizers.isEmpty) return const SizedBox.shrink();
                      final label = organizers.length == 1
                          ? 'Organisateur'
                          : 'Organisateurs';
                      final subtitle = organizers.length == 1
                          ? '${organizers.first.firstName} organise cette activité!'
                          : '${organizers.map((o) => o.firstName).join(', ')} organisent cette activité!';
                      return _StatCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shield_rounded, size: 32, color: AppTheme.ocean),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textColor(context),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          color: AppTheme.secondaryText(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: organizers.map((o) {
                                return GestureDetector(
                                  onTap: () => UserProfileSheet.show(context, o),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      UserAvatar(
                                        name: o.firstName,
                                        photoUrl: o.photoUrl,
                                        size: 40,
                                        showRing: false,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        o.firstName,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textColor(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    _StatCard(
                      child: Row(
                        children: [
                          Icon(Icons.groups_rounded, size: 32, color: AppTheme.teal),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Activité autogérée',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textColor(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Le groupe décide ensemble du trajet et du rythme. Pas besoin de leader — on s\'organise sur place!',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: AppTheme.secondaryText(context),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // --- SECTION: Point de départ ---
                  if (!e.isPast && meetingPoint != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      '📍 Point de départ',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (e.registrationStatus == RegistrationStatus.confirmed)
                      MeetingPointCard(meetingPoint: meetingPoint)
                    else
                      _StatCard(
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: AppTheme.secondaryText(context), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'L\'emplacement exact sera indiqué lorsque tu seras sélectionné(e)',
                                style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.secondaryText(context), height: 1.4, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],

                  // --- SECTION: Trajet (future only) ---
                  if (!e.isPast) const SizedBox(height: 12),
                  if (!e.isPast) Builder(builder: (_) {
                    String routeText;
                    if (e.hasOrganizers) {
                      final organizers = mockUsers
                          .where((u) => e.organizerIds.contains(u.id))
                          .toList();
                      final names = organizers.map((o) => o.firstName).join(' et ');
                      routeText = 'Le trajet sera décidé par $names';
                    } else {
                      routeText = 'Le trajet sera décidé ensemble par le groupe sur place';
                    }
                    return _StatCard(
                      child: Row(
                        children: [
                          Icon(Icons.route_rounded, color: AppTheme.teal, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🗺️ Trajet',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textColor(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  routeText,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: AppTheme.textColor(context),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // --- SECTION: Ravito (fin de l'activité) ---
                  if (e.aperoSmoothieSpot != null) ...[
                    const SizedBox(height: 12),
                    _AperoSmoothieCard(
                      spotName: e.aperoSmoothieSpot!,
                      eventTime: e.date,
                    ),
                  ],

                  // --- SECTION: Share & Invite ---
                  const SizedBox(height: 16),
                  _ShareInviteCard(event: e),

                  // Gender breakdown
                  const SizedBox(height: 12),
                  _StatCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Répartition',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textColor(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _GenderRow(
                          icon: Icons.male,
                          iconColor: AppTheme.navyIcon(context),
                          label: 'Hommes',
                          count: e.menCount,
                          percent: menPct,
                        ),
                        const SizedBox(height: 12),
                        _GenderRow(
                          icon: Icons.female,
                          iconColor: AppTheme.ocean,
                          label: 'Femmes',
                          count: e.womenCount,
                          percent: womenPct,
                        ),
                        const SizedBox(height: 12),
                        _GenderRow(
                          icon: Icons.people_outline,
                          iconColor: AppTheme.teal,
                          label: 'Autres',
                          count: e.otherCount,
                          percent: otherPct,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.pets, color: AppTheme.warning, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Toutous', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor(context))),
                            ),
                            Text('3 🐕', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.warning)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Suggest a meeting spot
                  const SizedBox(height: 12),
                  _StatCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('🗺️', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                'Tu connais un endroit le fun pour bouger? Propose-le à notre clan!',
                style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textColor(context), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(builder: (_) => const ContactFormScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.teal,
                              side: BorderSide(color: AppTheme.teal.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Proposer un endroit', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // My group section — only for registered users
                  if (!e.isPast && e.isRegistered) ...[
                    const SizedBox(height: 16),
                    _MyGroupCard(event: e),
                  ],

                  // How it works
                  const SizedBox(height: 32),
                  Text(
                    'Comment ça marche ?',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Column(
                    children: [
                      _HowItWorksStep(number: '1', icon: Icons.edit_outlined, title: 'Inscris-toi', description: 'Choisis ton rythme et découvre avec qui tu vas courir'),
                      const SizedBox(height: 10),
                      _HowItWorksStep(number: '2', icon: Icons.location_on_outlined, title: 'Rendez-vous au point de départ', description: 'On se rejoint tous au même endroit pour partir ensemble'),
                      const SizedBox(height: 10),
                      _HowItWorksStep(number: '3', icon: Icons.directions_run_rounded, title: 'On court!', description: 'On court en duo ou en groupe, à ton rythme — l\'important c\'est la connexion'),
                      const SizedBox(height: 10),
                      _HowItWorksStep(number: '4', icon: Icons.local_cafe_outlined, title: 'L\'Apéro Smoothie', description: 'Après la course, on se retrouve dans un café pour mieux se connaître'),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (e.registrationStatus == RegistrationStatus.confirmed) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final conv = mockConversations.isNotEmpty ? mockConversations.first : null;
                          if (conv != null) {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(builder: (_) => ChatScreen(conversation: conv)),
                            );
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: Text('Messagerie du groupe', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.teal,
                          side: BorderSide(color: AppTheme.teal.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (e.registrationStatus == RegistrationStatus.confirmed) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: e.isPast
                            ? null
                            : () => _showUnsubscribeSheet(context, e),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: Text(
                          'Se désinscrire',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: BorderSide(
                              color: AppTheme.error.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: e.isPast
                            ? null
                            : () {
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (_) => e.isFree
                                        ? ApplyWizardScreen(event: widget.event)
                                        : PaymentCheckoutScreen(event: widget.event),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.ocean,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppTheme.slateGrey.withValues(alpha: 0.35),
                          disabledForegroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'S\'inscrire à cette activité',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Événement ajouté à ton calendrier!',
                              style: GoogleFonts.dmSans(),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Text('📅', style: TextStyle(fontSize: 16)),
                      label: Text(
                        'Ajouter à mon calendrier',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.navyIcon(context),
                        side: BorderSide(
                            color: AppTheme.navy.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 2-tier registration gauge: threshold + capacity
class _RegistrationGauge extends StatelessWidget {
  const _RegistrationGauge({required this.event});
  final KaiEvent event;

  @override
  Widget build(BuildContext context) {
    final total = event.totalRegistered;
    final threshold = event.minThreshold;
    // Progress toward minimum threshold (capped at 100% once confirmed)
    final thresholdProgress = (total / threshold).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Inscriptions',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor(context),
                ),
              ),
              const Spacer(),
              Text(
                '$total inscrits',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Threshold progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.slateGrey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: thresholdProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.teal, AppTheme.teal],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!event.isConfirmed && event.neededForThreshold > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Encore ${event.neededForThreshold} pour confirmer',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warning,
                ),
              ),
            )
          else if (event.isConfirmed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Confirmé! ✅',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.teal,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              intensityLevelIcon(event.intensityLevel, size: 20),
              const SizedBox(width: 8),
              Text(
                'Intensité : ${event.intensitySummary}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryText(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}

class _GenderRow extends StatelessWidget {
  const _GenderRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.count,
    required this.percent,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int count;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor(context),
            ),
          ),
        ),
        Text(
          '$count',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryText(context),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$percent %',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}

class _AperoSmoothieCard extends StatelessWidget {
  const _AperoSmoothieCard({
    required this.spotName,
    required this.eventTime,
  });

  final String spotName;
  final DateTime eventTime;

  String get _estimatedTime {
    final arrival = eventTime.add(const Duration(hours: 1, minutes: 15));
    return '~${arrival.hour}h${arrival.minute.toString().padLeft(2, '0')}';
  }

  void _openMaps() {
    final query = Uri.encodeComponent('$spotName, Montréal');
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/icons/apero_smoothie.png', width: 32, height: 32, errorBuilder: (_, _, _) => const Text('🥤', style: TextStyle(fontSize: 26))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ravito Smoothie',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Peu importe ton groupe, tout le monde se retrouve ici après!',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.secondaryText(context),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.ocean.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.ocean.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_cafe_outlined, size: 20, color: AppTheme.ocean),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        spotName,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule_outlined, size: 16, color: AppTheme.secondaryText(context)),
                    const SizedBox(width: 8),
                    Text(
                      'Arrivée estimée: $_estimatedTime',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openMaps,
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: Text(
                      'Voir sur Google Maps',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.ocean,
                      side: BorderSide(color: AppTheme.ocean.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String number;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.ocean.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppTheme.ocean, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textColor(context)),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.secondaryText(context), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Pace Companions Card — shown only for registered events
// ===========================================================================

class _MyGroupCard extends StatelessWidget {
  const _MyGroupCard({required this.event});
  final KaiEvent event;

  @override
  Widget build(BuildContext context) {
    final companions = mockUsers
        .where((u) =>
            u.activities.any((a) => a.level == event.intensityLevel) &&
            u.id != currentUser.id)
        .take(6)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups_rounded, color: AppTheme.teal, size: 24),
              const SizedBox(width: 10),
              Text(
                'Tes compagnons d\'intensité',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ces personnes bougent au même rythme que toi. Sur place, vous pouvez former des groupes — tout le monde se retrouve au Ravito Smoothie après!',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.secondaryText(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          if (companions.isEmpty)
            Text(
              'Sois le premier à cette intensité! 💪',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
              ),
            )
          else
            Wrap(
              spacing: 14,
              runSpacing: 12,
              children: companions.map((u) {
                return GestureDetector(
                  onTap: () => UserProfileSheet.show(context, u),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserAvatar(
                        name: u.firstName,
                        photoUrl: u.photoUrl,
                        size: 44,
                        showRing: false,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        u.firstName,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColor(context),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _EventCountdown extends StatelessWidget {
  const _EventCountdown({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined,
            size: 16, color: AppTheme.slateGrey.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        if (days > 0) _CountdownSegment(value: days, label: 'j'),
        if (days > 0) _CountdownSeparator(),
        _CountdownSegment(value: hours, label: 'h'),
        _CountdownSeparator(),
        _CountdownSegment(value: minutes, label: 'min'),
        if (days == 0) _CountdownSeparator(),
        if (days == 0) _CountdownSegment(value: seconds, label: 's'),
      ],
    );
  }
}

class _CountdownSegment extends StatelessWidget {
  const _CountdownSegment({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.navyIcon(context),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.secondaryText(context),
          ),
        ),
      ],
    );
  }
}

class _CountdownSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.slateGrey.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _RateEventCard extends StatefulWidget {
  const _RateEventCard({required this.event});
  final KaiEvent event;

  @override
  State<_RateEventCard> createState() => _RateEventCardState();
}

class _RateEventCardState extends State<_RateEventCard> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: AppTheme.teal, size: 24),
              const SizedBox(width: 10),
              Text(
                'Comment c\'était?',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ton avis aide la communauté!',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              return GestureDetector(
                onTap: _submitted ? null : () => setState(() => _rating = starIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 40,
                    color: starIndex <= _rating
                        ? AppTheme.warning
                        : AppTheme.slateGrey.withValues(alpha: 0.4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          if (!_submitted)
            TextField(
              controller: _commentController,
              maxLines: 2,
              style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textColor(context)),
              decoration: InputDecoration(
                hintText: 'Un commentaire? (optionnel)',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.slateGrey.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: AppTheme.cardColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.teal, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitted || _rating == 0
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      setState(() => _submitted = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Merci pour ton avis! 🙏', style: GoogleFonts.dmSans()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.slateGrey.withValues(alpha: 0.25),
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              child: Text(_submitted ? 'Avis envoyé ✓' : 'Envoyer mon avis'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RateMembersCard extends StatefulWidget {
  const _RateMembersCard({required this.event});
  final KaiEvent event;

  @override
  State<_RateMembersCard> createState() => _RateMembersCardState();
}

class _RateMembersCardState extends State<_RateMembersCard> {
  final Map<String, bool> _votes = {};
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final companions = mockUsers
        .where((u) =>
            u.activities.any((a) => a.level == widget.event.intensityLevel) &&
            u.id != currentUser.id)
        .take(6)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: AppTheme.ocean, size: 22),
              const SizedBox(width: 10),
              Text(
                'Tes compagnons de course',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'As-tu passé un bon moment avec eux?',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 16),
          ...companions.map((u) {
            final vote = _votes[u.id];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => UserProfileSheet.show(context, u),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UserAvatar(name: u.firstName, photoUrl: u.photoUrl, size: 40, showRing: false),
                        const SizedBox(width: 12),
                        Text(
                          u.firstName,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _submitted ? null : () => setState(() => _votes[u.id] = true),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: vote == true
                            ? const Color(0xFF00C853).withValues(alpha: 0.12)
                            : AppTheme.slateGrey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.thumb_up_rounded,
                        size: 20,
                        color: vote == true ? const Color(0xFF00C853) : AppTheme.slateGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _submitted ? null : () => setState(() => _votes[u.id] = false),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: vote == false
                            ? AppTheme.error.withValues(alpha: 0.12)
                            : AppTheme.slateGrey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.thumb_down_rounded,
                        size: 20,
                        color: vote == false ? AppTheme.error : AppTheme.slateGrey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitted || _votes.isEmpty
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      setState(() => _submitted = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Merci pour ton feedback! 💪', style: GoogleFonts.dmSans()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ocean,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.slateGrey.withValues(alpha: 0.25),
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              child: Text(_submitted ? 'Envoyé ✓' : 'Envoyer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipOrganizerCard extends StatelessWidget {
  const _TipOrganizerCard({required this.event});
  final KaiEvent event;

  @override
  Widget build(BuildContext context) {
    final organizers = mockUsers
        .where((u) => event.organizerIds.contains(u.id))
        .toList();

    return GestureDetector(
      onTap: () => TipOrganizerSheet.show(context, organizers),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remercie ton organisateur!',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Envoie un petit tip pour dire merci',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareInviteCard extends StatelessWidget {
  const _ShareInviteCard({required this.event});
  final KaiEvent event;

  String get _shareText {
    final day = _frenchWeekday(event.date.weekday);
    final time = '${event.date.hour}h${event.date.minute.toString().padLeft(2, '0')}';
    return 'Viens bouger avec moi! 💪\n\n'
        '${event.neighborhood} — $day $time\n'
        '${event.category.emoji} ${event.category.label} · ${event.intensityLevel.label}\n'
        '${event.distanceLabel.label}\n\n'
        'Inscris-toi sur rundate.app';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline_rounded, color: AppTheme.ocean, size: 22),
              const SizedBox(width: 10),
              Text(
                'Invite tes amis!',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Plus on est, plus c\'est le fun!',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareIcon(
                icon: Icons.camera_alt_outlined,
                label: 'Stories',
                color: const Color(0xFFE1306C),
                onTap: () => Share.share(_shareText),
              ),
              _ShareIcon(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                onTap: () => Share.share(_shareText),
              ),
              _ShareIcon(
                icon: Icons.chat_rounded,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () {
                  final encoded = Uri.encodeComponent(_shareText);
                  launchUrl(
                    Uri.parse('https://wa.me/?text=$encoded'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              _ShareIcon(
                icon: Icons.copy_rounded,
                label: 'Copier',
                color: AppTheme.slateGrey,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'rundate.app'));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lien copié!', style: GoogleFonts.dmSans()),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const InviteFriendScreen()),
                );
              },
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
              label: Text(
                'Envoyer à un ami',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.ocean,
                side: BorderSide(color: AppTheme.ocean.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  const _ShareIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }
}
