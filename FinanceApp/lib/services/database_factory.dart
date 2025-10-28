import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/investment.dart';
import '../models/transaction.dart' as model;
import 'database_service.dart';
import 'database_service_web.dart';

/// Factory to get the appropriate database service based on platform
class DatabaseServiceFactory {
  static dynamic createDatabaseService() {
    if (kIsWeb) {
      return DatabaseServiceWeb();
    } else {
      return DatabaseService();
    }
  }
}
