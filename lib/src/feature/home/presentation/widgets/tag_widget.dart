import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String tag;
  final bool? defaultSelected;
  final Function()? onTap;

  const Tag({super.key, required this.tag, this.onTap, this.defaultSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Chip(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          label: Text(
            tag,
          ),
        ),
      ),
    );
  }
}