import 'dart:io';
import '../models/product.dart';
import 'full_screen_image.dart';
import 'add_edit_product_screen.dart';
import 'package:flutter/material.dart';
import '../providers/product_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _isLoading = true;
  bool _updateSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  void _showUpdateSuccessAnimation() {
    setState(() {
      _updateSuccess = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _updateSuccess = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditProductScreen(product: widget.product),
                ),
              );
              if (result == true) {
                _showUpdateSuccessAnimation();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Product'),
                  content: const Text(
                      'Are you sure you want to delete this product?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        ref
                            .read(productProvider.notifier)
                            .deleteProduct(widget.product);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            Center(
              child: SpinKitCubeGrid(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${widget.product.name}'),
                  const SizedBox(height: 8),
                  Text('Price: \$${widget.product.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text('Category: ${widget.product.category}'),
                  const SizedBox(height: 16),
                  const Text('Description:'),
                  Text(
                    widget.product.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                              imagePath: widget.product.imagePath),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'productImage',
                      child: Image.file(
                        File(widget.product.imagePath),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_updateSuccess)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitCubeGrid(
                      color: Colors.white,
                      size: 50.0,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Update Successful!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
