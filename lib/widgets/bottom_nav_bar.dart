import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/user/user_home_page.dart';
import '../screens/user/venue_list_page.dart';
import '../screens/user/booking_history_page.dart';
import '../screens/user/profile_page.dart';
import '../screens/mitra/mitra_home_page.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // Initialize navigator keys for each tab
    for (int i = 0; i < 5; i++) {
      _navigatorKeys.add(GlobalKey<NavigatorState>());
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      // Pop to root if tapping the same tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => child,
          settings: settings,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isMitra = userProvider.isMitra;

    // Define pages based on user role
    List<Widget> pages = [
      _buildNavigator(0, const UserHomePage()),
      _buildNavigator(1, const VenueListPage()),
      _buildNavigator(2, const BookingHistoryPage()),
      if (isMitra) _buildNavigator(3, const MitraHomePage()),
      _buildNavigator(isMitra ? 4 : 3, const ProfilePage()),
    ];

    // Define navigation items
    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search),
        label: 'Court',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.history_outlined),
        activeIcon: Icon(Icons.history),
        label: 'Booking',
      ),
      if (isMitra)
        const BottomNavigationBarItem(
          icon: Icon(Icons.business_outlined),
          activeIcon: Icon(Icons.business),
          label: 'Mitra',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    return WillPopScope(
      onWillPop: () async {
        // Handle back button - pop the current tab's navigator
        final isFirstRouteInCurrentTab = !await _navigatorKeys[_selectedIndex]
            .currentState!
            .maybePop();

        if (isFirstRouteInCurrentTab) {
          // If on first route, switch to home tab
          if (_selectedIndex != 0) {
            setState(() => _selectedIndex = 0);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: navItems,
        ),
      ),
    );
  }
}
