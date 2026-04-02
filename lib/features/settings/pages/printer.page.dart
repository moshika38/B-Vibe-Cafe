import 'dart:io';

import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/provider/printer.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

 
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

        _buildActivePrintersSummary(context),

        const SizedBox(height: 24),

        if (_isLoading && _printers.isEmpty)
          _buildLoadingState(theme)
        else if (!_isLoading && _printers.isEmpty)
          _buildEmptyState(theme)
        else
          Column(
            children: _printers.map((e) => _buildPrinterCard(context, theme, e)).toList(),
          ),
      ],
    );
  }

  Widget _buildActivePrintersSummary(BuildContext context) {
    final printerProvider = context.watch<PrinterProvider>();
    final primary = printerProvider.primaryPrinter;
    final secondary = printerProvider.secondaryPrinter;

    return Row(
      children: [
        Expanded(
          child: _buildRoleIndicator(
            title: "Primary (Receipt)",
            printer: primary,
            color: AppColors.primary,
            onRemove: () => printerProvider.removePrinter('primary'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRoleIndicator(
            title: "Secondary (Kitchen)",
            printer: secondary,
            color: const Color(0xFF8B5CF6),
            onRemove: () => printerProvider.removePrinter('secondary'),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleIndicator({
    required String title,
    required SavedPrinter? printer,
    required Color color,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              if (printer != null)
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Symbols.close, size: 14, color: color),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            printer?.name ?? "Not Configured",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: printer != null ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
            color: AppColors.textSecondary.withOpacity(0.4),
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
                color: AppColors.textSecondary.withOpacity(0.3),
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

  Widget _buildPrinterCard(BuildContext context, ThemeData theme, _PrinterEntry entry) {
    final printerProvider = context.watch<PrinterProvider>();
    final device = entry.device;
    final type = entry.type;
    final isBle = entry.isBle;
    final label = device.name.isNotEmpty == true ? device.name : "Unknown Printer";
    final address = device.address ?? "";

    final isPrimary = printerProvider.isSelected(address, device.name, 'primary');
    final isSecondary = printerProvider.isSelected(address, device.name, 'secondary');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: (isPrimary || isSecondary)
              ? Border.all(color: isPrimary ? AppColors.primary : const Color(0xFF8B5CF6), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.06),
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
                color: (isPrimary || isSecondary)
                    ? (isPrimary ? AppColors.primary : const Color(0xFF8B5CF6)).withOpacity(0.1)
                    : AppColors.textSecondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Symbols.print,
                size: 20,
                color: (isPrimary || isSecondary)
                    ? (isPrimary ? AppColors.primary : const Color(0xFF8B5CF6))
                    : AppColors.textSecondary,
              ),
            ),

            const SizedBox(width: 14),

            // Name + type badge + address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPrimary) _buildSmallBadge("Primary", AppColors.primary),
                      if (isSecondary) _buildSmallBadge("Secondary", const Color(0xFF8B5CF6)),
                    ],
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

            // Actions
            Row(
              children: [
                _buildActionButton(
                  icon: Symbols.receipt,
                  tooltip: "Set Primary",
                  isActive: isPrimary,
                  color: AppColors.primary,
                  onTap: () => _savePrinter(context, entry, 'primary'),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Symbols.kitchen,
                  tooltip: "Set Secondary",
                  isActive: isSecondary,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _savePrinter(context, entry, 'secondary'),
                ),
                const SizedBox(width: 8),
                VerticalDivider(width: 1, color: AppColors.divider.withOpacity(0.5)),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _testPrint(entry),
                  icon: const Icon(Symbols.print_connect, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: "Test Print",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? color : color.withOpacity(0.1)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.white : color,
        ),
      ),
    );
  }

  Future<void> _savePrinter(BuildContext context, _PrinterEntry entry, String role) async {
    final printerProvider = context.read<PrinterProvider>();
    
    await printerProvider.savePrinter(
      name: entry.device.name,
      address: entry.device.address ?? "",
      type: entry.type.name,
      isBle: entry.isBle,
      vendorId: entry.device.vendorId,
      productId: entry.device.productId,
      role: role,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${role.toUpperCase()} printer updated to ${entry.device.name}"),
          behavior: SnackBarBehavior.floating,
          width: 300,
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}