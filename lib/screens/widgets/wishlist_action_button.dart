import 'package:flutter/material.dart';

class WishlistActionButton extends StatelessWidget {
  const WishlistActionButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE7ECF3)),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 20,
              color: Color(0xFFE55767),
            ),
          ),
        ),
      ),
    );
  }
}
