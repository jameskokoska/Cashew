import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';

class AutoTaggingService {
  
  // Check if a transaction matches any auto-tagging rules and assign tags
  Future<void> autoTagTransaction(Transaction transaction) async {
    final rules = await database.getAllTransactionAssociatedTags();
    
    for (var rule in rules) {
      bool match = false;
      if (rule.isExactMatch) {
        match = transaction.name.toLowerCase() == rule.title.toLowerCase();
      } else {
        match = transaction.name.toLowerCase().contains(rule.title.toLowerCase());
      }
      
      if (match) {
        await database.createOrUpdateTransactionTag(
          TransactionTag(
            transactionTagPk: uuid.v4(),
            transactionFk: transaction.transactionPk,
            tagFk: rule.tagFk,
            dateCreated: DateTime.now(),
          )
        );
      }
    }
  }

  // Add a new rule when user manually tags a transaction
  Future<void> addRule(String keyword, String tagFk, {bool isExactMatch = false}) async {
    await database.createOrUpdateTransactionAssociatedTag(
      TransactionAssociatedTag(
        transactionAssociatedTagPk: uuid.v4(),
        tagFk: tagFk,
        title: keyword,
        isExactMatch: isExactMatch,
        dateCreated: DateTime.now(),
      )
    );
  }

  String cleanMerchantName(String description) {
    String name = description;
    
    // Common prefixes/suffixes to remove
    final prefixes = ["POS*", "UPI*", "ATW*", "PURCHASE*", "NETBANKING*", "IMPS*", "NEFT*"];
    for (var prefix in prefixes) {
      if (name.toUpperCase().startsWith(prefix)) {
        name = name.substring(prefix.length);
      }
    }
    
    name = name.trim();
    
    // Capitalize first letter of each word
    name = name.split(' ').map((str) => str.length > 0 ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '').join(' ');
    
    return name;
  }
}
