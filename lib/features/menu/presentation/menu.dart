import 'package:bvibe/components/app.title.dart';
import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/const/theme.dart';
import 'package:bvibe/provider/categories.helper.dart';
import 'package:bvibe/features/dashboard/widgets/cate.card.dart';
import 'package:bvibe/features/menu/widgets/edit.item.cart.dart';
import 'package:bvibe/features/menu/widgets/headline.dart';
import 'package:bvibe/features/menu/widgets/items.catalog.dart';
import 'package:bvibe/features/menu/widgets/add.cate.dart';
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
      CategoriesProvider.instance.fetchCategories();
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
          addBtnTap: () {
            // add new items
          },
        ),

        // category section
        Consumer<CategoriesProvider>(
          builder: (context, cate, child) => Expanded(
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
                                return const Center(
                                  child: Text("No categories found"),
                                );
                              }

                              final listOfCate = cate.categories;

                              return ListView.builder(
                                controller: _scrollController,
                                itemCount: listOfCate.length,
                                itemBuilder: (context, index) {
                                  return CateCard(
                                    isActive: index == activeIndex,
                                    imageNumber: listOfCate[index].iconNumber,
                                    count: "25",
                                    title: listOfCate[index].itemName,
                                    onTap: () => setState(() {
                                      activeIndex = index;
                                    }),
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
                          SizedBox(height: 25),
                          Text(
                            "Rice and curry",
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

                          SizedBox(height: 30),
                          // ItemCatalog,
                          ItemCatalog(),
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

                    child: EditItemCart(),
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
