import 'package:bvibe/const/theme.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

// ── Models ────────────────────────────────────────────────────────────────────

enum DiscountType { percentage, fixed }

class DiscountRule {
  final String id;
  final double thresholdAmount;
  final DiscountType type;
  final double value;
  bool enabled;

  DiscountRule({
    required this.id,
    required this.thresholdAmount,
    required this.type,
    required this.value,
    this.enabled = true,
  });

  DiscountRule copyWith({
    double? thresholdAmount,
    DiscountType? type,
    double? value,
    bool? enabled,
  }) {
    return DiscountRule(
      id: id,
      thresholdAmount: thresholdAmount ?? this.thresholdAmount,
      type: type ?? this.type,
      value: value ?? this.value,
      enabled: enabled ?? this.enabled,
    );
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final _taxController = TextEditingController(text: "0");
  bool _taxEnabled = false;
  bool _taxInclusive = false;

  final List<DiscountRule> _rules = [
    DiscountRule(
      id: '1',
      thresholdAmount: 5000,
      type: DiscountType.percentage,
      value: 5,
    ),
    DiscountRule(
      id: '2',
      thresholdAmount: 10000,
      type: DiscountType.fixed,
      value: 1000,
    ),
  ];

  int _idCounter = 3;

  @override
  void dispose() {
    _taxController.dispose();
    super.dispose();
  }

  void _addRule() {
    setState(() {
      _rules.add(
        DiscountRule(
          id: '${_idCounter++}',
          thresholdAmount: 0,
          type: DiscountType.percentage,
          value: 0,
        ),
      );
    });
  }

  void _removeRule(String id) =>
      setState(() => _rules.removeWhere((r) => r.id == id));

  void _updateRule(DiscountRule updated) {
    setState(() {
      final idx = _rules.indexWhere((r) => r.id == updated.id);
      if (idx != -1) _rules[idx] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tax & Discounts",
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Configure tax rates and automatic bill discounts.",
          style: theme.textTheme.labelSmall,
        ),

        const SizedBox(height: 30),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTaxSection(theme),
                  const SizedBox(height: 32),
                  _buildDiscountSection(theme),
                ],
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(theme, "Bill Preview"),
                  const SizedBox(height: 16),
                  _buildBillPreview(theme),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Tax Section ─────────────────────────────────────────────────────────────

  Widget _buildTaxSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, "Tax"),
        const SizedBox(height: 16),
        _card(
          child: Column(
            children: [
              _toggleRow(
                theme,
                label: "Enable Tax",
                subtitle: "Apply tax to all bills",
                icon: Symbols.receipt_long,
                value: _taxEnabled,
                onChanged: (v) => setState(() => _taxEnabled = v),
              ),
              if (_taxEnabled) ...[
                Divider(color: AppColors.divider, height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tax Rate (%)",
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _taxController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Symbols.percent, size: 18),
                              suffixText: "%",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tax Type", style: theme.textTheme.labelMedium),
                          const SizedBox(height: 6),
                          _segmentedControl(
                            theme,
                            options: ["Exclusive", "Inclusive"],
                            selected: _taxInclusive ? 1 : 0,
                            onTap: (i) =>
                                setState(() => _taxInclusive = i == 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _infoChip(
                  theme,
                  _taxInclusive
                      ? "Tax is included in the displayed price."
                      : "Tax will be added on top of the subtotal.",
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Discount Section ─────────────────────────────────────────────────────────

  Widget _buildDiscountSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle(theme, "Automatic Discounts")),
            TextButton.icon(
              onPressed: _addRule,
              icon: const Icon(Symbols.add, size: 16),
              label: const Text("Add Rule"),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Discounts applied automatically when bill exceeds a threshold.",
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 16),
        if (_rules.isEmpty)
          _emptyRules(theme)
        else
          // key: ValueKey(rule.id) ensures the StatefulWidget for each rule
          // is NOT recreated on rebuild — controllers survive setState calls
          Column(
            children: _rules
                .map(
                  (rule) => _RuleCard(
                    key: ValueKey(rule.id),
                    rule: rule,
                    onChanged: _updateRule,
                    onDelete: () => _removeRule(rule.id),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  // ── Bill Preview ─────────────────────────────────────────────────────────────

  Widget _buildBillPreview(ThemeData theme) {
    const subtotal = 8500.0;
    final taxRate = double.tryParse(_taxController.text) ?? 0;

    final activeRules =
        _rules
            .where(
              (r) => r.enabled && r.thresholdAmount <= subtotal && r.value > 0,
            )
            .toList()
          ..sort((a, b) => b.thresholdAmount.compareTo(a.thresholdAmount));
    final bestRule = activeRules.isNotEmpty ? activeRules.first : null;

    double discountAmount = 0;
    if (bestRule != null) {
      discountAmount = bestRule.type == DiscountType.percentage
          ? subtotal * bestRule.value / 100
          : bestRule.value;
    }

    final afterDiscount = subtotal - discountAmount;
    double taxAmount = 0;
    double total = afterDiscount;

    if (_taxEnabled && taxRate > 0) {
      if (_taxInclusive) {
        taxAmount = afterDiscount - (afterDiscount / (1 + taxRate / 100));
        total = afterDiscount;
      } else {
        taxAmount = afterDiscount * taxRate / 100;
        total = afterDiscount + taxAmount;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sample Bill",
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _billRow(theme, "Item 1 × 2", "Rs. 3,000.00"),
          _billRow(theme, "Item 2 × 1", "Rs. 2,500.00"),
          _billRow(theme, "Item 3 × 3", "Rs. 3,000.00"),
          const SizedBox(height: 10),
          Divider(color: AppColors.divider),
          const SizedBox(height: 6),
          _billRow(
            theme,
            "Subtotal",
            "${AppNumberFormat.formatNumber(subtotal)} LKR",
          ),
          if (discountAmount > 0) ...[
            const SizedBox(height: 4),
            _billRow(
              theme,
              bestRule!.type == DiscountType.percentage
                  ? "Discount (${bestRule.value.toStringAsFixed(1)}%)"
                  : "Discount",
              "- ${AppNumberFormat.formatNumber(discountAmount)} LKR",
              valueColor: const Color(0xFF22C55E),
            ),
          ],
          if (_taxEnabled && taxRate > 0) ...[
            const SizedBox(height: 4),
            _billRow(
              theme,
              _taxInclusive
                  ? "Tax (${taxRate.toStringAsFixed(1)}% incl.)"
                  : "Tax (${taxRate.toStringAsFixed(1)}%)",
              "${AppNumberFormat.formatNumber(taxAmount)} LKR",
              valueColor: AppColors.textSecondary,
            ),
          ],
          const SizedBox(height: 10),
          Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TOTAL",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "${AppNumberFormat.formatNumber(total)} LKR",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          if (bestRule != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Symbols.local_offer,
                    size: 14,
                    color: Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "\"${_ruleLabel(bestRule)}\" applied",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF22C55E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _ruleLabel(DiscountRule rule) {
    final threshold =
        "${AppNumberFormat.formatNumber(rule.thresholdAmount)} LKR";
    final discount = rule.type == DiscountType.percentage
        ? "${rule.value.toStringAsFixed(1)}% off"
        : "${AppNumberFormat.formatNumber(rule.value)} LKR off";
    return "Spend over $threshold → $discount";
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.textSecondary.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );

  Widget _sectionTitle(ThemeData theme, String title) => Text(
    title,
    style: theme.textTheme.labelMedium?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _toggleRow(
    ThemeData theme, {
    required String label,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(subtitle, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _segmentedControl(
    ThemeData theme, {
    required List<String> options,
    required int selected,
    required ValueChanged<int> onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final isSel = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                options[i],
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSel ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _infoChip(ThemeData theme, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(Symbols.info, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _billRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyRules(ThemeData theme) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 32),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      children: [
        Icon(
          Symbols.local_offer,
          size: 32,
          color: AppColors.textSecondary.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 10),
        Text(
          "No discount rules yet",
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Tap \"Add Rule\" to create one.",
          style: theme.textTheme.labelSmall,
        ),
      ],
    ),
  );
}

// ── Rule Card — own StatefulWidget so controllers are NOT recreated on parent rebuild ──

class _RuleCard extends StatefulWidget {
  final DiscountRule rule;
  final ValueChanged<DiscountRule> onChanged;
  final VoidCallback onDelete;

  const _RuleCard({
    super.key,
    required this.rule,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_RuleCard> createState() => _RuleCardState();
}

class _RuleCardState extends State<_RuleCard> {
  late final TextEditingController _thresholdCtrl;
  late final TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    _thresholdCtrl = TextEditingController(
      text: widget.rule.thresholdAmount > 0
          ? widget.rule.thresholdAmount.toStringAsFixed(0)
          : '',
    );
    _valueCtrl = TextEditingController(
      text: widget.rule.value > 0
          ? widget.rule.value.toStringAsFixed(
              widget.rule.type == DiscountType.percentage ? 1 : 0,
            )
          : '',
    );
  }

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _notify({
    double? threshold,
    DiscountType? type,
    double? value,
    bool? enabled,
  }) {
    widget.onChanged(
      widget.rule.copyWith(
        thresholdAmount: threshold,
        type: type,
        value: value,
        enabled: enabled,
      ),
    );
  }

  String _ruleLabel() {
    final r = widget.rule;
    final threshold = "${AppNumberFormat.formatNumber(r.thresholdAmount)} LKR";
    final discount = r.type == DiscountType.percentage
        ? "${r.value.toStringAsFixed(1)}% off"
        : "${AppNumberFormat.formatNumber(r.value)} LKR off";
    return "Spend over $threshold → $discount";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rule = widget.rule;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row — toggle + label + delete
            Row(
              children: [
                Switch(
                  value: rule.enabled,
                  onChanged: (v) => _notify(enabled: v),
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _ruleLabel(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: rule.enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: Icon(
                    Symbols.delete_outline,
                    size: 18,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.textSecondary.withValues(
                      alpha: 0.06,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            Divider(color: AppColors.divider, height: 16),

            // Fields row
            Row(
              children: [
                // Threshold
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Min. Bill (LKR)",
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _thresholdCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (v) =>
                            _notify(threshold: double.tryParse(v) ?? 0),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Symbols.currency_rupee, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Discount value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Discount Value",
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _valueCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        onChanged: (v) =>
                            _notify(value: double.tryParse(v) ?? 0),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            rule.type == DiscountType.percentage
                                ? Symbols.percent
                                : Symbols.currency_rupee,
                            size: 18,
                          ),
                          suffixText: rule.type == DiscountType.percentage
                              ? "%"
                              : "LKR",
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Type toggle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Type", style: theme.textTheme.labelMedium),
                    const SizedBox(height: 6),
                    _segmentedControl(
                      theme,
                      options: ["%", "LKR"],
                      selected: rule.type == DiscountType.percentage ? 0 : 1,
                      onTap: (i) => _notify(
                        type: i == 0
                            ? DiscountType.percentage
                            : DiscountType.fixed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentedControl(
    ThemeData theme, {
    required List<String> options,
    required int selected,
    required ValueChanged<int> onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final isSel = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                options[i],
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSel ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
