import 'package:flutter/material.dart';
import 'dart:async';

/// Halaman Stopwatch untuk aplikasi, menggunakan `StatefulWidget` karena status timer yang berubah.
class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
  //Duration _initialOffset = Duration(minutes: 59, seconds: 50, milliseconds: 990);

}

class _StopwatchPageState extends State<StopwatchPage>
    with SingleTickerProviderStateMixin {
  // Inisialisasi objek stopwatch dan timer untuk memperbarui tampilan.
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  List<Duration> _lapTimes = []; // Menyimpan waktu lap yang tercatat
  Duration _previousLapTime = Duration.zero; // Waktu lap sebelumnya

  // Inisialisasi animasi untuk efek visual pada tombol dan stopwatch.
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Menyiapkan animasi dengan durasi 500ms dan efek `easeInOut`.
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  // Fungsi untuk memulai stopwatch.
  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
        setState(() {
          // Batas maksimum 59 menit, 59 detik, 990 milidetik
          if (_stopwatch.elapsed.inMinutes >= 60) {
            _stopwatch.reset();
            _lapTimes.clear();
            _previousLapTime = Duration.zero;
            _animationController.reset();
          }
        });
      });
      _animationController.repeat(reverse: true);
    }
  }

  // Fungsi untuk menghentikan stopwatch.
  void _stopStopwatch() {
    _stopwatch.stop();
    _timer?.cancel(); // Menghentikan timer untuk pembaruan tampilan
    _animationController.stop(); // Menghentikan animasi
    setState(() {});
  }

  // Fungsi untuk mereset stopwatch dan daftar lap.
  void _resetStopwatch() {
    _stopwatch.reset();
    _lapTimes.clear();
    _previousLapTime = Duration.zero;
    _animationController.reset(); // Mereset animasi
    setState(() {});
  }

  // Fungsi untuk menambahkan lap (putaran) ke daftar lap.
  void _addLap() {
    final currentElapsed = _stopwatch.elapsed;
    final lapTime = currentElapsed - _previousLapTime;

    //final currentDuration = _initialOffset + _stopwatch.elapsed;
    //final timeStr = _formatDuration(currentDuration);


    setState(() {
      _lapTimes.insert(
          0, lapTime); // Menambahkan lap ke posisi pertama dalam daftar
      _previousLapTime = currentElapsed;
    });
  }

  // Fungsi untuk memformat durasi menjadi string (MM:SS.mmm).
  String _formatDuration(Duration duration) {
    return '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}.'
        '${(duration.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _timer?.cancel(); // Menghentikan timer saat widget dihancurkan
    _animationController.dispose(); // Menghentikan controller animasi
    super.dispose();
  }

  // Widget untuk membuat tombol berbentuk bulat dengan teks dan ikon.
  Widget _buildCircularButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    double size = 64.0,
  }) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(size / 4),
              backgroundColor: color,
              elevation: 8,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size / 2.5,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;
    final timeStr = _formatDuration(elapsed);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                // Tombol kembali
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: Colors.white, size: 28),
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
                    Icon(Icons.timer, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "STOPWATCH",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),

                // Tampilan waktu dengan efek animasi
                Center(
                  child: Container(
                    height: 220,
                    width: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Container(
                            height: 190,
                            width: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: _stopwatch.isRunning
                                      //warna ketika waktu berjalan
                                      ? Colors.purpleAccent.withOpacity(
                                          0.5 + _animation.value * 0.3)
                                      : Colors.transparent,
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  //warna text angka nya
                                  color: Color(0xFF6A11CB),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),

                // Tombol aksi (Mulai, Berhenti, Putaran, Reset)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _stopwatch.isRunning
                      ? [
                          _buildCircularButton(
                            onPressed: _stopStopwatch,
                            icon: Icons.pause,
                            label: "Berhenti",
                            color: Colors.redAccent,
                            size: 72,
                          ),
                          SizedBox(width: 40),
                          _buildCircularButton(
                            onPressed: _addLap,
                            icon: Icons.flag,
                            label: "Putaran",
                            color: Colors.orangeAccent,
                          ),
                        ]
                      : [
                          _buildCircularButton(
                            onPressed: _startStopwatch,
                            icon: Icons.play_arrow,
                            label: "Mulai",
                            color: Colors.greenAccent.shade700,
                            size: 72,
                          ),
                          SizedBox(width: 40),
                          _buildCircularButton(
                            onPressed: _resetStopwatch,
                            icon: Icons.refresh,
                            label: "Reset",
                            color: Colors.blueGrey,
                          ),
                        ],
                ),
                SizedBox(height: 30),

                // Daftar lap (putaran)
                if (_lapTimes.isNotEmpty) ...[
                  Divider(thickness: 1, color: Colors.white.withOpacity(0.5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "DAFTAR PUTARAN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        //mengatur tingkat transparansi (alpha) dari sebuah warna. 1 = transparan
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: _lapTimes.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              leading: CircleAvatar(
                                backgroundColor: Color(0xFF6A11CB),
                                child: Text(
                                  (_lapTimes.length - index).toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                _formatDuration(_lapTimes[index]),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF6A11CB),
                                ),
                              ),
                              trailing: Text(
                                "Putaran ${_lapTimes.length - index}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
