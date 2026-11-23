import 'package:material_ui/material_ui.dart';

import '../core/breakpoints.dart';
import '../core/modules.dart';
import '../core/session.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar.dart';
import 'side_nav.dart';

/// Responsive frame: full side nav on desktop, icon rail on tablet,
/// slide-out menu on phone. The top bar shows the current module's title.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final size = Breakpoints.of(context);
    final module = moduleFor(widget.location);
    final content = Column(children: [
      TopBar(
        module: module,
        size: size,
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      Expanded(child: widget.child),
    ]);

    if (size == ScreenSize.phone) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          width: 260,
          backgroundColor: AppColors.sidebar,
          shape: const RoundedRectangleBorder(),
          child: SideNav(
            location: widget.location,
            expanded: true,
            onNavigate: () => _scaffoldKey.currentState?.closeDrawer(),
          ),
        ),
        body: content,
      );
    }

    return Scaffold(
      body: Row(children: [
        SideNav(location: widget.location, expanded: size == ScreenSize.desktop),
        Expanded(child: content),
      ]),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.module,
    required this.size,
    required this.onMenu,
  });

  final AdminModule module;
  final ScreenSize size;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final s = AdminSession.instance;
    final phone = size == ScreenSize.phone;
    final desktop = size == ScreenSize.desktop;
    final isDashboard = module.id == 'dashboard';
    final title = isDashboard ? 'Welcome back, ${s.name}' : module.label;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(phone ? 6 : 28, phone ? 8 : 16, phone ? 10 : 28,
              phone ? 8 : 16),
          child: Row(children: [
            if (phone)
              IconButton(
                tooltip: 'Menu',
                onPressed: onMenu,
                icon: const Icon(Icons.menu_rounded, color: AppColors.text),
              ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isDashboard && phone ? 'Dashboard' : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: phone ? 18 : 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3)),
                if (!phone) ...[
                  const SizedBox(height: 4),
                  Text(module.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5, color: AppColors.textSecondary)),
                ],
              ]),
            ),
            const SizedBox(width: 16),
            if (!phone) _SearchField(width: desktop ? 320 : 220),
            if (phone)
              IconButton(
                tooltip: 'Search',
                onPressed: () {},
                icon: const Icon(Icons.search_rounded, color: AppColors.text),
              ),
            SizedBox(width: phone ? 2 : 16),
            const _BellButton(count: 12),
            if (!phone) ...[
              const SizedBox(width: 18),
              Avatar(name: s.name, size: 40),
              if (desktop) ...[
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 1),
                  Text(s.role,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary),
              ],
            ],
          ]),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 42,
      child: TextField(
        style: const TextStyle(fontSize: 13.5),
        decoration: InputDecoration(
          hintText: 'Search anything...',
          hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: AppColors.textSecondary),
          suffixIcon: SizedBox(
            width: 50,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Ctrl K',
                    style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.brand, width: 1.3),
          ),
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Notifications',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {},
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(clipBehavior: Clip.none, children: [
            const Center(
              child: Icon(Icons.notifications_none_rounded,
                  size: 21, color: AppColors.text),
            ),
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                width: 19,
                height: 19,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text('$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
