
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class GridActionItem extends StatelessWidget {
  final GridItem item;
  final VoidCallback onTap;

  const GridActionItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


class GridItem {
  final String title;
  GridItem(this.title);
}