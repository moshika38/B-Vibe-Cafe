import 'dart:convert';
import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/const/print/print.invoice.dart';
import 'package:bvibe/provider/printer.provider.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/workspace/dummy.dart';
import 'package:bvibe/features/orders/widgets/build.cate.card.dart';
import 'package:bvibe/features/orders/widgets/build.item.card.dart';
import 'package:bvibe/features/orders/widgets/current.order.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/provider/categories.provider.dart';
import 'package:bvibe/provider/item.provider.dart';
import 'package:bvibe/provider/receipt.provider.dart';
import 'package:bvibe/components/conform.window.dart';
import 'package:bvibe/data/model/item.model.dart';
import 'package:bvibe/data/model/categories.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CreateOrders extends StatefulWidget {
  final String invoiceId;
  const CreateOrders({super.key, required this.invoiceId});

  @override
  State<CreateOrders> createState() => _CreateOrdersState();
}

class _CreateOrdersState extends State<CreateOrders> {
  int activeCate = 0;
  int selectedItem = 0;
  String receiptId = "";
  bool isCartFocused = false;
  int selectedCartItemIndex = 0;

  Future? _categoriesFuture;
  int _maxCategories = 0;
  int _maxItems = 0;

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  final ScrollController _categoryScrollController = ScrollController();
  String _searchQuery = "";
  bool _shouldFocusQty = false;
  int _currentCrossAxisCount = 4;

