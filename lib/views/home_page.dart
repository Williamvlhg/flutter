import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/theme.dart';
import 'news_page.dart';
import 'series_page.dart';
import 'episodes_page.dart';
import 'characters_page.dart';
import 'gallery_page.dart';
import 'trivia_page.dart';
import 'analysis_page.dart';
import 'auth_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.newspaper,
      label: 'Actualités',
      page: const NewsPage(),
    ),
    NavigationItem(
      icon: Icons.tv,
      label: 'Série',
      page: const SeriesPage(),
    ),
    NavigationItem(
      icon: Icons.video_library,
      label: 'Épisodes',
      page: const EpisodesPage(),
    ),
    NavigationItem(
      icon: Icons.people,
      label: 'Personnages',
      page: const CharactersPage(),
    ),
    NavigationItem(
      icon: Icons.photo_library,
      label: 'Images',
      page: const GalleryPage(),
    ),
    NavigationItem(
      icon: Icons.quiz,
      label: 'Trivia',
      page: const TriviaPage(),
    ),
    NavigationItem(
      icon: Icons.analytics,
      label: 'Analyses',
      page: const AnalysisPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _navigationItems.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    
    // Charger les données initiales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      dbService.fetchNews();
      dbService.fetchEpisodes();
      dbService.fetchCharacters();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Scaffold(
      appBar: _buildAppBar(context, isMobile),
      body: isMobile ? _buildMobileBody() : _buildDesktopBody(),
      bottomNavigationBar: isMobile ? _buildBottomNavigation() : null,
      drawer: isMobile ? _buildDrawer(context) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isMobile) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SimpsonsColors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'S',
              style: TextStyle(
                color: SimpsonsColors.yellow,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Simpsons Park'),
        ],
      ),
      actions: [
        if (!isMobile) ..._buildDesktopNavigation(context),
        _buildUserMenu(context),
      ],
      bottom: !isMobile ? TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: SimpsonsColors.darkBlue,
        unselectedLabelColor: SimpsonsColors.darkBlue.withOpacity(0.6),
        indicatorColor: SimpsonsColors.blue,
        tabs: _navigationItems.map((item) => Tab(
          icon: Icon(item.icon),
          text: item.label,
        )).toList(),
      ) : null,
    );
  }

  Widget _buildMobileBody() {
    return _navigationItems[_selectedIndex].page;
  }

  Widget _buildDesktopBody() {
    return TabBarView(
      controller: _tabController,
      children: _navigationItems.map((item) => item.page).toList(),
    );
  }

  List<Widget> _buildDesktopNavigation(BuildContext context) {
    return [
      Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.isAdmin) {
            return TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/admin'),
              icon: const Icon(Icons.admin_panel_settings, color: SimpsonsColors.blue),
              label: const Text('Admin', style: TextStyle(color: SimpsonsColors.blue)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    ];
  }

  Widget _buildUserMenu(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: SimpsonsColors.blue,
            child: Icon(
              authService.isAuthenticated ? Icons.person : Icons.login,
              color: SimpsonsColors.white,
            ),
          ),
          onSelected: (value) async {
            switch (value) {
              case 'login':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
                break;
              case 'admin':
                Navigator.pushNamed(context, '/admin');
                break;
              case 'logout':
                authService.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Déconnexion réussie'),
                    backgroundColor: SimpsonsColors.blue,
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) {
            if (authService.isAuthenticated) {
              return [
                PopupMenuItem(
                  child: Text('Bonjour ${authService.currentUser?.username}'),
                  enabled: false,
                ),
                if (authService.isAdmin)
                  const PopupMenuItem(
                    value: 'admin',
                    child: ListTile(
                      leading: Icon(Icons.admin_panel_settings),
                      title: Text('Administration'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Déconnexion'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            } else {
              return [
                const PopupMenuItem(
                  value: 'login',
                  child: ListTile(
                    leading: Icon(Icons.login),
                    title: Text('Connexion'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            }
          },
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex.clamp(0, 4), 
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: SimpsonsColors.yellow,
      selectedItemColor: SimpsonsColors.blue,
      unselectedItemColor: SimpsonsColors.darkBlue.withOpacity(0.6),
      items: _navigationItems.take(5).map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        label: item.label,
      )).toList(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: SimpsonsColors.lightYellow,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: SimpsonsColors.yellow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SimpsonsColors.blue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'SP',
                      style: TextStyle(
                        color: SimpsonsColors.yellow,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Simpsons Park',
                    style: TextStyle(
                      color: SimpsonsColors.darkBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Le site des fans',
                    style: TextStyle(
                      color: SimpsonsColors.darkBlue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ..._navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListTile(
                leading: Icon(
                  item.icon,
                  color: _selectedIndex == index ? SimpsonsColors.blue : SimpsonsColors.darkBlue,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    color: _selectedIndex == index ? SimpsonsColors.blue : SimpsonsColors.darkBlue,
                    fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == index,
                selectedTileColor: SimpsonsColors.yellow.withOpacity(0.3),
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const Divider(),
            Consumer<AuthService>(
              builder: (context, authService, child) {
                if (authService.isAuthenticated && authService.isAdmin) {
                  return ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: SimpsonsColors.orange),
                    title: const Text(
                      'Administration',
                      style: TextStyle(color: SimpsonsColors.orange, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin');
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}