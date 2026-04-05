import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/provider/expense.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class AddExpenseEntryDialog extends StatefulWidget {
  const AddExpenseEntryDialog({super.key});

  @override
  State<AddExpenseEntryDialog> createState() => _AddExpenseEntryDialogState();
}

class _AddExpenseEntryDialogState extends State<AddExpenseEntryDialog>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _qtyCtrl    = TextEditingController(text: '1');
  final _descCtrl   = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  DateTime _dateSelection  = DateTime.now();
  String?  _selectedItemId;
  bool     _isSaving       = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _qtyCtrl.dispose();
    _descCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon, {String? hint, String? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      hintStyle:  TextStyle(color: Colors.grey.shade400, fontSize: 13),
      suffixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Icon(icon, size: 18, color: Colors.grey.shade400),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 46),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.6),
      ),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.enter): () {
              final provider = context.read<ExpenseProvider>();
              final selectedItem = _selectedItemId == null
                  ? null
                  : provider.expenseItems
                      .where((i) => i.id == _selectedItemId)
                      .firstOrNull;
              _save(provider, selectedItem);
            },
            const SingleActivator(LogicalKeyboardKey.numpadEnter): () {
              final provider = context.read<ExpenseProvider>();
              final selectedItem = _selectedItemId == null
                  ? null
                  : provider.expenseItems
                      .where((i) => i.id == _selectedItemId)
                      .firstOrNull;
              _save(provider, selectedItem);
            },
          },
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 20,
            shadowColor: Colors.black.withOpacity(0.18),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Consumer<ExpenseProvider>(
                  builder: (context, provider, _) {
                    final items = provider.expenseItems;
                    final selectedItem = _selectedItemId == null
                        ? null
                        : items.where((i) => i.id == _selectedItemId).firstOrNull;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Header ────────────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                Color.alphaBlend(
                                  Colors.black.withOpacity(0.10),
                                  AppColors.primary,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Icon(
                                  Symbols.receipt_long,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Record New Expense',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      'Log a new expense entry to your records',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.70),
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Symbols.close, size: 20),
                                color: Colors.white70,
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(36, 36),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Form ──────────────────────────────────────────────
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: _selectedItemId,
                                    isExpanded: true,
                                    icon: Icon(Symbols.expand_more, size: 20, color: Colors.grey.shade400),
                                    decoration: _dec('Expense Item', Symbols.inventory_2),
                                    items: [
                                      DropdownMenuItem(
                                        value: null,
                                        child: Row(
                                          children: [
                                            Icon(Symbols.category, size: 15, color: Colors.grey.shade400),
                                            const SizedBox(width: 10),
                                            const Text('Miscellaneous / Other', style: TextStyle(fontSize: 13.5)),
                                          ],
                                        ),
                                      ),
                                      ...items.map((i) => DropdownMenuItem(
                                            value: i.id,
                                            child: Text(i.name, style: const TextStyle(fontSize: 13.5)),
                                          )),
                                    ],
                                    onChanged: (v) => setState(() => _selectedItemId = v),
                                  ),
                                  const SizedBox(height: 13),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: TextFormField(
                                          controller: _amountCtrl,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: _dec('Amount (LKR)', Symbols.payments),
                                          validator: (v) =>
                                              v == null || v.trim().isEmpty ? 'Required' : null,
                                        ),
                                      ),
                                      if (_selectedItemId != null) ...[
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 3,
                                          child: TextFormField(
                                            controller: _qtyCtrl,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: _dec(
                                              'Qty',
                                              Symbols.pin,
                                              suffix: selectedItem?.unit ?? '',
                                            ),
                                            validator: (v) =>
                                                v == null || v.trim().isEmpty ? 'Required' : null,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 13),
                                  TextFormField(
                                    controller: _descCtrl,
                                    textCapitalization: TextCapitalization.sentences,
                                    decoration: _dec(
                                      'Note / Details (optional)',
                                      Symbols.description,
                                      hint: 'Any specific detail about this expense…',
                                    ),
                                  ),
                                  const SizedBox(height: 13),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: _pickDate,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F9FA),
                                          border: Border.all(color: Colors.grey.shade200),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Symbols.calendar_today, size: 18, color: Colors.grey.shade400),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Expense Date',
                                                    style: TextStyle(
                                                      fontSize: 11.5,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 1),
                                                  Text(
                                                    DateFormat('MMMM dd, yyyy').format(_dateSelection),
                                                    style: const TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Change',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 12,
                                          ),
                                          foregroundColor: Colors.grey.shade500,
                                        ),
                                        child: const Text('Cancel', style: TextStyle(fontSize: 13.5)),
                                      ),
                                      const SizedBox(width: 8),
                                      FilledButton.icon(
                                        onPressed: _isSaving ? null : () => _save(provider, selectedItem),
                                        icon: _isSaving
                                            ? const SizedBox(
                                                width: 14,
                                                height: 14,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Icon(Symbols.add_circle, size: 17),
                                        label: const Text(
                                          'Record Expense',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateSelection,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateSelection = picked);
  }

  Future<void> _save(ExpenseProvider provider, dynamic selectedItem) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await provider.addExpense(
        amount: _amountCtrl.text.trim(),
        date: _dateSelection,
        description: _descCtrl.text.trim().isEmpty
            ? (selectedItem?.name ?? 'Miscellaneous')
            : _descCtrl.text.trim(),
        itemId: _selectedItemId,
        qty: _qtyCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to record expense'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}