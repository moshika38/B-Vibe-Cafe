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

  List<CategoriesModel> _cachedCategories = [];
  Future? _categoriesFuture;
  int _maxCategories = 0;

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

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final bool isCtrlPressed =
          HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isLogicalKeyPressed(
            LogicalKeyboardKey.controlLeft,
          ) ||
          HardwareKeyboard.instance.isLogicalKeyPressed(
            LogicalKeyboardKey.controlRight,
          );
      final bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

      // SHIFT + LETTER Shortcut for Categories
      if (isShiftPressed &&
          !isCtrlPressed &&
          event.logicalKey.keyLabel.length == 1 &&
          RegExp(r'[A-Za-z]').hasMatch(event.logicalKey.keyLabel)) {
        _selectNextCategoryByLetter(event.logicalKey.keyLabel.toUpperCase());
        return true;
      }

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

      if (isCtrlPressed &&
          isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.keyA) {
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
          return true;
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
          _moveSelection(1, 0);
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
          _moveSelection(-1, 0);
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
          _moveSelection(0, 1);
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
          _moveSelection(0, -1);
        }
        return true;
      }
    }
    return false;
  }

  (List<List<int>>, List<ItemModel>) _getCurrentNavigationGrid() {
    final itemProv = context.read<ItemProvider>();
    final categories = _cachedCategories;

    if (categories.isEmpty) return ([], []);

    List<ItemModel> filteredItems = [];
    if (_searchQuery.isNotEmpty) {
      filteredItems = itemProv.items.where((item) {
        return item.itemName.toLowerCase().contains(_searchQuery) ||
            item.description.toLowerCase().contains(_searchQuery);
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

    if (filteredItems.isEmpty) return ([], []);

    final Map<String, List<ItemModel>> groupedItems = {};
    for (var item in filteredItems) {
      groupedItems.putIfAbsent(item.categoryId, () => []).add(item);
    }

    final sortedCategoryIds = categories
        .where((c) => groupedItems.containsKey(c.id))
        .map((c) => c.id!)
        .toList();

    for (var catId in groupedItems.keys) {
      if (!sortedCategoryIds.contains(catId)) sortedCategoryIds.add(catId);
    }

    final List<List<int>> grid = [];
    for (var catId in sortedCategoryIds) {
      final itemsInCat = groupedItems[catId]!;
      for (int i = 0; i < itemsInCat.length; i += _currentCrossAxisCount) {
        final List<int> row = [];
        for (int j = 0; j < _currentCrossAxisCount; j++) {
          if (i + j < itemsInCat.length) {
            row.add(filteredItems.indexOf(itemsInCat[i + j]));
          } else {
            row.add(-1);
          }
        }
        grid.add(row);
      }
    }

    return (grid, filteredItems);
  }

  void _moveSelection(int colOffset, int rowOffset) {
    final (grid, items) = _getCurrentNavigationGrid();
    if (grid.isEmpty || items.isEmpty) return;

    if (selectedItem < 0) {
      // Grid scan කරලා visually top-most (first non-empty) item find කරනවා
      int firstItem = -1;
      outer:
      for (final row in grid) {
        for (final idx in row) {
          if (idx >= 0) {
            firstItem = idx;
            break outer;
          }
        }
      }
      if (firstItem >= 0) {
        setState(() {
          selectedItem = firstItem;
          _shouldFocusQty = true;
        });
      }
      return;
    }

    int currentRow = -1;
    int currentCol = -1;

    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if (grid[r][c] == selectedItem) {
          currentRow = r;
          currentCol = c;
          break;
        }
      }
      if (currentRow != -1) break;
    }

    if (currentRow == -1) {
      setState(() {
        selectedItem = 0;
        _shouldFocusQty = true;
      });
      return;
    }

    int nextRow = currentRow + rowOffset;
    int nextCol = currentCol + colOffset;

    if (colOffset != 0) {
      if (nextCol >= _currentCrossAxisCount) {
        nextRow++;
        nextCol = 0;
      } else if (nextCol < 0) {
        nextRow--;
        nextCol = _currentCrossAxisCount - 1;
      }
    }

    if (nextRow >= 0 && nextRow < grid.length) {
      int targetCol = nextCol.clamp(0, _currentCrossAxisCount - 1);
      int targetIndex = grid[nextRow][targetCol];

      if (colOffset > 0 && targetIndex == -1) {
        if (nextRow + 1 < grid.length) {
          nextRow++;
          targetCol = 0;
          targetIndex = grid[nextRow][targetCol];
        }
      }

      while (targetIndex == -1 && targetCol > 0) {
        targetCol--;
        targetIndex = grid[nextRow][targetCol];
      }

      if (targetIndex != -1) {
        setState(() {
          selectedItem = targetIndex;
          _shouldFocusQty = true;
        });
      }
    }
  }

  void _selectNextCategoryByLetter(String letter) {
    if (_cachedCategories.isEmpty) return;

    final matches = <int>[];
    for (int i = 0; i < _cachedCategories.length; i++) {
      if (_cachedCategories[i].itemName.toUpperCase().startsWith(letter)) {
        matches.add(i);
      }
    }

    if (matches.isEmpty) return;

    int target = matches.first;
    for (int idx in matches) {
      if (idx > activeCate) {
        target = idx;
        break;
      }
    }

    setState(() {
      activeCate = target;
      selectedItem = 0;
      _shouldFocusQty = false;
      _refocusSearch();
    });
    _scrollToCategory();
  }

  KeyEventResult _handleSearchKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_searchController.text.isEmpty) {
          context.pop();
          return KeyEventResult.handled;
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        return KeyEventResult.handled;
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

  Widget _menuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NavigationTitle(
          title: "Orders",
          subtitle: "Create Orders",
          isBackIcon: true,
        ),

        Shortcuts(
          shortcuts: <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowUp):
                const DirectionalFocusIntent(TraversalDirection.up),
            SingleActivator(LogicalKeyboardKey.arrowDown):
                const DirectionalFocusIntent(TraversalDirection.down),
            SingleActivator(LogicalKeyboardKey.arrowLeft):
                const DirectionalFocusIntent(TraversalDirection.left),
            SingleActivator(LogicalKeyboardKey.arrowRight):
                const DirectionalFocusIntent(TraversalDirection.right),
          },
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.toLowerCase();
                selectedItem = -1;
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
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
                    final categories = [
                      CategoriesModel(
                        id: 'all',
                        itemName: 'All Items',
                        iconNumber: Icons.grid_view.codePoint,
                      ),
                      ...rawCategories,
                    ];

                    if (_cachedCategories.length != categories.length) {
                      _cachedCategories = categories;
                    }

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
                                  List<ItemModel> filteredItems = [];

                                  if (_searchQuery.isNotEmpty) {
                                    filteredItems = itemProv.items.where((
                                      item,
                                    ) {
                                      return item.itemName
                                              .toLowerCase()
                                              .contains(_searchQuery) ||
                                          item.description
                                              .toLowerCase()
                                              .contains(_searchQuery);
                                    }).toList();
                                  } else {
                                    if (activeCate == 0) {
                                      filteredItems = itemProv.items;
                                    } else {
                                      final selectedCatId =
                                          categories[activeCate].id;
                                      filteredItems = itemProv.items
                                          .where(
                                            (item) =>
                                                item.categoryId ==
                                                selectedCatId,
                                          )
                                          .toList();
                                    }
                                  }

                                  if (filteredItems.isEmpty) {
                                    return const EmptyItem();
                                  }

                                  final Map<String, List<ItemModel>>
                                  groupedItems = {};
                                  for (var item in filteredItems) {
                                    groupedItems
                                        .putIfAbsent(item.categoryId, () => [])
                                        .add(item);
                                  }

                                  final sortedCategoryIds = categories
                                      .where(
                                        (c) => groupedItems.containsKey(c.id),
                                      )
                                      .map((c) => c.id!)
                                      .toList();

                                  for (var catId in groupedItems.keys) {
                                    if (!sortedCategoryIds.contains(catId)) {
                                      sortedCategoryIds.add(catId);
                                    }
                                  }

                                  return CustomScrollView(
                                    slivers: [
                                      for (var catId in sortedCategoryIds) ...[
                                        if (activeCate == 0 ||
                                            _searchQuery.isNotEmpty)
                                          SliverToBoxAdapter(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 15,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 4,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    categories
                                                        .firstWhere(
                                                          (c) => c.id == catId,
                                                          orElse: () =>
                                                              CategoriesModel(
                                                                itemName:
                                                                    'Other',
                                                                iconNumber: 0,
                                                              ),
                                                        )
                                                        .itemName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '(${groupedItems[catId]!.length})',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors.textHint,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                        SliverGrid(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                                mainAxisExtent: 220,
                                              ),
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              final item =
                                                  groupedItems[catId]![index];
                                              final globalIndex = filteredItems
                                                  .indexOf(item);

                                              return BuildItemCard(
                                                isRetail: item.isRetail,
                                                itemId: item.id.toString(),
                                                cate: item.categoryId,
                                                des: item.description,
                                                receiptId: receiptId,
                                                image: item.imagePath,
                                                price: item.price.toString(),
                                                title: item.itemName,
                                                isSelect:
                                                    selectedItem >= 0 &&
                                                    selectedItem == globalIndex,
                                                shouldFocus:
                                                    _shouldFocusQty &&
                                                    selectedItem >= 0 &&
                                                    (selectedItem ==
                                                        globalIndex),
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
                                            childCount:
                                                groupedItems[catId]!.length,
                                          ),
                                        ),
                                      ],
                                      const SliverToBoxAdapter(
                                        child: SizedBox(height: 50),
                                      ),
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

  Widget _cartSection() {
    return CurrentOrder(
      receiptId: receiptId,
      isFocused: isCartFocused,
      selectedIndex: selectedCartItemIndex,
    );
  }
}