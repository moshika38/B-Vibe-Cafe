import 'package:flutter/material.dart';
import 'package:bvibe/data/workspace/number.format.dart';

// ─── Data Models ───────────────────────────────────────────────

class ReceiptItem {
  final String name;
  final int qty;
  final double unitPrice;

  const ReceiptItem({
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  double get total => qty * unitPrice;
}

class ReceiptData {
  // Business Info
  final String businessName;
  final String businessAddress;
  final String businessPhone;
  final String? businessEmail;

  // Receipt Meta
  final String receiptNo;
  final DateTime dateTime;
  final String? cashierName;

  // Customer (optional)
  final String? customerName;

  // Items
  final List<ReceiptItem> items;

  // Financials
  final double discountAmount; // fixed amount discount
  final double taxRate; // e.g. 0.08 = 8%

  // Payment
  final String paymentMethod; // e.g. "CASH", "CARD"
  final double amountPaid;

  const ReceiptData({
    required this.businessName,
    required this.businessAddress,
    required this.businessPhone,
    this.businessEmail,
    required this.receiptNo,
    required this.dateTime,
    this.cashierName,
    this.customerName,
    required this.items,
    this.discountAmount = 0,
    this.taxRate = 0,
    required this.paymentMethod,
    required this.amountPaid,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get taxAmount => (subtotal - discountAmount) * taxRate;
  double get grandTotal => subtotal - discountAmount + taxAmount;
  double get change => amountPaid - grandTotal;
}

// ─── Receipt Widget ─────────────────────────────────────────────

class ThermalReceipt extends StatelessWidget {
  final ReceiptData data;

  /// paperWidth: 58mm = 220px | 80mm = 302px (at 96dpi approx)
  final double paperWidth;

  const ThermalReceipt({super.key, required this.data, this.paperWidth = 302});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: paperWidth,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 11,
            color: Colors.black,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Business Info ──
              Text(
                data.businessName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(data.businessAddress, textAlign: TextAlign.center),
              Text(data.businessPhone, textAlign: TextAlign.center),
              if (data.businessEmail != null)
                Text(data.businessEmail!, textAlign: TextAlign.center),

              _dottedDivider(),

              // ── Receipt Meta ──
              _row('Receipt No:', data.receiptNo),
              _row(
                'Date:',
                '${data.dateTime.day.toString().padLeft(2, '0')}/'
                    '${data.dateTime.month.toString().padLeft(2, '0')}/'
                    '${data.dateTime.year}',
              ),
              _row(
                'Time:',
                '${data.dateTime.hour.toString().padLeft(2, '0')}:'
                    '${data.dateTime.minute.toString().padLeft(2, '0')}',
              ),
              if (data.cashierName != null) _row('Cashier:', data.cashierName!),
              if (data.customerName != null)
                _row('Customer:', data.customerName!),

              _dottedDivider(),

              // ── Column Headers ──
              Row(
                children: [
                  Expanded(flex: 4, child: Text('Item', style: _boldStyle())),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Qty',
                      style: _boldStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Price',
                      style: _boldStyle(),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total',
                      style: _boldStyle(),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.black, thickness: 0.5, height: 8),

              // ── Items ──
              ...data.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: Text(item.name)),
                      Expanded(
                        flex: 1,
                        child: Text('${item.qty}', textAlign: TextAlign.center),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _fmt(item.unitPrice),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _fmt(item.total),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _dottedDivider(),

              // ── Totals ──
              _row('Subtotal:', _fmt(data.subtotal)),
              if (data.discountAmount > 0)
                _row('Discount:', '- ${_fmt(data.discountAmount)}'),
              if (data.taxRate > 0)
                _row(
                  'Tax (${(data.taxRate * 100).toStringAsFixed(0)}%):',
                  _fmt(data.taxAmount),
                ),

              const Divider(color: Colors.black, thickness: 1, height: 8),

              _row('TOTAL:', _fmt(data.grandTotal), bold: true, fontSize: 13),

              const SizedBox(height: 4),

              _row('Payment (${data.paymentMethod}):', _fmt(data.amountPaid)),
              if (data.change >= 0) _row('Change:', _fmt(data.change)),

              _dottedDivider(),

              // ── Footer ──
              const Text(
                'Thank You!\nPlease Come Again',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────

  Widget _dottedDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(
      '- ' * 22,
      style: const TextStyle(fontSize: 9, letterSpacing: 0),
      overflow: TextOverflow.clip,
      maxLines: 1,
    ),
  );

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    double fontSize = 11,
  }) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: fontSize,
    );
    return Row(
      children: [
        Expanded(flex: 5, child: Text(label, style: style)),
        Expanded(
          flex: 4,
          child: Text(value, style: style, textAlign: TextAlign.right),
        ),
      ],
    );
  }

  TextStyle _boldStyle() =>
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 11);

  String _fmt(double amount) => '${AppNumberFormat.formatNumber(amount)} LKR';
}

// ─── Example Usage ─────────────────────────────────────────────

void main() => runApp(const ReceiptPreviewApp());

class ReceiptPreviewApp extends StatelessWidget {
  const ReceiptPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    final receipt = ReceiptData(
      // Business Info
      businessName: 'My Shop',
      businessAddress: '123, Galle Road, Colombo 03',
      businessPhone: '011-2345678',
      businessEmail: 'myshop@email.com',

      // Meta
      receiptNo: 'INV-00123',
      dateTime: DateTime.now(),
      cashierName: 'Kamal',
      customerName: 'Nimal',

      // Items
      items: const [
        ReceiptItem(name: 'Coca Cola 1L', qty: 2, unitPrice: 280.00),
        ReceiptItem(name: 'Bread', qty: 1, unitPrice: 120.00),
        ReceiptItem(name: 'Rice 1kg', qty: 3, unitPrice: 195.00),
        ReceiptItem(name: 'Milk Powder', qty: 1, unitPrice: 850.00),
      ],

      // Financials
      discountAmount: 50.00,
      taxRate: 0.08,

      // Payment
      paymentMethod: 'CASH',
      amountPaid: 2500.00,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(title: const Text('Receipt Preview')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ThermalReceipt(
            data: receipt,
            paperWidth: 302, // 80mm — change to 220 for 58mm
          ),
        ),
      ),
    );
  }
}
