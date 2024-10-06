// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for getting the current user

class CompletedTodo extends StatefulWidget {
  const CompletedTodo({super.key});

  @override
  State<CompletedTodo> createState() => _CompletedTodoState();
}

class _CompletedTodoState extends State<CompletedTodo> {
  // Reference to Firestore collection
  CollectionReference todos = FirebaseFirestore.instance.collection('addtodo');

  // Get the current user's ID
  String? getUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<void> _deleteTodo(String id) async {
    try {
      await todos.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TODO deleted successfully'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete TODO: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = getUserId(); // Get the logged-in user ID

    return Scaffold(
      body: userId == null
          ? const Center(
              child: Text('User not logged in'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: todos
                  .where('completed', isEqualTo: true)
                  .where('user_id', isEqualTo: userId)
                  .snapshots(), // Fetch only completed TODOs of the logged-in user
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final completedTodos = snapshot.data?.docs;

                if (completedTodos == null || completedTodos.isEmpty) {
                  return const Center(
                      child: Text('No completed TODOs available.'));
                }

                return ListView.builder(
                  itemCount: completedTodos.length,
                  itemBuilder: (context, index) {
                    final todo = completedTodos[index];
                    final title = todo['title'];
                    final description = todo['description'];
                    final id = todo.id; // Get the document ID

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10.0),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(description),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                          ),
                          onPressed: () {
                            _deleteTodo(id);
                          },
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
