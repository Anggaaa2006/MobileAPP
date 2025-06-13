import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/bill_service.dart';
import '../../models/bill_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customerNumberController = TextEditingController();
  
  String _selectedCategory = 'Listrik';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isRecurring = false;
  String _recurringType = 'monthly';
  bool _isLoading = false;
  String? _errorMessage;
  
  final List<String> _categories = [
    'Listrik',
    'Air',
    'Internet',
    'Telepon',
    'Kartu Kredit',
    'Asuransi',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _customerNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.darkBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final amount = double.parse(_amountController.text.replaceAll(RegExp(r'[^\d]'), ''));
      
      final bill = Bill(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        amount: amount,
        dueDate: _dueDate,
        description: _descriptionController.text.trim(),
        isRecurring: _isRecurring,
        recurringType: _recurringType,
        customerNumber: _customerNumberController.text.trim(),
        createdAt: DateTime.now(),
      );
      
      final billService = Provider.of<BillService>(context, listen: false);
      final error = await billService.addBill(bill);
      
      if (mounted) {
        if (error != null) {
          setState(() {
            _errorMessage = error;
            _isLoading = false;
          });
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tagihan'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_errorMessage != null) const SizedBox(height: 20),
                  
                  // Title Field
                  CustomTextField(
                    controller: _titleController,
                    labelText: 'Nama Tagihan',
                    hintText: 'Masukkan nama tagihan',
                    prefixIcon: Icons.title,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tagihan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount Field
                  CustomTextField(
                    controller: _amountController,
                    labelText: 'Jumlah',
                    hintText: 'Masukkan jumlah tagihan',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah tidak boleh kosong';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        // Format as currency
                        final numericValue = double.tryParse(
                          value.replaceAll(RegExp(r'[^\d]'), '')
                        ) ?? 0;
                        
                        final formatted = NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        ).format(numericValue);
                        
                        _amountController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Due Date Field
                  InkWell(
                    onTap: _selectDueDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Tanggal Jatuh Tempo',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        DateFormat('dd MMMM yyyy', 'id').format(_dueDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Customer Number Field
                  CustomTextField(
                    controller: _customerNumberController,
                    labelText: 'Nomor Pelanggan (Opsional)',
                    hintText: 'Masukkan nomor pelanggan',
                    prefixIcon: Icons.numbers,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description Field
                  CustomTextField(
                    controller: _descriptionController,
                    labelText: 'Deskripsi (Opsional)',
                    hintText: 'Masukkan deskripsi tagihan',
                    prefixIcon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Recurring Switch
                  SwitchListTile(
                    title: const Text('Tagihan Berulang'),
                    subtitle: const Text('Aktifkan untuk tagihan bulanan/tahunan'),
                    value: _isRecurring,
                    activeColor: AppColors.primaryBlue,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    onChanged: (value) {
                      setState(() {
                        _isRecurring = value;
                      });
                    },
                  ),
                  
                  // Recurring Type
                  if (_isRecurring)
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Bulanan'),
                            value: 'monthly',
                            groupValue: _recurringType,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (value) {
                              setState(() {
                                _recurringType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Tahunan'),
                            value: 'yearly',
                            groupValue: _recurringType,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (value) {
                              setState(() {
                                _recurringType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button
                  CustomButton(
                    text: 'Simpan Tagihan',
                    isLoading: _isLoading,
                    onPressed: _saveBill,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}