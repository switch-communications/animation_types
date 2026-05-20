import 'package:flutter/material.dart';

class PageSnapToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PageSnapToggle({
    super.key,
    this.value = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Page Snapping',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}


