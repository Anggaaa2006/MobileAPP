import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/bill_service.dart';
import '../../models/bill_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/bill_card.dart';
import 'bill_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Tagihan'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Belum Dibayar'),
            Tab(text: 'Sudah Dibayar'),
          ],
        ),
      ),
      body: Consumer<BillService>(
        builder: (context, billService, child) {
          final unpaidBills = billService.bills.where((bill) => !bill.isPaid).toList();
          final paidBills = billService.bills.where((bill) => bill.isPaid).toList();
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Unpaid Bills Tab
              _buildBillsList(
                unpaidBills,
                'Belum ada tagihan yang perlu dibayar',
                isUnpaid: true,
              ),
              
              // Paid Bills Tab
              _buildBillsList(
                paidBills,
                'Belum ada tagihan yang sudah dibayar',
                isUnpaid: false,
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildBillsList(List<Bill> bills, String emptyMessage, {required bool isUnpaid}) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnpaid ? Icons.check_circle_outline : Icons.receipt_long,
              size: 64,
              color: AppColors.lightGray,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => Provider.of<BillService>(context, listen: false).loadBills(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bills.length + 1, // +1 for the summary card
        itemBuilder: (context, index) {
          if (index == 0) {
            // Summary Card
            double totalAmount = 0;
            for (var bill in bills) {
              totalAmount += bill.amount;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUnpaid ? 'Total Tagihan Belum Dibayar' : 'Total Tagihan Sudah Dibayar',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(totalAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${bills.length} tagihan',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }
          
          final bill = bills[index - 1];
          return BillCard(
            bill: bill,
            isOverdue: isUnpaid && bill.dueDate.isBefore(DateTime.now()),
            onTap: () => _navigateToBillDetail(bill),
          );
        },
      ),
    );
  }
  
  void _navigateToBillDetail(Bill bill) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BillDetailScreen(bill: bill),
      ),
    );
  }
}