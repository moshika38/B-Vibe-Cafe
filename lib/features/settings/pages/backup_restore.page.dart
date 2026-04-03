import 'dart:io';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/helper/database.helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  bool _isProcessing = false;

  Future<void> _handleBackup() async {
    setState(() => _isProcessing = true);
    try {
      final dbPath = await DatabaseHelper.instance.getDatabasePath();
      final dbFile = File(dbPath);

      if (!dbFile.existsSync()) {
        throw Exception("Database file not found at $dbPath");
      }

      String fileName = "bvibe_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db";
      
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Select Backup Location',
        fileName: fileName,
        type: FileType.any,
      );

      if (outputFile != null) {
        // Ensure extension
        if (!outputFile.toLowerCase().endsWith('.db')) {
          outputFile += '.db';
        }

        // We can use VACUUM INTO for a consistent backup if the DB is open
        final db = await DatabaseHelper.instance.database;
        await db.execute("VACUUM INTO '$outputFile'");

        if (context.mounted) {
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Database backup created successfully!",
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: "Backup failed: ${e.toString()}",
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRestore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Restore"),
        content: const Text(
          "RESTORE will completely OVERWRITE your current data with the selected backup file. This action cannot be undone.\n\nAre you sure you want to proceed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(0, 48),
            ),
            child: const Text("Yes, Restore Data"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        dialogTitle: 'Select Backup File to Restore',
      );

      if (result != null && result.files.single.path != null) {
        final backupPath = result.files.single.path!;
        final dbPath = await DatabaseHelper.instance.getDatabasePath();

        // 1. Close current DB
        await DatabaseHelper.instance.closeDatabase();

        // 2. Delete existing DB and journals
        final dbFile = File(dbPath);
        if (dbFile.existsSync()) await dbFile.delete();
        
        final walFile = File("$dbPath-wal");
        if (walFile.existsSync()) await walFile.delete();
        
        final shmFile = File("$dbPath-shm");
        if (shmFile.existsSync()) await shmFile.delete();

        // 3. Copy backup to original path
        await File(backupPath).copy(dbPath);

        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Restore Successful"),
              content: const Text(
                "Data has been restored. The application needs to be restarted into order to load the new data.",
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // In a real app we might attempt exit(0) or similar
                    // but for safety we'll just close dialog
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: "Restore failed: ${e.toString()}",
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              const Icon(Symbols.backup, color: AppColors.primary, size: 32),
              const SizedBox(width: 16),
              Text(
                "Backup & Restore",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Manage your data safety by creating backups or restoring from a previous state.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          
          // Backup Card
          _buildActionCard(
            title: "Backup Database",
            description: "Export a complete snapshot of your current database. This includes all products, sales history, and settings.",
            icon: Symbols.upload_file,
            buttonText: "Create Backup",
            onPressed: _isProcessing ? null : _handleBackup,
            color: Colors.blue,
          ),
          
          const SizedBox(height: 24),
          
          // Restore Card
          _buildActionCard(
            title: "Restore Database",
            description: "Replace your current data with a previously saved backup file. WARNING: This will overwrite ALL current information.",
            icon: Symbols.file_download,
            buttonText: "Restore Data",
            onPressed: _isProcessing ? null : _handleRestore,
            color: Colors.orange,
          ),
          
          if (_isProcessing) ...[
            const SizedBox(height: 32),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Processing data operation... Please wait."),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required String buttonText,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
