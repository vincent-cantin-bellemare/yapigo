import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaiiak/data/mock_event_photos.dart';
import 'package:kaiiak/data/mock_events.dart';
import 'package:kaiiak/data/mock_users.dart';
import 'package:kaiiak/models/kai_event.dart';
import 'package:kaiiak/models/user.dart';
import 'package:kaiiak/screens/events/rate_event_screen.dart';
import 'package:kaiiak/screens/profile/user_profile_sheet.dart';
import 'package:kaiiak/theme/app_theme.dart';
import 'package:kaiiak/widgets/add_photo_sheet.dart';
import 'package:kaiiak/widgets/like_message_sheet.dart';
import 'package:kaiiak/widgets/photo_gallery_viewer.dart';
import 'package:kaiiak/widgets/user_avatar.dart';

class RunHistoryScreen extends StatelessWidget {
  const RunHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pastEvents = mockEvents
        .where((e) => e.isPast && e.isRegistered)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Historique d\'activités',
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context))),
      ),
      body: pastEvents.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history,
                        size: 64,
                        color: AppTheme.slateGrey.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune activité passée pour le moment.\nInscris-toi à un événement!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: AppTheme.secondaryText(context),
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: pastEvents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _HistoryCard(
                  event: pastEvents[index],
                  members: mockUsers.take(6).toList(),
                );
              },
            ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  const _HistoryCard({
    required this.event,
    required this.members,
  });

  final KaiEvent event;
  final List<User> members;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  final Set<String> _likedUserIds = {};

  String _frenchDate(DateTime dt) {
    const months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  void _goToRate() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RateEventScreen(event: widget.event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final members = widget.members;
    final photos =
        mockEventPhotos.where((p) => p.eventId == event.id).toList();
    const maxVisible = 5;
    final visiblePhotos = photos.take(maxVisible).toList();
    final extraCount = photos.length - maxVisible;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${event.category.emoji} ${event.neighborhood}',
                        style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textColor(context))),
                    const SizedBox(height: 4),
                    Text(_frenchDate(event.date),
                        style: GoogleFonts.dmSans(
                            fontSize: 14, color: AppTheme.secondaryText(context))),
                  ],
                ),
              ),
              if (event.myRating != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 18, color: AppTheme.warning),
                      const SizedBox(width: 4),
                      Text(
                        event.myRating!.toStringAsFixed(1),
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.warning),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (event.myRating != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _goToRate,
                icon: Icon(Icons.edit_outlined,
                    size: 16, color: AppTheme.ocean),
                label: Text(
                  'Modifier la note',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ocean,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text('Membres du groupe',
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryText(context))),
          const SizedBox(height: 10),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final u = members[i];
                final liked = _likedUserIds.contains(u.id);
                return Column(
                  children: [
                    UserAvatar(
                      name: u.firstName,
                      photoUrl: u.photoUrl,
                      isVerified: u.isVerified,
                      xp: u.xp,
                      size: 32,
                      showRing: true,
                      onTap: () => UserProfileSheet.show(context, u),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(u.firstName,
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: AppTheme.secondaryText(context))),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTap: () {
                            if (liked) {
                              setState(() => _likedUserIds.remove(u.id));
                              return;
                            }
                            showLikeMessageBottomSheet(
                              context,
                              firstName: u.firstName,
                              onSend: () {
                                setState(() => _likedUserIds.add(u.id));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Demande envoyée à ${u.firstName}!',
                                      style: GoogleFonts.dmSans(),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration:
                                        const Duration(milliseconds: 1500),
                                  ),
                                );
                              },
                            );
                          },
                          child: Icon(
                            liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            size: 14,
                            color: liked
                                ? AppTheme.error
                                : AppTheme.slateGrey.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Photos de l\'activité',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryText(context),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => AddPhotoSheet.show(
                  context,
                  eventId: event.id,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        size: 14, color: AppTheme.teal),
                    const SizedBox(width: 4),
                    Text(
                      'Ajouter',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (photos.isNotEmpty)
            Row(
              children: [
                for (var i = 0; i < visiblePhotos.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  if (i == visiblePhotos.length - 1 && extraCount > 0)
                    GestureDetector(
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
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              visiblePhotos[i].photoUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.navy.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '+$extraCount',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GestureDetector(
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
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          visiblePhotos[i].photoUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
