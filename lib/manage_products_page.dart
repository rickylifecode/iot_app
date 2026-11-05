import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Lab 3 homework - CRUD on the 'products' collection.
///   Create: "Add product" button  -> collection.add({...})
///   Read:   StreamBuilder         -> collection.snapshots()
///   Update: pencil icon           -> doc.reference.update({...})
///   Delete: trash icon            -> doc.reference.delete()
class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('products');

  void _msg(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  /// Opens the form. doc == null -> ADD mode, otherwise -> EDIT mode.
  Future<void> _openForm({QueryDocumentSnapshot<Map<String, dynamic>>? doc}) {
    final data = doc?.data();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 8, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: _ProductForm(
          title: doc == null ? 'Add product' : 'Edit product',
          initialName: (data?['Name'] ?? '').toString(),
          initialPrice: data?['Price']?.toString() ?? '',
          initialInStock: data?['inStock'] as bool? ?? true,
          onSave: (name, price, inStock) async {
            final fields = {'Name': name, 'Price': price, 'inStock': inStock};
            try {
              if (doc == null) {
                await _col.add(fields); // CREATE
                if (mounted) _msg('Product added');
              } else {
                await doc.reference.update(fields); // UPDATE
                if (mounted) _msg('Product updated');
              }
            } catch (e) {
              if (mounted) _msg('Error: $e');
            }
          },
        ),
      ),
    );
  }

  Future<void> _delete(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final name = (doc.data()['Name'] ?? 'this product').toString();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('"$name" will be removed permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await doc.reference.delete(); // DELETE
      if (mounted) _msg('Product deleted');
    } catch (e) {
      if (mounted) _msg('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _col.snapshots(), // READ (live)
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Something went wrong:\n${snapshot.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('No products yet.\nTap "Add product" to create one.',
                  textAlign: TextAlign.center),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();
              final name = (data['Name'] ?? 'Unnamed').toString();
              final price = data['Price'];
              final inStock = data['inStock'] == true;
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE3E5EE)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 16, right: 4),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0A66C2),
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${price != null ? 'Price: $price' : 'No price'}  •  '
                      '${inStock ? 'In stock' : 'Out of stock'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openForm(doc: doc),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        onPressed: () => _delete(doc),
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

// ---------------------------------------------------------------------
// The add / edit form (shown in a bottom sheet)
// ---------------------------------------------------------------------
class _ProductForm extends StatefulWidget {
  final String title;
  final String initialName;
  final String initialPrice;
  final bool initialInStock;
  final Future<void> Function(String name, double price, bool inStock) onSave;

  const _ProductForm({
    required this.title,
    required this.initialName,
    required this.initialPrice,
    required this.initialInStock,
    required this.onSave,
  });

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName);
  late final TextEditingController _price =
      TextEditingController(text: widget.initialPrice);
  late bool _inStock = widget.initialInStock;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final price = double.parse(_price.text.trim().replaceAll(',', '.'));
    await widget.onSave(_name.text.trim(), price, _inStock);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _name,
            decoration: _decoration('Name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _price,
            decoration: _decoration('Price'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => double.tryParse(
                        (v ?? '').trim().replaceAll(',', '.')) ==
                    null
                ? 'Enter a valid number'
                : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('In stock'),
            value: _inStock,
            onChanged: (v) => setState(() => _inStock = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : const Text('Save',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
