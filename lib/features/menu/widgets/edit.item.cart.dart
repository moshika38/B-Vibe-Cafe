import 'package:bvibe/components/app.buttons.dart';
import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class EditItemCart extends StatelessWidget {
  const EditItemCart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          // Header
          Row(
            children: [
              Text(
                "Edit Item".toUpperCase(),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: Colors.grey, thickness: 0.2),
          SizedBox(height: 20),

          // scrollable content
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            "assets/img/login_page.jpg",
                            height: 400,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    textInput(theme, "Item Name", "Item Name"),
                    textInput(theme, "1000 LKR", "Price(LKR)"),
                    textInput(theme, "800 LKR", "Cost(LKR)"),
                    textInput(theme, "Main", "Category"),
                    textInput(theme, "Description...", "Description"),
                  ],
                ),
              ),
            ),
          ),

          // buttons always visible
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButtons(
                icon: Symbols.delete,
                text: "Delete Item",
                onTap: () {},
                isNotPrimary: true,
              ),
              SizedBox(width: 20),
              AppButtons(
                icon: Symbols.save,
                text: "Save Changes",
                onTap: () {},
                isNotPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textInput(ThemeData theme, String hintText, String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(labelText.toUpperCase(), style: theme.textTheme.labelSmall),
        SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: TextFormField(
            style: theme.textTheme.labelMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.labelMedium!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w200,
                fontSize: 11,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey, width: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}