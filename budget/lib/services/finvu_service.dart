import 'package:budget/database/tables.dart';
import 'package:budget/services/auto_tagging_service.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:flutter/services.dart';

class FinvuService {
  static const MethodChannel _channel = MethodChannel('com.budget.tracker_app/finvu');
  final AutoTaggingService _autoTaggingService = AutoTaggingService();

  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      print("Failed to initialize Finvu: '${e.message}'.");
    }
  }

  Future<void> connect() async {
    try {
      await _channel.invokeMethod('connect');
    } on PlatformException catch (e) {
      print("Failed to connect Finvu: '${e.message}'.");
    }
  }

  Future<List<dynamic>> fetchTransactions() async {
    try {
      final List<dynamic> transactionsData = await _channel.invokeMethod('fetchTransactions');
      
      // Process and save transactions
      for (var data in transactionsData) {
        if (data is Map) {
          try {
            // Basic mapping - adjust keys based on actual Finvu response
            String rawName = data['description'] ?? 'Finvu Transaction';
            String name = _autoTaggingService.cleanMerchantName(rawName);
            
            double amount = double.tryParse(data['amount'].toString()) ?? 0.0;
            DateTime date = DateTime.tryParse(data['date'].toString()) ?? DateTime.now();
            String transactionPk = data['id']?.toString() ?? uuid.v4();
            
            Transaction transaction = Transaction(
              transactionPk: transactionPk,
              name: name,
              amount: amount,
              note: "Fetched from Finvu",
              categoryFk: "0", // Default category
              walletFk: "0", // Default wallet
              dateCreated: date,
              methodAdded: MethodAdded.finvu,
              paid: true,
              skipPaid: false,
              type: TransactionSpecialType.credit, // Default to credit/expense? Need to check amount sign
            );
            
            await database.createOrUpdateTransaction(transaction);
            await _autoTaggingService.autoTagTransaction(transaction);
          } catch (e) {
            print("Error processing Finvu transaction: $e");
          }
        }
      }
      
      return transactionsData;
    } on PlatformException catch (e) {
      print("Failed to fetch transactions: '${e.message}'.");
      return [];
    }
  }
}
