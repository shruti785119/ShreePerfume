// screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:shree/core/app_state.dart';
import 'package:shree/screens/cart/checkout_screen.dart';
import 'package:shree/screens/widgets/wishlist_action_button.dart';
import 'package:shree/screens/wishlist/wishlist_screen.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _openWishlist(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WishlistScreen()),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openCheckout(BuildContext context) async {
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );

    if (completed == true && context.mounted) {
      _showMessage(context, 'Order placed successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final cartEntries = appState.cartEntries;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Shree Perfume',
              style: TextStyle(
                color: _dark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              WishlistActionButton(onTap: () => _openWishlist(context)),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Cart',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appState.cartItemCount} items in your bag',
                  style: const TextStyle(fontSize: 13, color: _muted),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: cartEntries.isEmpty
                      ? const _EmptyCart()
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              for (final entry in cartEntries) ...[
                                _CartItem(
                                  entry: entry,
                                  onRemove: () {
                                    appState.removeFromCart(entry.product);
                                    _showMessage(
                                      context,
                                      '${entry.product.title} removed from cart',
                                    );
                                  },
                                  onIncrease: () {
                                    appState.addToCart(entry.product);
                                  },
                                  onDecrease: () {
                                    appState.decreaseQuantity(entry.product);
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                              _SummaryCard(
                                subtotal: appState.subtotal,
                                onCheckout: () => _openCheckout(context),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.entry,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
  });

  final CartEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              fit: StackFit.expand,
              children: [
                entry.product.image.isNotEmpty
                    ? Image.asset(
                        entry.product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const ColoredBox(color: Color(0xFFF4F7FB));
                        },
                      )
                    : const ColoredBox(color: Color(0xFFF4F7FB)),
                ColoredBox(color: entry.product.overlay),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.product.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${entry.product.category} - ${entry.product.scentFamily}',
                style: const TextStyle(fontSize: 12.5, color: _muted),
              ),
              const SizedBox(height: 12),
              Text(
                entry.product.formattedPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            InkWell(
              onTap: onRemove,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Color(0xFFA8B4C6),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6FB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: onDecrease,
                    child: const Icon(Icons.remove, size: 18, color: _muted),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${entry.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  InkWell(
                    onTap: onIncrease,
                    child: const Icon(Icons.add, size: 18, color: _muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.subtotal, required this.onCheckout});

  final double subtotal;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FFF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDF5E7)),
      ),
      child: Column(
        children: [
          _PriceLine(
            label: 'Subtotal',
            value: '₹${subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          const _PriceLine(label: 'Shipping', value: 'Free'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: subtotal == 0 ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Checkout Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: _muted)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 36, color: _muted),
          SizedBox(height: 10),
          Text(
            'Your cart is empty. Tap the bag icon on any product to add it here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _muted),
          ),
        ],
      ),
    );
  }
}
