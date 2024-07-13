import 'package:app_usage/app_usage.dart';
import 'package:apps_list/ext_app_info.dart';
import 'package:get/get.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

enum SortOption {
  mostUsed,
  leastUsed,
}

class AppsContoller extends GetxController {
  late final List<ExtendedAppInfo> apps;
  late final List<AppInfo> _apps;
  late final List<AppInfo> _with_system_apps;

  var uiApps = <ExtendedAppInfo>[].obs;
  var uiUsage = <AppUsageInfo>[].obs;
  var withSystemApps = false.obs;
  var sort = SortOption.mostUsed.obs;
  var interval = const Duration(hours: 1).obs;

  Future<List<AppUsageInfo>> getTodayAppsUsage() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day);
      List<AppUsageInfo> infoList =
          await AppUsage().getAppUsage(startDate, endDate);

      return infoList..sort(((a, b) => b.usage.compareTo(a.usage)));
    } on AppUsageException catch (exception) {
      print(exception);
      return [];
    }
  }

  Future<void> getAppsUsage() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(interval.value);
      uiUsage.value =
          (await AppUsage().getAppUsage(startDate, endDate)).where((e) => uiApps.firstWhereOrNull((a) => e.packageName == a.packageName) != null).toList();
    } on Exception catch (exception) {
      print(exception);
    }
  }

  void onShowSystemChanged() {
    uiApps.value = apps.where((app) {
      if (!withSystemApps.value) {
        return !app.isSystemApp;
      }
      return true;
    }).toList(growable: false);

    print(uiApps);
  }

  void onSortChanged() {
    sort.value == SortOption.mostUsed
        ? uiUsage.sort((a, b) => b.usage.compareTo(a.usage))
        : uiUsage.sort((a, b) => a.usage.compareTo(b.usage));
  }

  @override
  Future<void> onInit() async {
    _with_system_apps = await InstalledApps.getInstalledApps(false, true);
    _apps = await InstalledApps.getInstalledApps(true, true);

    apps = List.from(
      _with_system_apps.map(
        (a) => ExtendedAppInfo(
          a.name,
          a.icon,
          a.packageName,
          a.versionName,
          a.versionCode,
          isSystemApp:
              _apps.firstWhereOrNull((e) => e.packageName == a.packageName) ==
                  null,
        ),
      ),
      growable: false,
    );

    onShowSystemChanged();

    await getAppsUsage();
    onSortChanged();

    _apps.clear();
    _with_system_apps.clear();

    super.onInit();
  }
}
