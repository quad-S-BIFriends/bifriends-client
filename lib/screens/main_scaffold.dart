import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'learning_screen.dart';
import 'conversation_screen.dart';
import 'reward_screen.dart';
import 'my_info_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LearningScreen(),
    const ConversationScreen(),
    const RewardScreen(),
    const MyInfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF75A66B),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: _ActiveIcon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: _ActiveIcon(Icons.menu_book),
            label: '배움',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: _ActiveIcon(Icons.chat_bubble),
            label: '대화',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            activeIcon: _ActiveIcon(Icons.card_giftcard),
            label: '보상',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: _ActiveIcon(Icons.person),
            label: '내정보',
          ),
        ],
      ),
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
