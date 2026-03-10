import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/const/theme.dart';
import 'package:bvibe/features/orders/widgets/build.cate.card.dart';
import 'package:bvibe/features/orders/widgets/build.item.card.dart';
import 'package:bvibe/features/orders/widgets/current.order.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  int activeCate = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    /// responsive breakpoints
    final bool isTablet = width < 1100;
    final bool isMobile = width < 750;

    return Padding(
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
                Expanded(flex: 3, child: _cartSection()),
              ],
            ),
    );
  }

  /// LEFT SIDE (Menu)
  Widget _menuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NavigationTitle(title: "Orders", subtitle: "Menu Selection"),

        TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.textHint),
            ),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 20,
            itemBuilder: (context, index) {
              return BuildCateCard(
                isActive: index == activeCate,
                title: 'Rice & Curry',
                icon: Icons.rice_bowl,
                onTap: () {
                  setState(() {
                    activeCate = index;
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

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 220,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  return const BuildItemCard();
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
    return CurrentOrder();
  }
}
