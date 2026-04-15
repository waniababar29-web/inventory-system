import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),

            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
            ),

            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                final result = await SupabaseService.addProduct(
                  nameController.text,
                  priceController.text,
                  qtyController.text,
                );

                if (result == "duplicate") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Product already exists ❌")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Product added ✅")),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}