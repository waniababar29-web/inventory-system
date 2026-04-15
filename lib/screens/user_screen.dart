import 'login_screen.dart';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {

  List products = [];
  List filteredProducts = [];

  final TextEditingController searchController = TextEditingController();

  // 🔄 LOAD DATA FROM DATABASE
  Future load() async {
    try {
      final data = await SupabaseService.getProducts();
      products = data;
      filteredProducts = data;
      setState(() {});
    } catch (e) {
      print("Error loading products: $e");
    }
  }

  // 🔍 SEARCH FUNCTION
  void search(String value) {
    filteredProducts = products
        .where((p) =>
        p['name'].toString().toLowerCase().contains(value.toLowerCase()))
        .toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("User Panel"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          )
        ],
      ),

      // 🟢 BODY
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
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 📦 PRODUCT LIST
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("No Products"))
                : ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {

                final p = filteredProducts[index];

                // 🔒 SAFE PARSE (NO CRASH)
                int qty = int.tryParse(p['quantity'].toString()) ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(p['name'] ?? "No Name"),

                    subtitle: Text(
                      qty == 0
                          ? "Out of Stock ❌"
                          : "Qty: $qty",
                      style: TextStyle(
                        color: qty == 0
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),

                    // 🛒 SELL BUTTON
                    trailing: IconButton(
                      icon: const Icon(Icons.shopping_cart,
                          color: Colors.green),

                      onPressed: () async {

                        final result = await SupabaseService.sellProduct(
                          p['id'],
                          qty,
                        );

                        if (result == "out") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Out of Stock ❌")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Product Sold ✅")),
                          );
                          load(); // 🔄 refresh list
                        }
                      },
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