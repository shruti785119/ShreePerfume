//lib/core/session_manager.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// enum SessionRole { user, admin }

// class SessionManager {
//   static const String _loggedInKey = 'isLoggedIn';
//   static const String _roleKey = 'sessionRole';

//   static Future<void> saveLogin(SessionRole role) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_loggedInKey, true);
//     await prefs.setString(_roleKey, role.name);
//   }

//   static Future<bool> isLoggedIn() async {
//     return FirebaseAuth.instance.currentUser != null;
//   }

//   static Future<SessionRole> currentRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     final roleName = prefs.getString(_roleKey);

//     if (roleName == SessionRole.admin.name) {
//       return SessionRole.admin;
//     }

//     return SessionRole.user;
//   }

//   static Future<void> clear() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_loggedInKey);
//     await prefs.remove(_roleKey);
//   }
// }




//=====================================================



import 'package:shared_preferences/shared_preferences.dart';

enum SessionRole { user, admin }

class SessionManager {
  static const String _loggedInKey = 'isLoggedIn';
  static const String _roleKey = 'sessionRole';

  static Future<void> saveLogin(SessionRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_roleKey, role.name);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<SessionRole> currentRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString(_roleKey);

    if (roleName == SessionRole.admin.name) {
      return SessionRole.admin;
    }
    return SessionRole.user;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_roleKey);
  }
}