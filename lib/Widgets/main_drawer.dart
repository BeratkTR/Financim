import 'package:flutter/material.dart';
import '../Screens/home_screen.dart';
import '../Screens/monthly_view_screen.dart';

class MainDrawer extends StatelessWidget {
  final String currentRoute;

  const MainDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            accountName: Text("Kullanıcı", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text("finance@app.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.indigo, size: 40),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: currentRoute == 'home' ? Colors.indigo : Colors.grey),
            title: Text(
              "Ana Sayfa",
              style: TextStyle(
                color: currentRoute == 'home' ? Colors.indigo : Colors.black,
                fontWeight: currentRoute == 'home' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: currentRoute == 'home',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'home') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_month, color: currentRoute == 'monthly' ? Colors.indigo : Colors.grey),
            title: Text(
              "Aylık Görünüm",
              style: TextStyle(
                color: currentRoute == 'monthly' ? Colors.indigo : Colors.black,
                fontWeight: currentRoute == 'monthly' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: currentRoute == 'monthly',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'monthly') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MonthlyViewScreen()),
                );
              }
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("v1.2.0", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
