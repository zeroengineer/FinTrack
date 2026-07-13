import '../models/category.dart';
import '../models/txn_kind.dart';

final kDefaultCategories = <CategoryRecord>[
  CategoryRecord(id: 'food', name: 'Food', kind: TxnKind.expense, iconName: 'restaurant', colorHex: '#F59E0B'),
  CategoryRecord(id: 'transport', name: 'Transport', kind: TxnKind.expense, iconName: 'directions_bus', colorHex: '#3B82F6'),
  CategoryRecord(id: 'shopping', name: 'Shopping', kind: TxnKind.expense, iconName: 'shopping_bag', colorHex: '#EC4899'),
  CategoryRecord(id: 'bills', name: 'Bills', kind: TxnKind.expense, iconName: 'receipt_long', colorHex: '#8B5CF6'),
  CategoryRecord(id: 'entertainment', name: 'Entertainment', kind: TxnKind.expense, iconName: 'movie', colorHex: '#F43F5E'),
  CategoryRecord(id: 'health', name: 'Health', kind: TxnKind.expense, iconName: 'ecg_heart', colorHex: '#22C55E'),
  CategoryRecord(id: 'travel', name: 'Travel', kind: TxnKind.expense, iconName: 'flight', colorHex: '#06B6D4'),
  CategoryRecord(id: 'education', name: 'Education', kind: TxnKind.expense, iconName: 'school', colorHex: '#6366F1'),
  CategoryRecord(id: 'rent', name: 'Rent', kind: TxnKind.expense, iconName: 'home_work', colorHex: '#F97316'),
  CategoryRecord(id: 'others', name: 'Others', kind: TxnKind.expense, iconName: 'category', colorHex: '#94A3B8'),
  CategoryRecord(id: 'salary', name: 'Salary', kind: TxnKind.income, iconName: 'payments', colorHex: '#22C55E'),
  CategoryRecord(id: 'freelance', name: 'Freelance', kind: TxnKind.income, iconName: 'work', colorHex: '#3B82F6'),
  CategoryRecord(id: 'bonus', name: 'Bonus', kind: TxnKind.income, iconName: 'redeem', colorHex: '#F59E0B'),
  CategoryRecord(id: 'gift', name: 'Gift', kind: TxnKind.income, iconName: 'card_giftcard', colorHex: '#EC4899'),
  CategoryRecord(id: 'other_income', name: 'Other', kind: TxnKind.income, iconName: 'savings', colorHex: '#94A3B8'),
];
