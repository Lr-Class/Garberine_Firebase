// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:app_garb/screens/profile_screen.dart';
import 'community_screen.dart';
import 'leaderboard_screen.dart';
import 'main_game_screen.dart';
import 'news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  final List<Widget> _screens = [
    CommunityScreen(),
    NewsScreen(),
    MainMenuScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Permite que el contenido se extienda detrás de la barra
      body: Padding(
        padding: const EdgeInsets.only(bottom: 70), // Espacio reservado para la barra
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  

  Widget _buildFloatingNavBar() {
    Color colorOriginal = Color.fromARGB(255, 159, 50, 209);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: Colors.white.withOpacity(0.7),
            selectedItemColor: const Color.fromARGB(255, 97, 2, 141),
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _currentIndex == 0
                        ? colorOriginal.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people_outline, size: 26),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: colorOriginal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people, size: 26),
                ),
                label: 'Community',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _currentIndex == 1
                        ? colorOriginal.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.new_releases_outlined, size: 26),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: colorOriginal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.new_releases, size: 26),
                ),
                label: 'News',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _currentIndex == 2
                        ? colorOriginal.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sports_esports_outlined, size: 26),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: colorOriginal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sports_esports, size: 26),
                ),
                label: 'Play',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _currentIndex == 3
                        ? colorOriginal.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.leaderboard_outlined, size: 26),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: colorOriginal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.leaderboard, size: 26),
                ),
                label: 'Ranking',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _currentIndex == 4
                        ? colorOriginal.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_outline, size: 26),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: colorOriginal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, size: 26),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}