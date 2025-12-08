import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/models/kid.dart';
import 'package:my_app/services/firestore_service.dart';

class AddKidScreen extends StatefulWidget {
  const AddKidScreen({super.key});

  @override
  State<AddKidScreen> createState() => _AddKidScreenState();
}

class _AddKidScreenState extends State<AddKidScreen> {
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Child")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Child Name"),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _birthdateController,
                decoration: const InputDecoration(
                  labelText: "Birthdate (YYYY-MM-DD)",
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: "Height (cm)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Notes"),
                maxLines: 3,
              ),

              const SizedBox(height: 25),

              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveKid,
                      child: const Text("Save"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveKid() async {
    if (_nameController.text.trim().isEmpty) {
      _showError("Please enter a name.");
      return;
    }

    if (_saving) return;
    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Not logged in");

      await FirestoreService().addKid(
        user.uid,
        Kid(
          id: '',
          name: _nameController.text.trim(),
          birthdate: _birthdateController.text.isEmpty
              ? null
              : DateTime.tryParse(_birthdateController.text),
          heightCm: double.tryParse(_heightController.text),
          weightKg: double.tryParse(_weightController.text),
          notes: _notesController.text.trim(),
        ),
      );

      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
