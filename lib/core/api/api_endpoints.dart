class ApiEndpoints{
  // Базовый URL
  static const String baseUrl = 'https://api.example.com';


  //Auth
   static const String login = '$baseUrl/auth/login';
   static const String register = '$baseUrl/auth/register';
   static const String logout = '$baseUrl/auth/logout';
   static const String refreshToken = '$baseUrl/auth/refresh-token';

   // Car Wash
   static const String carWashes = '$baseUrl/car-washes';

   //User


}