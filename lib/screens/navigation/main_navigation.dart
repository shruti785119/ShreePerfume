import 'package:flutter/material.dart';
import 'package:shree/screens/account/account_screen.dart';
import 'package:shree/screens/cart/cart_screen.dart';
import 'package:shree/screens/category/category_screen.dart';
import 'package:shree/screens/home/home_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final screens = const [
    HomeScreen(),
    CategoryScreen(),
    CartScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1FD58B),
        unselectedItemColor: const Color(0xFF9AA8BE),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        onTap: (value) {
          setState(() => index = value);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart_rounded),
            label: 'CART',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'ACCOUNT',
          ),
        ],
      ),
    );
  }
}
