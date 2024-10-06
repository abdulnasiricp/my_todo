// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_todo/Utils/my_button.dart';
import 'package:my_todo/home.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({super.key});

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Firebase Auth instance to access the current user
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to add data to Firestore
  Future<void> _addData() async {
    if (_formKey.currentState!.validate()) {
      // Get data from controllers
      String title = _titleController.text.trim();
      String description = _descriptionController.text.trim();

      // Get the current user's UID
      User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not signed in!')),
        );
        return;
      }
      String uid = user.uid;

      // Reference to Firestore collection
      CollectionReference todos =
          FirebaseFirestore.instance.collection('addtodo');

      // Add data
      try {
        await todos.add({
          'title': title,
          'description': description,
          'created_at': Timestamp.now(),
          'completed': false, // Initialize as not completed
          'user_id': uid, // Store the user's UID with the todo
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TODO Added Successfully')),
        );

        // Clear the form
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();

        // Navigate to HomePage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add TODO: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers when not needed
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add TODO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Title Field
                TextFormField(
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Description Field
                TextFormField(
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  maxLines: null,
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Submit Button
                MyButton(
                  onPressed: _addData,
                  title: const Text('ADD TODO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
