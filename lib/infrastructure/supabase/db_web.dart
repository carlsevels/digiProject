class MyBackendConnector {
  MyBackendConnector(dynamic db);
}

class AppDatabase {
  static dynamic get db => throw UnsupportedError("PowerSync no está disponible en la Web");
  
  static Future<void> initialize() async {
    print("PowerSync omitido en la Web.");
  }
}