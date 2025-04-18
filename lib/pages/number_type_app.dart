import 'package:flutter/material.dart';

class NumberTypePage extends StatefulWidget {
  const NumberTypePage({Key? key}) : super(key: key);

  @override
  _NumberTypePageState createState() => _NumberTypePageState();
}

class _NumberTypePageState extends State<NumberTypePage> {
  final TextEditingController _controller = TextEditingController();

  bool _isPrime = false;
  bool _isDecimal = false;
  bool _isPositiveInteger = false;
  bool _isNegativeInteger = false;
  bool _isCacah = false;
  bool _isFraction = false;
  bool _hasChecked = false;
  String _error = '';

  bool _checkPrime(int n) {
    if (n < 2) return false;
    for (int i = 2; i <= n ~/ 2; i++) {
      if (n % i == 0) return false;
    }
    return true;
  }

  void _evaluate() {
    setState(() {
      _error = '';
      _hasChecked = true;
      _isPrime = _isDecimal = _isPositiveInteger = _isNegativeInteger = _isCacah = _isFraction = false;

      final input = _controller.text.trim();

      if (input.isEmpty) {
        _error = 'Input tidak boleh kosong';
        return;
      }

      if (RegExp(r'[a-zA-Z]').hasMatch(input)) {
        _error = 'Input mengandung huruf, masukkan input yang valid';
        return;
      }

      if (RegExp(r'[^\d\.\-\/]').hasMatch(input)) {
        _error = 'Input mengandung simbol yang tidak valid. Hanya angka, titik, minus, dan garis miring yang diperbolehkan.';
        return;
      }

      final digitOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitOnly.length > 14) {
        _error = 'Maksimum 14 digit angka yang diperbolehkan';
        return;
      }

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

      final parsed = double.tryParse(input);
      if (parsed == null) {
        _error = 'Masukkan angka valid';
        return;
      }

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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Jenis Bilangan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Masukkan angka',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _evaluate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd0efff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Cek'),
                      ),
                      if (_error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(_error, style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 24),
                      ..._buildResultBoxes(),
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
}