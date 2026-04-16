import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'product_list_screen.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int totalProducts = 0;
  int totalSales = 0;
  int lowStock = 0;

  Future loadData() async {
    try {
      final products = await SupabaseService.getProducts();
      final sales = await SupabaseService.getSales();

      // ✅ TOTAL PRODUCTS
      totalProducts = products.length;

      // ✅ TOTAL SALES
      totalSales = 0;
      for (var s in sales) {
        totalSales += int.tryParse(s['quantity'].toString()) ?? 0;
      }

      // ✅ LOW STOCK LIST
      List lowItems = products.where((p) {
        int qty = int.tryParse(p['quantity'].toString()) ?? 0;
        return qty < 5;
      }).toList();

      lowStock = lowItems.length;

      setState(() {});

      // 🔔 POPUP ALERT
      if (lowItems.isNotEmpty) {
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("⚠ Low Stock"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: lowItems.map((p) {
                    return Text("${p['name']} (${p['quantity']})");
                  }).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  )
                ],
              );
            },
          );
        });
      }

    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future goAndRefresh(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [

          // BACKGROUND SAME
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.jpg",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [

                // 🔥 SAME UI (ONE ROW)
                Row(
                  children: [
                    Expanded(child: buildCard("Products", totalProducts, Colors.blue)),
                    const SizedBox(width: 8),
                    Expanded(child: buildCard("Sales", totalSales, Colors.green)),
                    const SizedBox(width: 8),
                    Expanded(child: buildCard("Low", lowStock, Colors.red)),
                  ],
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () => goAndRefresh(ProductListScreen()),
                  child: const Text("View Products"),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () => goAndRefresh(AddProductScreen()),
                  child: const Text("Add Product"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            "$value",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}