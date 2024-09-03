import '../models/product.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super([]) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final box = Hive.box<Product>('products');
    state = box.values.toList();
  }

  Future<void> addProduct(Product product) async {
    final box = Hive.box<Product>('products');
    await box.add(product);
    state = [...state, product];
  }

  Future<void> updateProduct(Product product) async {
    final box = Hive.box<Product>('products');
    // Find the index of the product in the box
    final index = box.values.toList().indexWhere((p) => p.id == product.id);
    if (index != -1) {
      // Update the product at the found index
      await box.putAt(index, product);
      // Update the state
      state = [...state.where((p) => p.id != product.id), product];
    } else {
      throw Exception('Product not found in the box');
    }
  }

  Future<void> deleteProduct(Product product) async {
    await product.delete();
    state = state.where((item) => item.id != product.id).toList();
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>(
  (ref) => ProductNotifier(),
);
