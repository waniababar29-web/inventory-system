import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product['name']);
    priceController = TextEditingController(text: widget.product['price']);
    quantityController = TextEditingController(text: widget.product['quantity']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
            ),

            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                await SupabaseService.updateProduct(
                  widget.product['id'],
                  nameController.text,
                  priceController.text,
                  quantityController.text,
                );

                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}