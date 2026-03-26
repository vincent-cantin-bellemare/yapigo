import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/data/mock_events.dart';
import 'package:rundate/data/mock_weather.dart';
import 'package:rundate/models/kai_event.dart';
import 'package:rundate/models/user.dart';
import 'package:rundate/screens/events/event_detail_screen.dart';
import 'package:rundate/screens/profile/contact_form_screen.dart';
import 'package:rundate/data/mock_users.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/utils/neighborhood_assets.dart';
import 'package:rundate/widgets/user_avatar.dart';
import 'package:rundate/widgets/pace_label_icon.dart' show intensityLevelIcon;
import 'package:rundate/widgets/weather_badge.dart';

String _formatOrganizerNames(List<User> organizers) {
  if (organizers.isEmpty) return '';
  if (organizers.length == 1) return organizers.first.firstName;
  if (organizers.length == 2) {
    return '${organizers[0].firstName} et ${organizers[1].firstName}';
  }
  final extra = organizers.length - 2;
  return '${organizers[0].firstName}, ${organizers[1].firstName} '
      'et $extra autre${extra > 1 ? 's' : ''}';
}

String _frenchDate(DateTime dt) {
  const days = [
    '', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
  ];
  const months = [
    '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];
  return '${days[dt.weekday]} ${dt.day} ${months[dt.month]}';
}

String _formatCountdown(KaiEvent event) {
  final d = event.timeUntilDeadline;
  if (event.isDeadlinePassed || d.isNegative) return 'Inscriptions closes';
  final days = d.inDays;
  final hours = d.inHours.remainder(24);
  final minutes = d.inMinutes.remainder(60);
  return '${days}j ${hours}h ${minutes}min';
}


class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

enum _DayFilter { all, saturday, sunday, weekday }
enum _SortMode { dateAsc, spotsDesc }

class _EventsListScreenState extends State<EventsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _tick;
  bool _showMap = false;
  _DayFilter _dayFilter = _DayFilter.all;
  String? _neighborhoodFilter;
  _SortMode _sortMode = _SortMode.dateAsc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tick = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tick?.cancel();
    super.dispose();
  }

  List<KaiEvent> _applyFilters(List<KaiEvent> events) {
    var filtered = events.toList();

    if (_dayFilter != _DayFilter.all) {
      filtered = filtered.where((e) {
        return switch (_dayFilter) {
          _DayFilter.saturday => e.date.weekday == DateTime.saturday,
          _DayFilter.sunday => e.date.weekday == DateTime.sunday,
          _DayFilter.weekday => e.date.weekday < DateTime.saturday,
          _DayFilter.all => true,
        };
      }).toList();
    }

    if (_neighborhoodFilter != null) {
      filtered = filtered
          .where((e) => e.neighborhood == _neighborhoodFilter)
          .toList();
    }

    if (_sortMode == _SortMode.spotsDesc) {
      filtered.sort((a, b) => b.totalRegistered.compareTo(a.totalRegistered));
    } else {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    }

    return filtered;
  }

  List<KaiEvent> get _upcomingRaw =>
      mockEvents.where((e) => !e.isPast && e.registrationStatus == RegistrationStatus.notRegistered).toList();

  List<KaiEvent> get _upcoming => _applyFilters(_upcomingRaw);

  List<String> get _availableNeighborhoods =>
      _upcomingRaw.map((e) => e.neighborhood).toSet().toList()..sort();

  List<KaiEvent> get _registered =>
      mockEvents.where((e) => e.registrationStatus != RegistrationStatus.notRegistered && !e.isPast).toList();

  List<KaiEvent> get _past =>
      mockEvents.where((e) => e.isPast && e.registrationStatus != RegistrationStatus.notRegistered).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  bool get _hasActiveFilters =>
      _dayFilter != _DayFilter.all || _neighborhoodFilter != null;

  void _resetFilters() => setState(() {
        _dayFilter = _DayFilter.all;
        _neighborhoodFilter = null;
        _sortMode = _SortMode.dateAsc;
      });

  @override
  Widget build(BuildContext context) {
    final nextEventDate =
        _upcoming.isNotEmpty ? _upcoming.first.date : DateTime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Événements',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _frenchDate(nextEventDate),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                _showMap ? Icons.list_rounded : Icons.map_outlined,
                key: ValueKey(_showMap),
                color: AppTheme.textColor(context),
                size: 24,
              ),
            ),
            tooltip: _showMap ? 'Vue liste' : 'Vue carte',
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.cardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.slateGrey.withValues(alpha: 0.15)),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppTheme.ocean,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textColor(context),
                labelStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                labelPadding: EdgeInsets.zero,
                padding: const EdgeInsets.all(2),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Prochains'),
                        if (_upcoming.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          _CountChip(
                            count: _upcoming.length,
                            active: _tabController.index == 0,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Inscrits'),
                        if (_registered.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          _CountChip(
                            count: _registered.length,
                            active: _tabController.index == 1,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: 'Passés'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (!_showMap && _tabController.index == 0) _buildFilterBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _showMap
                  ? _EventMapView(
                      key: const ValueKey('map'),
                      events: _upcoming,
                    )
                  : TabBarView(
                      key: const ValueKey('list'),
                      controller: _tabController,
                      children: [
                        _EventList(
                          events: _upcoming,
                          emptyIcon: Icons.event_available,
                          emptyText: _hasActiveFilters
                              ? 'Aucun événement ne correspond à tes filtres.'
                              : 'Aucun événement à venir pour le moment.',
                        ),
                        _EventList(
                          events: _registered,
                          emptyIcon: Icons.how_to_reg,
                          emptyText:
                              'Tu n\'es inscrit à aucun événement.\nChoisis un quartier dans « Prochains » !',
                          showRegisteredBadge: true,
                        ),
                        _PastEventList(events: _past),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    const dayLabels = {
      _DayFilter.all: 'Tous',
      _DayFilter.saturday: 'Sam.',
      _DayFilter.sunday: 'Dim.',
      _DayFilter.weekday: 'Soir sem.',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...dayLabels.entries.map((entry) {
                  final isActive = _dayFilter == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(entry.value),
                      selected: isActive,
                      onSelected: (_) =>
                          setState(() => _dayFilter = isActive ? _DayFilter.all : entry.key),
                      selectedColor: AppTheme.ocean.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.ocean,
                      backgroundColor: AppTheme.cardColor(context),
                      side: BorderSide(
                        color: isActive
                            ? AppTheme.ocean
                            : AppTheme.slateGrey.withValues(alpha: 0.2),
                      ),
                      labelStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? AppTheme.ocean : AppTheme.textColor(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
                const SizedBox(width: 4),
                PopupMenuButton<String?>(
                  onSelected: (v) => setState(() => _neighborhoodFilter = v),
                  itemBuilder: (_) => [
                    PopupMenuItem<String?>(
                      value: null,
                      child: Text(
                        'Tous les quartiers',
                        style: GoogleFonts.dmSans(
                          fontWeight: _neighborhoodFilter == null
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    ..._availableNeighborhoods.map(
                      (n) => PopupMenuItem<String?>(
                        value: n,
                        child: Text(
                          n,
                          style: GoogleFonts.dmSans(
                            fontWeight: _neighborhoodFilter == n
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                  child: Chip(
                    label: Text(
                      _neighborhoodFilter ?? 'Quartier',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: _neighborhoodFilter != null
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _neighborhoodFilter != null
                            ? AppTheme.navyIcon(context)
                            : AppTheme.textColor(context),
                      ),
                    ),
                    avatar: Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: _neighborhoodFilter != null
                          ? AppTheme.navyIcon(context)
                          : AppTheme.slateGrey,
                    ),
                    backgroundColor: _neighborhoodFilter != null
                        ? AppTheme.navy.withValues(alpha: 0.1)
                        : AppTheme.cardColor(context),
                    side: BorderSide(
                      color: _neighborhoodFilter != null
                          ? AppTheme.navy
                          : AppTheme.slateGrey.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<_SortMode>(
                  onSelected: (v) => setState(() => _sortMode = v),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _SortMode.dateAsc,
                      child: Text(
                        'Date ↑',
                        style: GoogleFonts.dmSans(
                          fontWeight: _sortMode == _SortMode.dateAsc
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: _SortMode.spotsDesc,
                      child: Text(
                        'Popularité ↓',
                        style: GoogleFonts.dmSans(
                          fontWeight: _sortMode == _SortMode.spotsDesc
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                  child: Chip(
                    label: Text(
                      _sortMode == _SortMode.dateAsc ? 'Date ↑' : 'Pop. ↓',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    avatar: Icon(Icons.sort, size: 16, color: AppTheme.secondaryText(context)),
                    backgroundColor: AppTheme.cardColor(context),
                    side: BorderSide(
                      color: AppTheme.slateGrey.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                if (_hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: AppTheme.error),
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

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count, required this.active});
  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: active
            ? Colors.white.withValues(alpha: 0.3)
            : AppTheme.ocean.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: active ? Colors.white : AppTheme.ocean,
        ),
      ),
    );
  }
}

// Approximate positions for Montreal neighborhoods on the simulated map
const _neighborhoodPositions = <String, Offset>{
  'Plateau Mont-Royal': Offset(0.55, 0.35),
  'Mile-End': Offset(0.50, 0.25),
  'Griffintown': Offset(0.40, 0.55),
  'Vieux-Montréal': Offset(0.45, 0.65),
  'Hochelaga': Offset(0.70, 0.50),
  'Villeray': Offset(0.45, 0.15),
  'Rosemont': Offset(0.60, 0.20),
  'Saint-Henri': Offset(0.30, 0.50),
  'Verdun': Offset(0.30, 0.70),
  'Le Sud-Ouest': Offset(0.35, 0.60),
};

class _EventMapView extends StatelessWidget {
  const _EventMapView({super.key, required this.events});
  final List<KaiEvent> events;

  Offset _positionFor(String neighborhood) {
    return _neighborhoodPositions[neighborhood] ??
        Offset(0.5 + (neighborhood.hashCode % 20 - 10) / 50,
            0.4 + (neighborhood.hashCode % 30 - 15) / 50);
  }

  void _showEventSheet(BuildContext context, KaiEvent event) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor(ctx),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    event.neighborhood,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textColor(ctx),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.city,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(event.category.emoji,
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        event.category.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryText(ctx),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SheetInfoChip(
                          icon: Icons.people_outline,
                          label: '${event.totalRegistered} inscrits',
                          color: AppTheme.navyIcon(context),
                        ),
                        _SheetInfoChip(
                          icon: Icons.fitness_center,
                          label: event.intensitySummary,
                          labelPrefix: intensityLevelIcon(event.intensityLevel),
                          color: AppTheme.teal,
                        ),
                        _SheetInfoChip(
                          icon: Icons.straighten,
                          label: event.distanceSummary,
                          color: AppTheme.secondaryText(context),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  // Gender ratio bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          Expanded(
                            flex: (event.menRatio * 100).round().clamp(1, 100),
                            child: Container(color: AppTheme.navy),
                          ),
                          Expanded(
                            flex:
                                (event.womenRatio * 100).round().clamp(1, 100),
                            child: Container(color: AppTheme.ocean),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${event.menCount} hommes',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.navyIcon(context),
                        ),
                      ),
                      Text(
                        '${event.womenCount} femmes',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ocean,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatCountdown(event),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warning,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ocean,
                      foregroundColor: Colors.white,
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
                    child: const Text('Voir le détail'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE8EDF2),
              const Color(0xFFD9E2EC),
              const Color(0xFFCFD8E3),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navy.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Subtle grid pattern
            CustomPaint(
              size: Size.infinite,
              painter: _MapGridPainter(),
            ),

            // "Montréal" title
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_city,
                          size: 16, color: AppTheme.navyIcon(context)),
                      const SizedBox(width: 6),
                      Text(
                        'Montréal',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navyIcon(context),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.3, end: 0, duration: 400.ms),
            ),

            // Decorative "river" line (Saint-Laurent)
            Positioned.fill(
              child: CustomPaint(
                painter: _RiverPainter(),
              ),
            ),

            // Event markers
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return Stack(
                  children: [
                    for (var i = 0; i < events.length; i++)
                      Builder(
                        builder: (context) {
                          final event = events[i];
                          final pos = _positionFor(event.neighborhood);
                          final markerW = 140.0;
                          final markerH = 42.0;

                          final left =
                              (pos.dx * w - markerW / 2).clamp(4.0, w - markerW - 4);
                          final top =
                              (pos.dy * h - markerH / 2).clamp(44.0, h - markerH - 4);

                          return Positioned(
                            left: left,
                            top: top,
                            child: GestureDetector(
                              onTap: () => _showEventSheet(context, event),
                              child: _MapMarker(event: event),
                            )
                                .animate()
                                .fadeIn(
                                  delay: (80 * i).ms,
                                  duration: 350.ms,
                                )
                                .scale(
                                  begin: const Offset(0.6, 0.6),
                                  end: const Offset(1, 1),
                                  delay: (80 * i).ms,
                                  duration: 350.ms,
                                  curve: Curves.easeOutBack,
                                ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),

            // Bottom legend
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: AppTheme.ocean, label: 'Ouvert'),
                  const SizedBox(width: 16),
                  _LegendDot(color: AppTheme.teal, label: 'Confirmé'),
                ],
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 300.ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.event});
  final KaiEvent event;

  @override
  Widget build(BuildContext context) {
    final color = event.isConfirmed ? AppTheme.teal : AppTheme.ocean;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              event.neighborhood,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '${event.totalRegistered}',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(width: 1),
          Icon(Icons.people, size: 11, color: AppTheme.secondaryText(context)),
        ],
      ),
    );
  }
}

class _SheetInfoChip extends StatelessWidget {
  const _SheetInfoChip({
    required this.icon,
    required this.label,
    required this.color,
    this.labelPrefix,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Widget? labelPrefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          if (labelPrefix != null) ...[
            labelPrefix!,
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
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

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Subtle dots at intersections
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RiverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF90B4CE).withValues(alpha: 0.25)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.72,
        size.width * 0.55,
        size.height * 0.82,
        size.width,
        size.height * 0.76,
      );
    canvas.drawPath(path, paint);

    // Thinner secondary line
    final paint2 = Paint()
      ..color = const Color(0xFF90B4CE).withValues(alpha: 0.15)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path2 = Path()
      ..moveTo(0, size.height * 0.82)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.77,
        size.width * 0.6,
        size.height * 0.86,
        size.width,
        size.height * 0.80,
      );
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EventList extends StatelessWidget {
  const _EventList({
    required this.events,
    required this.emptyIcon,
    required this.emptyText,
    this.showRegisteredBadge = false,
  });

  final List<KaiEvent> events;
  final IconData emptyIcon;
  final String emptyText;
  final bool showRegisteredBadge;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/empty/no_events.png',
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) => Icon(emptyIcon, size: 64, color: AppTheme.ocean.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 16),
              Text(
                emptyText,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppTheme.secondaryText(context),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.ocean,
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 800));
      },
      child: ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: events.length + 1,
      itemBuilder: (context, index) {
        if (index == events.length) {
          return _SuggestLocationBlock();
        }
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _EventCard(
            event: event,
            countdownLabel: _formatCountdown(event),
            showRegisteredBadge: showRegisteredBadge,
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => EventDetailScreen(event: event),
                ),
              );
            },
          ),
        );
      },
    ),
    );
  }
}

class _SuggestLocationBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.teal.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            'Tu as un endroit magique à proposer?',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Propose un endroit où tu aimerais bouger! Notre équipe évalue toutes les suggestions.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const ContactFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_location_alt_outlined, size: 18),
              label: Text(
                'Proposer un endroit',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.teal,
                side: BorderSide(color: AppTheme.teal.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _PastEventList extends StatelessWidget {
  const _PastEventList({required this.events});
  final List<KaiEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64,
                  color: AppTheme.slateGrey.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'Aucune activité passée.\nInscris-toi à un événement Run Date pour commencer!',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppTheme.secondaryText(context),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PastEventCard(event: event),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.countdownLabel,
    required this.onTap,
    this.showRegisteredBadge = false,
  });

  final KaiEvent event;
  final String countdownLabel;
  final VoidCallback onTap;
  final bool showRegisteredBadge;

  @override
  Widget build(BuildContext context) {
    final menFlex = (event.menRatio * 1000).round().clamp(1, 1000);
    final womenFlex = (event.womenRatio * 1000).round().clamp(1, 1000);

    return Material(
      color: AppTheme.cardColor(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: showRegisteredBadge
                  ? AppTheme.teal.withValues(alpha: 0.4)
                  : AppTheme.slateGrey.withValues(alpha: 0.2),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeighborhoodBanner(
                neighborhood: event.neighborhood,
                height: 140,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.neighborhood,
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textColor(context),
                            ),
                          ),
                        ),
                        if (showRegisteredBadge)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.teal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 14,
                                    color: AppTheme.teal),
                                const SizedBox(width: 4),
                                Text(
                                  'Inscrit',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.secondaryText(context)),
                  const SizedBox(width: 6),
                  Text(
                    '${_frenchDate(event.date)} à ${event.date.hour}h${event.date.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    event.category.emoji,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    event.category.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final orgUsers = event.organizerIds
                      .map((id) => mockUsers.cast<User?>().firstWhere(
                            (u) => u!.id == id,
                            orElse: () => null,
                          ))
                      .whereType<User>()
                      .toList();
                  if (orgUsers.isEmpty) return const SizedBox.shrink();
                  final names = _formatOrganizerNames(orgUsers);
                  return Row(
                    children: [
                      SizedBox(
                        width: orgUsers.length > 1
                            ? 22.0 + (orgUsers.length - 1).clamp(0, 1) * 12.0
                            : 22.0,
                        height: 22,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            for (var i = 0; i < orgUsers.length.clamp(0, 2); i++)
                              Positioned(
                                left: i * 12.0,
                                child: UserAvatar(
                                  name: orgUsers[i].firstName,
                                  photoUrl: orgUsers[i].photoUrl,
                                  size: 22,
                                  showRing: false,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Organisé par $names',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppTheme.secondaryText(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.people_outline, size: 20, color: AppTheme.navyIcon(context)),
                  const SizedBox(width: 6),
                  Text(
                    '${event.totalRegistered} inscrits',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: event.isFree
                          ? AppTheme.teal.withValues(alpha: 0.12)
                          : AppTheme.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.priceLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: event.isFree ? AppTheme.teal : AppTheme.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${event.menCount}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.navyIcon(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 10,
                        child: Row(
                          children: [
                            Expanded(
                              flex: menFlex,
                              child: Container(color: AppTheme.navy),
                            ),
                            Expanded(
                              flex: womenFlex,
                              child: Container(color: AppTheme.ocean),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${event.womenCount}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ocean,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      countdownLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warning,
                      ),
                    ),
                  ),
                  if (mockWeatherByEventId.containsKey(event.id))
                    WeatherBadge(
                      forecast: mockWeatherByEventId[event.id]!,
                      compact: true,
                    ),
                ],
              ),
              if (mockWeatherByEventId.containsKey(event.id)) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: mockWeatherByEventId[event.id]!.isGoodForRun
                        ? AppTheme.teal.withValues(alpha: 0.08)
                        : AppTheme.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    mockWeatherByEventId[event.id]!.weatherTipShort,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                ),
              ],
              
              // Ravito Smoothie note
              if (event.aperoSmoothieSpot != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/apero_smoothie.png',
                      width: 22,
                      height: 22,
                      errorBuilder: (_, _, _) =>
                          const Text('🥤', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: event.aperoSmoothieSpot!,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor(context),
                            ),
                          ),
                          TextSpan(
                            text: ' · Tous les groupes se retrouvent ici après!',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppTheme.secondaryText(context),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
              
            ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastEventCard extends StatelessWidget {
  const _PastEventCard({required this.event});
  final KaiEvent event;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardColor(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => EventDetailScreen(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeighborhoodBanner(
                neighborhood: event.neighborhood,
                height: 140,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.neighborhood,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textColor(context),
                        ),
                      ),
                    ),
                    if (event.myRating != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: AppTheme.warning),
                            const SizedBox(width: 4),
                            Text(
                              event.myRating!.toStringAsFixed(1),
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16,
                        color: AppTheme.secondaryText(context)),
                    const SizedBox(width: 6),
                    Text(
                      '${_frenchDate(event.date)} à ${event.date.hour}h${event.date.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(event.category.emoji,
                        style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      event.category.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final orgUsers = event.organizerIds
                        .map((id) => mockUsers.cast<User?>().firstWhere(
                              (u) => u!.id == id,
                              orElse: () => null,
                            ))
                        .whereType<User>()
                        .toList();
                    if (orgUsers.isEmpty) return const SizedBox.shrink();
                    final names = _formatOrganizerNames(orgUsers);
                    return Row(
                      children: [
                        SizedBox(
                          width: orgUsers.length > 1
                              ? 22.0 + (orgUsers.length - 1).clamp(0, 1) * 12.0
                              : 22.0,
                          height: 22,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              for (var i = 0; i < orgUsers.length.clamp(0, 2); i++)
                                Positioned(
                                  left: i * 12.0,
                                  child: UserAvatar(
                                    name: orgUsers[i].firstName,
                                    photoUrl: orgUsers[i].photoUrl,
                                    size: 22,
                                    showRing: false,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Organisé par $names',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppTheme.secondaryText(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.people_outline,
                        size: 18, color: AppTheme.secondaryText(context)),
                    const SizedBox(width: 6),
                    Text(
                      '${event.totalRegistered} participants',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: event.isFree
                            ? AppTheme.teal.withValues(alpha: 0.12)
                            : AppTheme.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.priceLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: event.isFree ? AppTheme.teal : AppTheme.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

