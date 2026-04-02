import 'package:bvibe/data/model/invoice.model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/provider/receipt.provider.dart';

class InvoicePage extends StatelessWidget {
  final InvoiceDisplayModel? invoice;
  const InvoicePage({super.key, this.invoice});

  static Widget fromId(String id) {
    return Consumer<ReceiptProvider>(
      builder: (context, provider, _) => FutureBuilder<ReceiptModel?>(
        future: provider.getReceipt(id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, color: Colors.black54, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'No Invoice',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.black54),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Invoice not found',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            );
          }
          return InvoicePage(
            invoice: InvoiceDisplayModel.fromReceipt(snap.data!),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (invoice == null) return const SizedBox.shrink();
    return Center(
      child: Container(
        width: 360,
        margin: const EdgeInsets.symmetric(vertical: 24),
        color: const Color(0xFFFAFAFA),
        padding: const EdgeInsets.all(28),
        child: _InvoiceLayout(invoice: invoice!),
      ),
    );
  }
}

class _InvoiceLayout extends StatelessWidget {
  final InvoiceDisplayModel invoice;
  const _InvoiceLayout({required this.invoice});

  static const String _fontFamily = 'monospace';
  static const Color _ink = Color(0xFF111111);
  static const Color _muted = Color(0xFF999999);
  static const Color _light = Color(0xFFAAAAAA);
  static const Color _dash = Color(0xFFBBBBBB);
  static const Color _itemDash = Color(0xFFE0E0E0);

  TextStyle get _mono => const TextStyle(fontFamily: _fontFamily);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        _divider(),
        _buildMeta(),
        _divider(),
        _buildItemsHeader(),
        _divider(color: _dash, marginTop: 0, marginBottom: 0),
        _buildItems(),
        _divider(marginBottom: 0),
        _buildSummary(),
        _divider(marginTop: 0),

        _buildPayment(),
        _divider(),
        _buildFooter(),
      ],
    );
  }

  Widget _divider({
    Color color = _dash,
    double marginTop = 16,
    double marginBottom = 16,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: marginTop, bottom: marginBottom),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final count = (constraints.maxWidth / 7).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(width: 4, height: 1.5, color: color),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(color: _ink, shape: BoxShape.circle),
          child: const Center(child: Text('☕', style: TextStyle(fontSize: 20))),
        ),
        const SizedBox(height: 10),
        Text(
          'B-VIBE CAFE',
          style: _mono.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: 5,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'No. 12, Main Street, Colombo, Sri Lanka  ',
          textAlign: TextAlign.center,
          style: _mono.copyWith(fontSize: 9.5, color: _muted, height: 1.7),
        ),
        const SizedBox(height: 4),
        Text(
          '+94 11 234 5678',
          textAlign: TextAlign.center,
          style: _mono.copyWith(fontSize: 9.5, color: _muted, height: 1.7),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMeta() {
    return Column(
      children: [
        _metaRow('Invoice', invoice.invoiceId),
        _metaRow(
          'Date & Time',
          '${DateFormat('MMM dd, yyyy').format(invoice.dateTime)} · '
              '${DateFormat('HH:mm').format(invoice.dateTime)}',
        ),
      ],
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _mono.copyWith(fontSize: 10.5, color: _muted)),
          Text(
            value,
            style: _mono.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsHeader() {
    final style = _mono.copyWith(
      fontSize: 9,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.5,
      color: _light,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text('ITEM', style: style)),
          SizedBox(
            width: 36,
            child: Text('QTY', textAlign: TextAlign.center, style: style),
          ),
          SizedBox(
            width: 96,
            child: Text('PRICE', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }

  Widget _buildItems() {
    return Column(
      children: invoice.items.asMap().entries.map((e) {
        final isLast = e.key == invoice.items.length - 1;
        return _buildItemRow(e.value, isLast);
      }).toList(),
    );
  }

  Widget _buildItemRow(InvoiceDisplayItem item, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: _itemDash, width: 1.5)),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: _mono.copyWith(fontSize: 12.5, color: _ink),
                ),
                if (item.hasDiscount)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: RichText(
                      text: TextSpan(
                        style: _mono.copyWith(fontSize: 9, color: _muted),
                        children: [
                          TextSpan(
                            text: '${item.discountLabel ?? 'Discount'} ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _ink.withOpacity(0.7),
                              fontFamily: _fontFamily,
                            ),
                          ),
                          TextSpan(
                            text:
                                '− LKR ${item.discountAmount.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '×${item.qty}',
              textAlign: TextAlign.center,
              style: _mono.copyWith(fontSize: 12, color: _light),
            ),
          ),
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.hasDiscount)
                  Text(
                    'LKR ${item.price}',
                    style: _mono.copyWith(
                      fontSize: 9,
                      color: const Color(0xFFBBBBBB),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  'LKR ${item.finalPrice.toStringAsFixed(2)}',
                  style: _mono.copyWith(
                    fontSize: 12.5,
                    color: _ink,
                    fontWeight: item.hasDiscount
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final double total = double.tryParse(invoice.totalAmount.toString()) ?? 0;
    final double discount = invoice.totalDiscount;

    final bool isTakeaway = invoice.orderType == 'Takeaway';
    final bool shouldExcludeServiceCharge = invoice.isRetail || isTakeaway;
    final double netTotal = shouldExcludeServiceCharge ? total : total / 1.10;
    final double serviceCharge = total - netTotal;
    final double subtotal = netTotal + discount;
    final double grandTotal = total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          _sumRow('Subtotal', 'LKR ${subtotal.toStringAsFixed(2)}'),

          if (discount > 0)
            _sumRow(
              'Discount',
              '- LKR ${discount.toStringAsFixed(2)}',
              italic: true,
            ),

          if (serviceCharge > 0)
            _sumRow(
              'Service Charge (10%)',
              'LKR ${serviceCharge.toStringAsFixed(2)}',
            ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GRAND TOTAL',
                style: _mono.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: _ink,
                ),
              ),
              Text(
                'LKR ${grandTotal.toStringAsFixed(2)}',
                style: _mono.copyWith(
                  fontSize: 15, // bigger
                  fontWeight: FontWeight.w700,
                  color: _ink, // black
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sumRow(String label, String value, {bool italic = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: _mono.copyWith(
              fontSize: 10.5,
              color: _muted,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          Text(
            value,
            style: _mono.copyWith(
              fontSize: 10.5,
              color: const Color(0xFF444444),
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayment() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: _payCol(
              'Method',
              invoice.paymentMethod,
              align: CrossAxisAlignment.start,
            ),
          ),
          Expanded(
            child: _payCol(
              'Paid',
              'LKR ${invoice.paidAmount}',
              align: CrossAxisAlignment.center,
            ),
          ),
          Expanded(
            child: _payCol(
              'Change',
              'LKR ${invoice.balanceAmount}',
              align: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _payCol(
    String label,
    String value, {
    required CrossAxisAlignment align,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label.toUpperCase(),
          style: _mono.copyWith(fontSize: 9, color: _light, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: _mono.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _ink,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'THANK YOU!',
          style: _mono.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Please visit us again soon.',
          style: _mono.copyWith(
            fontSize: 9.5,
            color: _muted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
