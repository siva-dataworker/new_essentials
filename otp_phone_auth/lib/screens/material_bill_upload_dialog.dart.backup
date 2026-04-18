import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/accountant_bills_service.dart';
import '../utils/app_colors.dart';

class MaterialBillUploadDialog extends StatefulWidget {
  final String siteId;
  final String siteName;
  final VoidCallback onSuccess;

  const MaterialBillUploadDialog({
    super.key,
    required this.siteId,
    required this.siteName,
    required this.onSuccess,
  });

  @override
  State<MaterialBillUploadDialog> createState() => _MaterialBillUploadDialogState();
}

class _MaterialBillUploadDialogState extends State<MaterialBillUploadDialog> {
  final _billsService = AccountantBillsService();
  final _billNumberController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _taxController = TextEditingController();
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _vendorType = 'Tiles Shop';
  String _materialType = 'Tiles';
  String _unit = 'sqft';
  String _paymentStatus = 'PENDING';
  DateTime _billDate = DateTime.now();
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> _vendorTypes = [
    'Tiles Shop', 'Cement Supplier', 'Steel Supplier', 'Hardware Store',
    'Paint Shop', 'Electrical Shop', 'Plumbing Shop', 'Other'
  ];

  final List<String> _materialTypes = [
    'Tiles', 'Cement', 'Steel', 'Sand', 'Bricks', 'Paint', 'Electrical', 'Plumbing', 'Other'
  ];

  final List<String> _units = ['nos', 'bags', 'kg', 'tons', 'sqft', 'boxes', 'pieces'];
  final List<String> _paymentStatuses = ['PENDING', 'PARTIAL', 'PAID'];

  @override
  void dispose() {
    _billNumberController.dispose();
    _vendorNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _taxController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_unitPriceController.text) ?? 0;
    return qty * price;
  }

  double get _finalAmount {
    final tax = double.tryParse(_taxController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    return _totalAmount + tax - discount;
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _selectedFile = File(result.files.single.path!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _upload() async {
    if (_billNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter bill number'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_vendorNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter vendor name'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_quantityController.text.trim().isEmpty || _unitPriceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter quantity and unit price'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please select a PDF file'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUploading = true);

    final result = await _billsService.uploadMaterialBill(
      siteId: widget.siteId,
      billNumber: _billNumberController.text,
      billDate: _billDate.toIso8601String().split('T')[0],
      vendorName: _vendorNameController.text,
      vendorType: _vendorType,
      materialType: _materialType,
      quantity: double.parse(_quantityController.text),
      unit: _unit,
      unitPrice: double.parse(_unitPriceController.text),
      totalAmount: _totalAmount,
      taxAmount: double.tryParse(_taxController.text) ?? 0,
      discountAmount: double.tryParse(_discountController.text) ?? 0,
      finalAmount: _finalAmount,
      paymentStatus: _paymentStatus,
      notes: _notesController.text,
      file: _selectedFile!,
    );

    setState(() => _isUploading = false);

    if (mounted) {
      if (result['success'] == true) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Material bill uploaded successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${result['error']}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: const Text('Upload Material Bill'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.siteName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepNavy)),
            const SizedBox(height: 24),
            
            // Bill Number
            TextField(
              controller: _billNumberController,
              decoration: const InputDecoration(
                labelText: 'Bill Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),
            
            // Bill Date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _billDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _billDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Bill Date *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text('${_billDate.day}/${_billDate.month}/${_billDate.year}'),
              ),
            ),
            const SizedBox(height: 16),
            
            // Vendor Name
            TextField(
              controller: _vendorNameController,
              decoration: const InputDecoration(
                labelText: 'Vendor Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),
            
            // Vendor Type
            DropdownButtonFormField<String>(
              value: _vendorType,
              decoration: const InputDecoration(
                labelText: 'Vendor Type *',
                border: OutlineInputBorder(),
              ),
              items: _vendorTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) => setState(() => _vendorType = value!),
            ),
            const SizedBox(height: 16),
            
            // Material Type
            DropdownButtonFormField<String>(
              value: _materialType,
              decoration: const InputDecoration(
                labelText: 'Material Type *',
                border: OutlineInputBorder(),
              ),
              items: _materialTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) => setState(() => _materialType = value!),
            ),
            const SizedBox(height: 16),
            
            // Quantity and Unit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Unit *',
                      border: OutlineInputBorder(),
                    ),
                    items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (value) => setState(() => _unit = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Unit Price
            TextField(
              controller: _unitPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Unit Price (₹) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            
            // Total Amount (calculated)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('₹${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Tax and Discount
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tax (₹)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Discount (₹)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Final Amount (calculated)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Final Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('₹${_finalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment Status
            DropdownButtonFormField<String>(
              value: _paymentStatus,
              decoration: const InputDecoration(
                labelText: 'Payment Status',
                border: OutlineInputBorder(),
              ),
              items: _paymentStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => _paymentStatus = value!),
            ),
            const SizedBox(height: 16),
            
            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // File Picker
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFile == null ? 'Select PDF File *' : 'PDF Selected'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFile!.path.split('/').last,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            
            // Upload Button
            ElevatedButton(
              onPressed: _isUploading ? null : _upload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Upload Material Bill', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
