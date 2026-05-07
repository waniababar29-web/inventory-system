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

  // ✅ recent products
  List recentProducts = [];

  // ✅ popup only once
  bool popupShown = false;

  // 🔄 LOAD DATA
  Future loadData() async {

    try {

      // 🟢 PRODUCTS
      final products = await SupabaseService.getProducts();

      totalProducts = products.length;

      // 🔥 RECENT PRODUCTS
      recentProducts = products.reversed.take(5).toList();

      // 🟢 LOW STOCK
      List lowItems = products.where((p) {

        int qty = int.tryParse(
          p['quantity'].toString(),
        ) ?? 0;

        return qty < 5;

      }).toList();

      lowStock = lowItems.length;

      // 🟢 SALES
      totalSales = 0;

      try {

        final sales = await SupabaseService.getSales();

        for (var s in sales) {

          totalSales += int.tryParse(
            s['quantity'].toString(),
          ) ?? 0;
        }

      } catch (e) {

        totalSales = 0;

        print("Sales Error: $e");
      }

      setState(() {});

      // 🔥 LOW STOCK POPUP
      if (lowItems.isNotEmpty && !popupShown) {

        popupShown = true;

        Future.delayed(Duration.zero, () {

          showDialog(
            context: context,

            builder: (context) {

              return Dialog(

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Container(

                  width: 300,
                  height: 280,

                  padding: const EdgeInsets.all(18),

                  child: Column(

                    children: [

                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 45,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Low Stock Alert",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: ListView.builder(
                          itemCount: lowItems.length,

                          itemBuilder: (context, index) {

                            final p = lowItems[index];

                            return Container(

                              margin: const EdgeInsets.only(bottom: 8),

                              padding: const EdgeInsets.all(8),

                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                                children: [

                                  Expanded(
                                    child: Text(
                                      p['name'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  Text(
                                    "${p['quantity']} left",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          onPressed: () {
                            Navigator.pop(context);
                          },

                          child: const Text(
                            "OK",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
      }

    } catch (e) {

      print("Dashboard Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  // 🔄 REFRESH AFTER RETURN
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

      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [

          // 🔄 REFRESH
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: loadData,
          ),

          // 🔓 LOGOUT
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),

            onPressed: () {

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [

          // 🔥 BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 🔥 DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.20),
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  // 🔥 HEADER
                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [

                        Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: const Color(0xff5B4CF0),
                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: const [

                            Text(
                              "Admin Dashboard",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 2),

                            Text(
                              "Pharmacy Inventory Management",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🔥 STATS
                  Row(
                    children: [

                      Expanded(
                        child: buildCard(
                          "Total Products",
                          totalProducts.toString(),
                          Icons.inventory_2_outlined,
                          const Color(0xff4A7CFF),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: buildCard(
                          "Total Sales",
                          totalSales.toString(),
                          Icons.shopping_cart_outlined,
                          const Color(0xff22C55E),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: buildCard(
                          "Low Stock",
                          lowStock.toString(),
                          Icons.warning_amber_rounded,
                          const Color(0xffFF4D4F),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 🔥 ACTION BUTTONS
                  Row(
                    children: [

                      Expanded(
                        child: actionButton(
                          title: "View Products",
                          subtitle: "Browse inventory",
                          icon: Icons.list_alt_rounded,
                          color: const Color(0xff5B4CF0),

                          onTap: () => goAndRefresh(
                            ProductListScreen(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: actionButton(
                          title: "Add Product",
                          subtitle: "Add new items",
                          icon: Icons.add,
                          color: const Color(0xff10B981),

                          onTap: () => goAndRefresh(
                            AddProductScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 🔥 RECENT PRODUCTS
                  Container(

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [

                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        const Text(
                          "Recent Products",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // TABLE HEADER
                        Row(
                          children: const [

                            Expanded(
                              flex: 3,
                              child: Text(
                                "PRODUCT",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            Expanded(
                              child: Text(
                                "STOCK",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            Expanded(
                              child: Text(
                                "STATUS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        // 🔥 PRODUCTS LIST
                        ListView.builder(

                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),

                          itemCount: recentProducts.length,

                          itemBuilder: (context, index) {

                            final p = recentProducts[index];

                            int qty = int.tryParse(
                              p['quantity'].toString(),
                            ) ?? 0;

                            bool low = qty < 5;

                            return Padding(

                              padding: const EdgeInsets.only(bottom: 14),

                              child: Row(
                                children: [

                                  // PRODUCT NAME
                                  Expanded(
                                    flex: 3,

                                    child: Row(
                                      children: [

                                        CircleAvatar(
                                          radius: 18,

                                          backgroundColor:
                                          low
                                              ? Colors.red.withOpacity(0.15)
                                              : Colors.blue.withOpacity(0.15),

                                          child: Icon(
                                            Icons.medication,
                                            size: 18,

                                            color:
                                            low
                                                ? Colors.red
                                                : Colors.blue,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Text(
                                            p['name'],
                                            overflow: TextOverflow.ellipsis,

                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // STOCK
                                  Expanded(
                                    child: Text(
                                      qty.toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),

                                  // STATUS
                                  Expanded(
                                    child: Container(

                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),

                                      decoration: BoxDecoration(
                                        color:
                                        low
                                            ? Colors.red.withOpacity(0.15)
                                            : Colors.green.withOpacity(0.15),

                                        borderRadius: BorderRadius.circular(30),
                                      ),

                                      child: Text(
                                        low ? "Low" : "Good",

                                        textAlign: TextAlign.center,

                                        style: TextStyle(
                                          color:
                                          low
                                              ? Colors.red
                                              : Colors.green,

                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 SMALL COMPACT CARD
  Widget buildCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Expanded(
                child: Text(
                  title,

                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            value,

            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 SMALL ACTION BUTTON
  Widget actionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {

    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(20),

      child: Container(

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [

            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [

            Container(

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,

                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}