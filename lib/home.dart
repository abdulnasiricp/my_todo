import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/Auth/auth_services.dart';
import 'package:my_todo/add_todo.dart';
import 'package:my_todo/all_todo.dart';
import 'package:my_todo/completed_todo.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;

  // List of widgets to display for each tab
  final List<Widget> _pages = [const AllTodo(), const CompletedTodo()];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Get current date
  String get currentDate => DateFormat.yMMMMd().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'TODO APP',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.lightGreen,
          actions: [
            // Display the current date in the AppBar
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  currentDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // Sign Out Button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _authService.signOut();
                // Navigation is handled by AuthWrapper
              },
              tooltip: 'Sign Out',
            ),
          ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        shape: const CircleBorder(),
        onPressed: () {
          Get.to(() => const AddTodo());
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: _pages[_currentIndex], // Displays selected page content
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Currently selected tab
        onTap: _onTabTapped, // Change tab on tap
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Completed',
          ),
        ],
        selectedItemColor: Colors.blue, // Selected item color
        unselectedItemColor: Colors.white, // Unselected item color
        backgroundColor: Colors.lightGreen,
      ),
    );
  }
}
