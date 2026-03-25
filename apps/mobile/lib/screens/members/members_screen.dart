import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yapigo/data/mock_users.dart';
import 'package:yapigo/models/user.dart';
import 'package:yapigo/models/kai_event.dart';
import 'package:yapigo/screens/profile/user_profile_sheet.dart';
import 'package:yapigo/theme/app_theme.dart';
import 'package:yapigo/widgets/user_avatar.dart';

enum _SortMode { recentActivity, totalActivities }

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  String _search = '';
  String? _filterCity;
  EventCategory? _filterActivity;
  String? _filterGender;
  _SortMode _sort = _SortMode.recentActivity;

  List<User> get _filteredUsers {
    var users = mockUsers.where((u) => u.id != 'u0').toList();

    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      users = users.where((u) => u.firstName.toLowerCase().contains(q)).toList();
    }
    if (_filterCity != null) {
      users = users.where((u) => u.city == _filterCity).toList();
    }
    if (_filterActivity != null) {
      users = users
          .where((u) => u.activities.any((a) => a.category == _filterActivity))
          .toList();
    }
    if (_filterGender != null) {
      users = users.where((u) => u.gender == _filterGender).toList();
    }

    switch (_sort) {
      case _SortMode.totalActivities:
        users.sort((a, b) => b.totalActivities.compareTo(a.totalActivities));
      case _SortMode.recentActivity:
        users.sort(
            (a, b) => b.lastActivityDate?.compareTo(a.lastActivityDate ?? DateTime(0)) ??
                -1);
    }

    return users;
  }

  List<User> get _discoveryUsers {
    final me = currentUser;
    return mockUsers
        .where((u) => u.id != 'u0' && u.hasActivityInCommon(me))
        .take(5)
        .toList();
  }

  static final _cities =
      mockUsers.map((u) => u.city).toSet().toList()..sort();

  void _clearFilters() {
    setState(() {
      _search = '';
      _filterCity = null;
      _filterActivity = null;
      _filterGender = null;
    });
  }

  bool get _hasActiveFilters =>
      _filterCity != null || _filterActivity != null || _filterGender != null;

  List<User> _getSimilarUsers(User target) {
    final targetCategories = target.preferredCategories.toSet();
    final candidates = mockUsers
        .where((u) => u.id != 'u0' && u.id != target.id)
        .where((u) => u.hasActivityInCommon(target))
        .toList();
    candidates.sort((a, b) {
      final aShared = a.preferredCategories.where((c) => targetCategories.contains(c)).length;
      final bShared = b.preferredCategories.where((c) => targetCategories.contains(c)).length;
      if (aShared != bShared) return bShared.compareTo(aShared);
      final aCity = a.city == target.city ? 0 : 1;
      final bCity = b.city == target.city ? 0 : 1;
      return aCity.compareTo(bCity);
    });
    return candidates.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;
    final discovery = _discoveryUsers;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Membres',
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textColor(context),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un membre...',
                    hintStyle: GoogleFonts.dmSans(
                      color: AppTheme.secondaryText(context),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppTheme.secondaryText(context)),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () => setState(() => _search = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.cardColor(context),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: AppTheme.textColor(context),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (_hasActiveFilters)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text('Effacer',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w600)),
                          onPressed: _clearFilters,
                          backgroundColor: AppTheme.error.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    _buildFilterChip(
                      label: _filterGender ?? 'Genre',
                      active: _filterGender != null,
                      onTap: () => _showGenderPicker(),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: _filterCity ?? 'Quartier',
                      active: _filterCity != null,
                      onTap: () => _showCityPicker(),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: _filterActivity?.label ?? 'Sport',
                      active: _filterActivity != null,
                      onTap: () => _showActivityPicker(),
                    ),
                    const SizedBox(width: 8),
                    _buildSortChip(),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            ),

            // Discovery section
            if (discovery.isNotEmpty && _search.isEmpty && !_hasActiveFilters) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 20, color: AppTheme.ocean),
                      const SizedBox(width: 8),
                      Text(
                        'Sports en commun',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textColor(context),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: discovery.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      return _DiscoveryCard(
                        user: discovery[i],
                        onTap: () => UserProfileSheet.show(
                          context,
                          discovery[i],
                          similarUsers: _getSimilarUsers(discovery[i]),
                        ),
                      ).animate().fadeIn(
                            duration: 350.ms,
                            delay: (200 + i * 80).ms,
                          ).slideX(
                            begin: 0.1,
                            end: 0,
                            duration: 350.ms,
                            delay: (200 + i * 80).ms,
                          );
                    },
                  ),
                ),
              ),
            ],

            // Members count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  '${filtered.length} membre${filtered.length > 1 ? 's' : ''}',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryText(context),
                  ),
                ),
              ),
            ),

            // Members list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: AppTheme.slateGrey.withValues(alpha: 0.12),
                ),
                itemBuilder: (context, i) {
                  return _MemberRow(
                    user: filtered[i],
                    onTap: () => UserProfileSheet.show(
                      context,
                      filtered[i],
                      similarUsers: _getSimilarUsers(filtered[i]),
                    ),
                  ).animate().fadeIn(
                        duration: 300.ms,
                        delay: Duration(milliseconds: (100 + i * 40).clamp(100, 600)),
                      );
                },
              ),
            ),

            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 56,
                          color: AppTheme.slateGrey.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun membre trouvé',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: AppTheme.secondaryText(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _clearFilters,
                        child: Text('Effacer les filtres',
                            style: GoogleFonts.dmSans(color: AppTheme.ocean)),
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

  Widget _buildFilterChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.ocean.withValues(alpha: 0.12)
              : AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? AppTheme.ocean
                : AppTheme.slateGrey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? AppTheme.ocean : AppTheme.textColor(context),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: active ? AppTheme.ocean : AppTheme.secondaryText(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip() {
    final labels = {
      _SortMode.recentActivity: 'Récents',
      _SortMode.totalActivities: 'Plus d\'activités',
    };
    return GestureDetector(
      onTap: () {
        final modes = _SortMode.values;
        final next = modes[(modes.indexOf(_sort) + 1) % modes.length];
        setState(() => _sort = next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppTheme.slateGrey.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort_rounded, size: 16, color: AppTheme.secondaryText(context)),
            const SizedBox(width: 6),
            Text(
              labels[_sort]!,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderPicker() {
    _showOptionsPicker(
      title: 'Genre',
      options: ['Homme', 'Femme'],
      selected: _filterGender,
      onSelect: (v) => setState(() => _filterGender = v),
    );
  }

  void _showCityPicker() {
    _showOptionsPicker(
      title: 'Quartier',
      options: _cities,
      selected: _filterCity,
      onSelect: (v) => setState(() => _filterCity = v),
    );
  }

  void _showActivityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.slateGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Sport',
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(ctx))),
            const SizedBox(height: 8),
            ...EventCategory.values.map((cat) => ListTile(
                  leading: Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(cat.label,
                      style: GoogleFonts.dmSans(
                          fontWeight: _filterActivity == cat
                              ? FontWeight.w700
                              : FontWeight.w500)),
                  trailing: _filterActivity == cat
                      ? const Icon(Icons.check_circle,
                          color: AppTheme.ocean, size: 22)
                      : null,
                  onTap: () {
                    setState(() =>
                        _filterActivity = _filterActivity == cat ? null : cat);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showOptionsPicker({
    required String title,
    required List<String> options,
    required String? selected,
    required void Function(String?) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.slateGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(ctx))),
            const SizedBox(height: 8),
            ...options.map((o) => ListTile(
                  title: Text(o,
                      style: GoogleFonts.dmSans(
                          fontWeight:
                              selected == o ? FontWeight.w700 : FontWeight.w500)),
                  trailing: selected == o
                      ? const Icon(Icons.check_circle,
                          color: AppTheme.ocean, size: 22)
                      : null,
                  onTap: () {
                    onSelect(selected == o ? null : o);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({required this.user, required this.onTap});
  final User user;
  final VoidCallback onTap;

  bool get _isOnline {
    if (user.lastSeenDate == null) return false;
    return DateTime.now().difference(user.lastSeenDate!).inHours < 24;
  }

  bool get _hasPhoto => user.photoUrl != null && user.photoUrl!.isNotEmpty;

  String get _initial =>
      user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    const photoHeight = 130.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.slateGrey.withValues(alpha: 0.12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: photoHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_hasPhoto)
                    Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholderPhoto(),
                    )
                  else
                    _placeholderPhoto(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                      child: Text(
                        '${user.firstName}, ${user.age}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                                blurRadius: 4, color: Colors.black45)
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (user.isVerified)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.verified_rounded,
                          size: 18, color: Colors.white),
                    ),
                  if (_isOnline)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.teal,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 12,
                            color: AppTheme.secondaryText(context)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            user.neighborhood ?? user.city,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppTheme.secondaryText(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (user.activities.isNotEmpty)
                      Text(
                        user.activities.map((a) => a.category.emoji).join(' '),
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _placeholderPhoto() {
    final colors = [
      AppTheme.ocean,
      AppTheme.teal,
      AppTheme.teal,
      AppTheme.warning,
      const Color(0xFF7B8FD4),
      AppTheme.error,
    ];
    final color = colors[user.firstName.hashCode.abs() % colors.length];
    return Container(
      color: color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: GoogleFonts.nunito(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.user, required this.onTap});
  final User user;
  final VoidCallback onTap;

  bool get _isOnline {
    if (user.lastSeenDate == null) return false;
    return DateTime.now().difference(user.lastSeenDate!).inHours < 24;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              name: user.firstName,
              photoUrl: user.photoUrl,
              size: 72,
              isVerified: user.isVerified,
              xp: user.xp,
              showRing: true,
              isOnline: _isOnline,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${user.firstName}, ${user.age}',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            size: 16, color: AppTheme.teal),
                      ],
                      const SizedBox(width: 6),
                      Text(user.badge.icon,
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 14,
                          color: AppTheme.secondaryText(context)),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          user.neighborhood ?? user.city,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppTheme.secondaryText(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (user.activities.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      user.activities.map((a) => a.category.emoji).join(' '),
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${user.totalActivities} activité${user.totalActivities > 1 ? 's' : ''}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.secondaryText(context),
                        ),
                      ),
                      if (user.averageRating != null) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppTheme.warning),
                        const SizedBox(width: 2),
                        Text(
                          user.averageRating!.toStringAsFixed(1),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warning,
                          ),
                        ),
                      ],
                      if (user.isOrganizer) ...[
                        const SizedBox(width: 8),
                        _OrganizerBadge(),
                      ],
                    ],
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '« ${user.bio!} »',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.secondaryText(context)
                            .withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 20,
                color: AppTheme.slateGrey.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _OrganizerBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, size: 12, color: AppTheme.ocean),
          const SizedBox(width: 3),
          Text(
            'Organisateur',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.teal,
            ),
          ),
        ],
      ),
    );
  }
}
