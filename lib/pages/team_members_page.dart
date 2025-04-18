import 'package:flutter/material.dart';

class MemberListScreen extends StatefulWidget {
  @override
  _MemberListScreenState createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  PageController _pageController = PageController();
  List<Map<String, String>> members = [
    {
      'spotify': '---------------- || -----------------',
      'name': 'Muhammad Almas Farros D',
      'nim': '123220133',
      'image': 'assets/images/farros.jpg'
    },
    {
      'spotify': '---------------- || -----------------',
      'name': 'Jeslyn Vicky Hanjaya',
      'nim': '123220150',
      'image': 'assets/images/jeslyn.jpg'
    },
    {
      'spotify': '---------------- || -----------------',
      'name': 'Resti Ramadhani',
      'nim': '123220147',
      'image': 'assets/images/resti.jpg'
    },
  ];
  int currentIndex = 0;

  void nextPage() {
    if (currentIndex < members.length - 1) {
      setState(() {
        currentIndex++;
        _pageController.animateToPage(currentIndex,
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      });
    }
  }

  void prevPage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _pageController.animateToPage(currentIndex,
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Daftar Anggota'),
      centerTitle: true, // Pusatkan title
    ),
      backgroundColor: const Color.fromARGB(255, 243, 221, 191),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemCount: members.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Container(
                    width: 300, // Ukuran Card
                    height: 500,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 176, 73, 73),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(8), // Biar lebih rapi
                          child: Image.asset(
                            members[index]['image']!,
                            width: 300, // Ukuran gambar lebih kecil
                            height: 300, // Biar proporsional
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 40),
                        
                        Text(members[index]['spotify']!,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text(members[index]['name']!,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text(members[index]['nim']!,
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Tombol sebelah kiri
            Positioned(
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back, size: 30),
                onPressed: prevPage,
              ),
            ),
            // Tombol sebelah kanan
            Positioned(
              right: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_forward, size: 30),
                onPressed: nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}