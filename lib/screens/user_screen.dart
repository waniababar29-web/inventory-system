import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {

  List products = [];
  List filteredProducts = [];

  final TextEditingController searchController =
  TextEditingController();

  // quantity controllers
  Map<int, TextEditingController> qtyControllers = {};

  // LOAD DATA
  Future load() async {

    final data =
    await SupabaseService.getProducts();

    products = data;
    filteredProducts = data;

    // create controllers
    qtyControllers.clear();

    for (var p in data) {

      qtyControllers[p['id']] =
          TextEditingController(text: "1");
    }

    setState(() {});
  }

  // SEARCH
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

        title: const Text("User Panel"),

        leading: IconButton(

          icon: const Icon(Icons.arrow_back),

          onPressed: () =>
              Navigator.pop(context),
        ),

        actions: [

          IconButton(

            icon: const Icon(Icons.logout),

            onPressed: () {

              Navigator.pushReplacement(

                context,

                MaterialPageRoute(

                  builder: (context) =>
                  const LoginScreen(),
                ),
              );
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

                filled: true,

                fillColor:
                Colors.grey.shade200,

                border: OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(12),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📦 LIST
          Expanded(

            child: ListView.builder(

              itemCount:
              filteredProducts.length,

              itemBuilder:
                  (context, index) {

                final p =
                filteredProducts[index];

                int qty =
                    int.tryParse(
                      p['quantity'].toString(),
                    ) ??
                        0;

                final controller =
                qtyControllers[p['id']]!;

                return Card(

                  elevation: 3,

                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(12),
                  ),

                  child: Padding(

                    padding:
                    const EdgeInsets.all(10),

                    child: Column(
                      children: [

                        // NAME + STOCK
                        Row(

                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                          children: [

                            Text(

                              p['name'],

                              style:
                              const TextStyle(

                                fontSize: 16,

                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            Container(

                              padding:
                              const EdgeInsets
                                  .symmetric(

                                horizontal: 8,
                                vertical: 4,
                              ),

                              decoration:
                              BoxDecoration(

                                color: qty == 0
                                    ? Colors.red
                                    : Colors.green,

                                borderRadius:
                                BorderRadius
                                    .circular(8),
                              ),

                              child: Text(

                                qty == 0
                                    ? "Out"
                                    : "Stock: $qty",

                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ➕➖ + SELL
                        Row(
                          children: [

                            // ➖
                            IconButton(

                              icon: const Icon(
                                Icons.remove,
                              ),

                              onPressed: () {

                                int val =
                                    int.tryParse(
                                      controller.text,
                                    ) ??
                                        1;

                                if (val > 1) {

                                  controller.text =
                                      (val - 1)
                                          .toString();
                                }
                              },
                            ),

                            // INPUT
                            SizedBox(

                              width: 50,

                              child: TextField(

                                controller:
                                controller,

                                textAlign:
                                TextAlign.center,

                                keyboardType:
                                TextInputType
                                    .number,
                              ),
                            ),

                            // ➕
                            IconButton(

                              icon: const Icon(
                                Icons.add,
                              ),

                              onPressed: () {

                                int val =
                                    int.tryParse(
                                      controller.text,
                                    ) ??
                                        1;

                                controller.text =
                                    (val + 1)
                                        .toString();
                              },
                            ),

                            const Spacer(),

                            // 🛒 SELL
                            ElevatedButton(

                              onPressed: () async {

                                int sellQty =
                                    int.tryParse(
                                      controller.text,
                                    ) ??
                                        1;

                                if (sellQty > qty) {

                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(

                                    const SnackBar(
                                      content: Text(
                                        "Not enough stock ❌",
                                      ),
                                    ),
                                  );

                                  return;
                                }

                                int newQty =
                                    qty - sellQty;

                                // ✅ UPDATE PRODUCT
                                await SupabaseService
                                    .updateProductQuantity(

                                  p['id'],

                                  newQty,
                                );

                                // ✅ ADD SALE
                                await SupabaseService
                                    .addSale(

                                  p['name'],

                                  sellQty,
                                );

                                // ✅ INSTANT UI UPDATE
                                p['quantity'] =
                                    newQty.toString();

                                setState(() {});

                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(

                                  const SnackBar(
                                    content:
                                    Text("Sold ✅"),
                                  ),
                                );
                              },

                              child:
                              const Text("Sell"),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}