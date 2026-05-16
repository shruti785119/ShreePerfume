
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:shree/core/app_state.dart';
import 'package:shree/models/order_model.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);

const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final user = FirebaseAuth.instance.currentUser;
    final currentUid = user?.uid ?? '';
    final currentEmail = user?.email?.trim().toLowerCase() ?? '';

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final orders = appState.orders
            .where((order) => order.customerId == currentUid ||
                order.customerEmail == currentEmail)
            .toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text('Shree Perfume'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const _SectionHeader(
                title: 'My Orders',
                subtitle: 'Track, return, or buy again',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 18),
              if (orders.isEmpty)
                const _EmptyOrdersCard()
              else
                for (final order in orders) ...[
                  _OrderCard(order: order),
                  const SizedBox(height: 16),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF4FFF9), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFE3F6EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEFFFF8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrdersCard extends StatelessWidget {
  const _EmptyOrdersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 36, color: _muted),
          SizedBox(height: 12),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'When you place an order from the cart, it will appear here with status and payment details.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: _green,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFBF5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${order.itemCount} items  ${order.formattedTotalAmount}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _dark,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Placed on',
            value: _formatDate(order.placedAt),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Deliver to',
            value:
                '${order.shippingName}, ${order.shippingAddress}, ${order.city}',
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.payments_outlined,
            label: 'Payment',
            value: order.paymentLabel,
          ),
          const SizedBox(height: 14),
          for (final item in order.items) ...[
            _OrderItemRow(item: item),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: item.image.isNotEmpty
              ? Image.asset(
                  item.image,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const ColoredBox(color: Color(0xFFF4F7FB));
                  },
                )
              : const ColoredBox(color: Color(0xFFF4F7FB)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${item.title} x${item.quantity}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          item.formattedTotalPrice,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _muted),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'ShreeSans',
                fontSize: 13,
                color: _muted,
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    color: _dark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime value) {
  final hour = value.hour > 12
      ? value.hour - 12
      : value.hour == 0
      ? 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${_months[value.month - 1]} $day, ${value.year} ? $hour:$minute $period';
}

final BoxDecoration _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: const Color(0xFFEDF2F8)),
  boxShadow: const [
    BoxShadow(color: Color(0x080B1B34), blurRadius: 18, offset: Offset(0, 8)),
  ],
);

