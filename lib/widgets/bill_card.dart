import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill_model.dart';
import '../utils/app_colors.dart';

class BillCard extends StatelessWidget {
  final Bill bill;
  final bool isOverdue;
  final VoidCallback? onTap;

  const BillCard({
    super.key,
    required this.bill,
    this.isOverdue = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    final dateFormat = DateFormat('dd MMM yyyy', 'id');
    final now = DateTime.now();
    final daysUntilDue = bill.dueDate.difference(now).inDays;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (bill.isPaid) {
      statusColor = AppColors.success;
      statusText = 'Sudah Dibayar';
      statusIcon = Icons.check_circle;
    } else if (isOverdue) {
      statusColor = AppColors.error;
      statusText = 'Terlambat';
      statusIcon = Icons.warning;
    } else if (daysUntilDue <= 3) {
      statusColor = AppColors.warning;
      statusText = 'Segera Jatuh Tempo';
      statusIcon = Icons.schedule;
    } else {
      statusColor = AppColors.primaryBlue;
      statusText = 'Belum Dibayar';
      statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Category Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(bill.category),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bill.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Amount
                  Text(
                    currencyFormat.format(bill.amount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Status and Due Date Row
              Row(
                children: [
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  // Due Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.darkGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(bill.dueDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Days until due (for unpaid bills)
              if (!bill.isPaid && !isOverdue && daysUntilDue >= 0) ...[
                const SizedBox(height: 8),
                Text(
                  daysUntilDue == 0
                      ? 'Jatuh tempo hari ini'
                      : daysUntilDue == 1
                          ? 'Jatuh tempo besok'
                          : 'Jatuh tempo dalam $daysUntilDue hari',
                  style: TextStyle(
                    fontSize: 11,
                    color: daysUntilDue <= 3 ? AppColors.warning : AppColors.darkGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              
              // Overdue days
              if (isOverdue) ...[
                const SizedBox(height: 8),
                Text(
                  'Terlambat ${-daysUntilDue} hari',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              
              // Recurring indicator
              if (bill.isRecurring) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 12,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bill.recurringType == 'monthly' ? 'Bulanan' : 'Tahunan',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'listrik':
        return Icons.electrical_services;
      case 'air':
        return Icons.water_drop;
      case 'internet':
        return Icons.wifi;
      case 'telepon':
        return Icons.phone;
      case 'kartu kredit':
        return Icons.credit_card;
      case 'asuransi':
        return Icons.security;
      default:
        return Icons.receipt;
    }
  }
}