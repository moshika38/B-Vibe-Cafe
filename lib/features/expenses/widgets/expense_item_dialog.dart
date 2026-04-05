import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/model/expense_item.model.dart';
import 'package:bvibe/provider/expense.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ExpenseItemDialog extends StatefulWidget {
  final ExpenseItemModel? item;
  const ExpenseItemDialog({super.key, this.item});

  @override
  State<ExpenseItemDialog> createState() => _ExpenseItemDialogState();
}

class _ExpenseItemDialogState extends State<ExpenseItemDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String _unit = 'units';
  bool _isSaving = false;

  final List<Map<String, dynamic>> _units = [
    {'value': 'units', 'label': 'Units',               'icon': Symbols.tag},
    {'value': 'kg',    'label': 'Kilogram (kg)',        'icon': Symbols.weight},
    {'value': 'g',     'label': 'Gram (g)',             'icon': Symbols.weight},
    {'value': 'ltr',   'label': 'Litre (ltr)',          'icon': Symbols.water_drop},
    {'value': 'ml',    'label': 'Millilitre (ml)',      'icon': Symbols.water_drop},
    {'value': 'pcs',   'label': 'Pieces (pcs)',         'icon': Symbols.layers},
    {'value': 'box',   'label': 'Box',                  'icon': Symbols.inventory_2},
    {'value': 'bag',   'label': 'Bag',                  'icon': Symbols.shopping_bag},
    {'value': 'kWh',   'label': 'Kilowatt-hour (kWh)', 'icon': Symbols.bolt},
    {'value': 'm3',    'label': 'Cubic Metre (m³)',     'icon': Symbols.view_in_ar},
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item?.name ?? '');
    _descCtrl = TextEditingController(text: widget.item?.description ?? '');
    if (widget.item != null) _unit = widget.item!.unit;

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
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Shared field decoration ─────────────────────────────────────────────────
  InputDecoration _dec(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      hintStyle:  TextStyle(color: Colors.grey.shade400, fontSize: 13),
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
    final bool isEdit = widget.item != null;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.enter): _save,
            const SingleActivator(LogicalKeyboardKey.numpadEnter): _save,
          },
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 20,
            shadowColor: Colors.black.withOpacity(0.18),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460, maxHeight: 530),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // ── Header ──────────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            Color.alphaBlend(Colors.black.withOpacity(0.1), AppColors.primary),
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
                            child: Icon(
                              isEdit ? Symbols.edit : Symbols.inventory_2,
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
                                Text(
                                  isEdit ? 'Edit Expense Item' : 'New Expense Item',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  isEdit
                                      ? 'Update template details'
                                      : 'Create a reusable item template',
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

                    // ── Form ────────────────────────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _nameCtrl,
                                textCapitalization: TextCapitalization.words,
                                autofocus: true,
                                decoration: _dec(
                                  'Item Name *',
                                  Symbols.label,
                                  hint: 'e.g. Milk, Rent, Electricity',
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Item name is required'
                                        : null,
                              ),
                              const SizedBox(height: 13),
                              TextFormField(
                                controller: _descCtrl,
                                maxLines: 2,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: _dec(
                                  'Description (optional)',
                                  Symbols.description,
                                  hint: 'Short note about this item…',
                                ),
                              ),
                              const SizedBox(height: 13),
                              DropdownButtonFormField<String>(
                                value: _unit,
                                isExpanded: true,
                                icon: Icon(Symbols.expand_more, size: 20, color: Colors.grey.shade400),
                                decoration: _dec('Measurement Unit', Symbols.straighten),
                                items: _units.map((u) {
                                  return DropdownMenuItem<String>(
                                    value: u['value'] as String,
                                    child: Row(
                                      children: [
                                        Icon(u['icon'] as IconData, size: 15, color: Colors.grey.shade500),
                                        const SizedBox(width: 10),
                                        Text(u['label'] as String, style: const TextStyle(fontSize: 13.5)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _unit = v!),
                              ),
                              const SizedBox(height: 26),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                      foregroundColor: Colors.grey.shade500,
                                    ),
                                    child: const Text('Cancel', style: TextStyle(fontSize: 13.5)),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.icon(
                                    onPressed: _isSaving ? null : _save,
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Icon(isEdit ? Symbols.check : Symbols.add, size: 17),
                                    label: Text(
                                      isEdit ? 'Update Item' : 'Create Item',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      if (widget.item == null) {
        await context.read<ExpenseProvider>().addExpenseItem(
              name: _nameCtrl.text.trim(),
              unit: _unit,
              description: _descCtrl.text.trim(),
            );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save expense item'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}