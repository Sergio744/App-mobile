import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'data/progress_store.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/stats_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: GbeColors.cream,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(GbeApp(store: ProgressStore(prefs)));
}

class GbeApp extends StatelessWidget {
  const GbeApp({super.key, required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gbè',
      debugShowCheckedModeBanner: false,
      theme: GbeTheme.build(),
      home: AnimatedBuilder(
        animation: store,
        builder: (BuildContext context, Widget? child) {
          if (!store.isLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!store.onboarded) {
            // `setOnboarded()` notifie déjà les écouteurs : le rebuild de
            // l'AnimatedBuilder suffit à basculer vers l'app.
            return OnboardingScreen(store: store, onDone: () {});
          }
          return RootShell(store: store);
        },
      ),
    );
  }
}

/// La coquille à trois onglets : apprendre, parcourir, progresser.
class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.store});

  final ProgressStore store;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      HomeScreen(
        store: widget.store,
        onOpenStats: () => setState(() => _tab = 2),
        onOpenLibrary: () => setState(() => _tab = 1),
      ),
      LibraryScreen(store: widget.store),
      StatsScreen(store: widget.store),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: GbeColors.sand)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (int i) => setState(() => _tab = i),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school_rounded),
              label: 'Apprendre',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Lexique',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights_rounded),
              label: 'Progrès',
            ),
          ],
        ),
      ),
    );
  }
}
