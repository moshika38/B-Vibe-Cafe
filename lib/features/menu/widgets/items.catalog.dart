import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';

class ItemCatalog extends StatelessWidget {
  const ItemCatalog({super.key});

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

          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  return _buildItemCard(
                    theme,
                    "assets/img/login_page.jpg",
                    "Thai Rice ",
                    "Basmathi rice with frsh chiken, with coca cola 1l bottle",
                    "1500 LKR",
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Text(
              "Showing 230 of results",
              style: theme.textTheme.labelSmall!.copyWith(
                color: AppColors.primary,
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
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
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
              Text(
                price,
                style: theme.textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.w600,
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
