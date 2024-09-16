import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/common/app_constants.dart';
import 'package:flutter_boilerplate/core/common/interceptors.dart';
import 'package:flutter_boilerplate/core/common/network_info.dart';
import 'package:flutter_boilerplate/core/common/token_manager.dart';
import 'package:flutter_boilerplate/core/services/api_service.dart';
import 'package:flutter_boilerplate/data/data_sources/local/auth_local_data_source.dart';
import 'package:flutter_boilerplate/data/data_sources/local/db/users_db.dart';
import 'package:flutter_boilerplate/data/data_sources/local/user_local_data_source.dart';
import 'package:flutter_boilerplate/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:flutter_boilerplate/data/data_sources/remote/user_remote_data_source.dart';
import 'package:flutter_boilerplate/data/models/user_type.dart';
import 'package:flutter_boilerplate/data/repositories/auth_repository.dart';
import 'package:flutter_boilerplate/data/repositories/user_repository.dart';
import 'package:flutter_boilerplate/presentation/controllers/auth_controller.dart';
import 'package:flutter_boilerplate/presentation/controllers/connectivity_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Externals
    Get.lazyPut<Dio>(() => Dio());
    Get.lazyPut<AndroidOptions>(
        () => const AndroidOptions(encryptedSharedPreferences: true));
    Get.lazyPut<FlutterSecureStorage>(
        () => FlutterSecureStorage(aOptions: Get.find()));
    Get.lazyPut<Connectivity>(() => Connectivity());
    Get.lazyPut<ImagePicker>(() => ImagePicker());
    Get.lazyPut<DeviceInfoPlugin>(() => DeviceInfoPlugin());

    // Helpers
    Get.lazyPut<NetworkInfo>(() => NetworkInfo(Get.find()));
    Get.lazyPut<ApiService>(() => ApiService(Get.find()));
    Get.lazyPut<HeaderInterceptor>(() => HeaderInterceptor(Get.find()));
    Get.lazyPut<TokenManager>(() => TokenManager());

    // Boxes
    Get.lazyPut<Box<UserType>>(() => Hive.box(AppConstants.boxNames.users));

    // Databases
    Get.lazyPut<UsersDb>(() => UsersDb(Get.find()));

    // Data Sources
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSource(Get.find()));
    Get.lazyPut<AuthLocalDataSource>(
        () => AuthLocalDataSource(Get.find(), Get.find()));
    Get.lazyPut<UserRemoteDataSource>(() => UserRemoteDataSource(Get.find()));
    Get.lazyPut<UserLocalDataSource>(() => UserLocalDataSource(Get.find()));

    // Repositories
    Get.put<AuthRepository>(AuthRepository(Get.find(), Get.find()));
    Get.put<UserRepository>(UserRepository(Get.find(), Get.find()));

    // Controllers
    Get.put<AuthController>(AuthController(Get.find()));
    Get.put<ConnectivityController>(ConnectivityController(Get.find()));
  }
}
