// ignore_for_file: use_build_context_synchronously, avoid_print, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_todo/home.dart';

class AllTodo extends StatefulWidget {
  const AllTodo({super.key});

  @override
  State<AllTodo> createState() => _AllTodoState();
}

class _AllTodoState extends State<AllTodo> {
  // Reference to Firestore collection
  final CollectionReference todos =
      FirebaseFirestore.instance.collection('addtodo');

  // Firebase Auth instance to access the current user
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _editTodo(
      String id, String currentTitle, String currentDescription) async {
    TextEditingController titleController =
        TextEditingController(text: currentTitle);
    TextEditingController descriptionController =
        TextEditingController(text: currentDescription);

    // Show dialog for editing
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit TODO'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newTitle = titleController.text.trim();
                String newDescription = descriptionController.text.trim();

                if (newTitle.isNotEmpty && newDescription.isNotEmpty) {
                  try {
                    await todos.doc(id).update({
                      'title': newTitle,
                      'description': newDescription,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'TODO updated successfully',
                        ),
                        backgroundColor: Colors.grey,
                      ),
                    );
                    Navigator.of(context).pop(); // Close dialog
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update TODO: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeTodo(String id) async {
    try {
      await todos.doc(id).update({
        'completed': true, // Set completed to true
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TODO marked as completed'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete TODO: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user's UID
    User? user = _auth.currentUser;
    if (user == null) {
      // If user is not signed in, navigate to LoginPage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const HomePage()), // Or your LoginPage
        );
      });
      return const Center(child: CircularProgressIndicator());
    }
    String currentUid = user.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: todos
            .where('completed', isEqualTo: false)
            .where('user_id', isEqualTo: currentUid)
            .orderBy('created_at', descending: true)
            .snapshots(), // Listen for real-time updates of incomplete TODOs for current user
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Retrieve documents from the snapshot
          final todosData = snapshot.data?.docs;

          if (todosData == null || todosData.isEmpty) {
            return const Center(child: Text('No TODOs available.'));
          }

          return ListView.builder(
            itemCount: todosData.length,
            itemBuilder: (context, index) {
              // Get data for each document
              final todo = todosData[index];
              final Timestamp addTime = todo['created_at'] as Timestamp;
              final DateTime dateTime = addTime.toDate(); // Convert to DateTime
              final String formattedDate =
                  DateFormat.yMMMMd().format(dateTime); // Format date
              final title = todo['title'] as String? ?? 'No Title';
              final description =
                  todo['description'] as String? ?? 'No Description';
              final id = todo.id; // Get the document ID

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description),
                      Text(formattedDate),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                        ),
                        onPressed: () {
                          _editTodo(id, title, description);
                        },
                        tooltip: 'Edit TODO',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          size: 20,
                        ),
                        onPressed: () {
                          _completeTodo(id);
                        },
                        tooltip: 'Mark as Completed',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
