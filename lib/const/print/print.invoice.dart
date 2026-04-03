import 'package:bvibe/data/model/receipt.model.dart';
import 'package:bvibe/data/model/invoice.data.model.dart';
import 'package:bvibe/provider/printer.provider.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:intl/intl.dart';

class PrintInvoice {
  static Future<bool> printReceipt({
    required ReceiptModel receipt,
    required BusinessInfoModel? businessInfo,
    required SavedPrinter? printer,
  }) async {
    if (printer == null) return false;
    
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

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
          "Tel: $tel",
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      bytes += generator.hr();

      // Meta
      bytes += generator.text("Invoice: ${receipt.receiptId}");
      bytes += generator.text("Date: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}");
      bytes += generator.hr();

      // Items
      bytes += generator.row([
        PosColumn(text: 'ITEM', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(text: 'QTY', width: 2, styles: const PosStyles(bold: true, align: PosAlign.center)),
        PosColumn(text: 'PRICE', width: 4, styles: const PosStyles(bold: true, align: PosAlign.right)),
      ]);
      bytes += generator.hr(len: 32);

      for (var item in receipt.items) {
        bytes += generator.row([
          PosColumn(text: item.itemName, width: 6),
          PosColumn(text: "x${item.qty}", width: 2, styles: const PosStyles(align: PosAlign.center)),
          PosColumn(text: item.price, width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
        if (double.tryParse(item.discount) != null && double.parse(item.discount) > 0) {
          bytes += generator.text("  Discount: -${item.discount}");
        }
      }
      bytes += generator.hr();

      // Summary
      bytes += generator.row([
        PosColumn(text: 'TOTAL', width: 8, styles: const PosStyles(bold: true, height: PosTextSize.size2)),
        PosColumn(text: "LKR ${receipt.totalAmount}", width: 4, styles: const PosStyles(bold: true, align: PosAlign.right, height: PosTextSize.size2)),
      ]);
      bytes += generator.hr();

      // Payment
      bytes += generator.text("Method: ${receipt.paymentMethod}");
      bytes += generator.text("Paid: LKR ${receipt.paidAmount}");
      bytes += generator.text("Balance: LKR ${receipt.balanceAmount}");
      bytes += generator.hr();

      // Footer
      final tagLine = businessInfo?.tagLine;
      if (tagLine != null && tagLine.isNotEmpty) {
        bytes += generator.text(tagLine, styles: const PosStyles(align: PosAlign.center));
      }
      bytes += generator.text("THANK YOU!", styles: const PosStyles(align: PosAlign.center, bold: true));
      
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
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += generator.text("KITCHEN ORDER TOKEN", styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
      bytes += generator.hr();
      bytes += generator.text("Order: ${receipt.receiptId}", styles: const PosStyles(bold: true));
      bytes += generator.text("Type: ${receipt.orderType}");
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
