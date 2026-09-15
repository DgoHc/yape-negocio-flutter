enum Environment { dev, qa, prod }

class EnvConfig {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'prod');

  static Environment get environment {
    switch (env) {
      case 'prod':
        return Environment.prod;
      case 'qa':
        return Environment.qa;
      default:
        return Environment.dev;
    }
  }

  static String get baseUrl {
    // Forzamos HTTPS de producción para evitar bloqueos de Android en Release
    return 'https://api.novabytexrj.com/api';
  }

  static int get connectTimeout => 60000; // 60 seconds
  static int get receiveTimeout => 60000; // 60 seconds

  static bool get isDebug => environment != Environment.prod;
}
