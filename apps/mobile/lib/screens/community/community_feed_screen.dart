import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/data/mock_event_photos.dart';
import 'package:rundate/data/mock_events.dart';
import 'package:rundate/data/mock_meeting_points.dart';
import 'package:rundate/models/event_photo.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/widgets/add_photo_sheet.dart';
import 'package:rundate/widgets/photo_gallery_viewer.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final photos = mockEventPhotos.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.cream,
        elevation: 0,
        title: Text(
          'Communauté',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(context),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddPhotoSheet.show(context),
        backgroundColor: AppTheme.teal,
        elevation: 4,
        child: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
      ),
      body: photos.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 56, color: AppTheme.slateGrey.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune photo pour le moment',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: AppTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return _PhotoCard(photo: photos[index]);
              },
            ),
    );
  }
}

class _PhotoCard extends StatefulWidget {
  const _PhotoCard({required this.photo});
  final EventPhoto photo;

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  bool _liked = false;
  late int _likeCount;
  late int _commentCount;

  EventPhoto get photo => widget.photo;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _likeCount = rng.nextInt(13) + 3;
    _commentCount = rng.nextInt(9);
  }

  String _eventLabel() {
    final event = mockEvents.where((e) => e.id == photo.eventId).firstOrNull;
    if (event == null) return '';
    final point = mockMeetingPoints
        .where((p) => p.id == event.meetingPointId)
        .firstOrNull;
    return point != null
        ? '${point.name} · ${event.neighborhood}'
        : event.neighborhood;
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(photo.timestamp);
    if (diff.inDays > 7) return 'il y a ${diff.inDays ~/ 7} sem.';
    if (diff.inDays > 0) return 'il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'il y a ${diff.inHours}h';
    return 'maintenant';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.teal.withValues(alpha: 0.2),
                  child: Text(
                    photo.userName[0],
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.userName,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor(context),
                        ),
                      ),
                      Text(
                        _timeAgo(),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppTheme.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: AppTheme.secondaryText(context),
                  size: 20,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              final eventPhotos = mockEventPhotos
                  .where((p) => p.eventId == photo.eventId)
                  .toList();
              final idx = eventPhotos.indexWhere((p) => p.id == photo.id);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PhotoGalleryViewer(
                    photos: eventPhotos,
                    initialIndex: idx >= 0 ? idx : 0,
                  ),
                ),
              );
            },
            child: ClipRRect(
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  photo.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: AppTheme.slateGrey.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(Icons.image_outlined,
                          size: 40, color: AppTheme.secondaryText(context)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _liked = !_liked;
                          _likeCount += _liked ? 1 : -1;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            _liked ? Icons.favorite : Icons.favorite_border,
                            size: 22,
                            color: _liked ? Colors.red : AppTheme.ocean,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_likeCount',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.navy.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Commentaires — bientôt disponible',
                                style: GoogleFonts.dmSans()),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 20,
                              color: AppTheme.navy.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            '$_commentCount',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.navy.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lien copié!',
                                style: GoogleFonts.dmSans()),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Icon(Icons.share_outlined,
                          size: 20,
                          color: AppTheme.navy.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                if (_eventLabel().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.park_outlined,
                          size: 14, color: AppTheme.teal),
                      const SizedBox(width: 4),
                      Text(
                        _eventLabel(),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppTheme.secondaryText(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                if (photo.description != null && photo.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    photo.description!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.navy.withValues(alpha: 0.8),
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
