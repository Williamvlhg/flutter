import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'views/home_page.dart';
import 'views/auth_page.dart';
import 'views/admin_page.dart';
import 'views/episodes_page.dart';
import 'views/characters_page.dart';
import 'views/trivia_page.dart';
import 'views/analysis_page.dart';
import 'utils/theme.dart';

void main() {
  runApp(const SimpsonsApp());
}

class SimpsonsApp extends StatelessWidget {
  const SimpsonsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        title: 'Simpsons Park',
        theme: SimpsonsTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const HomePage(),
          '/auth': (context) => const AuthPage(),
          '/admin': (context) => const AdminPage(),
          '/episodes': (context) => const EpisodesPage(),
          '/characters': (context) => const CharactersPage(),
          '/trivia': (context) => const TriviaPage(),
          '/analysis': (context) => const AnalysisPage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoading) {
          return const Scaffold(
            backgroundColor: SimpsonsColors.yellow,
            body: Center(
              child: CircularProgressIndicator(
                color: SimpsonsColors.blue,
              ),
            ),
          );
        }
        
        return const HomePage();
      },
    );
  }
}