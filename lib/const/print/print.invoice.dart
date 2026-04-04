import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/data/model/invoice.data.model.dart';
import 'package:bvibe/provider/printer.provider.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:intl/intl.dart';

class PrintInvoice {
  static CapabilityProfile? _cachedProfile;

  static Future<bool> printReceipt({
    required ReceiptModel receipt,
    required BusinessInfoModel? businessInfo,
    required SavedPrinter? printer,
  }) async {
    if (printer == null) return false;

    try {
      _cachedProfile ??= await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, _cachedProfile!);
      List<int> bytes = [];

       final double grandTotal = double.tryParse(receipt.totalAmount) ?? 0;
      final double billDiscount = double.tryParse(receipt.totalDiscount) ?? 0;
      final double itemDiscount = receipt.items.fold(
          0.0,
          (sum, item) =>
              sum +
              (double.tryParse(item.discount) ?? 0) *
                  (int.tryParse(item.qty) ?? 1));

      final bool isTakeaway = receipt.orderType == 'Takeaway';
      final bool isRetail =
          receipt.items.isNotEmpty && receipt.items.every((i) => i.isRetail);
      final bool shouldExcludeServiceCharge = isRetail || isTakeaway;

      final double amountToTax = shouldExcludeServiceCharge
          ? grandTotal
          : grandTotal / 1.10;
      final double serviceCharge = shouldExcludeServiceCharge ? 0 : amountToTax * 0.10;
      final double netTotal = amountToTax + billDiscount;
      final double subtotal = netTotal + itemDiscount;

      // Header
      bytes += generator.text(
        businessInfo?.businessName ?? "B-Vibe Cafe",
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      final address = businessInfo?.businessAddress;
      if (address != null && address.isNotEmpty) {
        bytes += generator.text(
          address,
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      final tel = businessInfo?.businessNumber;
      if (tel != null && tel.isNotEmpty) {
        bytes += generator.text(
          tel,
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      bytes += generator.hr();

      // Meta Section
      bytes += generator.row([
        PosColumn(
            text: 'Invoice',
            width: 4,
            styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
            text: receipt.receiptId,
            width: 8,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      bytes += generator.row([
        PosColumn(
            text: 'Date & Time',
            width: 4,
            styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
            text:
                '${DateFormat('MMM dd, yyyy').format(receipt.receiptCreateDate)} . ${DateFormat('HH:mm').format(receipt.receiptCreateTime)}',
            width: 8,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      bytes += generator.hr();

      // Items Header
      bytes += generator.row([
        PosColumn(
            text: 'ITEM',
            width: 6,
            styles: const PosStyles(bold: true, height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            text: 'QTY',
            width: 2,
            styles: const PosStyles(
                bold: true, height: PosTextSize.size1, width: PosTextSize.size1, align: PosAlign.center)),
        PosColumn(
            text: 'PRICE',
            width: 4,
            styles: const PosStyles(
                bold: true, height: PosTextSize.size1, width: PosTextSize.size1, align: PosAlign.right)),
      ]);
      bytes += generator.hr(len: 32);

      // Items Section
      for (var item in receipt.items) {
        final double itemPrice = double.tryParse(item.price) ?? 0;
        final double itemDiscount = double.tryParse(item.discount) ?? 0;
        final double finalPrice = (itemPrice - itemDiscount) * (int.tryParse(item.qty) ?? 1);

        bytes += generator.row([
          PosColumn(
              text: item.itemName,
              width: 6,
              styles: const PosStyles(align: PosAlign.left)),
          PosColumn(
              text: "x${item.qty}",
              width: 2,
              styles: const PosStyles(align: PosAlign.center)),
          PosColumn(
              text: finalPrice.toStringAsFixed(2),
              width: 4,
              styles: const PosStyles(align: PosAlign.right)),
        ]);

        if (itemDiscount > 0) {
          bytes += generator.text(
              "  Discount: - LKR ${itemDiscount.toStringAsFixed(2)}",
              styles: const PosStyles(align: PosAlign.left));
        }
        bytes += generator.hr(len: 32); // itemDash substitute
      }

      // Summary Section
      bytes += generator.row([
        PosColumn(
            text: 'Subtotal',
            width: 8,
            styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
            text: 'LKR ${subtotal.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);

      if (itemDiscount > 0) {
        bytes += generator.row([
          PosColumn(
              text: 'Item Discount',
              width: 8,
              styles: const PosStyles(align: PosAlign.left)),
          PosColumn(
              text: '- LKR ${itemDiscount.toStringAsFixed(2)}',
              width: 4,
              styles: const PosStyles(align: PosAlign.right)),
        ]);
      }

      if (billDiscount > 0) {
        bytes += generator.row([
          PosColumn(
              text: 'Bill Discount',
              width: 8,
              styles: const PosStyles(align: PosAlign.left)),
          PosColumn(
              text: '- LKR ${billDiscount.toStringAsFixed(2)}',
              width: 4,
              styles: const PosStyles(align: PosAlign.right)),
        ]);
      }

      if (serviceCharge > 0) {
        bytes += generator.row([
          PosColumn(
              text: 'Service Charge (10%)',
              width: 8,
              styles: const PosStyles(align: PosAlign.left)),
          PosColumn(
              text: 'LKR ${serviceCharge.toStringAsFixed(2)}',
              width: 4,
              styles: const PosStyles(align: PosAlign.right)),
        ]);
      }

      bytes += generator.feed(1);
      bytes += generator.row([
        PosColumn(
            text: 'GRAND TOTAL',
            width: 6,
            styles: const PosStyles(
                bold: true,
                align: PosAlign.left,
                height: PosTextSize.size1,
                width: PosTextSize.size1)),
        PosColumn(
            text: 'LKR ${grandTotal.toStringAsFixed(2)}',
            width: 6,
            styles: const PosStyles(
                bold: true,
                align: PosAlign.right,
                height: PosTextSize.size2,
                width: PosTextSize.size1)),
      ]);
      bytes += generator.hr();

      // Payment Section
      bytes += generator.row([
        PosColumn(
            text: 'METHOD',
            width: 4,
            styles: const PosStyles(bold: true, align: PosAlign.left)),
        PosColumn(
            text: 'PAID',
            width: 4,
            styles: const PosStyles(bold: true, align: PosAlign.center)),
        PosColumn(
            text: 'CHANGE',
            width: 4,
            styles: const PosStyles(bold: true, align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(
            text: receipt.paymentMethod.toUpperCase(),
            width: 4,
            styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
            text: receipt.paidAmount,
            width: 4,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: receipt.balanceAmount,
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.hr();

      // Footer Section
      final tagLine = businessInfo?.tagLine;
      if (tagLine != null && tagLine.isNotEmpty) {
        bytes += generator.text(
          tagLine,
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      bytes += generator.text("THANK YOU!",
          styles: const PosStyles(
              align: PosAlign.center, bold: true, width: PosTextSize.size1));
      bytes += generator.hr();

      bytes += generator.feed(3);
      bytes += generator.cut();

      return await _sendToPrinter(printer, bytes);
    } catch (e) {
      print("Print Error: $e");
      return false;
    }
  }

  static Future<bool> printKOT({
    required ReceiptModel receipt,
    required SavedPrinter? printer,
  }) async {
    if (printer == null) return false;

    try {
      _cachedProfile ??= await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, _cachedProfile!);
      List<int> bytes = [];

      bytes += generator.text("KITCHEN ORDER TOKEN", styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
      bytes += generator.hr();
      bytes += generator.text("Order: ${receipt.receiptId}", styles: const PosStyles(bold: true));
      bytes += generator.text(
        "TYPE: ${receipt.orderType.toUpperCase()}",
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text("Time: ${DateFormat('HH:mm').format(DateTime.now())}");
      bytes += generator.hr();

      for (var item in receipt.items) {
        if (item.isRetail) continue; // Skip grocery items in KOT
        bytes += generator.row([
          PosColumn(text: item.itemName, width: 9, styles: const PosStyles(bold: true, height: PosTextSize.size2)),
          PosColumn(text: "x${item.qty}", width: 3, styles: const PosStyles(bold: true, align: PosAlign.right, height: PosTextSize.size2)),
        ]);
        if (item.description.isNotEmpty) {
          bytes += generator.text("  Note: ${item.description}");
        }
      }
      
      bytes += generator.feed(3);
      bytes += generator.cut();

      return await _sendToPrinter(printer, bytes);
    } catch (e) {
      print("KOT Print Error: $e");
      return false;
    }
  }

  static Future<bool> _sendToPrinter(SavedPrinter printer, List<int> bytes) async {
    final type = _getPrinterType(printer.type);
    
    try {
      switch (type) {
        case PrinterType.bluetooth:
          await PrinterManager.instance.connect(
            type: type,
            model: BluetoothPrinterInput(
              name: printer.name,
              address: printer.address,
              isBle: printer.isBle,
              autoConnect: false,
            ),
          );
          break;
        case PrinterType.usb:
          await PrinterManager.instance.connect(
            type: type,
            model: UsbPrinterInput(
              name: printer.name,
              productId: printer.productId,
              vendorId: printer.vendorId,
            ),
          );
          break;
        case PrinterType.network:
          await PrinterManager.instance.connect(
            type: type,
            model: TcpPrinterInput(ipAddress: printer.address),
          );
          break;
      }

      await PrinterManager.instance.send(type: type, bytes: bytes);
      return true;
    } catch (e) {
      print("Connect/Send Error: $e");
      return false;
    }
  }

  static PrinterType _getPrinterType(String typeStr) {
    if (typeStr.toLowerCase().contains('bluetooth')) return PrinterType.bluetooth;
    if (typeStr.toLowerCase().contains('usb')) return PrinterType.usb;
    return PrinterType.network;
  }
}
