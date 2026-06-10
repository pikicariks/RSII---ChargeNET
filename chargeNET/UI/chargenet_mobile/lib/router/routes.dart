/// Mobile app route paths.
abstract final class MobileRoutes {
  static const map = '/';
  static const history = '/history';
  static const profile = '/profile';

  static String stationDetail(int id) => '/stations/$id';
  static String stationReserve(int id) => '/stations/$id/reserve';
}
