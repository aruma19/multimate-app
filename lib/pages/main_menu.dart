// File: lib/pages/main_page.dart
import 'package:flutter/material.dart';
import 'package:project2/pages/time_converter_app.dart';
import 'stopwatch_app.dart';
import 'number_type_app.dart';
import 'tracking_lbs_app.dart';
import 'time_converter_app.dart';
import 'recommended_sites_app.dart';
import 'team_members_page.dart';
import 'help_page.dart';
import 'login_page.dart';
import '../services/session_manager.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    MemberListScreen(),
    HelpPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.white,
  selectedItemColor: Colors.white,
  unselectedItemColor: Colors.grey,
  elevation: 8, // memberi bayangan bawah
  items: [
    BottomNavigationBarItem(
      icon: _buildFloatingIcon(Icons.home, 0),
      label: 'Beranda',
    ),
    BottomNavigationBarItem(
      icon: _buildFloatingIcon(Icons.group, 1),
      label: 'Anggota',
    ),
    BottomNavigationBarItem(
      icon: _buildFloatingIcon(Icons.help, 2),
      label: 'Bantuan',
    ),
  ],
),

    );
  }

  Widget _buildFloatingIcon(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return Transform.translate(
      offset: isSelected
          ? Offset(0, -20)
          : Offset(0, 0), // Lebih tinggi dari sebelumnya
      child: Container(
        padding: EdgeInsets.all(isSelected ? 8 : 0), // Membuat bulatan besar
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6A11CB) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: isSelected ? 24 : 20,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<MenuOption> menuOptions = [
    MenuOption(
      title: 'Stopwatch',
      icon: Icons.timer,
      color: Colors.orange,
      page: StopwatchPage(),
    ),
    MenuOption(
      title: 'Jenis Bilangan',
      icon: Icons.numbers,
      color: Colors.green,
      page: NumberTypePage(),
    ),
    MenuOption(
        title: 'Tracking LBS',
        icon: Icons.location_on,
        color: Colors.red,
        page: TrackinglbsPage()),
    MenuOption(
        title: 'Konversi Waktu',
        icon: Icons.access_time,
        color: Colors.purple,
        page: TimeConverterPage()),
    MenuOption(
        title: 'Rekomendasi Website',
        icon: Icons.public,
        color: Colors.blue,
        page: WebsiteRecommendationPage(),),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi App'),
        backgroundColor: Color(0xFF6A11CB),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE6E6FA)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Pilih Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A11CB),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 30),
                ...menuOptions
                    .map((option) => _buildMenuButton(context, option))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, MenuOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => option.page),
          );
        },
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                decoration: BoxDecoration(
                  color: option.color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: Icon(
                    option.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuOption {
  final String title;
  final IconData icon;
  final Color color;
  final Widget page;

  MenuOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.page,
  });
}
