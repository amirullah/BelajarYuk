import 'package:flutter/widgets.dart';

/// Observer rute global agar layar bisa menyegarkan diri saat kembali terlihat
/// (mis. peta level memuat ulang bintang & level terbuka setelah selesai main).
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();
