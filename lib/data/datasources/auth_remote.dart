import 'package:gghgggfsfs/core/api/api_client.dart';
import 'package:gghgggfsfs/core/api/api_endpoints.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<bool> login(int phone, String password) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {
        'phone': phone.toString(),
        'password': password,
      },
    );
    return response.data['token'];
    }
  }