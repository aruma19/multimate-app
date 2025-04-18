import 'package:flutter/material.dart';

class TimeConverterPage extends StatefulWidget {
  const TimeConverterPage({Key? key}) : super(key: key);

  @override
  _TimeConverterPageState createState() => _TimeConverterPageState();
}

class _TimeConverterPageState extends State<TimeConverterPage> {
  final TextEditingController _controller = TextEditingController();
  double? _years;
  double? _months;
  int? _weeks;
  int? _days;
  int? _hours;
  int? _minutes;
  int? _seconds;
  String _error = '';

  final Color resultBoxColor = Color(0xFFd9e8ff); // biru muda senada dengan background

  void _convertTime() {
    final input = _controller.text.trim();
    setState(() {
      _error = '';
      _years = null;
      _months = null;
      _weeks = null;
      _days = null;
      _hours = null;
      _minutes = null;
      _seconds = null;

      if (input.isEmpty) {
        _error = 'Input tidak boleh kosong';
        return;
      }

      if (RegExp(r'[a-zA-Z]').hasMatch(input)) {
        _error = 'Input mengandung huruf, masukkan input yang valid';
        return;
      }

      if (RegExp(r'[^\d\.\-]').hasMatch(input)) {
        _error =
            'Input mengandung simbol yang tidak valid. Hanya angka, titik, dan minus yang diperbolehkan.';
        return;
      }

      final digitOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitOnly.length > 14) {
        _error = 'Maksimum 14 digit angka yang diperbolehkan';
        return;
      }

      final parsed = double.tryParse(input);
      if (parsed == null) {
        _error = 'Masukkan angka valid';
        return;
      }

      final months = parsed * 12;
      final days = (parsed * 365).round();
      final weeks = (days / 7).round();
      final hours = days * 24;
      final minutes = hours * 60;
      final seconds = minutes * 60;

      _years = parsed;
      _months = months;
      _weeks = weeks;
      _days = days;
      _hours = hours;
      _minutes = minutes;
      _seconds = seconds;
    });
  }

  String _getDisplayValue(dynamic value) {
    if (value == null) return '-';
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
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
          child: Column(
            children: [
              // Custom header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.0001),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Konversi Tahun ke Bulan, Minggu, Hari, Jam, Menit, dan Detik',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Masukkan jumlah tahun',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_error.isNotEmpty)
                        Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _convertTime,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd0efff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Konversi'),
                      ),
                      const SizedBox(height: 30),
                      _buildResultBox('Tahun', _getDisplayValue(_years)),
                      _buildResultBox('Bulan', _getDisplayValue(_months)),
                      _buildResultBox('Minggu', _getDisplayValue(_weeks)),
                      _buildResultBox('Hari', _getDisplayValue(_days)),
                      _buildResultBox('Jam', _getDisplayValue(_hours)),
                      _buildResultBox('Menit', _getDisplayValue(_minutes)),
                      _buildResultBox('Detik', _getDisplayValue(_seconds)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultBox(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: resultBoxColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}