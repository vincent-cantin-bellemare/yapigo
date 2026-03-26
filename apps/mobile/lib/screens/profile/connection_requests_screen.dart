import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/data/mock_users.dart';
import 'package:rundate/models/user.dart';
import 'package:rundate/screens/profile/user_profile_sheet.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/widgets/user_avatar.dart';

enum _RequestStatus { pending, accepted, declined }

class _ConnectionRequest {
  _ConnectionRequest({
    required this.user,
    required this.sentAt,
    this.message,
    this.status = _RequestStatus.pending,
  });

  final User user;
  final DateTime sentAt;
  final String? message;
  _RequestStatus status;
}

class ConnectionRequestsScreen extends StatefulWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  State<ConnectionRequestsScreen> createState() =>
      _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final List<_ConnectionRequest> _received;
  late final List<_ConnectionRequest> _sent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final others = mockUsers.where((u) => u.id != currentUser.id).toList();

    _received = [
      _ConnectionRequest(
        user: others[0],
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        message: 'Salut! On s\'est croisés à l\'activité du Plateau, ça te dit?',
      ),
      _ConnectionRequest(
        user: others[1],
        sentAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      _ConnectionRequest(
        user: others.length > 2 ? others[2] : others[0],
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        message: 'Hey! Je cherche un buddy pour le 5K de samedi.',
      ),
      if (others.length > 3)
        _ConnectionRequest(
          user: others[3],
          sentAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
    ];

    _sent = [
      if (others.length > 4)
        _ConnectionRequest(
          user: others[4],
          sentAt: DateTime.now().subtract(const Duration(days: 1)),
          status: _RequestStatus.accepted,
        ),
      _ConnectionRequest(
        user: others.length > 5 ? others[5] : others[0],
        sentAt: DateTime.now().subtract(const Duration(days: 3)),
        status: _RequestStatus.pending,
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _pendingCount =>
      _received.where((r) => r.status == _RequestStatus.pending).length;

  void _acceptRequest(_ConnectionRequest req) {
    HapticFeedback.mediumImpact();
    setState(() => req.status = _RequestStatus.accepted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${req.user.firstName} ajouté(e) à tes connexions!',
            style: GoogleFonts.dmSans()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _declineRequest(_ConnectionRequest req) {
    HapticFeedback.lightImpact();
    setState(() => req.status = _RequestStatus.declined);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demande de ${req.user.firstName} refusée',
            style: GoogleFonts.dmSans()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Connexions',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(context),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.ocean,
          unselectedLabelColor: AppTheme.secondaryText(context),
          indicatorColor: AppTheme.ocean,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle:
              GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
          dividerColor: Colors.transparent,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Reçues'),
                  if (_pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.ocean,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_pendingCount',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Envoyées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedTab(),
          _buildSentTab(),
        ],
      ),
    );
  }

  Widget _buildReceivedTab() {
    if (_received.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline_rounded,
        text: 'Aucune demande de connexion pour le moment',
        subtitle: 'Participe à des activités pour rencontrer du monde!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: _received.length,
      itemBuilder: (context, index) {
        final req = _received[index];
        return _RequestCard(
          request: req,
          onAccept: req.status == _RequestStatus.pending
              ? () => _acceptRequest(req)
              : null,
          onDecline: req.status == _RequestStatus.pending
              ? () => _declineRequest(req)
              : null,
          onTapProfile: () =>
              UserProfileSheet.show(context, req.user),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 80).ms)
            .slideX(begin: 0.05, end: 0, duration: 300.ms, delay: (index * 80).ms);
      },
    );
  }

  Widget _buildSentTab() {
    if (_sent.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_outlined,
        text: 'Aucune demande envoyée',
        subtitle: 'Visite le profil d\'un participant pour envoyer une demande.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: _sent.length,
      itemBuilder: (context, index) {
        final req = _sent[index];
        return _SentRequestCard(
          request: req,
          onTapProfile: () =>
              UserProfileSheet.show(context, req.user),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 80).ms)
            .slideX(begin: 0.05, end: 0, duration: 300.ms, delay: (index * 80).ms);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String text,
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.slateGrey.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppTheme.secondaryText(context)),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.secondaryText(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onTapProfile,
    this.onAccept,
    this.onDecline,
  });

  final _ConnectionRequest request;
  final VoidCallback onTapProfile;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} jours';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == _RequestStatus.pending;
    final isAccepted = request.status == _RequestStatus.accepted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? AppTheme.teal.withValues(alpha: 0.25)
              : AppTheme.slateGrey.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTapProfile,
            child: Row(
              children: [
                UserAvatar(
                  name: request.user.firstName,
                  photoUrl: request.user.photoUrl,
                  isVerified: request.user.isVerified,
                  xp: request.user.xp,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${request.user.firstName}, ${request.user.age}',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textColor(context),
                            ),
                          ),
                          if (request.user.isVerified)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.check_circle,
                                  size: 16, color: AppTheme.teal),
                            ),
                        ],
                      ),
                      Text(
                        '${request.user.city} · ${_timeAgo(request.sentAt)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppTheme.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.slateGrey.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
          if (request.message != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.slateGrey.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded,
                      size: 18,
                      color: AppTheme.slateGrey.withValues(alpha: 0.4)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.message!,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textColor(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.secondaryText(context),
                      side: BorderSide(
                          color: AppTheme.slateGrey.withValues(alpha: 0.25)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                      textStyle: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isAccepted
                    ? AppTheme.teal.withValues(alpha: 0.08)
                    : AppTheme.slateGrey.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAccepted
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    size: 18,
                    color: isAccepted
                        ? AppTheme.teal
                        : AppTheme.secondaryText(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAccepted ? 'Acceptée' : 'Refusée',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isAccepted
                          ? AppTheme.teal
                          : AppTheme.secondaryText(context),
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

class _SentRequestCard extends StatelessWidget {
  const _SentRequestCard({
    required this.request,
    required this.onTapProfile,
  });

  final _ConnectionRequest request;
  final VoidCallback onTapProfile;

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} jours';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == _RequestStatus.pending;
    final isAccepted = request.status == _RequestStatus.accepted;

    return GestureDetector(
      onTap: onTapProfile,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.slateGrey.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            UserAvatar(
              name: request.user.firstName,
              photoUrl: request.user.photoUrl,
              isVerified: request.user.isVerified,
              xp: request.user.xp,
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.user.firstName,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  Text(
                    'Envoyée ${_timeAgo(request.sentAt).toLowerCase()}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isPending
                    ? AppTheme.warning.withValues(alpha: 0.1)
                    : isAccepted
                        ? AppTheme.teal.withValues(alpha: 0.1)
                        : AppTheme.slateGrey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isPending
                    ? 'En attente'
                    : isAccepted
                        ? 'Acceptée'
                        : 'Refusée',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPending
                      ? AppTheme.warning
                      : isAccepted
                          ? AppTheme.teal
                          : AppTheme.secondaryText(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
