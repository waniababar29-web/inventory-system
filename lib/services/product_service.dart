import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {

  static List<Map<String, dynamic>> products = [];

  // LOAD PRODUCTS (NO DEFAULT DATA)
  static Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();

    String? data = prefs.getString('products');

    if (data != null && data.isNotEmpty) {
      List decoded = jsonDecode(data);
      products = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      products = []; // 🔥 EMPTY LIST (no default)
    }
  }

  // SAVE PRODUCTS
  static Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', jsonEncode(products));
  }

  // ADD PRODUCT
  static Future<bool> addProduct(String name, String price, String quantity) async {

    bool exists = products.any((p) =>
    p['name'].toLowerCase() == name.toLowerCase());

    if (exists) return false;

    products.add({
      'name': name,
      'price': price,
      'quantity': quantity,
    });

    await saveProducts();
    return true;
  }

  // UPDATE
  static Future<void> updateProduct(int index, String name, String price, String quantity) async {
    products[index] = {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
    await saveProducts();
  }

  // DELETE
  static Future<void> deleteProduct(int index) async {
    products.removeAt(index);
    await saveProducts();
  }

  // SELL
  static Future<bool> sellProduct(int index) async {
    int qty = int.parse(products[index]['quantity']);

    if (qty > 0) {
      qty--;
      products[index]['quantity'] = qty.toString();
      await saveProducts();
      return true;
    }

    return false;
  }
}