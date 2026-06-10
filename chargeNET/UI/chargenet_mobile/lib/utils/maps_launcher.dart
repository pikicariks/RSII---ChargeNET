import 'package:url_launcher/url_launcher.dart';

/// Opens Google Maps directions to [lat],[lng] (M-navigate-tbd — option A).
Future<bool> openMapsNavigation({
  required double lat,
  required double lng,
}) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
  );
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  return false;
}
