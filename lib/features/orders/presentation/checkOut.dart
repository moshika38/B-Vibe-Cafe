import 'package:bvibe/components/navigation.title.dart';
import 'package:bvibe/const/theme.dart';
import 'package:bvibe/features/orders/widgets/checkout.order.summary.dart';
import 'package:bvibe/features/orders/widgets/checkout.payment.section.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width < 1100;
    final bool isMobile = width < 800;

    return Container(
      decoration: BoxDecoration(color: AppColors.background),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const NavigationTitle(
                  title: "Orders",
                  subtitle: "Checkout",
                  isBackIcon: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isMobile
                  ? ListView(
                      children: const [
                        CheckoutOrderSummary(),
                        SizedBox(height: 20),
                        CheckoutPaymentSection(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: isTablet ? 1 : 2,
                          child: const CheckoutOrderSummary(),
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          flex: isTablet ? 1 : 2,
                          child: const CheckoutPaymentSection(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
