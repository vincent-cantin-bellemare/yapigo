import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rundate/data/mock_messages.dart';
import 'package:rundate/data/mock_notifications.dart';
import 'package:rundate/screens/home/home_screen.dart';
import 'package:rundate/screens/events/events_list_screen.dart';
import 'package:rundate/screens/members/members_screen.dart';
import 'package:rundate/screens/activity/activity_screen.dart';
import 'package:rundate/screens/profile/profile_screen.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/widgets/frosted_container.dart';

const double _kNavBarHeight = 64;

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTabIndex = 0});

  /// Bottom nav index: 0 home, 1 events, 2 members, 3 activity, 4 profile.
  final int initialTabIndex;

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  void switchTab(int index) {
    setState(() => _currentIndex = index.clamp(0, 4));
  }

  late int _currentIndex;
  bool _isNavVisible = true;
  late final AnimationController _navAnim;
  late final Animation<double> _navHeight;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex.clamp(0, 4);
    _navAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _navHeight = CurvedAnimation(
      parent: _navAnim,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _navAnim.dispose();
    super.dispose();
  }

  final _screens = const [
    HomeScreen(),
    EventsListScreen(),
    MembersScreen(),
    ActivityScreen(),
    ProfileScreen(),
  ];

  int get _unreadNotifications =>
      mockNotifications.where((n) => !n.isRead).length;

  int get _unreadMessages {
    var count = 0;
    for (final c in mockConversations) {
      if (c.messages.isNotEmpty && c.messages.last.senderId != 'current') {
        count++;
      }
    }
    return count;
  }

  void _showNav() {
    if (!_isNavVisible) {
      _isNavVisible = true;
      _navAnim.forward();
    }
  }

  bool _onScrollNotification(UserScrollNotification notification) {
    final direction = notification.direction;
    if (direction == ScrollDirection.reverse && _isNavVisible) {
      _isNavVisible = false;
      _navAnim.reverse();
    } else if (direction == ScrollDirection.forward && !_isNavVisible) {
      _showNav();
    } else if (direction == ScrollDirection.idle && !_isNavVisible) {
      _showNav();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<UserScrollNotification>(
            onNotification: _onScrollNotification,
            child: AnimatedBuilder(
              animation: _navHeight,
              builder: (ctx, child) {
                final mq = MediaQuery.of(ctx);
                final extra = _kNavBarHeight * _navHeight.value;
                return MediaQuery(
                  data: mq.copyWith(
                    padding: mq.padding.copyWith(
                      bottom: mq.padding.bottom + extra,
                    ),
                    viewPadding: mq.viewPadding.copyWith(
                      bottom: mq.viewPadding.bottom + extra,
                    ),
                  ),
                  child: child!,
                );
              },
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              offset: _isNavVisible ? Offset.zero : const Offset(0, 1),
              child:               _CustomBottomNav(
                currentIndex: _currentIndex,
                onTap: (i) {
                  _showNav();
                  setState(() => _currentIndex = i);
                },
                activityBadge: _unreadMessages + _unreadNotifications,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom frosted-glass bottom navigation bar — icons only, peach dot indicator
// ---------------------------------------------------------------------------

class _CustomBottomNav extends StatelessWidget {
  const _CustomBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.activityBadge,
  });

  final int currentIndex;
  final void Function(int) onTap;
  final int activityBadge;

  static const _items = [
    _NavItemData(Icons.home_outlined, Icons.home),
    _NavItemData(Icons.event_outlined, Icons.event),
    _NavItemData(Icons.people_outline_rounded, Icons.people_rounded),
    _NavItemData(Icons.forum_outlined, Icons.forum_rounded),
    _NavItemData(Icons.person_outline, Icons.person),
  ];

  int _badgeFor(int index) {
    if (index == 3) return activityBadge;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: FrostedContainer(
        borderRadius: 0,
        opacity: isDark ? 0.85 : 0.92,
        color: isDark
            ? AppTheme.darkSurface.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.92),
        child: Container(
          height: _kNavBarHeight + bottomSafe,
          padding: EdgeInsets.only(bottom: bottomSafe),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              return _NavItemWidget(
                inactiveIcon: _items[i].inactiveIcon,
                activeIcon: _items[i].activeIcon,
                isActive: currentIndex == i,
                badge: _badgeFor(i),
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData(this.inactiveIcon, this.activeIcon);
  final IconData inactiveIcon;
  final IconData activeIcon;
}

class _NavItemWidget extends StatelessWidget {
  const _NavItemWidget({
    required this.inactiveIcon,
    required this.activeIcon,
    required this.isActive,
    required this.badge,
    required this.onTap,
  });

  final IconData inactiveIcon;
  final IconData activeIcon;
  final bool isActive;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final iconColor = isActive ? primaryColor : AppTheme.slateGrey;

    Widget icon = Icon(
      isActive ? activeIcon : inactiveIcon,
      size: 28,
      color: iconColor,
    );

    if (badge > 0) {
      icon = Badge(
        label: Text(
          '$badge',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.ocean,
        child: icon,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: icon,
            ),
            const SizedBox(height: 4),
            // Reserve space even when inactive to prevent layout jumps
            AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
