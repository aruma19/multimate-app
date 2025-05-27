import 'package:flutter/material.dart';
import 'package:project2/data/phone_data.dart'; // Mengimpor data list ponsel dari file phone_data.dart
import 'package:project2/pages/detail_page.dart'; // Mengimpor halaman detail untuk ponsel

// Halaman rekomendasi website untuk menampilkan daftar ponsel
class WebsiteRecommendationPage extends StatefulWidget {
  const WebsiteRecommendationPage({super.key});

  @override
  State<WebsiteRecommendationPage> createState() =>
      _WebsiteRecommendationPageState();
}

// State untuk halaman WebsiteRecommendationPage
class _WebsiteRecommendationPageState extends State<WebsiteRecommendationPage> {
  @override
  Widget build(BuildContext context) {
    // Menggunakan Container dengan background gradasi
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, // Mulai gradasi dari kiri atas
          end: Alignment.bottomRight, // Akhiri gradasi di kanan bawah
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Warna gradasi
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Membuat latar belakang transparan untuk melihat gradasi
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Transparan agar tidak menghalangi gradasi
          elevation: 0, // Menghilangkan bayangan pada AppBar
          iconTheme: const IconThemeData(color: Colors.white), // Menyesuaikan warna ikon di AppBar
          title: const Text(
            "Phone Recommendation", // Judul aplikasi
            style: TextStyle(color: Colors.white), // Agar teks kontras dengan latar belakang
          ),
          centerTitle: true, // Memusatkan judul
        ),

        // Bagian utama halaman berisi GridView untuk menampilkan daftar ponsel
        body: Padding(
          padding: const EdgeInsets.all(20), // Padding untuk ruang di sekitar grid
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 kolom dalam grid
              crossAxisSpacing: 16, // Spasi antar kolom
              mainAxisSpacing: 8, // Spasi antar baris
            ),
            itemBuilder: (context, index) => _phonesData(context, index), // Fungsi untuk membangun setiap item dalam grid
            itemCount: phones.length, // Jumlah item yang akan ditampilkan berdasarkan panjang list phones
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membangun tampilan setiap ponsel dalam grid
  Widget _phonesData(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        // Ketika ponsel di-tap, navigasikan ke halaman DetailPage untuk informasi lebih lanjut
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DetailPage(index: index)));
      },
      child: Container(
        padding: EdgeInsets.all(16), // Memberikan padding dalam container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), // Membuat sudut container melengkung
          border: Border.all(width: 1), // Memberikan border dengan ketebalan 1
        ),
        child: Column(
          children: [
            Expanded(
              // Menampilkan gambar ponsel dengan menggunakan URL gambar dari phones[index]
              child: Image.network(phones[index].imageUrl),
            ),
            Align(
              alignment: Alignment.centerLeft, // Menyelaraskan teks ke kiri
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Menyelaraskan teks ke kiri di dalam kolom
                children: [
                  Text(phones[index].model,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), // Model ponsel dengan teks tebal dan warna putih
                  Text(
                    phones[index].brand,
                    style: TextStyle(color: const Color.fromARGB(255, 208, 190, 190)), // Merek ponsel dengan warna abu-abu
                  ),
                  Text(
                    "\$ ${phones[index].price[0]}", // Menampilkan harga ponsel (mengambil harga pertama dalam list harga)
                    style: TextStyle(color: const Color.fromARGB(255, 24, 240, 31)), // Menampilkan harga dengan warna hijau
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
