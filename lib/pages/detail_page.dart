import 'package:flutter/material.dart';
import 'package:project2/data/phone_data.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final int index;
  const DetailPage({super.key, required this.index});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int selectedAuto = 0;
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final phone = phones[widget.index];

    return Scaffold(
      backgroundColor: const Color(0xFFd0efff),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1167B1),
        title: Text("Detail ${phone.model}"),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              isFavorite = !isFavorite;
            });
          },
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          )
          ) 
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            Image.network(phone.imageUrl),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  phone.model,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Text(
                  "\$ ${phone.price[selectedAuto]}",
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              ],
            ),
            Text(
              phone.brand,
              style: TextStyle(color: Colors.grey),
            ),
            Text("Memori: ${phone.memory} GB"),
            Text("Processor: ${phone.processor}"),
            Text("Battery: ${phone.batteryCapacity} mAh"),
            Text("Warna: ${phone.colors.join(", ")}"),
            Text("Size: ${phone.size.join(" x ")} mm"),
            SizedBox(height: 10),
            Text("Storage:"),
            Row(
              children: List.generate(phone.storage.length, (index) {
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedAuto = index;
                      });
                    },
                    child: Text(
                      "${phone.storage[index]}GB",
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
                onPressed: () async {
                  await launchUrl(Uri.parse(phones[widget.index].websiteUrl));
                },
                child: Text(
                  "Go To Store Page",
                  style: TextStyle(color: Colors.white),
                )),
          ],
        ),
      ),
    );
  }
}
