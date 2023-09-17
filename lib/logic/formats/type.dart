abstract class Format {
  abstract String name;
  abstract String ext;
  abstract bool rich;
  abstract bool code;

  String get prettyName => '$name (.$ext)';
}
