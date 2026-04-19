import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'learning_screen.dart';
import 'conversation_screen.dart';
import 'reward_screen.dart';
import 'my_info_screen.dart';
import '../widgets/guide_tour_overlay.dart';
import '../widgets/rocket_animation.dart';

class MainScaffold extends StatefulWidget {
  final bool isFirstVisit;

  const MainScaffold({super.key, this.isFirstVisit = false});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  bool _isGuideTourActive = false;
  bool _isRocketPlaying = false;
  GuideTourStep? _currentGuideTourStep;

  final GlobalKey _learningTabKey = GlobalKey();
  final GlobalKey _chatTabKey = GlobalKey();
  final GlobalKey _reportTabKey = GlobalKey();
  final GlobalKey _heartTabKey = GlobalKey();

  List<Widget> get _screens => [
    HomeScreen(onNavigateToTab: _navigateToTab),
    const LearningScreen(),
    const ConversationScreen(),
    const RewardScreen(),
    const MyInfoScreen(),
  ];

  void _navigateToTab(int index) {
    if (_isGuideTourActive || _isRocketPlaying) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.isFirstVisit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startGuideTour();
      });
    }
  }

  void _startGuideTour() {
    setState(() {
      _isGuideTourActive = true;
      _currentGuideTourStep = GuideTourStep.welcomePopup;
    });
  }

  void _nextGuideTourStep() {
    setState(() {
      switch (_currentGuideTourStep!) {
        case GuideTourStep.welcomePopup:
          _currentGuideTourStep = GuideTourStep.learningTab;
          break;
        case GuideTourStep.learningTab:
          _currentGuideTourStep = GuideTourStep.chatTab;
          break;
        case GuideTourStep.chatTab:
          _currentGuideTourStep = GuideTourStep.reportTab;
          break;
        case GuideTourStep.reportTab:
          _currentGuideTourStep = GuideTourStep.heartTab;
          break;
        case GuideTourStep.heartTab:
          break;
      }
    });
  }

  void _finishGuideTour() {
    setState(() {
      _isGuideTourActive = false;
      _currentGuideTourStep = null;
      _isRocketPlaying = true;
    });
  }

  void _onRocketComplete() {
    setState(() {
      _isRocketPlaying = false;
    });
  }

  GlobalKey? _getCurrentSpotlightKey() {
    switch (_currentGuideTourStep) {
      case GuideTourStep.learningTab:
        return _learningTabKey;
      case GuideTourStep.chatTab:
        return _chatTabKey;
      case GuideTourStep.reportTab:
        return _reportTabKey;
      case GuideTourStep.heartTab:
        return _heartTabKey;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: _screens[_currentIndex]),

          if (_isGuideTourActive && _currentGuideTourStep != null)
            GuideTourOverlay(
              currentStep: _currentGuideTourStep!,
              spotlightTargetKey: _getCurrentSpotlightKey(),
              onNext: _nextGuideTourStep,
              onFinish: _finishGuideTour,
            ),

          if (_isRocketPlaying) RocketAnimation(onComplete: _onRocketComplete),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (_isGuideTourActive || _isRocketPlaying) return;
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF75A66B),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      showUnselectedLabels: true,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: _ActiveIcon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: _KeyedIcon(
            key: _learningTabKey,
            icon: Icons.menu_book_outlined,
          ),
          activeIcon: _ActiveIcon(Icons.menu_book),
          label: '배움',
        ),
        BottomNavigationBarItem(
          icon: _KeyedIcon(key: _chatTabKey, icon: Icons.chat_bubble_outline),
          activeIcon: _ActiveIcon(Icons.chat_bubble),
          label: '챗',
        ),
        BottomNavigationBarItem(
          icon: _KeyedIcon(key: _reportTabKey, icon: Icons.bar_chart_outlined),
          activeIcon: _ActiveIcon(Icons.bar_chart),
          label: '리포트',
        ),
        BottomNavigationBarItem(
          icon: _KeyedIcon(key: _heartTabKey, icon: Icons.favorite_outline),
          activeIcon: _ActiveIcon(Icons.favorite),
          label: '마음',
        ),
      ],
    );
  }
}

class _ActiveIcon extends StatelessWidget {
  final IconData iconData;

  const _ActiveIcon(this.iconData);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F1DF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: const Color(0xFF75A66B)),
    );
  }
}

class _KeyedIcon extends StatelessWidget {
  final IconData icon;

  const _KeyedIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon);
  }
}
