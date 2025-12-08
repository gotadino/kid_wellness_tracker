import 'package:flutter/material.dart';
import 'package:my_app/models/kid.dart';
import 'package:my_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewKidsScreen extends StatelessWidget {
  ViewKidsScreen({super.key});

  final FirestoreService _fs = FirestoreService();

  String _formatDate(DateTime? date) {
    if (date == null) return "—";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Your Children")),

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
            itemCount: kids.length,
            itemBuilder: (context, index) {
              final kid = kids[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(kid.name, style: const TextStyle(fontSize: 18)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Gender: ${kid.gender ?? '—'}\n"
                      "Height: ${kid.heightCm?.toStringAsFixed(1) ?? '—'} cm\n"
                      "Weight: ${kid.weightKg?.toStringAsFixed(1) ?? '—'} kg\n"
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
