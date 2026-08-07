import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../favorites/favorites_screen.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../trending/trending_screen.dart';
import '../profile/profile_screen.dart';
import '../categories/categories_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    TrendingScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];
  void _changeTab(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: _PremiumBottomNavigation(
          selectedIndex: _selectedIndex,
          onSelected: _changeTab,
        ),
      ),
    );
  }
}

class _PremiumBottomNavigation extends StatelessWidget {
  const _PremiumBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const items = [
      _NavigationItem(
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      _NavigationItem(
        label: 'Categories',
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
      ),
      _NavigationItem(
        label: 'Trending',
        icon: Icons.local_fire_department_outlined,
        selectedIcon: Icons.local_fire_department_rounded,
      ),
      _NavigationItem(
        label: 'Favorites',
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
      ),
      _NavigationItem(
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF18151F)
            : Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF0EEF5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.08),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = selectedIndex == index;

          return Expanded(
            child: _NavigationButton(
              item: item,
              isSelected: isSelected,
              onTap: () => onSelected(index),
            ),
          );
        }),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutQuart,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 5 : 3,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF4C2E76), const Color(0xFF36204E)]
                        : [const Color(0xFFF0E4FF), const Color(0xFFFFF2EC)],
                  )
                : null,
            borderRadius: BorderRadius.circular(18),
            border: isSelected && isDark
                ? Border.all(color: Colors.white.withValues(alpha: 0.05))
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.88,
                        end: 1,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  key: ValueKey(isSelected),
                  size: isSelected ? 23 : 21,
                  color: isSelected
                      ? isDark
                            ? const Color(0xFFD6BEFF)
                            : AppColors.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? isDark
                            ? const Color(0xFFB78CFF)
                            : AppColors.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
