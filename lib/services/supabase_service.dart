import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {

  static final supabase =
      Supabase.instance.client;

  // 🟢 GET PRODUCTS
  static Future<List<Map<String, dynamic>>>
  getProducts() async {

    try {

      final data =
      await supabase
          .from('products')
          .select();

      return List<Map<String, dynamic>>
          .from(data);

    } catch (e) {

      print("GET PRODUCTS ERROR: $e");

      return [];
    }
  }

  // 🟢 ADD PRODUCT
  static Future<String> addProduct(
      String name,
      String price,
      String quantity,
      ) async {

    try {

      final existing =
      await supabase
          .from('products')
          .select()
          .eq('name', name);

      if (existing.isNotEmpty) {

        return "duplicate";
      }

      await supabase
          .from('products')
          .insert({

        'name': name,

        'price': price,

        'quantity': quantity,
      });

      return "added";

    } catch (e) {

      print("ADD ERROR: $e");

      return "error";
    }
  }

  // 🟢 DELETE PRODUCT
  static Future<void>
  deleteProduct(int id) async {

    try {

      await supabase
          .from('products')
          .delete()
          .eq('id', id);

    } catch (e) {

      print("DELETE ERROR: $e");
    }
  }

  // 🟢 UPDATE PRODUCT
  static Future<void> updateProduct(
      int id,
      String name,
      String price,
      String quantity,
      ) async {

    try {

      await supabase
          .from('products')
          .update({

        'name': name,

        'price': price,

        'quantity': quantity,
      })
          .eq('id', id);

    } catch (e) {

      print("UPDATE ERROR: $e");
    }
  }

  // 🔥 SELL PRODUCT
  static Future<String>
  sellProduct(int id) async {

    try {

      final data =
      await supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();

      int currentQty =
          int.tryParse(
            data['quantity']
                .toString(),
          ) ??
              0;

      if (currentQty <= 0) {

        return "out";
      }

      int newQty =
          currentQty - 1;

      // 🟢 UPDATE QUANTITY
      await supabase
          .from('products')
          .update({

        'quantity':
        newQty.toString(),
      })
          .eq('id', id);

      // 🟢 SAVE SALE
      await supabase
          .from('sales')
          .insert({

        'product_name':
        data['name'],

        'quantity': 1,
      });

      print(
          "SALE INSERTED SUCCESS ✅");

      return "sold";

    } catch (e) {

      print("SELL ERROR: $e");

      return "error";
    }
  }

  // 🟢 BULK UPDATE
  static Future<void>
  updateProductQuantity(
      int id,
      int newQty,
      ) async {

    try {

      await supabase
          .from('products')
          .update({

        'quantity':
        newQty.toString(),
      })
          .eq('id', id);

    } catch (e) {

      print(
          "BULK UPDATE ERROR: $e");
    }
  }

  // 🟢 ADD SALE
  static Future<void> addSale(
      String name,
      int qty,
      ) async {

    try {

      await supabase
          .from('sales')
          .insert({

        'product_name': name,

        'quantity': qty,
      });

      print(
          "SALE INSERTED SUCCESS ✅");

    } catch (e) {

      print(
          "ADD SALE ERROR: $e");
    }
  }

  // 🟢 GET SALES
  static Future<List<Map<String, dynamic>>>
  getSales() async {

    try {

      final data =
      await supabase
          .from('sales')
          .select();

      return List<Map<String, dynamic>>
          .from(data);

    } catch (e) {

      print("GET SALES ERROR: $e");

      return [];
    }
  }
}