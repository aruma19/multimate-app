// import 'package:flutter/material.dart';
// import 'pages/stopwatch_page.dart';
// import 'number_type_page.dart';
// import 'tracking_lbs_page.dart';
// import 'time_conversion_page.dart';
// import 'site_recommendation_page.dart';
// import 'favorite_page.dart';
// import '../widgets/bottom_nav_bar.dart';

// class HomePage extends StatelessWidget {
//   final List<Map<String, dynamic>> menuItems = [
//     {'title': 'Stopwatch', 'page': StopwatchPage()},
//     {'title': 'Jenis Bilangan', 'page': NumberTypePage()},
//     {'title': 'Tracking LBS', 'page': TrackingLBSPage()},
//     {'title': 'Konversi Waktu', 'page': TimeConversionPage()},
//     {'title': 'Daftar Situs & Favorite', 'page': SiteRecommendationPage()},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Halaman Utama")),
//       bottomNavigationBar: BottomNavBar(currentIndex: 0),
//       body: ListView.builder(
//         itemCount: menuItems.length,
//         itemBuilder: (context, index) => ListTile(
//           title: Text(menuItems[index]['title']),
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => menuItems[index]['page']),
//           ),
//         ),
//       ),
//     );
//   }
// }
