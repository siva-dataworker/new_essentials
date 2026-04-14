import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../services/accountant_bills_service.dart';
import '../utils/app_colors.dart';

// ============================================
// MATERIAL BILL UPLOAD DIALOG
// ============================================

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
  final _taxController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  
  String _vendorType = 'Tiles Shop';
  String _materialType = 'Tiles';
  String _unit = 'sqft';
  String _paymentStatus = 'PENDING';
  String? _paymentMode;
  DateTime _billDate = DateTime.now();
  DateTime? _paymentDate;
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
  final List<String> _paymentModes = ['Cash', 'Cheque', 'Bank Transfer', 'UPI', 'Credit'];

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
        const SnackBar(content: Text('⚠️ Please enter bill number')),
      );
      return;
    }

    if (_vendorNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter vendor name')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please select a PDF file')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final result = await _billsService.uploadMaterialBill(
      siteId: widget.siteId,
      billNumber: _billNumberController.text,
      billDate: DateFormat('yyyy-MM-dd').format(_billDate),
      vendorName: _vendorNameController.text,
      vendorType: _vendorType,
      materialType: _materialType,
      quantity: double.tryParse(_quantityController.text) ?? 0,
      unit: _unit,
      unitPrice: double.tryParse(_unitPriceController.text) ?? 0,
      totalAmount: _totalAmount,
      taxAmount: double.tryParse(_taxController.text) ?? 0,
      discountAmount: double.tryParse(_discountController.text) ?? 0,
      finalAmount: _finalAmount,
      paymentStatus: _paymentStatus,
      paymentMode: _paymentMode,
      paymentDate: _paymentDate != null ? DateFormat('yyyy-MM-dd').format(_paymentDate!) : null,
      notes: _notesController.text,
      file: _selectedFile!,
    );

    setState(() => _isUploading = false);

    if (mounted) {
      if (result['success'] == true) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Material bill uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Upload Material Bill',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
              ),
              const SizedBox(height: 8),
              Text(widget.siteName, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
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
                  child: Text(DateFormat('dd MMM yyyy').format(_billDate)),
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
                  labelText: 'Vendor Type',
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
                  labelText: 'Material Type',
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
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
                  labelText: 'Unit Price *',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              
              // Total Amount (calculated)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('₹${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        labelText: 'Tax',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Discount',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Final Amount (calculated)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Final Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('₹${_finalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
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
              
              // File Picker
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile == null ? 'Select PDF File *' : 'PDF Selected'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
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
                          : const Text('Upload'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================
// VENDOR BILL UPLOAD DIALOG
// ============================================

class VendorBillUploadDialog extends StatefulWidget {
  final String siteId;
  final String siteName;
  final VoidCallback onSuccess;

  const VendorBillUploadDialog({
    super.key,
    required this.siteId,
    required this.siteName,
    required this.onSuccess,
  });

  @override
  State<VendorBillUploadDialog> createState() => _VendorBillUploadDialogState();
}

class _VendorBillUploadDialogState extends State<VendorBillUploadDialog> {
  final _billsService = AccountantBillsService();
  final _billNumberController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _serviceDescController = TextEditingController();
  final _amountController = TextEditingController();
  final _taxController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  
  String _vendorType = 'Contractor';
  String _paymentStatus = 'PENDING';
  DateTime _billDate = DateTime.now();
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> _vendorTypes = [
    'Contractor', 'Electrician', 'Plumber', 'Carpenter', 'Mason', 
    'Painter', 'Transport', 'Equipment Rental', 'Other'
  ];

  @override
  void dispose() {
    _billNumberController.dispose();
    _vendorNameController.dispose();
    _serviceTypeController.dispose();
    _serviceDescController.dispose();
    _amountController.dispose();
    _taxController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _finalAmount {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final tax = double.tryParse(_taxController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    return amount + tax - discount;
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
    if (_billNumberController.text.trim().isEmpty ||
        _vendorNameController.text.trim().isEmpty ||
        _serviceTypeController.text.trim().isEmpty ||
        _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please fill all required fields')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final result = await _billsService.uploadVendorBill(
      siteId: widget.siteId,
      billNumber: _billNumberController.text,
      billDate: DateFormat('yyyy-MM-dd').format(_billDate),
      vendorName: _vendorNameController.text,
      vendorType: _vendorType,
      serviceType: _serviceTypeController.text,
      serviceDescription: _serviceDescController.text,
      amount: double.tryParse(_amountController.text) ?? 0,
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
          const SnackBar(
            content: Text('✅ Vendor bill uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Upload Vendor Bill',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
              ),
              const SizedBox(height: 8),
              Text(widget.siteName, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              
              TextField(
                controller: _billNumberController,
                decoration: const InputDecoration(
                  labelText: 'Bill Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              
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
                  child: Text(DateFormat('dd MMM yyyy').format(_billDate)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _vendorNameController,
                decoration: const InputDecoration(
                  labelText: 'Vendor Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _vendorType,
                decoration: const InputDecoration(
                  labelText: 'Vendor Type',
                  border: OutlineInputBorder(),
                ),
                items: _vendorTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _vendorType = value!),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(
                  labelText: 'Service Type *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Electrical Wiring, Plumbing Work',
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _serviceDescController,
                decoration: const InputDecoration(
                  labelText: 'Service Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tax',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Discount',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Final Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('₹${_finalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile == null ? 'Select PDF File *' : 'PDF Selected'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
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
                          : const Text('Upload'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================
// SITE AGREEMENT UPLOAD DIALOG
// ============================================

class SiteAgreementUploadDialog extends StatefulWidget {
  final String siteId;
  final String siteName;
  final VoidCallback onSuccess;

  const SiteAgreementUploadDialog({
    super.key,
    required this.siteId,
    required this.siteName,
    required this.onSuccess,
  });

  @override
  State<SiteAgreementUploadDialog> createState() => _SiteAgreementUploadDialogState();
}

class _SiteAgreementUploadDialogState extends State<SiteAgreementUploadDialog> {
  final _billsService = AccountantBillsService();
  final _agreementNumberController = TextEditingController();
  final _partyNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contractValueController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _agreementType = 'Site Agreement';
  String _partyType = 'Customer';
  DateTime _agreementDate = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> _agreementTypes = [
    'Site Agreement', 'Contractor Agreement', 'Vendor Agreement', 
    'Lease Agreement', 'Purchase Agreement', 'Other'
  ];

  final List<String> _partyTypes = ['Customer', 'Contractor', 'Vendor', 'Owner', 'Other'];

  @override
  void dispose() {
    _agreementNumberController.dispose();
    _partyNameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contractValueController.dispose();
    _notesController.dispose();
    super.dispose();
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
    if (_partyNameController.text.trim().isEmpty ||
        _titleController.text.trim().isEmpty ||
        _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please fill all required fields')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final result = await _billsService.uploadSiteAgreement(
      siteId: widget.siteId,
      agreementType: _agreementType,
      agreementNumber: _agreementNumberController.text,
      agreementDate: DateFormat('yyyy-MM-dd').format(_agreementDate),
      partyName: _partyNameController.text,
      partyType: _partyType,
      title: _titleController.text,
      description: _descriptionController.text,
      contractValue: double.tryParse(_contractValueController.text),
      startDate: _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : null,
      endDate: _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
      notes: _notesController.text,
      file: _selectedFile!,
    );

    setState(() => _isUploading = false);

    if (mounted) {
      if (result['success'] == true) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Site agreement uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Upload Site Agreement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
              ),
              const SizedBox(height: 8),
              Text(widget.siteName, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              
              DropdownButtonFormField<String>(
                value: _agreementType,
                decoration: const InputDecoration(
                  labelText: 'Agreement Type',
                  border: OutlineInputBorder(),
                ),
                items: _agreementTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _agreementType = value!),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _agreementNumberController,
                decoration: const InputDecoration(
                  labelText: 'Agreement Number',
                  border: OutlineInputBorder(),
                  hintText: 'Optional',
                ),
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _agreementDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _agreementDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Agreement Date *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_agreementDate)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _partyNameController,
                decoration: const InputDecoration(
                  labelText: 'Party Name *',
                  border: OutlineInputBorder(),
                  hintText: 'Customer/Contractor/Vendor name',
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _partyType,
                decoration: const InputDecoration(
                  labelText: 'Party Type',
                  border: OutlineInputBorder(),
                ),
                items: _partyTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _partyType = value!),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Agreement Title *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Construction Agreement for Residential Building',
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _contractValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Contract Value',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                  hintText: 'Optional',
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) setState(() => _startDate = date);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_startDate != null ? DateFormat('dd MMM yyyy').format(_startDate!) : 'Optional'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) setState(() => _endDate = date);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_endDate != null ? DateFormat('dd MMM yyyy').format(_endDate!) : 'Optional'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile == null ? 'Select PDF File *' : 'PDF Selected'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
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
                          : const Text('Upload'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
