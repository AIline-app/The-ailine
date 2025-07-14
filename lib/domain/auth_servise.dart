
import '../core/api/api_client.dart';

class AuthServise {
  final ApiClient apiClient;
  AuthServise({required this.apiClient});

  Future<bool> login(int phone, String password, String name) async {
    if(password.isEmpty) {
      throw Exception('Пароль не может быть пустым');
    }
    if(phone.toString().isEmpty) {
      throw Exception('Телефон не может быть пустым');
    }
    if(name.isEmpty) {
      throw Exception('Имя не может быть пустым');
    }
    return true;
  }
}

