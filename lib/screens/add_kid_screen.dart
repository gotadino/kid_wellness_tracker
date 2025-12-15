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
  bool _isMetric = true;
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Add Child")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Unit toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Metric"),
                    selected: _isMetric,
                    onSelected: (_) => setState(() => _isMetric = true),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text("US"),
                    selected: !_isMetric,
                    onSelected: (_) => setState(() => _isMetric = false),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Child Name",
                ),
              ),
              const SizedBox(height: 12),

              // Birthdate picker (NO formatter, NO lag)
              TextField(
                controller: _birthdateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Birthdate",
                  hintText: "YYYY-MM-DD",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  FocusScope.of(context).unfocus();

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2015),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null) {
                    _birthdateController.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: "Gender"),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _isMetric
                      ? "Height (cm)"
                      : "Height (inches)",
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _isMetric
                      ? "Weight (kg)"
                      : "Weight (lbs)",
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Notes"),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              _saving
                  ? const CircularProgressIndicator()
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

    DateTime? birthdate;
    if (_birthdateController.text.isNotEmpty) {
      birthdate = DateTime.tryParse(_birthdateController.text);
      if (birthdate == null) {
        _showError("Invalid birthdate");
        return;
      }
    }

    double? heightCm;
    double? weightKg;

    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);

    if (h != null) {
      heightCm = _isMetric ? h : h * 2.54;
    }
    if (w != null) {
      weightKg = _isMetric ? w : w * 0.453592;
    }

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirestoreService().addKid(
        user.uid,
        Kid(
          id: '',
          name: _nameController.text.trim(),
          birthdate: birthdate,
          gender: _selectedGender,
          heightCm: heightCm,
          weightKg: weightKg,
          notes: _notesController.text.trim(),
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
