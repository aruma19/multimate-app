import 'package:flutter/material.dart';

// Halaman utama untuk konversi waktu (TimeConverterPage)
class TimeConverterPage extends StatefulWidget {
  const TimeConverterPage({Key? key}) : super(key: key);

  @override
  _TimeConverterPageState createState() => _TimeConverterPageState();
}

// State untuk halaman TimeConverterPage
class _TimeConverterPageState extends State<TimeConverterPage> {
  final TextEditingController _controller =
      TextEditingController(); // Controller untuk input user
  double? _years; // Variabel untuk menyimpan hasil konversi dalam tahun
  double? _months; // Variabel untuk menyimpan hasil konversi dalam bulan
  int? _weeks; // Variabel untuk menyimpan hasil konversi dalam minggu
  int? _days; // Variabel untuk menyimpan hasil konversi dalam hari
  int? _hours; // Variabel untuk menyimpan hasil konversi dalam jam
  int? _minutes; // Variabel untuk menyimpan hasil konversi dalam menit
  int? _seconds; // Variabel untuk menyimpan hasil konversi dalam detik
  String _error = ''; // Pesan error yang ditampilkan jika input tidak valid

  final Color resultBoxColor =
      Color(0xFFd9e8ff); // Warna untuk kotak hasil konversi

  // Fungsi untuk mengonversi input waktu ke satuan lain (tahun, bulan, minggu, hari, jam, menit, detik)
  void _convertTime() {
    final input = _controller.text
        .trim(); // Ambil input dari user dan hilangkan spasi ekstra
    setState(() {
      // Reset nilai variabel hasil konversi dan pesan error
      _error = '';
      _years = null;
      _months = null;
      _weeks = null;
      _days = null;
      _hours = null;
      _minutes = null;
      _seconds = null;

      // Validasi input kosong
      if (input.isEmpty) {
        _error = 'Input tidak boleh kosong';
        return;
      }

      // Validasi jika input mengandung huruf
      if (RegExp(r'[a-zA-Z]').hasMatch(input)) {
        _error = 'Input mengandung huruf, masukkan input yang valid';
        return;
      }

      // Validasi jika input mengandung simbol yang tidak valid
      if (RegExp(r'[^\d\.\-]').hasMatch(input)) {
        _error =
            'Input mengandung simbol yang tidak valid. Hanya angka, titik, dan minus yang diperbolehkan.';
        return;
      }

      // Validasi jika input melebihi batas digit yang diperbolehkan
      final digitOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitOnly.length > 15) {
        _error = 'Maksimum 15 digit angka yang diperbolehkan';
        return;
      }

      // Parsing input ke tipe data double
      final parsed = double.tryParse(input);
      if (parsed == null) {
        _error = 'Masukkan angka valid';
        return;
      }

      // Konversi angka input ke satuan waktu lainnya
      final months = parsed * 12; // Konversi tahun ke bulan
      final days = (parsed * 365).round(); // Konversi tahun ke hari
      final weeks = (days / 7).round(); // Konversi hari ke minggu
      final hours = days * 24; // Konversi hari ke jam
      final minutes = hours * 60; // Konversi jam ke menit
      final seconds = minutes * 60; // Konversi menit ke detik

      // Menyimpan hasil konversi ke variabel terkait
      _years = parsed;
      _months = months;
      _weeks = weeks;
      _days = days;
      _hours = hours;
      _minutes = minutes;
      _seconds = seconds;
    });
  }

  // Fungsi untuk menampilkan hasil konversi dengan format yang sesuai
  String _getDisplayValue(dynamic value) {
    if (value == null) return '-'; // Jika nilai null, tampilkan tanda "-"
    if (value is double)
      return value.toStringAsFixed(
          2); // Format 2 digit desimal untuk angka bertipe double
    return value.toString(); // Untuk tipe lainnya, konversi ke string
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC)
            ], // Gradient warna background
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Tombol back di pojok kiri atas
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Navigasi kembali ke halaman sebelumnya
                      },
                    ),
                  ),
                ),

                // Judul halaman
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "KONVERSI WAKTU",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Konten utama halaman
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Input field untuk memasukkan nilai tahun
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.15), // Styling untuk input field
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Masukkan jumlah tahun:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _controller,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  hintText: "Contoh: 1, 2.5, 0.25",
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _convertTime, // Fungsi konversi dijalankan saat tombol ditekan
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Color(0xFF6A11CB),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'KONVERSI',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Menampilkan pesan error jika input tidak valid
                        if (_error.isNotEmpty) ...[
                          Container(
                            margin: EdgeInsets.only(top: 16),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.white),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Header hasil konversi
                        if (_years != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.greenAccent),
                                SizedBox(width: 8),
                                Text(
                                  "HASIL KONVERSI",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Menampilkan kotak hasil konversi untuk masing-masing satuan waktu
                          _buildEnhancedResultBox('Tahun',
                              _getDisplayValue(_years), Icons.calendar_today),
                          _buildEnhancedResultBox('Bulan',
                              _getDisplayValue(_months), Icons.date_range),
                          _buildEnhancedResultBox('Minggu',
                              _getDisplayValue(_weeks), Icons.view_week),
                          _buildEnhancedResultBox(
                              'Hari', _getDisplayValue(_days), Icons.today),
                          _buildEnhancedResultBox('Jam',
                              _getDisplayValue(_hours), Icons.access_time),
                          _buildEnhancedResultBox(
                              'Menit', _getDisplayValue(_minutes), Icons.timer),
                          _buildEnhancedResultBox(
                              'Detik',
                              _getDisplayValue(_seconds),
                              Icons.hourglass_bottom),
                        ],

                        // Space at bottom for scrolling
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedResultBox(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: resultBoxColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF6A11CB), size: 24),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF6A11CB).withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2575FC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
