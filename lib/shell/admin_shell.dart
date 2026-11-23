import 'package:material_ui/material_ui.dart';

import '../core/breakpoints.dart';
import '../theme/app_colors.dart';
import 'side_nav.dart';

/// Responsive frame: full side nav on desktop, icon rail on tablet,
/// top bar with a slide-out menu on phone.
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

    if (size == ScreenSize.phone) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          width: 280,
          backgroundColor: AppColors.sidebar,
          shape: const RoundedRectangleBorder(),
          child: SideNav(
            location: widget.location,
            expanded: true,
            onNavigate: () => _scaffoldKey.currentState?.closeDrawer(),
          ),
        ),
        body: Column(children: [
          _PhoneTopBar(onMenu: () => _scaffoldKey.currentState?.openDrawer()),
          Expanded(child: widget.child),
        ]),
      );
    }

    return Scaffold(
      body: Row(children: [
        SideNav(location: widget.location, expanded: size == ScreenSize.desktop),
        Expanded(child: widget.child),
      ]),
    );
  }
}

class _PhoneTopBar extends StatelessWidget {
  const _PhoneTopBar({required this.onMenu});
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebar,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(children: [
            IconButton(
              tooltip: 'Menu',
              onPressed: onMenu,
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
            ),
            Image.asset('assets/images/logo.png', width: 28, height: 31),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [Colors.white, AppColors.brand, AppColors.magenta],
                stops: [0, 0.55, 1],
              ).createShader(r),
              child: const Text('SchatzApp',
                  style: TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () {},
              icon: const Badge(
                label: Text('12'),
                backgroundColor: AppColors.magenta,
                child: Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ),
            const SizedBox(width: 6),
          ]),
        ),
      ),
    );
  }
}
