import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/workspace/number.format.dart';
import 'package:bvibe/features/expenses/widgets/add_expense_entry_dialog.dart';
import 'package:bvibe/features/expenses/widgets/delete_confirmation_dialog.dart';
import 'package:bvibe/features/expenses/widgets/expense_item_dialog.dart';
import 'package:bvibe/features/expenses/widgets/expense_summary_card.dart';
import 'package:bvibe/provider/expense.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  int _selectedLogIndex = -1;
  int _selectedItemIndex = -1;
  final FocusNode _pageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _selectedLogIndex = -1;
          _selectedItemIndex = -1;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
      _pageFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageFocusNode.dispose();
    super.dispose();
  }

  void _refreshData() {
    _fetchExpenses();
    context.read<ExpenseProvider>().fetchExpenseItems();
  }

  void _fetchExpenses() {
    final end = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
    );
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    context.read<ExpenseProvider>().fetchExpensesByDateRange(start, end);
  }

  void _showAddItemDialog() {
    showDialog(context: context, builder: (child) => const ExpenseItemDialog());
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (child) => const AddExpenseEntryDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _pageFocusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final bool isCtrl = HardwareKeyboard.instance.isControlPressed;

          // Ctrl+Left/Right: Switch Tabs
          if (isCtrl) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              if (_tabController.index > 0) {
                _tabController.animateTo(_tabController.index - 1);
              }
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              if (_tabController.index < _tabController.length - 1) {
                _tabController.animateTo(_tabController.index + 1);
              }
              return KeyEventResult.handled;
            }
          }

          // Ctrl+T: New Template
          if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyT) {
            _showAddItemDialog();
            return KeyEventResult.handled;
          }

          // Ctrl+R: Record Expense
          if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyR) {
            _showAddEntryDialog();
            return KeyEventResult.handled;
          }

          // Del: Delete Selected
          if (event.logicalKey == LogicalKeyboardKey.delete) {
            if (_tabController.index == 0 && _selectedLogIndex != -1) {
              final provider = context.read<ExpenseProvider>();
              if (_selectedLogIndex < provider.expenses.length) {
                _confirmDelete(provider.expenses[_selectedLogIndex].id);
              }
              return KeyEventResult.handled;
            } else if (_tabController.index == 1 && _selectedItemIndex != -1) {
              final provider = context.read<ExpenseProvider>();
              if (_selectedItemIndex < provider.expenseItems.length) {
                _confirmDeleteItem(
                  provider.expenseItems[_selectedItemIndex].id,
                );
              }
              return KeyEventResult.handled;
            }
          }

          // Navigation
          final provider = context.read<ExpenseProvider>();
          
          if (_tabController.index == 0) {
            // Logs View (List)
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(() {
                _selectedLogIndex = (_selectedLogIndex + 1).clamp(0, provider.expenses.length - 1);
              });
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              setState(() {
                _selectedLogIndex = (_selectedLogIndex - 1).clamp(0, provider.expenses.length - 1);
              });
              return KeyEventResult.handled;
            }
          } else {
            // Templates View (3-column Grid)
            const int columns = 3;
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(() {
                if (_selectedItemIndex == -1) {
                  _selectedItemIndex = 0;
                } else {
                  _selectedItemIndex = (_selectedItemIndex + columns).clamp(0, provider.expenseItems.length - 1);
                }
              });
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              setState(() {
                if (_selectedItemIndex != -1) {
                  _selectedItemIndex = (_selectedItemIndex - columns).clamp(0, provider.expenseItems.length - 1);
                }
              });
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              setState(() {
                if (_selectedItemIndex == -1) {
                  _selectedItemIndex = 0;
                } else {
                  _selectedItemIndex = (_selectedItemIndex + 1).clamp(0, provider.expenseItems.length - 1);
                }
              });
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              setState(() {
                if (_selectedItemIndex != -1) {
                  _selectedItemIndex = (_selectedItemIndex - 1).clamp(0, provider.expenseItems.length - 1);
                }
              });
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NavigationTitle(
                title: 'Business Expenses',
                subtitle:
                    'Track operational costs and itemize spending (Ctrl+R)',
                isBtn: true,
                btnText: 'Add Record ( Ctrl+R )',
                onTap: _showAddEntryDialog,
              ),
              const SizedBox(height: 24),
              _buildHeaderSummary(),
              const SizedBox(height: 24),
              _buildHeaderActions(),
              const SizedBox(height: 12),
              _buildTabBar(),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildHistoryTab(), _buildItemsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        const Spacer(),
        TextButton.icon(
          onPressed: _showAddItemDialog,
          icon: const Icon(Symbols.add_circle, size: 18),
          label: const Text('Add Template (Ctrl+T)'),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Expense Logs (Ctrl+Left Arrow)'),
          Tab(text: 'Itemized Totals (Ctrl+Right Arrow)'),
        ],
      ),
    );
  }

  Widget _buildHeaderSummary() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final total = provider.expenses.fold<double>(
          0,
          (sum, e) => sum + (double.tryParse(e.amount) ?? 0),
        );

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Period Spending',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'LKR ${AppNumberFormat.formatNumber(total)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFiltersInline(),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            _buildQuickStatCard(
              'Template Items',
              provider.expenseItems.length.toString(),
              Symbols.inventory_2,
              onTap: () => _tabController.animateTo(1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStatCard(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersInline() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterBtn('Today', _setToday),
          const SizedBox(width: 8),
          _filterBtn('Yesterday', _setYesterday),
          const SizedBox(width: 8),
          _filterBtn('7 Days', _setLast7Days),
          const SizedBox(width: 8),
          _filterBtn('This Month', _setThisMonth),
          const SizedBox(width: 12),
          const VerticalDivider(
            color: Colors.white24,
            width: 1,
            indent: 5,
            endIndent: 5,
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _selectDateRange,
            child: Row(
              children: [
                const Icon(
                  Symbols.calendar_month,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _selectSingleDate,
            icon: const Icon(Symbols.event, color: Colors.white, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Select Single Date',
          ),
        ],
      ),
    );
  }

  Widget _filterBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.expenses.isEmpty) {
          return _buildEmptyState('No entries found for this period');
        }

        return ListView.builder(
          itemCount: provider.expenses.length,
          itemBuilder: (context, index) {
            final entry = provider.expenses[index];
            final item = entry.itemId == null
                ? null
                : provider.expenseItems
                      .where((i) => i.id == entry.itemId)
                      .firstOrNull;

            return GestureDetector(
              onTap: () => setState(() => _selectedLogIndex = index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedLogIndex == index
                        ? AppColors.primary
                        : AppColors.divider,
                    width: _selectedLogIndex == index ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Symbols.payments,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        item?.name ?? 'Miscellaneous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (item != null && entry.qty != '0') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${entry.qty} ${item.unit}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        entry.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(DateTime.parse(entry.date)),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LKR ${AppNumberFormat.formatNumber(double.tryParse(entry.amount) ?? 0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Symbols.delete,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () => _confirmDelete(entry.id),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemsTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final totals = provider.getTotalsByItem();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expense Item Templates',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Template'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.8,
                ),
                itemCount: provider.expenseItems.length,
                itemBuilder: (context, index) {
                  final item = provider.expenseItems[index];
                  final isSelected = _selectedItemIndex == index;
                  return InkWell(
                    onTap: () => setState(() => _selectedItemIndex = index),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ExpenseSummaryCard(
                              title: item.name,
                              total: totals[item.name] ?? 0,
                              unit: item.unit,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Symbols.delete,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onPressed: () => _confirmDeleteItem(item.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.receipt_long, size: 64, color: AppColors.divider),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteConfirmationDialog(
        title: 'Delete Expense Log',
        message:
            'Are you sure you want to delete this expense entry? This action cannot be undone.',
        confirmText: 'Delete Log',
        onConfirm: () {
          context.read<ExpenseProvider>().deleteExpense(id);
        },
      ),
    );
  }

  void _confirmDeleteItem(String id) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteConfirmationDialog(
        title: 'Delete Template',
        message:
            'Are you sure you want to delete this expense category template? Existing logs will be marked as "Miscellaneous".',
        confirmText: 'Delete Template',
        onConfirm: () {
          context.read<ExpenseProvider>().deleteExpenseItem(id);
        },
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchExpenses();
    }
  }

  void _selectSingleDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day);
        _endDate = DateTime(picked.year, picked.month, picked.day);
      });
      _fetchExpenses();
    }
  }

  void _setThisMonth() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = now;
    });
    _fetchExpenses();
  }

  void _setToday() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = now;
    });
    _fetchExpenses();
  }

  void _setYesterday() {
    final yest = DateTime.now().subtract(const Duration(days: 1));
    setState(() {
      _startDate = DateTime(yest.year, yest.month, yest.day);
      _endDate = DateTime(yest.year, yest.month, yest.day);
    });
    _fetchExpenses();
  }

  void _setLast7Days() {
    final now = DateTime.now();
    setState(() {
      _startDate = now.subtract(const Duration(days: 7));
      _endDate = now;
    });
    _fetchExpenses();
  }
}
