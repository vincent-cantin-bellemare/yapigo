import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yapigo/models/meeting_point.dart';
import 'package:yapigo/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingPointCard extends StatelessWidget {
  const MeetingPointCard({
    super.key,
    required this.meetingPoint,
    this.showMapButton = true,
  });

  final MeetingPoint meetingPoint;
  final bool showMapButton;

  Future<void> _openMaps() async {
    final url = meetingPoint.mapsUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    meetingPoint.typeEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meetingPoint.name,
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.navy,
                      ),
                    ),
                    Text(
                      meetingPoint.address,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.slateGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  meetingPoint.typeLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.teal,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.navy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  meetingPoint.neighborhood,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.navyIcon(context),
                  ),
                ),
              ),
            ],
          ),
          if (meetingPoint.description != null) ...[
            const SizedBox(height: 12),
            Text(
              meetingPoint.description!,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                height: 1.4,
                color: AppTheme.navy.withValues(alpha: 0.85),
              ),
            ),
          ],
          if (showMapButton && meetingPoint.mapsUrl != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Voir sur la carte'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.navyIcon(context),
                  side: BorderSide(color: AppTheme.navy.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
