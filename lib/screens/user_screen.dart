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
  final Map<int, TextEditingController> qtyControllers = {};

  Future load() async {
    final data = await SupabaseService.getProducts();
    products = data;
    filteredProducts = data;
    setState(() {});
  }

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
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("User Panel"),
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

      body: Column(
        children: [

          // SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: search,
              decoration: const InputDecoration(
                hintText: "Search product...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {

                final p = filteredProducts[index];
                int qty = int.tryParse(p['quantity'].toString()) ?? 0;

                qtyControllers.putIfAbsent(index, () => TextEditingController());

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [

                        ListTile(
                          title: Text(p['name']),
                          subtitle: Text(
                            qty == 0
                                ? "Out of Stock ❌"
                                : "Qty: $qty",
                          ),
                        ),

                        TextField(
                          controller: qtyControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Enter quantity",
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            ElevatedButton(
                              onPressed: () {
                                int current = int.tryParse(
                                    qtyControllers[index]?.text ?? "0") ?? 0;
                                qtyControllers[index]?.text =
                                    (current + 1).toString();
                              },
                              child: const Text("+1"),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                int current = int.tryParse(
                                    qtyControllers[index]?.text ?? "0") ?? 0;
                                qtyControllers[index]?.text =
                                    (current + 5).toString();
                              },
                              child: const Text("+5"),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                int current = int.tryParse(
                                    qtyControllers[index]?.text ?? "0") ?? 0;
                                qtyControllers[index]?.text =
                                    (current + 10).toString();
                              },
                              child: const Text("+10"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: () async {

                            int sellQty = int.tryParse(
                                qtyControllers[index]?.text ?? "0") ?? 0;

                            if (sellQty <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Enter valid quantity")),
                              );
                              return;
                            }

                            if (sellQty > qty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Not enough stock")),
                              );
                              return;
                            }

                            bool? confirm = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Confirm"),
                                content: Text("Sell $sellQty items?"),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("No")),
                                  TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Yes")),
                                ],
                              ),
                            );

                            if (confirm != true) return;

                            int newQty = qty - sellQty;

                            await SupabaseService.updateProductQuantity(
                                p['id'], newQty);

                            // 🔥 NEW FEATURE (SALES HISTORY)
                            await SupabaseService.addSale(
                              p['name'],
                              sellQty,
                            );

                            qtyControllers[index]?.clear();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Sold Successfully ✅")),
                            );

                            load();
                          },
                          child: const Text("Sell"),
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