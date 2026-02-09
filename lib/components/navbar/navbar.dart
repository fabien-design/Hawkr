import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hawklap/core/auth/auth_service.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/views/login/login_view.dart';
import '../../views/explore/explore.dart';
import '../../views/search/search.dart';
import '../../views/favourites/favourites.dart';
import '../../views/add/add_view.dart';
import '../../views/profile/profile_view.dart';

class MainNavbar extends StatefulWidget {
  const MainNavbar({super.key});

  @override
  State<MainNavbar> createState() => _MainNavbarState();
}

class _MainNavbarState extends State<MainNavbar> {
  int _currentIndex = 0;
  final authService = AuthService();
  late StreamSubscription _authSubscription;

  // UniqueKey per tab to force rebuild when needed
  final List<UniqueKey> _tabKeys = List.generate(5, (_) => UniqueKey());

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  final List<Widget> _views = const [
    ExploreView(),
    SearchView(),
    FavouritesView(),
    AddView(),
    ProfileView(),
  ];

  // require authentication: Favourites (2), Add (3), Profile (4)
  final Set<int> _protectedIndices = const {2, 3, 4};

  @override
  void initState() {
    super.initState();
    _authSubscription = authService.authStateChanges.listen((authState) {
      if (!mounted) return;
      setState(() {
        // Reset protected tabs so they rebuild fresh
        for (final index in _protectedIndices) {
          _tabKeys[index] = UniqueKey();
          _navigatorKeys[index] = GlobalKey<NavigatorState>();
        }
        // Redirect to Explore on logout
        if (!authService.isLoggedIn() && _protectedIndices.contains(_currentIndex)) {
          _currentIndex = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) async {
    if (index == _currentIndex) {
      // Pop to root of current tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }

    if (_protectedIndices.contains(index) && !authService.isLoggedIn()) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginView(),
        ),
      );

      if (result == true && mounted) {
        setState(() {
          _currentIndex = index;
        });
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final navigatorState = _navigatorKeys[_currentIndex].currentState;
        if (navigatorState != null && navigatorState.canPop()) {
          navigatorState.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(_views.length, (index) {
            return KeyedSubtree(
              key: _tabKeys[index],
              child: Navigator(
                key: _navigatorKeys[index],
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (_) => _views[index],
                  );
                },
              ),
            );
          }),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colors.backgroundCard,
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: colors.backgroundCard,
            selectedItemColor: AppColors.brandPrimary,
            unselectedItemColor: colors.textSecondary,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                label: 'Favourites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
