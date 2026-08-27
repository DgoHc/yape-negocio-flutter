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
    final String url;
    switch (environment) {
      case Environment.prod:
        url = 'https://api.novabytexrj.com/api';
        break;
      case Environment.qa:
        url = 'https://qa-api.yape.pe/v1';
        break;
      default:
        url = 'http://104.248.230.19:3000/api';
    }
    // ignore: avoid_print
    print('🚀 SONOPAY_NETWORK: Conectando a $url');
    return url;
  }

  static int get connectTimeout => 60000; // 60 seconds
  static int get receiveTimeout => 60000; // 60 seconds

  static bool get isDebug => environment != Environment.prod;
}
