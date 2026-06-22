import 'package:addproduct/main.dart';
import 'package:addproduct/screens/aadproductscreen.dart';
import 'package:addproduct/screens/admin/admin_orders_screen.dart';
import 'package:addproduct/screens/admin/admin_products_list_screen.dart';
import 'package:addproduct/screens/cartscreen.dart';
import 'package:addproduct/screens/favoritescreen.dart';
import 'package:addproduct/screens/homescreen.dart';
import 'package:addproduct/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  late final PageController pageController;
  late final bool isAdmin;

  @override
  void initState() {
    super.initState();
    isAdmin = box.read('isAdmin') == true;
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  List<Widget> get _pages {
    if (isAdmin) {
      return const [
        HomeScreen(),
        AddProductScreen(),
        AdminProductsListScreen(),
        AdminOrdersScreen(),
        ProfileScreen(),
      ];
    }

    return const [
      HomeScreen(),
      Favoritescreen(),
      CartScreen(),
      ProfileScreen(),
    ];
  }

  List<BottomNavigationBarItem> get _navItems {
    if (isAdmin) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_outlined),
          activeIcon: Icon(Icons.edit),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite_outline_outlined),
        activeIcon: Icon(Icons.favorite_rounded),
        label: 'Favorites',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart_outlined),
        activeIcon: Icon(Icons.shopping_cart),
        label: 'Cart',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  void _onTabSelected(int index) {
    if (selectedIndex == index) return;
    setState(() => selectedIndex = index);
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            onTap: _onTabSelected,
            items: _navItems,
          ),
        ),
      ),
    );
  }
}
