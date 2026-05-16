//lib/data/dummy_products.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';

const List<Product> initialProducts = [
  Product(
    id: 'rose-musk',
    title: 'Rose Musk Eau de Parfum',
    brand: 'MANSION SCENTS',
    price: 120,
    image: "assets/victoria's.jpg",
    description:
        'A velvety floral fragrance with Turkish rose, soft musk, and a polished amber trail crafted for all-day elegance.',
    category: 'Women',
    scentFamily: 'Floral',
    overlay: Color(0x30D8988B),
  ),
  Product(
    id: 'peony-bloom',
    title: 'Peony Bloom',
    brand: 'HERITAGE PERFUMES',
    price: 95,
    image: 'assets/about.jpg',
    description:
        'Fresh peony petals meet pear nectar and white woods in a light, graceful blend for daytime wear.',
    category: 'Women',
    scentFamily: 'Floral',
    overlay: Color(0x22F7C8C8),
  ),
  Product(
    id: 'gardenia-night',
    title: 'Gardenia Night',
    brand: 'LUXURY BRAND A',
    price: 150,
    image: 'assets/DateNight.jpg',
    description:
        'Creamy gardenia layered with sandalwood and smoky vanilla for a deeper evening signature.',
    category: 'Unisex',
    scentFamily: 'Woody',
    overlay: Color(0x50000000),
  ),
  Product(
    id: 'lavender-mist',
    title: 'Lavender Mist',
    brand: 'PURE ESSENCE',
    price: 85,
    image: 'assets/perfume1.webp',
    description:
        'A crisp lavender and citrus composition balanced by airy musks for a clean, modern finish.',
    category: 'Men',
    scentFamily: 'Fresh',
    overlay: Color(0x18A8C8D0),
  ),
  Product(
    id: 'amber-saffron',
    title: 'Amber Saffron Reserve',
    brand: 'NOIR ATELIER',
    price: 175,
    image: 'assets/AcquaDGIO.jpg',
    description:
        'Warm saffron, resinous amber, and dry cedar notes create a rich premium blend with strong presence.',
    category: 'Unisex',
    scentFamily: 'Amber',
    overlay: Color(0x228E5E2F),
  ),
  Product(
    id: 'citrus-veil',
    title: 'Citrus Veil',
    brand: 'AURA LAB',
    price: 92,
    image: 'assets/jasmin.jpg',
    description:
        'Sparkling bergamot, neroli, and soft white tea give this fragrance a bright and uplifting personality.',
    category: 'Women',
    scentFamily: 'Fresh',
    overlay: Color(0x20E3B35F),
  ),
];
