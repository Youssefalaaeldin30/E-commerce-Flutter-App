import 'package:ecommerceapp/screens/card_screen.dart';
import 'package:ecommerceapp/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'products_screen.dart';
import 'cart_screen.dart';
import '/widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = const [
    ProductsScreen(),
    WishlistScreen(),
    CartScreen(),
    CardScreen(),
  ];

  final List<String> _labels = ["Home", "Wishlist", "Cart", "Cards"];

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.favorite_border,
    Icons.shopping_bag_outlined,
    Icons.credit_card_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: List.generate(_labels.length, (i) {
          final isSelected = _index == i;
          return BottomNavigationBarItem(
            icon: isSelected
                ? Text(
                    _labels[i],
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  )
                : Icon(_icons[i]),
            label: '',
          );
        }),
      ),
    );
  }
}
