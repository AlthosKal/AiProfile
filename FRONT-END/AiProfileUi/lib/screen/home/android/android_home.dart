import 'package:flutter/material.dart';

import '../../../route/app_routes.dart';

class AndroidHomeScreen extends StatelessWidget {
  const AndroidHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AndroidHome();
  }
}

class AndroidHome extends StatefulWidget {
  const AndroidHome({super.key});

  @override
  State<AndroidHome> createState() => _AndroidHomeState();
}

class _AndroidHomeState extends State<AndroidHome> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Aquí puedes cambiar la vista o hacer navegación por rutas
    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.transactions);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.chat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Bienvenido a AiProfile',
          style: TextStyle(color: Colors.white),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Historial', style: TextStyle(color: Colors.white)),
                  Row(
                    children: [
                      IconButton(
                        onPressed:
                            () =>
                                Navigator.pushNamed(context, AppRoutes.profile),
                        icon: const Icon(Icons.person, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'AiProfile, una app financiera con IA integrada',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on, color: Colors.white),
            label: 'Transacciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.white),
            label: 'Asistente',
          ),
        ],
      ),
    );
  }
}
