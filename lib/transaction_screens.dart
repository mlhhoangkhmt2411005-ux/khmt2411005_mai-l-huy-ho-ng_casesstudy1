import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class TxCategory {
  final String name;
  final IconData icon;
  final Color color;

  const TxCategory(this.name, this.icon, this.color);
}

const List<TxCategory> expenseCategories = [
  TxCategory('Ăn uống', Icons.restaurant, Color(0xFFFF5A5F)),
  TxCategory('Di chuyển', Icons.directions_bus, Color(0xFF1976D2)),
  TxCategory('Mua sắm', Icons.shopping_bag, Color(0xFFAB47BC)),
  TxCategory('Hóa đơn', Icons.receipt_long, Color(0xFFFFA726)),
];

const List<TxCategory> incomeCategories = [
  TxCategory('Lương', Icons.payments, Color(0xFF2E7D32)),
  TxCategory('Thưởng', Icons.card_giftcard, Color(0xFF00897B)),
  TxCategory('Khác', Icons.more_horiz, Color(0xFF757575)),
];

class Transaction {
  final bool isExpense;
  final String category;
  final int amount;
  final DateTime date;
  final String note;

  const Transaction({
    required this.isExpense,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// 100000 -> "100.000"
String formatAmount(int value) {
  final digits = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return buf.toString();
}

/// Tự thêm dấu chấm ngăn cách hàng nghìn khi nhập số tiền.
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = formatAmount(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ---------------------------------------------------------------------------
// Hai màn hình: Thêm giao dịch / Sửa giao dịch
// ---------------------------------------------------------------------------

/// Màn hình "Thêm giao dịch" (form trống).
class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionFormScreen(title: 'Thêm giao dịch');
  }
}

/// Màn hình "Sửa giao dịch" (form điền sẵn dữ liệu).
/// Nếu không truyền [transaction] sẽ dùng dữ liệu mẫu giống ảnh đề bài.
class EditTransactionScreen extends StatelessWidget {
  final Transaction? transaction;

  const EditTransactionScreen({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    return TransactionFormScreen(
      title: 'Sửa giao dịch',
      initial: transaction ??
          Transaction(
            isExpense: true,
            category: 'Ăn uống',
            amount: 100000,
            date: DateTime(2025, 4, 12),
            note: 'Ăn trưa',
          ),
    );
  }
}

/// Form dùng chung cho cả hai màn hình. Bấm "Lưu" sẽ trả [Transaction]
/// về màn hình trước qua Navigator.pop.
class TransactionFormScreen extends StatefulWidget {
  final String title;
  final Transaction? initial;

  const TransactionFormScreen({super.key, required this.title, this.initial});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  static const Color _primary = Color(0xFF1565C0);
  static const Color _expenseColor = Color(0xFFFF5A5F);
  static const Color _incomeColor = Color(0xFF2E7D32);
  static const Color _labelColor = Color(0xFF0B1B3A);
  static const Color _hintColor = Color(0xFF9CA3AF);
  static const Color _borderColor = Color(0xFFE5E7EB);

  late bool _isExpense;
  late TxCategory _category;
  late DateTime _date;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  List<TxCategory> get _categories =>
      _isExpense ? expenseCategories : incomeCategories;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _isExpense = t?.isExpense ?? true;
    _category = _categories.firstWhere(
      (c) => c.name == t?.category,
      orElse: () => _categories.first,
    );
    _date = t?.date ?? DateTime(2025, 4, 12);
    _amountController =
        TextEditingController(text: t == null ? '' : formatAmount(t.amount));
    _noteController = TextEditingController(text: t?.note ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setType(bool isExpense) {
    if (_isExpense == isExpense) return;
    setState(() {
      _isExpense = isExpense;
      _category = _categories.first; // đổi tab thì đổi danh sách danh mục
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final digits = _amountController.text.replaceAll('.', '');
    final amount = int.tryParse(digits) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }
    Navigator.of(context).pop(
      Transaction(
        isExpense: _isExpense,
        category: _category.name,
        amount: amount,
        date: _date,
        note: _noteController.text.trim(),
      ),
    );
  }

  // ---- UI -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _labelColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: _labelColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeToggle(),
                    const SizedBox(height: 20),
                    _label('Danh mục'),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 20),
                    _label('Số tiền'),
                    _buildAmountField(),
                    const SizedBox(height: 20),
                    _label('Ngày giao dịch'),
                    _buildDateField(),
                    const SizedBox(height: 20),
                    _label('Ghi chú'),
                    _buildNoteField(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _labelColor,
          ),
        ),
      );

  InputDecoration _decoration({String? hint, Widget? suffix}) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hintColor, fontSize: 14),
      suffixIcon: suffix,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: border(_borderColor),
      focusedBorder: border(_primary),
      border: border(_borderColor),
    );
  }

  Widget _buildTypeToggle() {
    Widget tab(String text, bool isExpenseTab) {
      final selected = _isExpense == isExpenseTab;
      final activeColor = isExpenseTab ? _expenseColor : _incomeColor;
      return Expanded(
        child: GestureDetector(
          onTap: () => _setType(isExpenseTab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? activeColor : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? activeColor : _borderColor,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _labelColor,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab('Chi tiêu', true),
        const SizedBox(width: 10),
        tab('Thu nhập', false),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<TxCategory>(
      key: ValueKey(_isExpense), // tạo lại dropdown khi đổi tab
      initialValue: _category,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down, color: _labelColor),
      decoration: _decoration(),
      items: _categories
          .map(
            (c) => DropdownMenuItem<TxCategory>(
              value: c,
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c.color.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(c.icon, size: 16, color: c.color),
                  ),
                  const SizedBox(width: 10),
                  Text(c.name, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _category = value);
      },
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandsFormatter(),
      ],
      decoration: _decoration(
        hint: 'Nhập số tiền',
        suffix: const Padding(
          padding: EdgeInsets.only(right: 14),
          child: Align(
            widthFactor: 1,
            child: Text('đ', style: TextStyle(color: _labelColor)),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _pickDate,
      child: InputDecorator(
        decoration: _decoration(
          suffix: const Icon(Icons.calendar_today_outlined,
              size: 20, color: _labelColor),
        ),
        child: Text(
          formatDate(_date),
          style: const TextStyle(fontSize: 14, color: _labelColor),
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      minLines: 3,
      maxLines: 3,
      decoration: _decoration(hint: 'Nhập ghi chú (tùy chọn)'),

    );
  }
}
