import 'dart:io';
import 'package:bvibe/const/theme.dart';
import 'package:bvibe/data/model/item.model.dart';
import 'package:bvibe/provider/item.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemCatalog extends StatelessWidget {
  final String category;
  final Function(ItemModel)? onItemSelected;
  
  const ItemCatalog({
    super.key, 
    required this.category,
    this.onItemSelected,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 600,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textHint, width: 0.15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Title
          _buildTableTitle(theme),

          Consumer<ItemProvider>(
            builder: (context, itemProvider, child) => Expanded(
              child: FutureBuilder(
                future: itemProvider.readAllItems(category),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (asyncSnapshot.hasError) {
                    return Center(child: Text("Error: ${asyncSnapshot.error}"));
                  }

                  if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
                    return const Center(child: Text("No items found"));
                  }

                  final items = asyncSnapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(
                            context,
                          ).copyWith(scrollbars: false),
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return InkWell(
                                onTap: () {
                                  if (onItemSelected != null) {
                                    onItemSelected!(item);
                                  }
                                },
                                child: _buildItemCard(
                                  theme,
                                  item.imagePath,
                                  item.name,
                                  item.description,
                                  item.price,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                        child: Text(
                          "Showing ${items.length} of results",
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    ThemeData theme,
    String image,
    String name,
    String des,
    String price,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          // bottom border
          border: Border(
            bottom: BorderSide(color: AppColors.textHint, width: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: image.contains('assets/img/')
                        ? Image.asset(
                            image,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                          )
                        : Image.file(
                            File(image),
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.fastfood, size: 40),
                          ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.textTheme.labelMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(height: 3),
                      SizedBox(
                        width: 200,
                        child: Text(
                          des,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: theme.textTheme.labelMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 90,
                child: Text(
                  "Rs $price",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text("Image".toUpperCase(), style: theme.textTheme.labelSmall),
              SizedBox(width: 37),
              Text("Name".toUpperCase(), style: theme.textTheme.labelSmall),
            ],
          ),
          Text("Pricing".toUpperCase(), style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
