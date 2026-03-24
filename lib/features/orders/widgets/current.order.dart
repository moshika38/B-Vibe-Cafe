import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CurrentOrder extends StatelessWidget {
  const CurrentOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Current Order",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Total 50",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(),
            ],
          ),

          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return _buildItemCard(
                  context,
                  "Current Order",
                  "10,000 LKR",
                  "assets/img/rice.jpg",
                  1,
                  "1,004,488 LKR",
                  () {
                    // add item
                  },
                  () {
                    // remove item
                  },
                );
              },
            ),
          ),

          Divider(),

          SizedBox(height: 20),

          _buildCheckOutSection(context),
        ],
      ),
    );
  }

  Widget _buildCheckOutSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Discount",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              "1000 LKR",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Net Amount",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(
                "1,004 LKR",
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 20),

        Row(
          children: [
            Card(
              color: AppColors.background,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.delete, size: 25),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // go to checkout page
                  context.push('/orders/checkout');
                },
                child: Text(
                  "Place Order",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _buildItemCard(
  BuildContext context,
  String name,
  String price,
  String image,
  int quantity,
  String total,
  VoidCallback onAdd,
  VoidCallback onRemove,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Card(
      color: AppColors.background,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),

            Spacer(),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _buildIconBtn(false, onRemove),
                    SizedBox(width: 10),
                    Text(
                      quantity.toString(),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(width: 10),
                    _buildIconBtn(true, onAdd),
                  ],
                ),

                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Text(
                    total,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildIconBtn(bool isAdd, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Icon(
      isAdd ? Icons.add : Icons.remove,
      color: AppColors.textPrimary,
      size: 20,
    ),
  );
}
