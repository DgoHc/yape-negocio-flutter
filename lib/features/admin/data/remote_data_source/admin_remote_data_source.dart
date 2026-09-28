import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/storage/secure/token_manager.dart';

abstract class AdminRemoteDataSource {
  Future<List<Map<String, dynamic>>> getDevices();
  Future<void> updateDevice(String id, {bool? isApproved, String? status, String? alias});
  Future<void> deleteDevice(String id);
  Future<void> adminRegisterDevice(String uuid, String alias, String? phoneNumber);
  Future<List<Map<String, dynamic>>> getUsers();
  Future<void> createUser(String username, String pin, String role);
  Future<void> updateUser(String id, {String? role, String? status});
  Future<void> deleteUser(String id);
  Future<List<Map<String, dynamic>>> getAppUsers();
  Future<void> updateAppUserSubscription(String id, bool isSubscribed, {int? days});
  Future<void> createAppUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessType,
    bool isSubscribed = true,
  });
  Future<void> updateAppUser(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? businessType,
    bool? isSubscribed,
    String? subscriptionPlan,
  });
  Future<void> deleteAppUser(String id);
}

@Injectable(as: AdminRemoteDataSource)
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio _dio;
  final TokenManager _tokenManager;

  AdminRemoteDataSourceImpl(this._dio, this._tokenManager);

  Future<Options> _getOptions() async {
    final token = await _tokenManager.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await _dio.get('/admin/devices', options: await _getOptions());
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<void> updateDevice(String id, {bool? isApproved, String? status, String? alias}) async {
    await _dio.patch(
      '/admin/devices/$id',
      data: {
        if (isApproved != null) 'isApproved': isApproved,
        if (status != null) 'status': status,
        if (alias != null) 'alias': alias,
      },
      options: await _getOptions(),
    );
  }

  @override
  Future<void> deleteDevice(String id) async {
    await _dio.delete('/admin/devices/$id', options: await _getOptions());
  }

  @override
  Future<void> adminRegisterDevice(String uuid, String alias, String? phoneNumber) async {
    await _dio.post(
      '/admin/devices',
      data: {
        'uuid': uuid,
        'alias': alias,
        'phoneNumber': phoneNumber,
      },
      options: await _getOptions(),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await _dio.get('/admin/users', options: await _getOptions());
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<void> createUser(String username, String pin, String role) async {
    await _dio.post(
      '/admin/users',
      data: {'username': username, 'pin': pin, 'role': role},
      options: await _getOptions(),
    );
  }

  @override
  Future<void> updateUser(String id, {String? role, String? status}) async {
    await _dio.patch(
      '/admin/users/$id',
      data: {
        if (role != null) 'role': role,
        if (status != null) 'status': status,
      },
      options: await _getOptions(),
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    await _dio.delete('/admin/users/$id', options: await _getOptions());
  }

  @override
  Future<List<Map<String, dynamic>>> getAppUsers() async {
    final response = await _dio.get('/admin/app-users', options: await _getOptions());
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<void> updateAppUserSubscription(String id, bool isSubscribed, {int? days}) async {
    await _dio.patch(
      '/admin/app-users/$id/subscription',
      data: {
        'isSubscribed': isSubscribed,
        if (days != null) 'days': days,
      },
      options: await _getOptions(),
    );
  }

  @override
  Future<void> createAppUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessType,
    bool isSubscribed = true,
  }) async {
    await _dio.post(
      '/admin/app-users',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'businessType': businessType,
        'isSubscribed': isSubscribed,
      },
      options: await _getOptions(),
    );
  }

  @override
  Future<void> updateAppUser(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? businessType,
    bool? isSubscribed,
    String? subscriptionPlan,
  }) async {
    await _dio.patch(
      '/admin/app-users/$id',
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (businessType != null) 'businessType': businessType,
        if (isSubscribed != null) 'isSubscribed': isSubscribed,
        if (subscriptionPlan != null) 'subscriptionPlan': subscriptionPlan,
      },
      options: await _getOptions(),
    );
  }

  @override
  Future<void> deleteAppUser(String id) async {
    await _dio.delete('/admin/app-users/$id', options: await _getOptions());
  }
}
