import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://06f5-14-97-183-132.ngrok-free.app';

  static String? get serverClientId => dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
}
