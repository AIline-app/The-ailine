abstract class ApiException implements Exception {
  final String message;

  ApiException(this.message);
}

class NetworkException extends ApiException {
  NetworkException() : super('Нет подключения к сети');
}
class UnauthorizedException  extends ApiException {
  UnauthorizedException () : super('Сессия истекла');
}