import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String? id;
  final String title;
  final String category;
  final double amount;
  final DateTime dueDate;
  final String description;
  final bool isPaid;
  final DateTime? paidDate;
  final bool isRecurring;
  final String recurringType;
  final String? customerNumber;
  final DateTime createdAt;

  Bill({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.dueDate,
    required this.description,
    this.isPaid = false,
    this.paidDate,
    this.isRecurring = false,
    this.recurringType = 'monthly',
    this.customerNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'description': description,
      'isPaid': isPaid,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'isRecurring': isRecurring,
      'recurringType': recurringType,
      'customerNumber': customerNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map, String id) {
    return Bill(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      isPaid: map['isPaid'] ?? false,
      paidDate: map['paidDate'] != null 
          ? (map['paidDate'] as Timestamp).toDate() 
          : null,
      isRecurring: map['isRecurring'] ?? false,
      recurringType: map['recurringType'] ?? 'monthly',
      customerNumber: map['customerNumber'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}