import 'package:shree/models/user_model.dart';

final List<AppUser> initialUsers = <AppUser>[
  AppUser(
    id: 'isabella-rose',
    name: 'Isabella Rose',
    email: 'isabella.rose@example.com',
    role: 'Customer',
    memberSince: DateTime(2023, 2, 14),
  ),
  AppUser(
    id: 'arjun-mehta',
    name: 'Arjun Mehta',
    email: 'arjun.mehta@example.com',
    role: 'Customer',
    memberSince: DateTime(2024, 6, 2),
  ),
  AppUser(
    id: 'mia-thomas',
    name: 'Mia Thomas',
    email: 'mia.thomas@example.com',
    role: 'Customer',
    memberSince: DateTime(2024, 9, 19),
  ),
  AppUser(
    id: 'admin-shree',
    name: 'Shree Admin',
    email: 'admin@shree.com',
    role: 'Admin',
    memberSince: DateTime(2022, 11, 8),
  ),
];

