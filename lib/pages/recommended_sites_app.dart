import 'package:flutter/material.dart';
import 'package:project2/data/phone_data.dart';
import 'package:project2/pages/detail_page.dart';

class WebsiteRecommendationPage extends StatefulWidget {
  const WebsiteRecommendationPage({super.key});

  @override
  State<WebsiteRecommendationPage> createState() => _WebsiteRecommendationPageState();
}

class _WebsiteRecommendationPageState extends State<WebsiteRecommendationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFd0efff),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1167B1),
        title: Text("Phone Recomendation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) => _phonesData(context, index),
          itemCount: phones.length,
        ),
      ),
    );
  }

  Widget _phonesData(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DetailPage(index: index)));
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 1),
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.network(phones[index].imageUrl),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phones[index].model,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    phones[index].brand,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "\$ ${phones[index].price[0]}",
                    style: TextStyle(color: Colors.green),
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
