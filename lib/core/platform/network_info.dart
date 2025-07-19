
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Интерфейс для проверки наличия интернет-соединения
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Реализация проверки подключения к интернету
/// Использует библиотеку `internet_connection_checker`
class NetworkInfoImp implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImp(this.connectionChecker);

  @override
  Future<bool> get isConnected async => connectionChecker.hasConnection;
}
