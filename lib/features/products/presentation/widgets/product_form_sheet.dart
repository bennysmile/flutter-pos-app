import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/product_image_storage.dart';
import '../../../../shared/models/product.dart';
import 'product_image_thumbnail.dart';

class ProductFormSheet extends StatefulWidget {
  const ProductFormSheet({super.key, required this.shopId, this.product});

  final String shopId;
  final Product? product;

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _reorderController;
  String? _imagePath;
  var _isPickingImage = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _skuController = TextEditingController(text: product?.sku ?? '');
    _barcodeController = TextEditingController(text: product?.barcode ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toStringAsFixed(2),
    );
    _stockController = TextEditingController(
      text: product?.stockQuantity.toString() ?? '',
    );
    _reorderController = TextEditingController(
      text: product?.reorderLevel.toString() ?? '5',
    );
    _imagePath = product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _reorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isEditing ? 'Edit product' : 'Add product',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                _ProductImagePicker(
                  imagePath: _imagePath,
                  isPickingImage: _isPickingImage,
                  onSelectImage: () => _pickImage(ImageSource.gallery),
                  onTakePhoto: () => _pickImage(ImageSource.camera),
                  onRemoveImage: _imagePath == null
                      ? null
                      : () => setState(() => _imagePath = null),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product name'),
                  textInputAction: TextInputAction.next,
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(labelText: 'SKU'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(labelText: 'Barcode'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Selling price',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _nonNegativeDecimal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock quantity',
                        ),
                        keyboardType: TextInputType.number,
                        validator: _nonNegativeInteger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reorderController,
                  decoration: const InputDecoration(labelText: 'Reorder level'),
                  keyboardType: TextInputType.number,
                  validator: _nonNegativeInteger,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isEditing ? 'Save changes' : 'Save product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final existing = widget.product;
    final product = Product(
      id: existing?.id ?? 'product-${now.microsecondsSinceEpoch}',
      shopId: existing?.shopId ?? widget.shopId,
      name: _nameController.text.trim(),
      sku: _optionalText(_skuController.text),
      barcode: _optionalText(_barcodeController.text),
      description: _optionalText(_descriptionController.text),
      imagePath: _imagePath,
      price: double.parse(_priceController.text.trim()),
      stockQuantity: int.parse(_stockController.text.trim()),
      reorderLevel: int.parse(_reorderController.text.trim()),
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? now,
      updatedAt: existing == null ? null : now,
    );

    Navigator.of(context).pop(product);
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPickingImage = true);
    try {
      final path = await ProductImageStorage.pickAndStore(source);
      if (path != null && mounted) {
        setState(() => _imagePath = path);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _nonNegativeDecimal(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) {
      return 'Enter a valid amount';
    }
    if (parsed < 0) {
      return 'Cannot be negative';
    }
    return null;
  }

  String? _nonNegativeInteger(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) {
      return 'Enter a whole number';
    }
    if (parsed < 0) {
      return 'Cannot be negative';
    }
    return null;
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _ProductImagePicker extends StatelessWidget {
  const _ProductImagePicker({
    required this.imagePath,
    required this.isPickingImage,
    required this.onSelectImage,
    required this.onTakePhoto,
    required this.onRemoveImage,
  });

  final String? imagePath;
  final bool isPickingImage;
  final VoidCallback onSelectImage;
  final VoidCallback onTakePhoto;
  final VoidCallback? onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductImageThumbnail(imagePath: imagePath, size: 88, iconSize: 34),
        const SizedBox(width: 16),
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: isPickingImage ? null : onSelectImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Select Image'),
              ),
              OutlinedButton.icon(
                onPressed: isPickingImage ? null : onTakePhoto,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Take Photo'),
              ),
              OutlinedButton.icon(
                onPressed: isPickingImage ? null : onRemoveImage,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove Image'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
