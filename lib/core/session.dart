import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;

/// Signed-in admin. UI phase: any details sign in as the sample Super Admin;
/// the real login (Supabase Auth + authenticator MFA) arrives with the backend.
class AdminSession extends ChangeNotifier {
  AdminSession._();
  static final instance = AdminSession._();

  static const _key = 'schatz_admin_session';

  String name = 'Kesta Wealth';
  String role = 'Super Admin';

  /// Permission keys granted to this admin. A Super Admin has every key.
  /// The backend is the real gate; this only decides which menu items show.
  Set<String> permissions = {'*'};

  /// Kept for the browser tab only (sessionStorage), so closing the tab
  /// signs the admin out.
  bool get signedIn => web.window.sessionStorage.getItem(_key) == '1';

  void signIn() {
    web.window.sessionStorage.setItem(_key, '1');
    notifyListeners();
  }

  void signOut() {
    web.window.sessionStorage.removeItem(_key);
    notifyListeners();
  }

  bool can(String permission) =>
      permissions.contains('*') || permissions.contains(permission);

  String get firstName => name.split(' ').first;
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}
