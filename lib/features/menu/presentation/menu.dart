import 'package:bvibe/components/app.title.dart';
import 'package:bvibe/const/theme.dart';
import 'package:bvibe/features/dashboard/widgets/cate.card.dart';
import 'package:bvibe/features/menu/widgets/edit.item.cart.dart';
import 'package:bvibe/features/menu/widgets/headline.dart';
import 'package:bvibe/features/menu/widgets/items.catalog.dart';
import 'package:flutter/material.dart';

class AppMenu extends StatefulWidget {
  const AppMenu({super.key});

  @override
  State<AppMenu> createState() => _AppMenuState();
}

class _AppMenuState extends State<AppMenu> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBarTitle(
          title: "Menu & Inventory",
          isAddBtn: true,
          addButtonText: "Add New Item",
          addBtnTap: () {},
        ),

        // category section
        Expanded(
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
                    HeadLine(),
                    const SizedBox(height: 10),

                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(
                          context,
                        ).copyWith(scrollbars: false),
                        child: ListView.builder(
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            return CateCard(
                              isActive: index == activeIndex ? true : false,
                              count: "25",
                              title: "Rice ans curry",
                              onTap: () => setState(() {
                                activeIndex = index;
                              }),
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
      ],
    );
  }
}
