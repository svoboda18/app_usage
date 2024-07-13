import 'package:installed_apps/app_info.dart';

class ExtendedAppInfo extends AppInfo {
  final bool isSystemApp;

  ExtendedAppInfo(
    super.name,
    super.icon,
    super.packageName,
    super.versionName,
    super.versionCode,
    { this.isSystemApp = false }
  );
} 