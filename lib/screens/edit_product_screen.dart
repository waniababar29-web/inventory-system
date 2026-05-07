import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class EditProductScreen extends StatefulWidget {

  final Map product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends State<EditProductScreen> {

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController priceController =
  TextEditingController();

  final TextEditingController quantityController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    nameController.text =
        widget.product['name'].toString();

    priceController.text =
        widget.product['price'].toString();

    quantityController.text =
        widget.product['quantity'].toString();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Product"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            // PRODUCT NAME
            TextField(

              controller: nameController,

              decoration: const InputDecoration(

                labelText: "Product Name",

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // PRICE
            TextField(

              controller: priceController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: "Price",

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // QUANTITY
            TextField(

              controller: quantityController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: "Quantity",

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: () async {

                  await SupabaseService.updateProduct(

                    widget.product['id'],

                    nameController.text,

                    priceController.text,

                    quantityController.text,
                  );

                  if (mounted) {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      const SnackBar(
                        content:
                        Text("Updated ✅"),
                      ),
                    );

                    Navigator.pop(context);
                  }
                },

                child: const Text("Update"),
              ),
            )
          ],
        ),
      ),
    );
  }
}