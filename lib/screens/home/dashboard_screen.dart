import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/bill_service.dart';
import '../../services/auth_service.dart';
import '../../models/bill_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/bill_card.dart';
import '../../widgets/summary_card.dart';
import 'bill_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final billService = Provider.of<BillService>(context);
    
    final upcomingBills = billService.getUpcomingBills();
    final overdueBills = billService.getOverdueBills();
    
    // Get current month summary
    final now = DateTime.now();
    final monthlySummary = billService.getMonthlySummary(now.year, now.month);
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => billService.loadBills(),
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: AppColors.darkBlue,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<Map<String, dynamic>?>(
                            future: authService.getUserData(),
                            builder: (context, snapshot) {
                              final userData = snapshot.data;
                              final name = userData?['fullName'] ?? 'Pengguna';
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // TODO: Navigate to notifications screen
                    },
                  ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monthly Summary
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: 'Total Tagihan',
                              amount: monthlySummary['total'] ?? 0,
                              icon: Icons.receipt_outlined,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SummaryCard(
                              title: 'Belum Dibayar',
                              amount: monthlySummary['unpaid'] ?? 0,
                              icon: Icons.warning_outlined,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Overdue Bills
                      if (overdueBills.isNotEmpty) ...[
                        const Text(
                          'Tagihan Terlambat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: overdueBills.length,
                          itemBuilder: (context, index) {
                            return BillCard(
                              bill: overdueBills[index],
                              isOverdue: true,
                              onTap: () => _navigateToBillDetail(overdueBills[index]),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Upcoming Bills
                      const Text(
                        'Tagihan Mendatang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (upcomingBills.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Tidak ada tagihan mendatang dalam 7 hari ke depan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.darkGray,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: upcomingBills.length,
                          itemBuilder: (context, index) {
                            return BillCard(
                              bill: upcomingBills[index],
                              onTap: () => _navigateToBillDetail(upcomingBills[index]),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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