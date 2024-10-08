import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/presentation/widgets/app_skeletonizer.dart';
import 'package:flutter_boilerplate/presentation/widgets/app_state.dart';
import 'package:flutter_boilerplate/core/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controllers/home/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Get.toNamed(AppRoutes.CREATE_USER);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: controller.obx(
          onLoading: AppSkeletonizer(
            enabled: true,
            child: ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, __) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    dense: true,
                    title: Text(BoneMock.fullName),
                    subtitle: Text(BoneMock.fullName),
                  ),
                );
              },
            ),
          ),
          onEmpty: AppState(
            onRefresh: controller.getUsers,
            child: const Text("There is no Users yet."),
          ),
          onError: (error) {
            return AppState(
              onRefresh: controller.getUsers,
              child: Text(error ?? ""),
            );
          },
          (users) {
            return RefreshIndicator.adaptive(
              onRefresh: () async {
                controller.getUsers();
              },
              child: ListView.separated(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.all(16),
                itemCount: users?.length ?? 0,
                separatorBuilder: (_, __) {
                  return const SizedBox(height: 16);
                },
                itemBuilder: (context, index) {
                  final user = users?[index];
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      onTap: () {
                        Get.toNamed(AppRoutes.USER, arguments: user?.id);
                      },
                      dense: true,
                      title: Text(
                        "${user?.firstName} ${user?.lastName}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        user?.username ?? "",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
