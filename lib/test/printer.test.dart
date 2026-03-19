import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';

class PrinterInfo {
  final PrinterDevice device;
  final PrinterType typePrinter;
  final bool? isBle;

  PrinterInfo({
    required this.device,
    required this.typePrinter,
    this.isBle = false,
  });

  String? get name => device.name;
  String? get vendorId => device.vendorId;
  String? get productId => device.productId;
  String? get address => device.address;
}

class PrinterTest extends StatefulWidget {
  const PrinterTest({super.key});

  @override
  State<PrinterTest> createState() => _PrinterTestState();
}

class _PrinterTestState extends State<PrinterTest> {
  var printerManager = PrinterManager.instance;
  List<PrinterInfo> devices = [];
  PrinterInfo? selectedPrinter;
  bool isDiscovering = false;

  @override
  void initState() {
    super.initState();
    scanPrinters();
  }

  void scanPrinters() {
    setState(() {
      devices.clear();
      isDiscovering = true;
    });

    printerManager.discovery(type: PrinterType.usb).listen((device) {
      bool exists = false;
      if (Platform.isWindows) {
        exists = devices.any((d) => d.name != null && d.name == device.name);
      } else {
        exists = devices.any((d) => d.vendorId != null && d.vendorId == device.vendorId && d.productId == device.productId);
      }
      if (!exists) {
        setState(() => devices.add(PrinterInfo(device: device, typePrinter: PrinterType.usb)));
      }
    });

    printerManager.discovery(type: PrinterType.network).listen((device) {
      if (!devices.any((d) => d.address == device.address)) {
        setState(() => devices.add(PrinterInfo(device: device, typePrinter: PrinterType.network)));
      }
    });

    try {
      if (Platform.isAndroid || Platform.isIOS || Platform.isWindows) {
        printerManager.discovery(type: PrinterType.bluetooth).listen((device) {
          if (!devices.any((d) => d.address == device.address)) {
            setState(() => devices.add(PrinterInfo(device: device, typePrinter: PrinterType.bluetooth, isBle: false)));
          }
        });
      }
    } catch (e) {
      // Bluetooth not supported on this platform
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => isDiscovering = false);
    });
  }

  Future<void> printReceipt() async {
    if (selectedPrinter == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a printer')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Printing...')));

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += generator.text('My Shop', styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
      bytes += generator.text('123 Main Street, Colombo', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('+94 11 234 5678', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.emptyLines(1);
      bytes += generator.hr(ch: '-');
      
      final dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
      final timeStr = DateFormat('hh:mm a').format(DateTime.now());
      
      bytes += generator.row([
        PosColumn(text: dateStr, width: 6),
        PosColumn(text: timeStr, width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.hr(ch: '-');
      
      bytes += generator.row([
        PosColumn(text: 'Item 1', width: 6),
        PosColumn(text: 'x2', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: 'Rs. 200.00', width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Item 2', width: 6),
        PosColumn(text: 'x1', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: 'Rs. 150.00', width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Item 3', width: 6),
        PosColumn(text: 'x3', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: 'Rs. 450.00', width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.hr(ch: '-');
      
      bytes += generator.row([
        PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(text: 'Rs. 800.00', width: 6, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      bytes += generator.hr(ch: '-');
      bytes += generator.emptyLines(1);
      bytes += generator.text('Thank you for your purchase!', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(2);
      bytes += generator.cut();

      final success = await printerManager.connect(
        type: selectedPrinter!.typePrinter,
        model: selectedPrinter!.typePrinter == PrinterType.usb 
            ? UsbPrinterInput(name: selectedPrinter!.name, productId: selectedPrinter!.productId, vendorId: selectedPrinter!.vendorId)
            : selectedPrinter!.typePrinter == PrinterType.network
                ? TcpPrinterInput(ipAddress: selectedPrinter!.address!)
                : BluetoothPrinterInput(name: selectedPrinter!.name, address: selectedPrinter!.address!, isBle: selectedPrinter!.isBle ?? false),
      );

      if (success) {
        printerManager.send(type: selectedPrinter!.typePrinter, bytes: bytes);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to connect to printer')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Printer Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: scanPrinters,
            tooltip: 'Rescan Printers',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Available printers section
              Container(
                width: 400,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                     BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Available Printers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (isDiscovering) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (devices.isEmpty && !isDiscovering) const Text('No printers found.'),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final p = devices[index];
                        IconData typeIcon = Icons.print;
                        if (p.typePrinter == PrinterType.usb) typeIcon = Icons.usb;
                        if (p.typePrinter == PrinterType.network) typeIcon = Icons.wifi;
                        if (p.typePrinter == PrinterType.bluetooth) typeIcon = Icons.bluetooth;

                        return RadioListTile<PrinterInfo>(
                          title: Text(p.name ?? p.address ?? 'Unknown Printer'),
                          subtitle: Text(p.address ?? '${p.vendorId} - ${p.productId}'),
                          secondary: Icon(typeIcon),
                          value: p,
                          groupValue: selectedPrinter,
                          onChanged: (val) {
                            setState(() {
                              selectedPrinter = val;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Mock Receipt Section
              Container(
                width: 350,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.orange[50],
                      child: const Icon(Icons.storefront_outlined, color: Colors.deepOrange, size: 30),
                    ),
                    const SizedBox(height: 16),
                    const Text('My Shop', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    const Text('123 Main Street, Colombo', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const Text('+94 11 234 5678', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 16),
                    const Text('------------------------------------------------', style: TextStyle(color: Colors.black26), maxLines: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 14, color: Colors.black54)),
                        Text(DateFormat('hh:mm a').format(DateTime.now()), style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('------------------------------------------------', style: TextStyle(color: Colors.black26), maxLines: 1),
                    const SizedBox(height: 16),
                    _buildItemRow('Item 1', 'x2', '200.00'),
                    const SizedBox(height: 8),
                    _buildItemRow('Item 2', 'x1', '150.00'),
                    const SizedBox(height: 8),
                    _buildItemRow('Item 3', 'x3', '450.00'),
                    const SizedBox(height: 16),
                    const Text('------------------------------------------------', style: TextStyle(color: Colors.black26), maxLines: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text('Rs. 800.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('------------------------------------------------', style: TextStyle(color: Colors.black26), maxLines: 1),
                    const SizedBox(height: 16),
                    const Text('Thank you for your purchase!', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 350,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: printReceipt,
                  icon: const Icon(Icons.print),
                  label: const Text('Print Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(String name, String qty, String price) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(name, style: const TextStyle(fontSize: 14, color: Colors.black87), textAlign: TextAlign.left)),
        Expanded(flex: 1, child: Text(qty, style: const TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center)),
        Expanded(flex: 2, child: Text('Rs. $price', style: const TextStyle(fontSize: 14, color: Colors.black87), textAlign: TextAlign.right)),
      ],
    );
  }
}