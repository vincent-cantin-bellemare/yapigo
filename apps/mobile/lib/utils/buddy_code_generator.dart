import 'dart:math';

const _animals = [
  'KAYAKO', 'RENARD', 'TORTUE', 'CANARD', 'CHEVREUIL',
  'HIBOU', 'LOUP', 'AIGLE', 'PANDA', 'KOALA',
  'TIGRE', 'OURS', 'FAUCON', 'LYNX', 'ORIGNAL',
  'CASTOR', 'HUSKY', 'COLIBRI', 'PINGOUIN', 'DAUPHIN',
  'TOUCAN', 'GECKO', 'JAGUAR', 'PHOQUE', 'RATON',
  'COYOTE', 'FURET', 'BISON', 'GAZELLE', 'CARIBOU',
];

const _words = [
  'QUEEN', 'DISCO', 'ROCKET', 'NINJA', 'TURBO',
  'COSMIC', 'FLASH', 'ZEN', 'ROYAL', 'REBEL',
  'WONDER', 'POWER', 'SONIC', 'PIXEL', 'SPARK',
  'LEGEND', 'GROOVE', 'FUNKY', 'STELLAR', 'MAGIC',
  'BLAZE', 'THUNDER', 'FROST', 'NEON', 'PRESTO',
  'VELVET', 'SAFARI', 'TEMPO', 'BOOST', 'VORTEX',
];

String generateBuddyCode({Set<String>? existingCodes}) {
  final random = Random();
  String code;
  int attempts = 0;
  do {
    final animal = _animals[random.nextInt(_animals.length)];
    final word = _words[random.nextInt(_words.length)];
    code = '$animal-$word';
    attempts++;
  } while (existingCodes != null && existingCodes.contains(code) && attempts < 100);
  return code;
}
