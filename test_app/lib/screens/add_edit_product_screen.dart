import 'dart:io';
import '../models/product.dart';
import 'package:flutter/material.dart';
import '../providers/product_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/screens/home_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

// ignore: depend_on_referenced_packages

class AddEditProductScreen extends ConsumerStatefulWidget {
  final Product? product;

  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _price;
  late String _category;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name = widget.product!.name;
      _description = widget.product!.description;
      _price = widget.product!.price;
      _category = widget.product!.category;
      _imagePath = widget.product!.imagePath;
    } else {
      _name = '';
      _description = '';
      _price = 0.0;
      _category = '';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final directory = await path_provider.getApplicationDocumentsDirectory();
      final String path = directory.path;
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File localImage = File('$path/$fileName');
      await File(pickedFile.path).copy(localImage.path);
      setState(() {
        _imagePath = localImage.path;
      });
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });
      final product = Product(
        id: widget.product?.id ?? DateTime.now().toString(),
        name: _name,
        description: _description,
        price: _price,
        category: _category,
        imagePath: _imagePath!,
      );
      if (widget.product == null) {
        await ref.read(productProvider.notifier).addProduct(product);
      } else {
        await ref.read(productProvider.notifier).updateProduct(product);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: _isLoading
          ? Center(
              child: SpinKitCubeGrid(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  TextFormField(
                    initialValue: _description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a description' : null,
                    onSaved: (value) => _description = value!,
                  ),
                  TextFormField(
                    initialValue: _price.toString(),
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a price' : null,
                    onSaved: (value) => _price = double.parse(value!),
                  ),
                  TextFormField(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a category' : null,
                    onSaved: (value) => _category = value!,
                  ),
                  const SizedBox(height: 16),
                  _imagePath != null
                      ? Image.file(File(_imagePath!), height: 200)
                      : const Text('No image selected'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        child: const Text('Pick from Gallery'),
                      ),
                      ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.camera),
                        child: const Text('Take a Photo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text(widget.product == null
                        ? 'Add Product'
                        : 'Update Product'),
                  ),
                ],
              ),
            ),
    );
  }
}
