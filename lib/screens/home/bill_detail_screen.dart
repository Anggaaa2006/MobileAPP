import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/bill_model.dart';
import '../../services/bill_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class BillDetailScreen extends StatefulWidget {
  final Bill bill;
  
  const BillDetailScreen({
    super.key,
    required this.bill,
  });

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  
  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  
  final dateFormat = DateFormat('dd MMMM yyyy', 'id');

  Future<void> _markAsPaid() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final billService = Provider.of<BillService>(context, listen: false);
    final error = await billService.updateBillStatus(widget.bill.id!, true);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      
      if (error == null) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _deleteBill() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tagihan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus tagihan ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final billService = Provider.of<BillService>(context, listen: false);
    final error = await billService.deleteBill(widget.bill.id!);
    
    if (mounted) {
      if (error == null) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final isOverdue = !bill.isPaid && bill.dueDate.isBefore(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tagihan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _isLoading ? null : _deleteBill,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                
                // Status Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bill.isPaid
                        ? Colors.green.shade50
                        : isOverdue
                            ? Colors.red.shade50
                            : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: bill.isPaid
                          ? Colors.green.shade200
                          : isOverdue
                              ? Colors.red.shade200
                              : Colors.blue.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            bill.isPaid
                                ? Icons.check_circle_outline
                                : isOverdue
                                    ? Icons.warning_amber_outlined
                                    : Icons.info_outline,
                            color: bill.isPaid
                                ? Colors.green
                                : isOverdue
                                    ? Colors.red
                                    : Colors.blue,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            bill.isPaid
                                ? 'Sudah Dibayar'
                                : isOverdue
                                    ? 'Terlambat'
                                    : 'Belum Dibayar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: bill.isPaid
                                  ? Colors.green
                                  : isOverdue
                                      ? Colors.red
                                      : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      if (bill.isPaid && bill.paidDate != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Dibayar pada ${dateFormat.format(bill.paidDate!)}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Bill Details
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Tagihan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow('Nama Tagihan', bill.title),
                        _buildDetailRow('Kategori', bill.category),
                        _buildDetailRow(
                          'Jumlah',
                          currencyFormat.format(bill.amount),
                        ),
                        _buildDetailRow(
                          'Tanggal Jatuh Tempo',
                          dateFormat.format(bill.dueDate),
                        ),
                        if (bill.customerNumber != null && bill.customerNumber!.isNotEmpty)
                          _buildDetailRow('Nomor Pelanggan', bill.customerNumber!),
                        _buildDetailRow(
                          'Tagihan Berulang',
                          bill.isRecurring ? 'Ya (${bill.recurringType == 'monthly' ? 'Bulanan' : 'Tahunan'})' : 'Tidak',
                        ),
                        _buildDetailRow(
                          'Tanggal Dibuat',
                          dateFormat.format(bill.createdAt),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                if (bill.description.isNotEmpty)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const Divider(height: 24),
                          Text(bill.description),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                
                // Mark as Paid Button
                if (!bill.isPaid)
                  CustomButton(
                    text: 'Tandai Sudah Dibayar',
                    isLoading: _isLoading,
                    onPressed: _markAsPaid,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}