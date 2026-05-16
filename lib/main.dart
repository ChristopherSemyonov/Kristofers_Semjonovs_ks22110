import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rank_screen.dart';
import 'services/game_state_service.dart';
import 'services/user_api_service.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GameStateService.loadGameState();
  await UserApiService.createDefaultUser();

  final backendUser = await UserApiService.fetchCurrentUser();
  GameStateService.updateFromBackendUser(backendUser);

  final solvedPuzzles = await UserApiService.fetchSolvedPuzzles();

  GameStateService.loadSolvedPuzzlesFromBackend(solvedPuzzles);

  runApp(const UrbanQuestApp());
}

class UrbanQuestApp extends StatefulWidget {
  const UrbanQuestApp({super.key});

  @override
  State<UrbanQuestApp> createState() => _UrbanQuestAppState();
}

class _UrbanQuestAppState extends State<UrbanQuestApp> {
  bool isLoggedIn = false;
  bool isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final loggedIn = await AuthService.isLoggedIn();

      if (!mounted) return;

      setState(() {
        isLoggedIn = loggedIn;
        isCheckingAuth = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoggedIn = false;
        isCheckingAuth = false;
      });
    }
  }

  void _handleLoginSuccess() {
    setState(() {
      isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingAuth) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Urban Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAA3000),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: isLoggedIn
          ? const MainNavigationScreen()
          : LoginScreen(onLoginSuccess: _handleLoginSuccess),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = const [
    ProfileScreen(),
    MapScreen(),
    RankScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Profile';
      case 1:
        return 'Urban Quest';
      case 2:
        return 'Rank';
      default:
        return 'Urban Quest';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFAA3000),
        unselectedItemColor: const Color(0xFF5C4037),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'MAP'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'RANK'),
        ],
      ),
    );
  }
}

class PuzzleMarker extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final Color color;
  final IconData icon;

  const PuzzleMarker({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mīkla vēl tiks pievienota nākamajā solī.'),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.location_on, size: 56, color: color),
            Positioned(
              top: 12,
              child: Icon(icon, size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFAA3000).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFAA3000),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ],
    );
  }
}

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0266FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(offset: Offset(4, 4), blurRadius: 0, color: Colors.black),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL SCORE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '5564 R',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Icon(Icons.stars, color: Colors.white, size: 52),
        ],
      ),
    );
  }
}

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const StatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEFED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(offset: Offset(3, 3), blurRadius: 0, color: Colors.black),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Color(0xFF5C4037),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          Text(subtitle, style: const TextStyle(color: Color(0xFF5C4037))),
        ],
      ),
    );
  }
}

class CompletedPuzzleCard extends StatelessWidget {
  final String title;
  final String difficulty;
  final String points;

  const CompletedPuzzleCard({
    super.key,
    required this.title,
    required this.difficulty,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(offset: Offset(3, 3), blurRadius: 0, color: Colors.black),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E3E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const Icon(Icons.extension, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00647C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        difficulty,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      points,
                      style: const TextStyle(
                        color: Color(0xFF5C4037),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF0050CC)),
        ],
      ),
    );
  }
}

class SimpleMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final smallRoadPaint = Paint()
      ..color = const Color(0xFFF7FAF8)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.25),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.75),
      Offset(size.width * 0.8, size.height * 0.45),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.45, size.height),
      smallRoadPaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.55),
      Offset(size.width, size.height * 0.58),
      smallRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
