import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';

  static String? get serverClientId => dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
}
