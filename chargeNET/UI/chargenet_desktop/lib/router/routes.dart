import 'package:flutter/material.dart';

/// Admin app route paths.
abstract final class AdminRoutes {
  static const dashboard = '/dashboard';
  static const stations = '/stations';
  static const sessions = '/sessions';
  static const reports = '/reports';
  static const tariffs = '/tariffs';
  static const faults = '/faults';
  static const users = '/users';
  static const serviceOrders = '/service-orders';
  static const settings = '/settings';
}

/// Sidebar nav item metadata.
class AdminNavItem {
  const AdminNavItem({
    required this.label,
    required this.path,
    required this.icon,
  });

  final String label;
  final String path;
  final IconData icon;
}

/// Sidebar navigation items (matches Figma Sidebar.tsx order).
const adminNavItems = [
  AdminNavItem(
    label: 'Dashboard',
    path: AdminRoutes.dashboard,
    icon: Icons.dashboard_outlined,
  ),
  AdminNavItem(
    label: 'Stations',
    path: AdminRoutes.stations,
    icon: Icons.ev_station_outlined,
  ),
  AdminNavItem(
    label: 'Sessions',
    path: AdminRoutes.sessions,
    icon: Icons.bolt_outlined,
  ),
  AdminNavItem(
    label: 'Reports',
    path: AdminRoutes.reports,
    icon: Icons.bar_chart_outlined,
  ),
  AdminNavItem(
    label: 'Tariffs',
    path: AdminRoutes.tariffs,
    icon: Icons.payments_outlined,
  ),
  AdminNavItem(
    label: 'Faults',
    path: AdminRoutes.faults,
    icon: Icons.warning_amber_outlined,
  ),
  AdminNavItem(
    label: 'Users',
    path: AdminRoutes.users,
    icon: Icons.group_outlined,
  ),
  AdminNavItem(
    label: 'Service Orders',
    path: AdminRoutes.serviceOrders,
    icon: Icons.build_outlined,
  ),
];

String adminTitleForPath(String path) {
  if (path.startsWith('${AdminRoutes.stations}/')) return 'Station Detail';
  for (final item in adminNavItems) {
    if (item.path == path) return item.label;
  }
  if (path == AdminRoutes.settings) return 'Settings';
  return 'ChargeNET Admin';
}
