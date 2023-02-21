import 'package:addproduct/screens/aadproductscreen.dart';
import 'package:addproduct/screens/cartscreen.dart';
import 'package:addproduct/screens/favoritescreen.dart';
import 'package:addproduct/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  late PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: const [
          HomeScreen(),
          AddProductScreen(),
          Favoritescreen(),
          CartScreen(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: WaterDropNavBar(
          waterDropColor: Colors.black,
          backgroundColor: Colors.white,
          onButtonPressed: (index) {
            setState(() {
              selectedIndex = index;
            });
            pageController.animateToPage(selectedIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuad);
          },
          selectedIndex: selectedIndex,
          barItems: [
            BarItem(
              filledIcon: Icons.home,
              outlinedIcon: Icons.home_outlined,
            ),
            BarItem(
                filledIcon: Icons.add_circle,
                outlinedIcon: Icons.add_circle_outline),
            BarItem(
              filledIcon: Icons.favorite_rounded,
              outlinedIcon: Icons.favorite_outline_outlined,
            ),
            BarItem(
              filledIcon: Icons.shopping_cart,
              outlinedIcon: Icons.shopping_cart_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
