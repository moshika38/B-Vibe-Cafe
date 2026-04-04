import 'package:bvibe/components/app.title.dart';
import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/features/orders/widgets/empty.item.dart';
import 'package:bvibe/provider/categories.provider.dart';
import 'package:bvibe/features/dashboard/widgets/cate.card.dart';
import 'package:bvibe/features/menu/widgets/edit.item.cart.dart';
import 'package:bvibe/features/menu/widgets/headline.dart';
import 'package:bvibe/features/menu/widgets/items.catalog.dart';
import 'package:bvibe/features/menu/widgets/add.cate.dart';
import 'package:bvibe/features/menu/widgets/add.items.dart';
import 'package:bvibe/provider/item.provider.dart';
import 'package:bvibe/data/model/item.model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppMenu extends StatefulWidget {
  const AppMenu({super.key});

  @override
  State<AppMenu> createState() => _AppMenuState();
}

class _AppMenuState extends State<AppMenu> {
  int activeIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().fetchCategories();
      context.read<ItemProvider>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBarTitle(
          title: "Menu & Inventory",
          isAddBtn: true,
          addButtonText: "Add New Item",
          addBtnTap: () async {
            final cateProvider = context.read<CategoriesProvider>();
            if (cateProvider.categories.isNotEmpty &&
                activeIndex < cateProvider.categories.length) {
              final currentCategory = cateProvider.categories[activeIndex];

              final itemModel = await AddItems.show(
                context,
                currentCategory,
                activeIndex,
              );
              if (itemModel != null) {
                final itemProvider = context.read<ItemProvider>();

                print("Item returned! Data: ${itemModel.toMap()}");
                final res = await itemProvider.insertItem(itemModel);
                if (res > 0) {
                  AppSnack.successSnack(context, "Item added successfully");
                } else {
                  AppSnack.errorSnack(context, "Failed to add item");
                }
              }
            } else {
              AppSnack.errorSnack(
                context,
                "Please create and select a category first",
              );
            }
          },
        ),

        // category section
        Consumer2<CategoriesProvider, ItemProvider>(
          builder: (context, cate, itemProv, child) => Expanded(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    color: AppColors.inputFill,
                  ),
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HeadLine
                      HeadLine(
                        onTap: () async {
                          final category = await CreateCategories.show(context);
                          if (category != null) {
                            final res = await cate.insertCategory(category);
                            if (res > 0) {
                              AppSnack.successSnack(
                                context,
                                "Category added successfully",
                              );
                            } else {
                              AppSnack.errorSnack(
                                context,
                                "Failed to add category",
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(
                            context,
                          ).copyWith(scrollbars: false),
                          child: Builder(
                            builder: (context) {
                              if (cate.isLoadingCategories) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (cate.categories.isEmpty) {
                                return const Center(child: EmptyItem());
                              }

                              final listOfCate = cate.categories;
                              return ReorderableListView.builder(
                                scrollController: _scrollController,
                                itemCount: listOfCate.length,
                                buildDefaultDragHandles: false,  
                                onReorder: (oldIndex, newIndex) {
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1;
                                  }
                                  final itemId = listOfCate[oldIndex].id;
                                  if (itemId != null) {
                                     
                                    if (oldIndex == newIndex) return;

                                     
                                    if (activeIndex == oldIndex) {
                                      setState(() => activeIndex = newIndex);
                                    } else if (activeIndex > oldIndex &&
                                        activeIndex <= newIndex) {
                                      setState(() => activeIndex -= 1);
                                    } else if (activeIndex < oldIndex &&
                                        activeIndex >= newIndex) {
                                      setState(() => activeIndex += 1);
                                    }

                                    cate.reorderCategory(itemId, newIndex);
                                  }
                                },
                                itemBuilder: (context, index) {
                                  final category = listOfCate[index];
                                  final categoryId = category.id;
                                  final itemCount = itemProv.items
                                      .where((i) => i.categoryId == categoryId)
                                      .length;

                                  return CateCard(
                                    key: ValueKey(categoryId ?? index),
                                    isActive: index == activeIndex,
                                    imageNumber: category.iconNumber,
                                    count: itemCount.toString(),
                                    title: category.itemName,
                                    dragHandle: ReorderableDragStartListener(
                                      index: index,
                                      child: const Icon(
                                        Icons.drag_handle,
                                        size: 20,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        activeIndex = index;
                                      });
                                      context.read<ItemProvider>().selectItem(
                                        null,
                                      );
                                    },
                                    onEdit: () async {
                                      final updatedCategory =
                                          await CreateCategories.show(
                                            context,
                                            category: category,
                                          );
                                      if (updatedCategory != null) {
                                        final res = await cate.insertCategory(
                                          updatedCategory,
                                        );
                                        if (res > 0) {
                                          AppSnack.successSnack(
                                            context,
                                            "Category updated successfully",
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // category items section
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Text(
                            cate.categories.isNotEmpty &&
                                    activeIndex < cate.categories.length
                                ? cate.categories[activeIndex].itemName
                                : "Select a category",
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            "Manage items and pricing for this category",
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 30),
                          // ItemCatalog,
                          ItemCatalog(
                            category:
                                cate.categories.isNotEmpty &&
                                    activeIndex < cate.categories.length
                                ? cate.categories[activeIndex].id ?? ""
                                : "",
                            onItemSelected: (ItemModel item) {
                              context.read<ItemProvider>().selectItem(item);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // category items edit section
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 100,
                          offset: const Offset(-1, 0),
                        ),
                      ],
                    ),

                    child: Consumer<ItemProvider>(
                      builder: (context, itemProv, child) {
                        final selectedItem = itemProv.selectedItem;
                        return selectedItem == null
                            ? Center(
                                child: Text(
                                  "Select an item to view or edit",
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(color: AppColors.textHint),
                                ),
                              )
                            : EditItemCart(
                                id: selectedItem.id ?? '',
                                categoryId:
                                    cate.categories[activeIndex].id ?? '',
                                categoryName:
                                    cate.categories[activeIndex].itemName,
                                cost: selectedItem.cost,
                                image: selectedItem.imagePath,
                                name: selectedItem.itemName,
                                price: selectedItem.price,
                                des: selectedItem.description,
                                isRetail: selectedItem.isRetail,
                              );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
