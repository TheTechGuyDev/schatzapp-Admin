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
    final visible = adminModules.where((m) => session.can(m.permission)).toList();

    return Container(
      width: expanded ? 252 : 80,
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(children: [
          _Brand(expanded: expanded),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(expanded ? 14 : 12, 6, expanded ? 14 : 12, 12),
              children: [
                for (final section in NavSection.values)
                  ..._section(context, section,
                      visible.where((m) => m.section == section).toList()),
              ],
            ),
          ),
          _AdminCard(expanded: expanded),
        ]),
      ),
    );
  }

  List<Widget> _section(
      BuildContext context, NavSection section, List<AdminModule> items) {
    if (items.isEmpty) return const [];
    return [
      if (section.label.isNotEmpty)
        Padding(
          padding: EdgeInsets.fromLTRB(expanded ? 10 : 0, 18, 0, 8),
          child: expanded
              ? Text(section.label,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6))
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
    final logo = Image.asset('assets/images/logo.png', width: 40, height: 44);
    if (!expanded) {
      return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10), child: logo);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 16, 10),
      child: Row(children: [
        logo,
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SchatzApp',
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),
          SizedBox(height: 1),
          Text('Admin Panel',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ]),
      ]),
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
          height: 42,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(horizontal: widget.expanded ? 12 : 0),
          decoration: BoxDecoration(
            color: active
                ? AppColors.brandSoft
                : _hover
                    ? AppColors.hover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.expanded
              ? Row(children: [
                  Icon(widget.module.icon, color: fg, size: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(widget.module.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: fg,
                            fontSize: 14,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
                  ),
                  if (widget.badge != null) _Badge(widget.badge!),
                ])
              : Stack(clipBehavior: Clip.none, children: [
                  Center(child: Icon(widget.module.icon, color: fg, size: 21)),
                  if (widget.badge != null)
                    Positioned(
                      right: 10,
                      top: 7,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.brand, shape: BoxShape.circle),
                      ),
                    ),
                ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$count',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.expanded});
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final s = AdminSession.instance;
    final avatar = Avatar(name: s.name, size: 42, online: true);
    return Container(
      padding: EdgeInsets.fromLTRB(expanded ? 18 : 0, 14, expanded ? 14 : 0, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: expanded
          ? Row(children: [
              avatar,
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 1),
                  Text(s.role,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 3),
                  const Row(children: [
                    Icon(Icons.circle, size: 7, color: AppColors.online),
                    SizedBox(width: 5),
                    Text('Online',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                ]),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary, size: 20),
            ])
          : Center(child: Tooltip(message: '${s.name} · ${s.role}', child: avatar)),
    );
  }
}
