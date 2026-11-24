import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Initials avatar with a stable tint per name and an optional online dot.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.size = 36,
    this.online = false,
  });

  final String name;
  final double size;
  final bool online;

  static const _tints = [
    (Color(0xFFEDE7FF), AppColors.brand),
    (Color(0xFFE6F7F5), Color(0xFF0F9488)),
    (Color(0xFFFFF1E0), Color(0xFFD97706)),
    (Color(0xFFFDEAF4), Color(0xFFDB2777)),
    (Color(0xFFEAF1FF), Color(0xFF2563EB)),
    (Color(0xFFE8F7EE), Color(0xFF15803D)),
  ];

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tint = _tints[name.hashCode.abs() % _tints.length];
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tint.$1, shape: BoxShape.circle),
            child: Text(
              _initials,
              style: TextStyle(
                color: tint.$2,
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: AppColors.online,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
