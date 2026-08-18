import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:flutter_test/flutter_test.dart';

Budget monthlyBudget(DateTime startDate) {
  return Budget(
    budgetPk: 'budget',
    name: 'Monthly budget',
    amount: 200,
    startDate: startDate,
    endDate: startDate,
    income: false,
    archived: false,
    addedTransactionsOnly: false,
    periodLength: 1,
    reoccurrence: BudgetReoccurence.monthly,
    dateCreated: startDate,
    pinned: false,
    order: 0,
    walletFk: 'wallet',
    isAbsoluteSpendingLimit: false,
    rollover: true,
  );
}

void main() {
  group('calculateRolloverBudgetAmount', () {
    test('carries the unused balance into the next period', () {
      expect(
        calculateRolloverBudgetAmount(
          baseAmount: 200,
          completedPeriods: 1,
          amountUsedBeforePeriod: 180,
        ),
        220,
      );
    });

    test('keeps cumulative overspending in later periods', () {
      expect(
        calculateRolloverBudgetAmount(
          baseAmount: 200,
          completedPeriods: 2,
          amountUsedBeforePeriod: 450,
        ),
        150,
      );
    });

    test('never returns a negative available amount', () {
      expect(
        calculateRolloverBudgetAmount(
          baseAmount: 200,
          completedPeriods: 1,
          amountUsedBeforePeriod: 450,
        ),
        0,
      );
    });

    test('caps the total available amount without lowering the base', () {
      expect(
        calculateRolloverBudgetAmount(
          baseAmount: 200,
          completedPeriods: 2,
          amountUsedBeforePeriod: 0,
          rolloverLimit: 300,
        ),
        300,
      );
      expect(
        calculateRolloverBudgetAmount(
          baseAmount: 200,
          completedPeriods: 1,
          amountUsedBeforePeriod: 180,
          rolloverLimit: 100,
        ),
        200,
      );
    });
  });

  group('getBudgetPeriodsBeforeDate', () {
    test('counts monthly periods using the budget calendar boundaries', () {
      Budget budget = monthlyBudget(DateTime(2024, 1, 31));

      expect(getBudgetPeriodsBeforeDate(budget, DateTime(2024, 1, 31)), 0);
      expect(getBudgetPeriodsBeforeDate(budget, DateTime(2024, 3, 2)), 1);
      expect(getBudgetPeriodsBeforeDate(budget, DateTime(2024, 4, 2)), 2);
    });
  });
}
