import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  // GET PRODUCTS
  static Future<List<Map<String, dynamic>>> getProducts() async {
    final data = await supabase.from('products').select();
    return List<Map<String, dynamic>>.from(data);
  }

  // ADD PRODUCT WITH DUPLICATE CHECK 🔥
  static Future<String> addProduct(String name, String price, String quantity) async {

    final existing = await supabase
        .from('products')
        .select()
        .eq('name', name);

    if (existing.isNotEmpty) {
      return "duplicate";
    }

    await supabase.from('products').insert({
      'name': name,
      'price': price,
      'quantity': quantity,
    });

    return "added";
  }

  // DELETE
  static Future<void> deleteProduct(int id) async {
    await supabase.from('products').delete().eq('id', id);
  }

  // UPDATE
  static Future<void> updateProduct(int id, String name, String price, String quantity) async {
    await supabase.from('products').update({
      'name': name,
      'price': price,
      'quantity': quantity,
    }).eq('id', id);
  }

  // SELL PRODUCT 🔥
  static Future<String> sellProduct(int id, int quantity) async {

    if (quantity <= 0) {
      return "out";
    }

    await supabase
        .from('products')
        .update({'quantity': (quantity - 1).toString()})
        .eq('id', id);

    return "sold";
  }
}