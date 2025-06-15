import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill_model.dart';

class BillService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Bill> _bills = [];
  List<Bill> get bills => _bills;

  User? get currentUser => _auth.currentUser;

  BillService() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loadBills();
      } else {
        _bills = [];
        notifyListeners();
      }
    });
  }

  Future<void> loadBills() async {
    if (currentUser == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('bills')
          .where('userId', isEqualTo: currentUser!.uid)
          .orderBy('dueDate')
          .get();

      _bills = querySnapshot.docs
          .map((doc) => Bill.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error loading bills: $e');
    }
  }

  Future<String?> addBill(Bill bill) async {
    if (currentUser == null) return 'User tidak ditemukan';

    try {
      final billData = bill.toMap();
      billData['userId'] = currentUser!.uid;

      await _firestore.collection('bills').add(billData);
      await loadBills();
      return null;
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> updateBillStatus(String billId, bool isPaid) async {
    if (currentUser == null) return 'User tidak ditemukan';

    try {
      await _firestore.collection('bills').doc(billId).update({
        'isPaid': isPaid,
        'paidDate': isPaid ? Timestamp.now() : null,
      });
      await loadBills();
      return null;
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> deleteBill(String billId) async {
    if (currentUser == null) return 'User tidak ditemukan';

    try {
      await _firestore.collection('bills').doc(billId).delete();
      await loadBills();
      return null;
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  List<Bill> getUpcomingBills() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return _bills
        .where((bill) =>
            !bill.isPaid &&
            bill.dueDate.isAfter(now) &&
            bill.dueDate.isBefore(nextWeek))
        .toList();
  }

  List<Bill> getOverdueBills() {
    final now = DateTime.now();
    return _bills
        .where((bill) => !bill.isPaid && bill.dueDate.isBefore(now))
        .toList();
  }

  Map<String, double> getMonthlySummary(int year, int month) {
    final monthlyBills = _bills.where((bill) {
      return bill.dueDate.year == year && bill.dueDate.month == month;
    }).toList();

    double total = 0;
    double unpaid = 0;

    for (var bill in monthlyBills) {
      total += bill.amount;
      if (!bill.isPaid) {
        unpaid += bill.amount;
      }
    }

    return {
      'total': total,
      'unpaid': unpaid,
      'paid': total - unpaid,
    };
  }
}