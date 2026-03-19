import 'dart:io';

import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:material_symbols_icons/symbols.dart';

// Track device + its type + whether it was discovered via BLE scan
typedef _PrinterEntry = ({
  PrinterDevice device,
  PrinterType type,
  bool isBle,
});

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  final List<_PrinterEntry> _printers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scanAll();
  }

  Future<void> _scanAll() async {
    setState(() {
      _printers.clear();
      _isLoading = true;
    });

    // Each scan pass: (type, isBle)
    final passes = [
      (PrinterType.bluetooth, false), // Classic BT
      (PrinterType.bluetooth, true),  // BLE
      if (Platform.isAndroid || Platform.isWindows)
        (PrinterType.usb, false),     // USB
      (PrinterType.network, false),   // Network/WiFi
    ];

    for (final (type, isBle) in passes) {
      try {
        await PrinterManager.instance
            .discovery(type: type, isBle: isBle)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: (sink) => sink.close(),
            )
            .forEach((device) {
          if (!mounted) return;
          final exists = _printers.any(
            (e) =>
                e.device.address == device.address &&
                e.device.name == device.name,
          );
          if (!exists) {
            setState(
              () => _printers.add((device: device, type: type, isBle: isBle)),
            );
          }
        });
      } catch (_) {}
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _testPrint(_PrinterEntry entry) async {
    try {
      final device = entry.device;
      final type = entry.type;

      switch (type) {
        case PrinterType.bluetooth:
          await PrinterManager.instance.connect(
            type: type,
            model: BluetoothPrinterInput(
              name: device.name,
              address: device.address!,
              isBle: entry.isBle,       // ← use the scanned flag, not device field
              autoConnect: false,
            ),
          );
        case PrinterType.usb:
          await PrinterManager.instance.connect(
            type: type,
            model: UsbPrinterInput(
              name: device.name,
              productId: device.productId,
              vendorId: device.vendorId,
            ),
          );
        case PrinterType.network:
          await PrinterManager.instance.connect(
            type: type,
            model: TcpPrinterInput(ipAddress: device.address!),
          );
      }

      await PrinterManager.instance.send(type: type, bytes: []);
    } catch (_) {}
  }

  static IconData _typeIcon(PrinterType type, bool isBle) {
    if (type == PrinterType.bluetooth) return Symbols.bluetooth;
    if (type == PrinterType.usb) return Symbols.usb;
    return Symbols.wifi;
  }

  static String _typeLabel(PrinterType type, bool isBle) {
    if (type == PrinterType.bluetooth) return isBle ? "BLE" : "Bluetooth";
    if (type == PrinterType.usb) return "USB";
    return "Network";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Printer & Hardware",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Configure receipt and kitchen printers.",
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: _scanAll,
                    icon: Icon(
                      Symbols.refresh,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: "Scan again",
                  ),
          ],
        ),

        const SizedBox(height: 24),

        if (_isLoading && _printers.isEmpty)
          _buildLoadingState(theme)
        else if (!_isLoading && _printers.isEmpty)
          _buildEmptyState(theme)
        else
          Column(
            children: _printers.map((e) => _buildPrinterCard(theme, e)).toList(),
          ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Scanning for printers...",
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Symbols.print_disabled,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            "No printers found",
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Make sure your printer is on and connected\nvia Bluetooth, USB, or Network.",
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _scanAll,
            icon: const Icon(Symbols.refresh, size: 16),
            label: const Text("Scan Again"),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrinterCard(ThemeData theme, _PrinterEntry entry) {
    final device = entry.device;
    final type = entry.type;
    final isBle = entry.isBle;
    final label =
        device.name.isNotEmpty == true ? device.name : "Unknown Printer";
    final address = device.address ?? "";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Printer Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Symbols.print,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(width: 14),

            // Name + type badge + address
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _typeIcon(type, isBle),
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          address.isNotEmpty
                              ? "${_typeLabel(type, isBle)} • $address"
                              : _typeLabel(type, isBle),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Test Print
            OutlinedButton(
              onPressed: () => _testPrint(entry),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                side: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Test Print",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}