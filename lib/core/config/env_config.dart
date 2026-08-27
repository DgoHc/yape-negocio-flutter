enum Environment { dev, qa, prod }

class EnvConfig {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

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
    switch (environment) {
      case Environment.prod:
        return 'https://api.novabytexrj.com/api';
      case Environment.qa:
        return 'https://qa-api.yape.pe/v1';
      case Environment.dev:
        return 'http://192.168.100.6:3000/api';
    }
  }

  static int get connectTimeout => 30000; // 30 seconds
  static int get receiveTimeout => 30000; // 30 seconds

  static bool get isDebug => environment != Environment.prod;
}
