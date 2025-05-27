import 'package:flutter/material.dart';

/// Halaman untuk memeriksa dan mengklasifikasikan jenis bilangan.
class NumberTypePage extends StatefulWidget {
  const NumberTypePage({Key? key}) : super(key: key);

  @override
  _NumberTypePageState createState() => _NumberTypePageState();
}

class _NumberTypePageState extends State<NumberTypePage> {
  // Kontroler untuk input teks
  final TextEditingController _controller = TextEditingController();

  // Variabel untuk menyimpan hasil klasifikasi
  bool _isPrime = false;
  bool _isDecimal = false;
  bool _isPositiveInteger = false;
  bool _isNegativeInteger = false;
  bool _isCacah = false;
  bool _isFraction = false;

  // Status pengecekan dan pesan error
  bool _hasChecked = false;
  String _error = '';

  /// Fungsi untuk mengecek apakah bilangan merupakan bilangan prima.
  bool _checkPrime(int n) {
    if (n < 2) return false;
    for (int i = 2; i <= n ~/ 2; i++) {
      if (n % i == 0) return false;
    }
    return true;
  }

  /// Fungsi untuk mengevaluasi input dan mengklasifikasikan jenis bilangan.
  void _evaluate() {
    setState(() {
      _error = '';  // Reset error
      _hasChecked = true;  // Tandai bahwa pengecekan sudah dilakukan
      _isPrime = _isDecimal = _isPositiveInteger = _isNegativeInteger = _isCacah = _isFraction = false;  // Reset hasil klasifikasi

      final input = _controller.text.trim();  // Ambil input dari text field

      // Validasi jika input kosong
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
      if (RegExp(r'[^\d\.\-\/]').hasMatch(input)) {
        _error = 'Input mengandung simbol yang tidak valid. Hanya angka, titik, minus, dan garis miring yang diperbolehkan.';
        return;
      }

      // Validasi panjang angka lebih dari 19 digit
      final digitOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitOnly.length > 19) {
        _error = 'Maksimum 19 digit angka yang diperbolehkan';
        return;
      }

      // Mengecek jika input adalah pecahan
      if (input.contains('/')) {
        final parts = input.split('/');
        if (parts.length == 2) {
          final num = double.tryParse(parts[0]);
          final den = double.tryParse(parts[1]);
          if (num != null && den != null && den != 0) {
            _isFraction = true;
            return;
          }
        }
        _error = 'Format pecahan tidak valid';
        return;
      }

      // Mengonversi input menjadi angka
      final parsed = double.tryParse(input);
      if (parsed == null) {
        _error = 'Masukkan angka valid';
        return;
      }

      // Menentukan jenis bilangan berdasarkan input
      if (parsed % 1 == 0 && parsed >= 0) {
        _isCacah = true;
      }
      if (parsed % 1 == 0 && parsed > 0) {
        _isPositiveInteger = true;
      }
      if (parsed % 1 == 0 && parsed < 0) {
        _isNegativeInteger = true;
      }
      if (parsed % 1 != 0) {
        _isDecimal = true;
      }
      if (parsed % 1 == 0 && _checkPrime(parsed.toInt())) {
        _isPrime = true;
      }
    });
  }

  /// Membuat widget Box untuk menampilkan hasil klasifikasi bilangan.
  Widget _buildBox(String label, bool active) {
    final display = active ? _controller.text.trim() : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFd9e8ff),
        border: Border.all(color: active ? Color(0xFF6A11CB) : Colors.grey.shade300),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.black : Colors.grey,
            ),
          ),
          Text(
            display,
            style: TextStyle(
              fontSize: 16,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.black : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  /// Mengembalikan list widget untuk menampilkan hasil klasifikasi bilangan.
  List<Widget> _buildResultBoxes() {
    if (!_hasChecked || _error.isNotEmpty) {
      return [];
    }

    final List<Widget> boxes = [];
    if (_isPrime) boxes.add(_buildBox('Bilangan Prima', true));
    if (_isDecimal) boxes.add(_buildBox('Bilangan Desimal', true));
    if (_isPositiveInteger) boxes.add(_buildBox('Bilangan Bulat Positif', true));
    if (_isNegativeInteger) boxes.add(_buildBox('Bilangan Bulat Negatif', true));
    if (_isCacah) boxes.add(_buildBox('Bilangan Cacah', true));
    if (_isFraction) boxes.add(_buildBox('Bilangan Pecahan', true));
    return boxes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Tombol kembali di pojok kiri atas
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                
                // Judul halaman
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tag, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "JENIS BILANGAN",
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
                
                // Konten inputan dan tombol cek
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Input field untuk memasukkan angka
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
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
                                "Masukkan angka:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _controller,
                                keyboardType: TextInputType.text,
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
                                  hintText: "Contoh: 12, 3.14, 5/2, -7",
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _evaluate,  // Tombol untuk mengevaluasi input
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
                                    'PERIKSA',
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
                        
                        // Menampilkan pesan error jika ada
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
                        
                        // Menampilkan hasil klasifikasi jika pengecekan sukses
                        if (_hasChecked && _error.isEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.greenAccent),
                                SizedBox(width: 8),
                                Text(
                                  "HASIL KLASIFIKASI",
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
                        ],
                        
                        // Hasil klasifikasi bilangan
                        ..._buildResultBoxes(),
                        
                        // Spasi untuk scroll
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
}
