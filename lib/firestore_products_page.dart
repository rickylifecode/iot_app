import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Lab 3 - reads the 'products' collection from Cloud Firestore.
/// StreamBuilder listens to snapshots(), so the list updates live
/// whenever you add, edit or delete a document.
class FirestoreProductsPage extends StatefulWidget {
  const FirestoreProductsPage({super.key});

  @override
  State<FirestoreProductsPage> createState() => _FirestoreProductsPageState();
}

class _FirestoreProductsPageState extends State<FirestoreProductsPage> {
  final Stream<QuerySnapshot> _productsStream =
      FirebaseFirestore.instance.collection('products').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Products',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                  'No products yet.\nAdd documents in the Firebase console.',
                  textAlign: TextAlign.center),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name =
                  (data['Name'] ?? data['name'] ?? 'Unnamed').toString();
              final price = data['Price'] ?? data['price'];

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE3E5EE)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0A66C2),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle:
                      Text(price != null ? 'Price: $price' : 'No price set'),
                  trailing: Text(
                    doc.id.length > 6 ? '${doc.id.substring(0, 6)}...' : doc.id,
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
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