  void _scrollToCategory() {
    if (_categoryScrollController.hasClients) {
      final target = activeCate * 140.0;
      final maxExtent = _categoryScrollController.position.maxScrollExtent;
      double offset = target - 100.0;
      if (offset < 0) offset = 0;
      if (offset > maxExtent) offset = maxExtent;
      _categoryScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _refocusSearch() {
    setState(() {
      _shouldFocusQty = false;
    });
    // Use post-frame callback so the focus happens AFTER all widget rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
        _searchController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _searchController.text.length,
        );
      }
    });
  }

  void _create() {
    final id = DummyData.dummyReceipt;
    setState(() {
      receiptId = id.receiptId;
    });
    Provider.of<ReceiptProvider>(context, listen: false).saveReceipt(id);
  }

  bool _handleGlobalKey(KeyEvent event) {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return false;

    if (event is KeyDownEvent) {
      final bool isCtrlPressed =
          HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isLogicalKeyPressed(
            LogicalKeyboardKey.controlLeft,
          ) ||
          HardwareKeyboard.instance.isLogicalKeyPressed(
            LogicalKeyboardKey.controlRight,
          );
      final bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

      if (event.logicalKey == LogicalKeyboardKey.tab) {
        setState(() {
          isCartFocused = !isCartFocused;
          if (isCartFocused) selectedCartItemIndex = 0;
        });
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.delete) {
        if (isCartFocused) {
          final provider = Provider.of<ReceiptProvider>(context, listen: false);
          provider.getReceipt(receiptId).then((receipt) {
            if (receipt != null &&
                selectedCartItemIndex < receipt.items.length) {
              final items = [...receipt.items];
              items.removeAt(selectedCartItemIndex);
              provider.updateReceiptItems(receiptId, items);
              setState(() {
                if (items.isEmpty) {
                  selectedCartItemIndex = 0;
                } else {
                  selectedCartItemIndex = selectedCartItemIndex.clamp(
                    0,
                    items.length - 1,
                  );
                }
              });
            }
          });
        } else {
          showPinDialog(context).then((confirmed) {
            if (confirmed && mounted) {
              Provider.of<ReceiptProvider>(
                context,
                listen: false,
              ).deleteReceipt(receiptId);
              context.pop();
            }
          });
        }
        return true;
      }

      if (isCtrlPressed && isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyA) {
        setState(() {
          activeCate = 0;
          selectedItem = -1;
          _refocusSearch();
        });
        _scrollToCategory();
        return true;
      }

      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
        _refocusSearch();
        return true;
      }

      if (isCtrlPressed &&
          (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
        final provider = Provider.of<ReceiptProvider>(context, listen: false);
        final printerProvider = Provider.of<PrinterProvider>(
          context,
          listen: false,
        );

        provider.getReceipt(receiptId).then((receipt) async {
          if (receipt != null) {
            // Filter to get only kitchen items (non-retail)
            final kitchenItems = receipt.items
                .where((item) => !item.isRetail)
                .toList();
            if (kitchenItems.isNotEmpty) {
              final currentKitchenJson = jsonEncode(
                kitchenItems.map((e) => e.toMap()).toList(),
              );
              final lastKitchenJson = jsonEncode(
                receipt.lastKotItems.map((e) => e.toMap()).toList(),
              );

              if (currentKitchenJson != lastKitchenJson) {
                final success = await PrintInvoice.printKOT(
                  receipt: receipt,
                  printer: printerProvider.secondaryPrinter,
                );
                if (success) {
                  await provider.updateLastKotItems(
                    receipt.receiptId,
                    kitchenItems,
                  );
                }
              }
            }
            if (mounted) {
              context.push('/orders/checkout', extra: receiptId);
            }
          }
        });
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (isCartFocused) {
          return true; // Consume but do nothing in cart for now
        }
        if (isShiftPressed) {
          Provider.of<ReceiptProvider>(
            context,
            listen: false,
          ).updateOrderType(receiptId, 'Takeaway');
        } else if (isCtrlPressed) {
          final max = _maxCategories > 0 ? _maxCategories - 1 : 0;
          setState(() => activeCate = (activeCate + 1).clamp(0, max));
          _scrollToCategory();
        } else {
          final max = _maxItems > 0 ? _maxItems - 1 : 0;
          setState(() {
            _shouldFocusQty = true;
            selectedItem = (selectedItem + 1).clamp(0, max);
          });
        }
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (isCartFocused) return true;
        if (isShiftPressed) {
          Provider.of<ReceiptProvider>(
            context,
            listen: false,
          ).updateOrderType(receiptId, 'Dine-In');
        } else if (isCtrlPressed) {
          final max = _maxCategories > 0 ? _maxCategories - 1 : 0;
          setState(() => activeCate = (activeCate - 1).clamp(0, max));
          _scrollToCategory();
        } else {
          final max = _maxItems > 0 ? _maxItems - 1 : 0;
          setState(() {
            _shouldFocusQty = true;
            final current = selectedItem < 0 ? 0 : selectedItem;
            selectedItem = (current - 1).clamp(0, max);
          });
        }
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (isCartFocused) {
          final provider = Provider.of<ReceiptProvider>(context, listen: false);
          provider.getReceipt(receiptId).then((receipt) {
            if (receipt != null && receipt.items.isNotEmpty) {
              setState(() {
                selectedCartItemIndex = (selectedCartItemIndex + 1).clamp(
                  0,
                  receipt.items.length - 1,
                );
              });
            }
          });
        } else {
          final max = _maxItems > 0 ? _maxItems - 1 : 0;
          setState(() {
            _shouldFocusQty = true;
            selectedItem = (selectedItem + _currentCrossAxisCount).clamp(
              0,
              max,
            );
          });
        }
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (isCartFocused) {
          setState(() {
            selectedCartItemIndex = (selectedCartItemIndex - 1).clamp(
              0,
              selectedCartItemIndex,
            );
          });
        } else {
          setState(() {
            _shouldFocusQty = true;
            final current = selectedItem < 0 ? 0 : selectedItem;
            selectedItem = (current - _currentCrossAxisCount).clamp(0, current);
          });
        }
        return true;
      }
    }
    return false;
  }

  KeyEventResult _handleSearchKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_searchController.text.isEmpty) {
          context.pop();
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    widget.invoiceId.isEmpty ? _create() : receiptId = widget.invoiceId;
    _searchFocusNode = FocusNode(onKeyEvent: _handleSearchKeyEvent);
    HardwareKeyboard.instance.addHandler(_handleGlobalKey);
    // Fetch all items once for global search and "All" category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().fetchItems();
      _refocusSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    HardwareKeyboard.instance.removeHandler(_handleGlobalKey);
    _focusNode.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    /// responsive breakpoints
    final bool isTablet = width < 1100;
    final bool isMobile = width < 750;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isMobile
              ? Column(
                  children: [
                    Expanded(child: _menuSection()),
                    const SizedBox(height: 20),
                    SizedBox(height: 350, child: _cartSection()),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: isTablet ? 6 : 7, child: _menuSection()),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: _cartSection()),
                  ],
                ),
        ),
      ),
    );
  }

  /// LEFT SIDE (Menu)
  Widget _menuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NavigationTitle(
          title: "Orders",
          subtitle: "Create Orders",
          isBackIcon: true,
        ),

        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (val) {
            setState(() {
              _searchQuery = val.toLowerCase();
              selectedItem = -1; // No selection when searching
              _shouldFocusQty = false;
            });
          },
          decoration: InputDecoration(
            hintText: '( Ctrl+S ) Search...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.textHint),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: Consumer<CategoriesProvider>(
            builder: (context, provider, child) {
              _categoriesFuture ??= provider.readAllCategories();
              return FutureBuilder(
                future: _categoriesFuture,
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (asyncSnapshot.hasData) {
                    final rawCategories =
                        asyncSnapshot.data! as List<CategoriesModel>;
                    // Add virtual "All" category
                    final categories = [
                      CategoriesModel(
                        id: 'all',
                        itemName: 'All Items',
                        iconNumber: Icons.grid_view.codePoint,
                      ),
                      ...rawCategories,
                    ];
                    _maxCategories = categories.length;

                    if (categories.isEmpty) {
                      return const Center(child: EmptyItem());
                    }

                    if (activeCate >= categories.length) {
                      Future.microtask(() {
                        if (mounted) setState(() => activeCate = 0);
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: _categoryScrollController,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              return BuildCateCard(
                                isActive: index == activeCate,
                                title: categories[index].itemName,
                                icon: categories[index].iconNumber,
                                onTap: () {
                                  setState(() {
                                    activeCate = index;
                                    selectedItem = 0;
                                    _searchFocusNode.requestFocus();
                                  });
                                  _scrollToCategory();
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 4;

                              if (constraints.maxWidth < 800) {
                                crossAxisCount = 3;
                              }
                              if (constraints.maxWidth < 600) {
                                crossAxisCount = 2;
                              }

                              if (_currentCrossAxisCount != crossAxisCount) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    setState(
                                      () => _currentCrossAxisCount =
                                          crossAxisCount,
                                    );
                                  }
                                });
                              }

                              return Consumer<ItemProvider>(
                                builder: (context, itemProv, child) {
                                  // 1. Determine the flat list of filtered items for keyboard navigation and global filtering
                                  List<ItemModel> filteredItems = [];

                                  if (_searchQuery.isNotEmpty) {
                                    // Global Search - show items from all categories if in "All Items", 
                                    // otherwise filter within the specific category.
                                    filteredItems = itemProv.items.where((item) {
                                      final isMatch = item.itemName.toLowerCase().contains(_searchQuery) ||
                                          item.description.toLowerCase().contains(_searchQuery);
                                      
                                      final isCategoryMatch = activeCate == 0 || 
                                          item.categoryId == categories[activeCate].id;
                                          
                                      return isMatch && isCategoryMatch;
                                    }).toList();
                                  } else {
                                    if (activeCate == 0) {
                                      filteredItems = itemProv.items;
                                    } else {
                                      final selectedCatId = categories[activeCate].id;
                                      filteredItems = itemProv.items
                                          .where((item) => item.categoryId == selectedCatId)
                                          .toList();
                                    }
                                  }

                                  _maxItems = filteredItems.length;

                                  if (filteredItems.isEmpty) {
                                    return const EmptyItem();
                                  }

                                  // 2. Group items by category for the UI layout
                                  final Map<String, List<ItemModel>> groupedItems = {};
                                  for (var item in filteredItems) {
                                    groupedItems.putIfAbsent(item.categoryId, () => []).add(item);
                                  }

                                  // Sort the category IDs based on their order in the 'categories' list
                                  final sortedCategoryIds = categories
                                      .where((c) => groupedItems.containsKey(c.id))
                                      .map((c) => c.id!)
                                      .toList();

                                  // Handle items whose category might not be in the tabs (edge case)
                                  for (var catId in groupedItems.keys) {
                                    if (!sortedCategoryIds.contains(catId)) {
                                      sortedCategoryIds.add(catId);
                                    }
                                  }

                                  return CustomScrollView(
                                    slivers: [
                                      for (var catId in sortedCategoryIds) ...[
                                        // Category Header
                                        if (activeCate == 0 || _searchQuery.isNotEmpty)
                                          SliverToBoxAdapter(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 15),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 4,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    categories.firstWhere(
                                                      (c) => c.id == catId,
                                                      orElse: () => CategoriesModel(itemName: 'Other', iconNumber: 0),
                                                    ).itemName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '(${groupedItems[catId]!.length})',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors.textHint,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                        // Item Grid for this category
                                        SliverGrid(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            mainAxisExtent: 220,
                                          ),
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              final item = groupedItems[catId]![index];
                                              final globalIndex = filteredItems.indexOf(item);

                                              return BuildItemCard(
                                                isRetail: item.isRetail,
                                                itemId: item.id.toString(),
                                                cate: item.categoryId,
                                                des: item.description,
                                                receiptId: receiptId,
                                                image: item.imagePath,
                                                price: item.price.toString(),
                                                title: item.itemName,
                                                isSelect: selectedItem >= 0 && selectedItem == globalIndex,
                                                shouldFocus: _shouldFocusQty &&
                                                    selectedItem >= 0 &&
                                                    (selectedItem == globalIndex),
                                                onAdded: () => _refocusSearch(),
                                                onTap: () {
                                                  setState(() {
                                                    selectedItem = globalIndex;
                                                    _shouldFocusQty = true;
                                                    _refocusSearch();
                                                  });
                                                },
                                              );
                                            },
                                            childCount: groupedItems[catId]!.length,
                                          ),
                                        ),
                                      ],
                                      const SliverToBoxAdapter(child: SizedBox(height: 50)),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: Text('Loading Categories...'));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// RIGHT SIDE (Cart)
  Widget _cartSection() {
    return CurrentOrder(
      receiptId: receiptId,
      isFocused: isCartFocused,
      selectedIndex: selectedCartItemIndex,
    );
  }
}
