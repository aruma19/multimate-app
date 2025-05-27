// Import package Flutter yang diperlukan
import 'package:flutter/material.dart';

// Import halaman-halaman dan widget tambahan dari project
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
import '../widgets/bottom_nav_bar.dart';

/// MainPage adalah halaman utama setelah login,
/// menampilkan navigasi bawah dan konten dinamis.
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Menyimpan index halaman yang sedang aktif

  // Daftar halaman yang akan ditampilkan berdasarkan bottom navigation
  final List<Widget> _pages = [
    HomeContent(),         // Halaman home dengan daftar menu
    MemberListScreen(),    // Halaman daftar anggota tim
    HelpPage(),            // Halaman bantuan
  ];

  /// Mengubah tampilan halaman sesuai index yang diklik
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Menampilkan halaman sesuai index aktif
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

/// HomeContent adalah halaman beranda utama
/// yang menampilkan menu-menu fitur dalam bentuk tombol
class HomeContent extends StatelessWidget {
  // Daftar menu aplikasi
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
      page: TrackinglbsPage(),
    ),
    MenuOption(
      title: 'Konversi Waktu',
      icon: Icons.access_time,
      color: Colors.purple,
      page: TimeConverterPage(),
    ),
    MenuOption(
      title: 'Rekomendasi Website',
      icon: Icons.public,
      color: Colors.blue,
      page: WebsiteRecommendationPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar di bagian atas halaman
      appBar: AppBar(
        title: Text(
          'Multi App',
          style: TextStyle(
            color: Colors.white, // Warna teks AppBar putih
          ),
        ),
        backgroundColor: Color(0xFF6A11CB), // Warna latar AppBar
        centerTitle: true,
      ),

      // Body dengan latar gradasi dan daftar menu
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
                // Judul "Pilih Menu"
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
                // Membuat tombol menu berdasarkan daftar menu
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

  /// Widget untuk membangun tombol menu individual
  Widget _buildMenuButton(BuildContext context, MenuOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman yang dipilih
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
              // Bagian kiri berisi ikon dan warna khas
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
                    color: Colors.white, // Warna ikon jadi putih
                    size: 30,
                  ),
                ),
              ),
              // Judul menu
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
              // Ikon panah ke kanan
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

/// Model data untuk opsi menu aplikasi
class MenuOption {
  final String title;   // Judul menu
  final IconData icon;  // Ikon menu
  final Color color;    // Warna ikon menu
  final Widget page;    // Halaman tujuan menu

  MenuOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.page,
  });
}
