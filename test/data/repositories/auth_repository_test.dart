import 'package:dartz/dartz.dart';
import 'package:flutter_boilerplate/core/common/exceptions.dart';
import 'package:flutter_boilerplate/core/common/failures.dart';
import 'package:flutter_boilerplate/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late AuthRepository repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepository(
      mockRemoteDataSource,
      mockLocalDataSource,
    );
  });

  final tAccessToken = tTokenModel.accessToken;
  final tRefreshToken = tTokenModel.refreshToken;

  group('getLoggedUser', () {
    test(
        'should return current logged user when the call to data source is successful',
        () async {
      // Arrange
      when(mockLocalDataSource.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(mockLocalDataSource.getUserSession())
          .thenAnswer((_) async => tUserModel);
      when(mockLocalDataSource.isTokenExpired()).thenAnswer((_) async => false);
      // Act
      final result = await repository.getLoggedUser();
      // Assert
      expect(result, Right(tUserModel));
    });

    test(
        'should refresh token and get new user data from remote when access token is expired',
        () async {
      // Arrange
      when(mockLocalDataSource.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(mockLocalDataSource.getUserSession())
          .thenAnswer((_) async => tUserModel);
      when(mockLocalDataSource.isTokenExpired()).thenAnswer((_) async => true);
      when(mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => tRefreshToken);
      when(mockRemoteDataSource.refreshToken(tRefreshToken))
          .thenAnswer((_) async => tTokenModel);
      when(mockLocalDataSource.setToken(tTokenModel))
          .thenAnswer((_) async => true);
      when(mockRemoteDataSource.getLoggedUser())
          .thenAnswer((_) async => tUserModel);
      when(mockLocalDataSource.setUserSession(tUserModel))
          .thenAnswer((_) async => true);
      // Act
      final result = await repository.getLoggedUser();
      // Assert
      expect(result, Right(tUserModel));
    });

    test(
        'should return server failure and clear session when access token not saved in local',
        () async {
      // Arrange
      when(mockLocalDataSource.getAccessToken()).thenAnswer((_) async => null);
      when(mockLocalDataSource.clearSession()).thenAnswer((_) async => true);
      // Act
      final result = await repository.getLoggedUser();
      // Assert
      expect(result, Left(AuthFailure()));
    });

    test(
        'should return server failure and clear session when refresh token not saved in local',
        () async {
      // Arrange
      when(mockLocalDataSource.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(mockLocalDataSource.getUserSession())
          .thenAnswer((_) async => tUserModel);
      when(mockLocalDataSource.isTokenExpired()).thenAnswer((_) async => true);
      when(mockLocalDataSource.getRefreshToken()).thenAnswer((_) async => null);
      when(mockLocalDataSource.clearSession()).thenAnswer((_) async => true);
      // Act
      final result = await repository.getLoggedUser();
      // Assert
      expect(result, Left(AuthFailure()));
    });

    test(
        'should return server failure and clear session when failed refresh token',
        () async {
      // Arrange
      when(mockLocalDataSource.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(mockLocalDataSource.getUserSession())
          .thenAnswer((_) async => tUserModel);
      when(mockLocalDataSource.isTokenExpired()).thenAnswer((_) async => true);
      when(mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => tRefreshToken);
      when(mockRemoteDataSource.refreshToken(tRefreshToken))
          .thenThrow(ApiException(
        statusCode: 400,
        error: tBaseErrorResponse,
      ));
      when(mockLocalDataSource.clearSession()).thenAnswer((_) async => true);
      // Act
      final result = await repository.getLoggedUser();
      // Assert
      expect(result, Left(AuthFailure()));
    });

    test(
        'should return server failure and clear session when failed get user data from remote',
        () async {
      // Arrange
      when(mockLocalDataSource.getAccessToken())
          .thenAnswer((_) async => tAccessToken);
      when(mockLocalDataSource.getUserSession())
          .thenAnswer((_) async => tUserModel);
      when(mockLocalDataSource.isTokenExpired()).thenAnswer((_) async => true);
      when(mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => tRefreshToken);
      when(mockRemoteDataSource.refreshToken(tRefreshToken))
          .thenAnswer((_) async => tTokenModel);
      when(mockLocalDataSource.setToken(tTokenModel))
          .thenAnswer((_) async => true);
      when(mockRemoteDataSource.getLoggedUser()).thenThrow(ApiException(
        statusCode: 400,
        error: tBaseErrorResponse,
      ));
      when(mockLocalDataSource.clearSession()).thenAnswer((_) async => true);
      // Act
      final result = await repository.getLoggedUser();
      // Assert
      expect(result, Left(AuthFailure()));
    });
  });

  group('login', () {
    final tUsername = tUserPayload.username;
    final tPassword = tUserPayload.password;

    test(
        'should return logged user and save token to local when login successfully',
        () async {
      // Arrange
      when(mockRemoteDataSource.login(tUsername, tPassword))
          .thenAnswer((_) async => tTokenModel);
      when(mockLocalDataSource.setToken(tTokenModel))
          .thenAnswer((_) async => true);
      // Act
      final result = await repository.login(tUsername!, tPassword!);
      // Assert
      expect(result, Right(tTokenModel));
    });

    test('should return server failure when login unsuccessfully', () async {
      // Arrange
      when(mockRemoteDataSource.login(tUsername, tPassword))
          .thenThrow(ApiException(
        statusCode: 401,
        error: tBaseErrorResponse,
      ));
      // Act
      final result = await repository.login(tUsername!, tPassword!);
      // Assert
      expect(result, Left(ServerFailure(tBaseErrorResponse)));
    });
  });

  group('logout', () {
    test('should return true and clear session when logout successfully',
        () async {
      // Arrange
      when(mockLocalDataSource.clearSession()).thenAnswer((_) async => true);
      // Act
      final result = await repository.logout();
      // Assert
      expect(result, true);
    });

    test('should return false when logout unsuccessfully', () async {
      // Arrange
      when(mockLocalDataSource.clearSession()).thenAnswer((_) async => false);
      // Act
      final result = await repository.logout();
      // Assert
      expect(result, false);
    });
  });
}
