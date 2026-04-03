import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/workspace/dummy.dart';
import 'package:bvibe/features/orders/widgets/build.cate.card.dart';
import 'package:bvibe/features/orders/widgets/build.item.card.dart';
import 'package:bvibe/features/orders/widgets/current.order.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/provider/categories.helper.dart';
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
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = "";
  bool _shouldFocusQty = false;
  int _currentCrossAxisCount = 4;

  void _refocusSearch() {
    _searchFocusNode.requestFocus();
    _searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _searchController.text.length,
    );
    _shouldFocusQty = false;
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
                  selectedCartItemIndex =
                      selectedCartItemIndex.clamp(0, items.length - 1);
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

      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
        _refocusSearch();
        return true;
      }

      if (isCtrlPressed &&
          (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
        context.push('/orders/checkout', extra: receiptId);
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (isCartFocused) return true; // Consume but do nothing in cart for now
        if (isShiftPressed) {
          Provider.of<ReceiptProvider>(
            context,
            listen: false,
          ).updateOrderType(receiptId, 'Takeaway');
        } else if (isCtrlPressed) {
          final max = _maxCategories > 0 ? _maxCategories - 1 : 0;
          setState(() => activeCate = (activeCate + 1).clamp(0, max));
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
        } else {
          final max = _maxItems > 0 ? _maxItems - 1 : 0;
          setState(() {
            _shouldFocusQty = true;
            selectedItem = (selectedItem - 1).clamp(0, max);
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
                selectedCartItemIndex =
                    (selectedCartItemIndex + 1).clamp(0, receipt.items.length - 1);
              });
            }
          });
        } else {
          final max = _maxItems > 0 ? _maxItems - 1 : 0;
          setState(() {
            _shouldFocusQty = true;
            selectedItem =
                (selectedItem + _currentCrossAxisCount).clamp(0, max);
          });
        }
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (isCartFocused) {
          setState(() {
            selectedCartItemIndex =
                (selectedCartItemIndex - 1).clamp(0, selectedCartItemIndex);
          });
        } else {
          setState(() {
            _shouldFocusQty = true;
            selectedItem =
                (selectedItem - _currentCrossAxisCount).clamp(0, selectedItem);
          });
        }
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    widget.invoiceId.isEmpty ? _create() : receiptId = widget.invoiceId;
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
              selectedItem = 0; // Reset selection when searching
              _shouldFocusQty = false; // Never focus qty while typing in search
            });
          },
          decoration: InputDecoration(
            hintText: 'Search...',
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
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() => _currentCrossAxisCount =
                                        crossAxisCount);
                                  }
                                });
                              }

                              return Consumer<ItemProvider>(
                                builder: (context, itemProv, child) {
                                  // Determine list to show
                                  List<ItemModel> filteredItems = [];

                                  if (_searchQuery.isNotEmpty) {
                                    // Global Search - show items from all categories
                                    filteredItems = itemProv.items
                                        .where((item) =>
                                            item.itemName
                                                .toLowerCase()
                                                .contains(_searchQuery) ||
                                            item.description
                                                .toLowerCase()
                                                .contains(_searchQuery))
                                        .toList();
                                  } else {
                                    if (activeCate == 0) {
                                      // "All" category selected, no search query
                                      filteredItems = itemProv.items;
                                    } else {
                                      // Specific category selected, no search query
                                      final selectedCatId =
                                          categories[activeCate].id;
                                      filteredItems = itemProv.items
                                          .where((item) =>
                                              item.categoryId == selectedCatId)
                                          .toList();
                                    }
                                  }

                                  _maxItems = filteredItems.length;

                                  if (filteredItems.isEmpty) {
                                    return const EmptyItem();
                                  }

                                  return GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      mainAxisExtent: 220,
                                    ),
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      return BuildItemCard(
                                        isRetail: filteredItems[index].isRetail,
                                        itemId:
                                            filteredItems[index].id.toString(),
                                        cate: filteredItems[index].categoryId,
                                        cost: filteredItems[index].cost,
                                        des: filteredItems[index].description,
                                        receiptId: receiptId,
                                        image: filteredItems[index].imagePath,
                                        price: filteredItems[index].price
                                            .toString(),
                                        title: filteredItems[index].itemName,
                                        isSelect: selectedItem == index,
                                        shouldFocus: _shouldFocusQty && (selectedItem == index),
                                        onAdded: () {
                                          _refocusSearch();
                                        },
                                        onTap: () {
                                          setState(() {
                                            selectedItem = index;
                                            _shouldFocusQty = true;
                                            // Request focus back to search bar after selecting
                                            _refocusSearch();
                                          });
                                        },
                                      );
                                    },
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
