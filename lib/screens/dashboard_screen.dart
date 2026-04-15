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

  // 🔄 LOAD DATA
  Future loadData() async {
    try {
      final data = await SupabaseService.getProducts();
      totalProducts = data.length;
      setState(() {});
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 🔄 NAVIGATION + REFRESH
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

      // 🟢 APPBAR
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
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

      // 🟢 BODY WITH BACKGROUND
      body: Stack(
        children: [

          // 🖼 BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 🌫 DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),

          // 🔲 ORIGINAL CONTENT (UNCHANGED)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                // 📊 TOTAL PRODUCTS CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Total Products",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "$totalProducts",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 📦 VIEW PRODUCTS BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => goAndRefresh(ProductListScreen()),
                  child: const Text("View Products"),
                ),

                const SizedBox(height: 15),

                // ➕ ADD PRODUCT BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
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
}