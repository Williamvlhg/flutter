
import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 1; // Mobile
    } else if (screenWidth < 900) {
      crossAxisCount = 2; // Tablet
    } else if (screenWidth < 1200) {
      crossAxisCount = 3; // Desktop small
    } else {
      crossAxisCount = 4; // Desktop large
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: 0.8,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}