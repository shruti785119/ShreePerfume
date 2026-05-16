import 'package:flutter/material.dart';

import 'package:shree/core/app_state.dart';
import 'package:shree/models/product_model.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);
const Color _redHeart = Color(0xFFE55767);

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final wishlistProducts = appState.wishlistProducts;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _dark,
                size: 18,
              ),
            ),
            title: const Text(
              'Shree Perfume',
              style: TextStyle(
                color: _dark,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              const Text(
                'My Wishlist',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${wishlistProducts.length} saved fragrances',
                style: const TextStyle(fontSize: 13, color: _muted),
              ),
              const SizedBox(height: 18),
              if (wishlistProducts.isEmpty)
                const _EmptyWishlist()
              else
                for (final product in wishlistProducts) ...[
                  _WishlistItem(
                    product: product,
                    onRemove: () {
                      appState.removeFromWishlist(product);
                      _showMessage(
                        context,
                        '${product.title} removed from wishlist',
                      );
                    },
                    onMoveToBag: () {
                      appState.moveWishlistToCart(product);
                      _showMessage(
                        context,
                        '${product.title} moved to cart',
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _WishlistItem extends StatelessWidget {
  const _WishlistItem({
    required this.product,
    required this.onRemove,
    required this.onMoveToBag,
  });

  final Product product;
  final VoidCallback onRemove;
  final VoidCallback onMoveToBag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF2F8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B1B34),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 88,
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.image.isNotEmpty
                      ? Image.asset(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const ColoredBox(color: Color(0xFFF4F7FB));
                          },
                        )
                      : const ColoredBox(color: Color(0xFFF4F7FB)),
                  ColoredBox(color: product.overlay),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: _green,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _green,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: _redHeart,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onMoveToBag,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Move to bag',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8F2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.favorite_border_rounded, size: 36, color: _muted),
          SizedBox(height: 10),
          Text(
            'No saved fragrances yet. Tap the heart icon on any product to add it here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _muted),
          ),
        ],
      ),
    );
  }
}
