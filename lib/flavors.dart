enum Flavor { dev, tst, acc, prod }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Edubadges Dev';
      case Flavor.tst:
        return 'Edubadges Tst';
      case Flavor.acc:
        return 'Edubadges Acc';
      case Flavor.prod:
        return 'Edubadges Prod';
    }
  }

  static String get envFileName {
    switch (appFlavor) {
      case Flavor.dev:
        return '.env.dev';
      case Flavor.tst:
        return '.env.tst';
      case Flavor.acc:
        return '.env.acc';
      case Flavor.prod:
        return '.env.prod';
    }
  }
}
