import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:chargenet_desktop/router/routes.dart';
import 'package:chargenet_desktop/shell/header.dart';
import 'package:chargenet_desktop/shell/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Admin layout — fixed sidebar + header + scrollable content (D0).
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final title = adminTitleForPath(path);

    return Scaffold(
      backgroundColor: ChargeNetColors.background,
      body: Row(
        children: [
          AdminSidebar(currentPath: path),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminHeader(title: title),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(ChargeNetSpacing.xl),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: ChargeNetSpacing.desktopMinContentWidth,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
