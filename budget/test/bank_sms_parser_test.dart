// Generated from sample bank SMS. Run with: flutter test test/bank_sms_parser_test.dart
import 'package:budget/struct/bankSmsParser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("SBI UPI debit", () {
    final r = BankSmsParser.parse("Dear UPI user A/C X1234 debited by 20.0 on date 01Nov26 trf to JOHN DOE Refno 630512345678. If not u? call 1800111109. -SBI", sender: "AD-SBIUPI");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 20.0);
    expect(r!.merchant, "John Doe");
    expect(r!.accountLast4, "1234");
    expect(r!.reference, "630512345678");
    expect(r!.bank, "SBI");
    expect(r!.isAutopay, false);
  });
  test("SBI credit", () {
    final r = BankSmsParser.parse("Dear SBI User, your A/c X1234-credited by Rs.5000 on 01Nov26 transfer from RAHUL KUMAR Ref No 630598765432 -SBI", sender: "VM-SBIINB");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.credit);
    expect(r!.amount, 5000.0);
    expect(r!.merchant, "Rahul Kumar");
    expect(r!.accountLast4, "1234");
    expect(r!.reference, "630598765432");
    expect(r!.bank, "SBI");
  });
  test("SBI transfer with balance", () {
    final r = BankSmsParser.parse("Dear Customer, Your A/C XXXXX1234 has a debit by transfer of Rs 1,500.00 on 01Nov26. Avl Bal Rs 10,250.50.-SBI", sender: "VK-SBIINB");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 1500.0);
    expect(r!.accountLast4, "1234");
    expect(r!.balance, 10250.5);
    expect(r!.bank, "SBI");
  });
  test("SBI credit card", () {
    final r = BankSmsParser.parse("Rs.499.00 spent on your SBI Credit Card ending 4321 at AMAZON PAY on 01/11/26. Trxn. not done by you? Report at https://sbicard.com/Dispute", sender: "VM-SBICRD");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 499.0);
    expect(r!.merchant, "Amazon Pay");
    expect(r!.accountLast4, "4321");
    expect(r!.bank, "SBI");
  });
  test("HDFC UPI sent", () {
    final r = BankSmsParser.parse("Sent Rs.500.00\nFrom HDFC Bank A/C *1234\nTo SWIGGY\nOn 01/11/26\nRef 630511112222\nNot You?\nCall 18002586161/SMS BLOCK UPI to 7308080808", sender: "VM-HDFCBK");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 500.0);
    expect(r!.merchant, "Swiggy");
    expect(r!.accountLast4, "1234");
    expect(r!.reference, "630511112222");
    expect(r!.bank, "HDFC");
  });
  test("HDFC UPI received", () {
    final r = BankSmsParser.parse("Received Rs.1000.00 in your A/C *1234 from priya.sharma@okicici on 01-11-26 by UPI ref no 630533334444", sender: "VM-HDFCBK");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.credit);
    expect(r!.amount, 1000.0);
    expect(r!.merchant, "Priya Sharma");
    expect(r!.accountLast4, "1234");
    expect(r!.reference, "630533334444");
    expect(r!.bank, "HDFC");
  });
  test("HDFC IMPS credit with balance", () {
    final r = BankSmsParser.parse("Money Received - INR 1,000.00 in A/c xx1234 on 01-11-26 by A/c linked to mobile 9XXXXXX000-JOHN DOE (IMPS Ref No. 630555556666) Avl bal: INR 12,345.67", sender: "AD-HDFCBK");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.credit);
    expect(r!.amount, 1000.0);
    expect(r!.accountLast4, "1234");
    expect(r!.balance, 12345.67);
    expect(r!.reference, "630555556666");
    expect(r!.bank, "HDFC");
  });
  test("HDFC card spend", () {
    final r = BankSmsParser.parse("Spent Rs.250 On HDFC Bank Card 5678 At ZOMATO On 2026-11-01:10:20:30 Not You? To Block+Reissue Call 18002586161/SMS BLOCK CC 5678 to 7308080808", sender: "VM-HDFCBK");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 250.0);
    expect(r!.merchant, "Zomato");
    expect(r!.accountLast4, "5678");
    expect(r!.bank, "HDFC");
  });
  test("ICICI UPI debit", () {
    final r = BankSmsParser.parse("ICICI Bank Acct XX123 debited for Rs 250.00 on 01-Nov-26; ZOMATO credited. UPI:630577778888. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.", sender: "JD-ICICIT");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 250.0);
    expect(r!.merchant, "Zomato");
    expect(r!.accountLast4, "123");
    expect(r!.reference, "630577778888");
    expect(r!.bank, "ICICI");
  });
  test("ICICI credit", () {
    final r = BankSmsParser.parse("Dear Customer, Acct XX123 is credited with Rs 5000.00 on 01-Nov-26 from ANITA DESAI. UPI:630599990000-ICICI Bank.", sender: "JD-ICICIT");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.credit);
    expect(r!.amount, 5000.0);
    expect(r!.merchant, "Anita Desai");
    expect(r!.accountLast4, "123");
    expect(r!.bank, "ICICI");
  });
  test("ICICI credit card with limit", () {
    final r = BankSmsParser.parse("INR 1,499.00 spent using ICICI Bank Card XX9012 on 01-Nov-26 on NETFLIX. Avl Limit: INR 98,501.00. If not you, call 1800 2662/SMS BLOCK 9012 to 9215676766.", sender: "VM-ICICIB");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 1499.0);
    expect(r!.accountLast4, "9012");
    expect(r!.balance, isNull);
    expect(r!.bank, "ICICI");
  });
  test("Axis UPI debit", () {
    final r = BankSmsParser.parse("INR 500.00 debited\nA/c no. XX1234\n01-11-26, 10:20:30\nUPI/P2M/630512340000/BIGBASKET\nNot you? SMS BLOCKUPI Cust ID to 919951860002\nAxis Bank", sender: "AX-AXISBK");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 500.0);
    expect(r!.merchant, "Bigbasket");
    expect(r!.accountLast4, "1234");
    expect(r!.reference, "630512340000");
    expect(r!.bank, "Axis");
  });
  test("Axis credit", () {
    final r = BankSmsParser.parse("INR 2,000.00 credited\nA/c no. XX1234\n01-11-26, 10:20:30 IST\nUPI/P2A/630543210000/SURESH\nAvl Bal: INR 7,000.00\nAxis Bank", sender: "AX-AXISBK");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.credit);
    expect(r!.amount, 2000.0);
    expect(r!.merchant, "Suresh");
    expect(r!.accountLast4, "1234");
    expect(r!.balance, 7000.0);
    expect(r!.bank, "Axis");
  });
  test("Kotak sent", () {
    final r = BankSmsParser.parse("Sent Rs.200.00 from Kotak Bank AC X4455 to chaiwala@ybl on 01-11-26.UPI Ref 630511223344. Not you, https://kotak.com/KBANKT/Fraud", sender: "VM-KOTAKB");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 200.0);
    expect(r!.merchant, "Chaiwala");
    expect(r!.accountLast4, "4455");
    expect(r!.reference, "630511223344");
    expect(r!.bank, "Kotak");
  });
  test("Kotak received", () {
    final r = BankSmsParser.parse("Received Rs.500.00 in your Kotak Bank AC X4455 from vikram@okaxis on 01-11-26.UPI Ref:630599887766.", sender: "VM-KOTAKB");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.credit);
    expect(r!.amount, 500.0);
    expect(r!.merchant, "Vikram");
    expect(r!.accountLast4, "4455");
    expect(r!.bank, "Kotak");
  });
  test("Paytm wallet", () {
    final r = BankSmsParser.parse("Paid Rs.100 to Ramesh Kirana Store from Paytm Balance. Updated Balance: Paytm Wallet- Rs 50. More details: https://m.paytm.me/xyz", sender: "VM-PAYTMB");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 100.0);
    expect(r!.merchant, "Ramesh Kirana Store");
    expect(r!.bank, "Paytm");
  });
  test("NACH autopay", () {
    final r = BankSmsParser.parse("Rs.1,200.00 debited from A/c XX1234 on 05-11-26 towards NACH-ICICI PRU LIFE. Avl bal Rs 8,800.00", sender: "VM-HDFCBK");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 1200.0);
    expect(r!.accountLast4, "1234");
    expect(r!.balance, 8800.0);
    expect(r!.isAutopay, true);
  });
  test("UPI mandate autopay", () {
    final r = BankSmsParser.parse("Your A/c XX123 debited with INR 649.00 on 05-Nov-26 for UPI Mandate NETFLIX. UPI Ref 630566554433. -ICICI Bank", sender: "JD-ICICIT");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 649.0);
    expect(r!.accountLast4, "123");
    expect(r!.isAutopay, true);
    expect(r!.reference, "630566554433");
  });
  test("Refund", () {
    final r = BankSmsParser.parse("Rs.299.00 has been refunded to your HDFC Bank Debit Card 5678 by FLIPKART on 01-11-26.", sender: "VM-HDFCBK");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.credit);
    expect(r!.amount, 299.0);
    expect(r!.accountLast4, "5678");
  });
  test("ATM", () {
    final r = BankSmsParser.parse("Dear Customer, Rs.2000 withdrawn at ATM from A/c XX1234 on 01Nov26. Avl Bal Rs 5000.00 -SBI", sender: "VM-SBIINB");
    expect(r, isNotNull);
    expect(r!.type, BankSmsType.debit);
    expect(r!.amount, 2000.0);
    expect(r!.accountLast4, "1234");
    expect(r!.balance, 5000.0);
  });
  test("IGNORE OTP", () {
    final r = BankSmsParser.parse("123456 is your OTP for txn of Rs.500 at AMAZON on HDFC Bank Card 5678. Do not share.", sender: "VM-HDFCBK");
    expect(r, isNull);
  });
  test("IGNORE future autopay", () {
    final r = BankSmsParser.parse("Your A/c XX1234 will be debited with Rs.649.00 on 05-11-26 towards NETFLIX autopay mandate.", sender: "VM-HDFCBK");
    expect(r, isNull);
  });
  test("IGNORE failed", () {
    final r = BankSmsParser.parse("Your UPI txn of Rs.500 to SWIGGY from A/c XX1234 has failed.", sender: "VM-HDFCBK");
    expect(r, isNull);
  });
  test("IGNORE collect request", () {
    final r = BankSmsParser.parse("RAJ has requested Rs.300 from you via UPI. Ignore if not known.", sender: "VM-HDFCBK");
    expect(r, isNull);
  });
  test("IGNORE card bill due", () {
    final r = BankSmsParser.parse("Total due Rs.12,000 for SBI Card ending 4321 is due on 15-11-26. Min amount due Rs.600.", sender: "VM-SBICRD");
    expect(r, isNull);
  });
  test("IGNORE card payment ack", () {
    final r = BankSmsParser.parse("Payment of Rs.12,000 received towards your SBI Credit Card ending 4321. Thank you.", sender: "VM-SBICRD");
    expect(r, isNull);
  });
  test("IGNORE loan offer", () {
    final r = BankSmsParser.parse("You are pre-approved for a loan of Rs.5,00,000 on your HDFC Bank account. Apply now.", sender: "VM-HDFCBK");
    expect(r, isNull);
  });
  test("IGNORE personal number", () {
    final r = BankSmsParser.parse("Sent Rs.500 to your account bro", sender: "+919876543210");
    expect(r, isNull);
  });
}
