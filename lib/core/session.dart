/// Signed-in admin. UI phase: sample admin; real login arrives with the backend.
class AdminSession {
  AdminSession._();
  static final instance = AdminSession._();

  String name = 'Emma Johnson';
  String role = 'Super Admin';

  /// Permission keys granted to this admin. A Super Admin has every key.
  /// The backend is the real gate; this only decides which menu items show.
  Set<String> permissions = {'*'};

  bool can(String permission) =>
      permissions.contains('*') || permissions.contains(permission);

  String get firstName => name.split(' ').first;
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}
