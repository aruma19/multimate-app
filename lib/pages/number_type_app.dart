import 'package:flutter/material.dart';

class NumberTypePage extends StatefulWidget {
  @override
  _NumberTypePageState createState() => _NumberTypePageState();
}

class _NumberTypePageState extends State<NumberTypePage> {
  final controller = TextEditingController();
  String result = '';

  bool isPrime(int num) {
    if (num < 2) return false;
    for (int i = 2; i <= num ~/ 2; i++) {
      if (num % i == 0) return false;
    }
    return true;
  }

  void checkNumberType() {
    final input = int.tryParse(controller.text);
    if (input == null) {
      setState(() => result = "Masukkan angka valid");
      return;
    }

    List<String> types = [];

    if (input >= 0) types.add("Bilangan cacah");
    if (input.isNegative) types.add("Bilangan negatif");
    if (input is int) types.add("Bilangan bulat");
    if (isPrime(input)) types.add("Bilangan prima");

    setState(() => result = types.join(", "));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Jenis Bilangan")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Masukkan angka"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkNumberType,
              child: Text("Cek"),
            ),
            SizedBox(height: 20),
            Text(result, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
