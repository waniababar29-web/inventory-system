import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {

  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState
    extends State<ProductListScreen> {

  List products = [];
  List filteredProducts = [];

  final TextEditingController searchController =
  TextEditingController();

  // 🔄 LOAD PRODUCTS
  Future load() async {

    products = await SupabaseService.getProducts();

    filteredProducts = products;

    setState(() {});
  }

  // 🔍 SEARCH
  void search(String value) {

    filteredProducts = products.where((p) {

      return p['name']
          .toString()
          .toLowerCase()
          .contains(value.toLowerCase());

    }).toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    load();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Admin Panel"),

        actions: [

          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),

      body: Column(
        children: [

          // 🔍 SEARCH BAR
          Padding(

            padding: const EdgeInsets.all(10),

            child: TextField(

              controller: searchController,

              onChanged: search,

              decoration: InputDecoration(

                hintText: "Search product...",

                prefixIcon:
                const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 📦 PRODUCTS
          Expanded(

            child: filteredProducts.isEmpty

                ? const Center(
              child: Text("No Products"),
            )

                : ListView.builder(

              itemCount:
              filteredProducts.length,

              itemBuilder:
                  (context, index) {

                final p =
                filteredProducts[index];

                int qty =
                    int.tryParse(
                      p['quantity']
                          .toString(),
                    ) ??
                        0;

                return Card(

                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  child: ListTile(

                    title: Text(
                      p['name']
                          .toString(),
                    ),

                    subtitle: Text(

                      qty == 0

                          ? "Out of Stock ❌"

                          : "Price: ${p['price']} | Qty: $qty",

                      style: TextStyle(
                        color:
                        qty == 0
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),

                    trailing: Row(

                      mainAxisSize:
                      MainAxisSize.min,

                      children: [

                        // ✏ EDIT
                        IconButton(

                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),

                          onPressed: () async {

                            await Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    EditProductScreen(
                                      product: p,
                                    ),
                              ),
                            );

                            load();
                          },
                        ),

                        // 🗑 DELETE
                        IconButton(

                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),

                          onPressed: () async {

                            await SupabaseService
                                .deleteProduct(
                              p['id'],
                            );

                            load();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}