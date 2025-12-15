import 'package:flutter/material.dart';
import 'package:my_app/models/kid.dart';
import 'package:my_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewKidsScreen extends StatefulWidget {
  const ViewKidsScreen({super.key});

  @override
  State<ViewKidsScreen> createState() => _ViewKidsScreenState();
}

class _ViewKidsScreenState extends State<ViewKidsScreen> {
  final FirestoreService _fs = FirestoreService();
  bool _isMetric = true;

  String _formatDate(DateTime? date) {
    if (date == null) return "—";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  int? _calculateAge(DateTime? birthdate) {
    if (birthdate == null) return null;
    final today = DateTime.now();
    int age = today.year - birthdate.year;
    if (today.month < birthdate.month ||
        (today.month == birthdate.month && today.day < birthdate.day)) {
      age--;
    }
    return age;
  }

  String _formatHeight(double? cm) {
    if (cm == null) return "—";
    if (_isMetric) {
      return "${cm.toStringAsFixed(1)} cm";
    } else {
      final inches = cm / 2.54;
      final feet = inches ~/ 12;
      final remainingInches = (inches % 12).round();
      return "$feet ft $remainingInches in";
    }
  }

  String _formatWeight(double? kg) {
    if (kg == null) return "—";
    if (_isMetric) {
      return "${kg.toStringAsFixed(1)} kg";
    } else {
      return "${(kg * 2.20462).toStringAsFixed(1)} lbs";
    }
  }

  String _calculateBMI(double? kg, double? cm) {
    if (kg == null || cm == null) return "—";
    double bmi;
    if (_isMetric) {
      final m = cm / 100;
      bmi = kg / (m * m);
    } else {
      // Convert to pounds/inches for US units
      final inches = cm / 2.54;
      final pounds = kg * 2.20462;
      bmi = pounds / (inches * inches) * 703;
    }
    return bmi.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Children"),
        actions: [
          Row(
            children: [
              const Text("Metric"),
              Switch(
                value: !_isMetric,
                onChanged: (v) => setState(() => _isMetric = !v),
              ),
              const Text("US"),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/addkid");
        },
      ),
      body: StreamBuilder<List<Kid>>(
        stream: _fs.streamKids(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final kids = snapshot.data!;
          if (kids.isEmpty) {
            return const Center(child: Text("No children added yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: kids.length,
            itemBuilder: (context, index) {
              final kid = kids[index];
              final age = _calculateAge(kid.birthdate);
              final bmi = _calculateBMI(kid.weightKg, kid.heightCm);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(kid.name, style: const TextStyle(fontSize: 18)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Age: ${age ?? '—'}\n"
                      "Gender: ${kid.gender ?? '—'}\n"
                      "Height: ${_formatHeight(kid.heightCm)}\n"
                      "Weight: ${_formatWeight(kid.weightKg)}\n"
                      "BMI: $bmi\n"
                      "Birthdate: ${_formatDate(kid.birthdate)}",
                    ),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _fs.deleteKid(uid, kid.id),
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
