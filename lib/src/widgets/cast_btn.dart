import 'package:flutter/material.dart';

class CastBtn extends StatelessWidget {
  const CastBtn({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(
        Icons.cast,
        color: Colors.white,
      ),
    );
  }
}
