import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/modules.dart';
import '../core/session.dart';
import '../theme/app_colors.dart';

/// Deep purple admin side nav. `expanded` = full labels (desktop and phone
/// drawer); collapsed = icons only (tablet).
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
      width: expanded ? 280 : 84,
      color: AppColors.sidebar,
      child: SafeArea(
        child: Column(children: [
          _Brand(expanded: expanded),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(expanded ? 18 : 14, 8, expanded ? 18 : 14, 12),
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
      Padding(
        padding: EdgeInsets.fromLTRB(expanded ? 8 : 0, 20, 0, 10),
        child: expanded
            ? Text(section.label,
                style: const TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.6))
            : const Divider(color: Color(0x22FFFFFF), height: 1),
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
    final logo = Image.asset('assets/images/logo.png', width: 42, height: 46);
    if (!expanded) {
      return Padding(padding: const EdgeInsets.only(top: 26, bottom: 8), child: logo);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 28, 20, 8),
      child: Row(children: [
        logo,
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              colors: [Colors.white, AppColors.brand, AppColors.magenta],
              stops: [0, 0.55, 1],
            ).createShader(r),
            child: const Text('SchatzApp',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3)),
          ),
          const SizedBox(height: 2),
          const Text('Secure . Verify . Trust',
              style: TextStyle(color: Color(0xDDFFFFFF), fontSize: 12)),
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
    final item = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 46,
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: EdgeInsets.symmetric(horizontal: widget.expanded ? 14 : 0),
          decoration: BoxDecoration(
            color: active
                ? const Color(0x14FFFFFF)
                : _hover
                    ? const Color(0x0FFFFFFF)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? AppColors.magenta : Colors.transparent,
              width: 1.4,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.magenta.withValues(alpha: 0.45),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: widget.expanded
              ? Row(children: [
                  Icon(widget.module.icon, color: Colors.white, size: 21),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(widget.module.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
                  ),
                  if (widget.badge != null) _Badge(widget.badge!),
                ])
              : Stack(clipBehavior: Clip.none, children: [
                  Center(
                    child: Icon(widget.module.icon, color: Colors.white, size: 22),
                  ),
                  if (widget.badge != null)
                    Positioned(
                      right: 8,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.magenta, shape: BoxShape.circle),
                      ),
                    ),
                ]),
        ),
      ),
    );
    if (widget.expanded) return item;
    return Tooltip(
      message: widget.module.label,
      preferBelow: false,
      verticalOffset: 0,
      margin: const EdgeInsets.only(left: 70),
      child: item,
    );
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
        color: AppColors.magenta,
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
    final avatar = Stack(clipBehavior: Clip.none, children: [
      CircleAvatar(
        radius: 21,
        backgroundColor: AppColors.brand,
        child: Text(s.initial,
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      Positioned(
        right: -1,
        bottom: -1,
        child: Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: AppColors.online,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.sidebar, width: 2),
          ),
        ),
      ),
    ]);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x22FFFFFF))),
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
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(s.role,
                      style: const TextStyle(color: Color(0xBBFFFFFF), fontSize: 12)),
                ]),
              ),
              const Icon(Icons.more_vert_rounded, color: Color(0xBBFFFFFF), size: 20),
            ])
          : Center(child: Tooltip(message: '${s.name} · ${s.role}', child: avatar)),
    );
  }
}
