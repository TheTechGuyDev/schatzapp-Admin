import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/modules.dart';
import '../core/session.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar.dart';

/// White admin side nav. `expanded` = full labels (desktop and phone drawer);
/// collapsed = icon rail (tablet).
class SideNav extends StatelessWidget {
  const SideNav({
    super.key,
    required this.location,
    required this.expanded,
    this.onNavigate,
  });

  final String location;
  final bool expanded;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final session = AdminSession.instance;
    final visible = adminModules
        .where((m) => session.can(m.permission))
        .toList();

    return Container(
      width: expanded ? 232 : 76,
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _Brand(expanded: expanded),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  expanded ? 14 : 12,
                  4,
                  expanded ? 14 : 12,
                  12,
                ),
                children: [
                  for (final section in NavSection.values)
                    ..._section(
                      context,
                      section,
                      visible.where((m) => m.section == section).toList(),
                    ),
                ],
              ),
            ),
            _AdminCard(expanded: expanded),
          ],
        ),
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    NavSection section,
    List<AdminModule> items,
  ) {
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: EdgeInsets.fromLTRB(expanded ? 10 : 0, 16, 0, 6),
        child: expanded
            ? Text(
                section.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              )
            : const Divider(color: AppColors.border, height: 1),
      ),
      for (final m in items)
        _NavItem(
          module: m,
          active: location.startsWith(m.path),
          expanded: expanded,
          badge: navBadges[m.id],
          onTap: () {
            onNavigate?.call();
            context.go(m.path);
          },
        ),
    ];
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.expanded});
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B4DFF), Color(0xFF5B2BE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset('assets/images/logo_white.png'),
    );
    if (!expanded) {
      return Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: logo,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 6),
      child: Row(
        children: [
          logo,
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SchatzApp',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Admin Panel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.module,
    required this.active,
    required this.expanded,
    required this.onTap,
    this.badge,
  });

  final AdminModule module;
  final bool active;
  final bool expanded;
  final VoidCallback onTap;
  final int? badge;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final fg = active ? AppColors.brand : AppColors.navText;
    final item = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 34,
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: EdgeInsets.symmetric(horizontal: widget.expanded ? 10 : 0),
          decoration: BoxDecoration(
            color: active
                ? AppColors.brandSoft
                : _hover
                ? AppColors.hover
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.expanded
              ? Row(
                  children: [
                    Icon(widget.module.icon, color: fg, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.module.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fg,
                          fontSize: 13,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.badge != null) _Badge(widget.badge!),
                  ],
                )
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(widget.module.icon, color: fg, size: 19),
                    ),
                    if (widget.badge != null)
                      Positioned(
                        right: 10,
                        top: 5,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.brand,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
    if (widget.expanded) return item;
    return Tooltip(message: widget.module.label, child: item);
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.count);
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.expanded});
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final s = AdminSession.instance;
    final avatar = Avatar(name: s.name, size: 40, online: !expanded);
    return Container(
      padding: EdgeInsets.fromLTRB(
        expanded ? 16 : 0,
        14,
        expanded ? 14 : 0,
        16,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: expanded
          ? Row(
              children: [
                avatar,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        s.role,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.circle, size: 7, color: AppColors.online),
                          SizedBox(width: 5),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const AccountMenu(
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ],
            )
          : Center(
              child: Tooltip(message: '${s.name} · ${s.role}', child: avatar),
            ),
    );
  }
}

/// Profile menu (Log out) used by the side nav and the top bar.
class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      onSelected: (v) {
        if (v == 'logout') {
          AdminSession.instance.signOut();
          context.go('/login');
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
              SizedBox(width: 10),
              Text(
                'Log out',
                style: TextStyle(fontSize: 13, color: AppColors.danger),
              ),
            ],
          ),
        ),
      ],
      child: child,
    );
  }
}
