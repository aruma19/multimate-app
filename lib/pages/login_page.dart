// File: lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import 'main_menu.dart';
import 'welcome_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // Controller untuk input username dan password
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variabel untuk menyembunyikan atau menampilkan password
  bool _obscurePassword = true;

  // Status loading saat proses login
  bool _isLoading = false;

  // Controller dan animasi untuk efek fade-in
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi fade-in
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 800), //mengatur durasi dan progres animasi
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        //transparan penuh ke terlihat sepenuhnya.
        CurvedAnimation(
            parent: _animationController,
            curve: Curves
                .easeIn) //animasi berjalan lambat di awal dan cepat di akhir.
        );

    _animationController.forward(); // Mulai animasi

    _checkExistingSession(); // Cek apakah user sudah login sebelumnya
  }

  @override
  void dispose() {
    // Membersihkan controller ketika widget dihapus dari widget tree
    usernameController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Cek apakah sesi login masih aktif
  void _checkExistingSession() async {
    final isLoggedIn = await SessionManager.isLoggedIn();

    if (isLoggedIn) {
      // Jika sudah login, langsung navigasi ke halaman utama
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      });
    }
  }

  // Fungsi untuk melakukan proses login
  void login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    // Validasi input
    if (username.isEmpty || password.isEmpty) {
      String errorMessage = 'Username dan password tidak boleh kosong!';
      if (username.isEmpty && password.isNotEmpty) {
        errorMessage = 'Username tidak boleh kosong!';
      } else if (password.isEmpty && username.isNotEmpty) {
        errorMessage = 'Password tidak boleh kosong!';
      }

      _showSnackBar(errorMessage, Colors.orange);
      return;
    }

    // Menampilkan indikator loading
    setState(() {
      _isLoading = true;
    });

    // Simulasi delay autentikasi (misal memanggil API)
    await Future.delayed(Duration(milliseconds: 800));

    // Proses autentikasi (sederhana)
    if (username == 'admin' && password == 'admin') {
      await SessionManager.login(); // Simpan status login ke SharedPreferences

      _showSnackBar('Login berhasil!', Colors.green);

      // Arahkan ke halaman utama
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      });
    } else {
      _showSnackBar('Login gagal! Username atau password salah.', Colors.red);
    }

    // Matikan indikator loading
    setState(() {
      _isLoading = false;
    });
  }

  // Menampilkan snackbar untuk notifikasi
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(
            seconds: 2), //Durasi SnackBar tampil di layar, yaitu 2 detik.
        behavior: SnackBarBehavior
            .floating, //Mengatur agar SnackBar mengambang di atas konten dan tidak menempel di bawah layar.
        margin: EdgeInsets.all(
            10), //Jarak antara SnackBar dan tepi layar (kanan, kiri, bawah, atas), yaitu 10 pixel dari semua sisi.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        // Background gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: Container(
                  width: screenSize.width > 600 ? 450 : screenSize.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol back di kiri atas
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon:
                                Icon(Icons.arrow_back, color: Colors.grey[700]),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        WelcomePage()), // Ganti dengan halaman asalmu
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        // Ikon logo
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFF6A11CB).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            size: 40,
                            color: Color(0xFF6A11CB),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Judul dan subtitle
                        Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A11CB),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Silakan login untuk melanjutkan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 32),

                        // Input username
                        _buildTextField(
                          controller: usernameController,
                          label: 'Username',
                          prefixIcon: Icons.person_outline,
                        ),
                        SizedBox(height: 20),

                        // Input password
                        _buildTextField(
                          controller: passwordController,
                          label: 'Password',
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                        ),
                        SizedBox(height: 24),

                        // Tombol login
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 203, 17, 17),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'LOGIN',
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk membuat input field username/password
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16),
              border: InputBorder.none,
              prefixIcon: Icon(
                prefixIcon,
                color: Color(0xFF6A11CB),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                  : null,
              hintText: 'Masukkan $label',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }
}
