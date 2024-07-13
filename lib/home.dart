import 'package:apps_list/apps_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppsContoller appsContoller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text(
                'Apps usage',
                style: TextStyle(fontSize: 24),
              ),
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: appsContoller.onSortChanged,
                ),
                PopupMenuButton<Duration>(
                  onSelected: (value) {
                    appsContoller.interval.value = value;
                    appsContoller.getAppsUsage();
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: Duration(hours: 1),
                      child: Text('Last Hour'),
                    ),
                    const PopupMenuItem(
                      value: Duration(days: 1),
                      child: Text('Last Day'),
                    ),
                    const PopupMenuItem(
                      value: Duration(days: 7),
                      child: Text('Last Week'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Show System'),
                      const SizedBox(
                        width: 14,
                      ),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: Obx(
                          () => Switch(
                            value: appsContoller.withSystemApps.value,
                            onChanged: (value) {
                              appsContoller.withSystemApps.value = value;
                              appsContoller.onShowSystemChanged();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SliverPadding(
              padding: EdgeInsets.all(8.0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Filtred Apps Usage',
                  style: TextStyle(fontSize: 26),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(
                () {
                  if (appsContoller.uiUsage.isEmpty) {
                    return Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  }

                  return Column(
                    children: [
                      ...appsContoller.uiUsage.map((e) {
                        final app = appsContoller.uiApps.firstWhereOrNull(
                          (a) => a.packageName == e.packageName,
                        );

                        if (app == null) return const SizedBox.shrink();

                        return ListTile(
                          leading: app.icon != null
                              ? Image.memory(app.icon!)
                              : const Icon(Icons.network_wifi_rounded),
                          title: Text(app.name!),
                          subtitle: Text(
                            '${app.packageName}\n'
                            'App used for about ${e.usage.inMinutes} minutes',
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.all(8.0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'All Apps',
                  style: TextStyle(fontSize: 26),
                ),
              ),
            ),
            Obx(() {
              if (appsContoller.uiApps.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading:
                            Image.memory(appsContoller.uiApps[index].icon!),
                        title: Text(appsContoller.uiApps[index].name!),
                        subtitle: Text(
                          appsContoller.uiApps[index].packageName!,
                        ),
                      ),
                    );
                  },
                  childCount: appsContoller.uiApps.length,
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
