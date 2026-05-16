//lib/data/dummy_categories.dart

import 'package:shree/models/category_model.dart';

final List<AppCategory> initialCategories = <AppCategory>[
  const AppCategory(
    id: 'women',
    name: 'Women',
    description:
        'Elegant floral and fresh signatures crafted for everyday luxury.',
  ),
  const AppCategory(
    id: 'men',
    name: 'Men',
    description: 'Clean, bold, and woody fragrances with a confident finish.',
  ),
  const AppCategory(
    id: 'unisex',
    name: 'Unisex',
    description:
        'Balanced blends designed to feel modern, versatile, and shared.',
  ),
];
