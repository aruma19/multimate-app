// File: lib/pages/help_page.dart
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  final List<HelpItem> helpItems = [
    HelpItem(
      title: 'Cara Login',
      content: 'Masukkan username dan password yang telah diberikan. Username default adalah "admin" dan password default adalah "admin".',
      icon: Icons.login,
    ),
    HelpItem(
      title: 'Menggunakan Stopwatch',
      content: 'Klik tombol "Mulai" untuk memulai stopwatch. Klik "Stop" untuk menghentikan dan "Reset" untuk mengatur ulang stopwatch ke nol.',
      icon: Icons.timer,
    ),
    HelpItem(
      title: 'Mengecek Jenis Bilangan',
      content: 'Masukkan bilangan yang ingin dicek pada kotak input. Aplikasi akan menampilkan jenis bilangan tersebut (prima, desimal, bulat, dll).',
      icon: Icons.numbers,
    ),
    HelpItem(
      title: 'Tracking LBS',
      content: 'Berikan izin lokasi pada aplikasi. Klik tombol "Mulai Tracking" untuk melihat lokasi Anda saat ini pada peta.',
      icon: Icons.location_on,
    ),
    HelpItem(
      title: 'Konversi Waktu',
      content: 'Masukkan jumlah tahun pada kotak input dan klik "Konversi" untuk mengubahnya menjadi jam, menit, dan detik.',
      icon: Icons.access_time,
    ),
    HelpItem(
      title: 'Rekomendasi Website',
      content: 'Browse daftar website yang direkomendasikan. Klik pada item untuk melihat detail dan membuka link website.',
      icon: Icons.public,
    ),
    HelpItem(
      title: 'Logout',
      content: 'Klik icon logout di pojok kanan atas aplikasi dan konfirmasi untuk keluar dari akun Anda.',
      icon: Icons.logout,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFE6E6FA)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Bantuan Penggunaan Aplikasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: helpItems.length,
                itemBuilder: (context, index) {
                  final item = helpItems[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(item.icon, color: Colors.deepPurple),
                      title: Text(
                        item.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.content),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpItem {
  final String title;
  final String content;
  final IconData icon;

  HelpItem({
    required this.title,
    required this.content,
    required this.icon,
  });
}
