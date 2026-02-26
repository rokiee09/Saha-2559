import 'package:flutter/material.dart';

import '../saha/saha_page.dart';
import '../mevzuat/mevzuat_page.dart';
import '../haklar/haklar_page.dart';
import '../teskilat/teskilat_page.dart';
import '../kultur/kultur_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    SahaPage(),
    MevzuatPage(),
    HaklarPage(),
    TeskilatPage(),
    KulturPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Saha'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: 'Mevzuat'),
          BottomNavigationBarItem(icon: Icon(Icons.balance), label: 'Haklar'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Teşkilat'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Kültür'),
        ],
      ),
    );
  }
}

