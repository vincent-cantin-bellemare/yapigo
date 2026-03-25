enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  lightRain,
  rain,
  thunderstorm,
  snow,
}

class WeatherForecast {
  final double temperature;
  final WeatherCondition condition;
  final int rainProbability;
  final double windSpeed;
  /// Perceived temperature accounting for wind chill / humidex.
  final double? feelsLike;
  final int humidityPercent;

  const WeatherForecast({
    required this.temperature,
    required this.condition,
    required this.rainProbability,
    this.windSpeed = 0,
    this.feelsLike,
    this.humidityPercent = 50,
  });

  double get _effective => feelsLike ?? temperature;

  String get conditionLabel => switch (condition) {
        WeatherCondition.sunny => 'Ensoleillé',
        WeatherCondition.partlyCloudy => 'Partiellement nuageux',
        WeatherCondition.cloudy => 'Nuageux',
        WeatherCondition.lightRain => 'Pluie légère',
        WeatherCondition.rain => 'Pluie',
        WeatherCondition.thunderstorm => 'Orage',
        WeatherCondition.snow => 'Neige',
      };

  String get emoji => switch (condition) {
        WeatherCondition.sunny => '☀️',
        WeatherCondition.partlyCloudy => '⛅',
        WeatherCondition.cloudy => '☁️',
        WeatherCondition.lightRain => '🌦️',
        WeatherCondition.rain => '🌧️',
        WeatherCondition.thunderstorm => '⛈️',
        WeatherCondition.snow => '🌨️',
      };

  bool get isGoodForRun =>
      rainProbability < 40 &&
      condition != WeatherCondition.thunderstorm &&
      condition != WeatherCondition.snow;

  /// Context-aware, humorous weather tip for runners.
  String get weatherTip {
    if (condition == WeatherCondition.thunderstorm) {
      return '⚡ Orage prévu! Si tu vois un éclair, c\'est pas un signe de Dieu que t\'es rapide. Reste prudent!';
    }
    if (condition == WeatherCondition.snow) {
      return '🧤 Neige annoncée! Habille-toi en pelures d\'oignon… et cours comme si t\'avais oublié ton char en double.';
    }
    if (_effective >= 30) {
      return '🥵 Il fait CHAUD! Amène ta gourde et tes électrolytes, sinon on va te faire le bouche-à-bouche plus vite que prévu.';
    }
    if (_effective >= 25) {
      return '💧 Beau temps mais ça chauffe! Hydrate-toi AVANT de partir. Ta gourde, c\'est ta meilleure date ce soir.';
    }
    if (_effective <= -10) {
      return '🥶 Frette en titi! Cache-oreilles, mitaines, pis un bon buff. Si tes cils gèlent, c\'est normal ici.';
    }
    if (_effective <= 0) {
      return '❄️ Sous zéro! Couvre tes extrémités, pis pense à des couches. Non, pas les couches de bébé… les couches de linge.';
    }
    if (_effective <= 8) {
      return '🧣 Un peu frisquet! Un bon chandail long pis des gants légers — tu vas te réchauffer en deux minutes.';
    }
    if (condition == WeatherCondition.rain || rainProbability >= 60) {
      return '🌧️ Pluie au menu! Casquette imperméable pis des souliers qui grippent. Tu vas briller… littéralement.';
    }
    if (condition == WeatherCondition.lightRain || rainProbability >= 40) {
      return '🌦️ Risque de crachin! Une p\'tite veste légère au cas où. Rien de dramatique, t\'es pas en sucre!';
    }
    if (windSpeed >= 30) {
      return '💨 Vent de fou! Attache ta tuque, pis cours face au vent à l\'aller — le retour sera ta récompense.';
    }
    if (windSpeed >= 20) {
      return '🍃 C\'est venteux! Bon côté: tu vas avoir l\'air dramatique en courant. Mauvais côté: ta casquette va lever.';
    }
    if (humidityPercent >= 80 && _effective >= 20) {
      return '😓 Humide en ta! Ça va coller. Amène un bandeau, pis accepte que tu vas avoir l\'air d\'un nageur olympique.';
    }
    if (condition == WeatherCondition.sunny && _effective >= 18) {
      return '😎 Météo parfaite! Crème solaire, lunettes, pis ta plus belle attitude — on court pour le fun!';
    }
    return '👍 Conditions correctes! Habille-toi selon ton confort pis profite de ta run. On se voit à l\'Apéro!';
  }

  /// Shorter one-liner for event cards.
  String get weatherTipShort {
    if (condition == WeatherCondition.thunderstorm) return '⚡ Orage — reste prudent!';
    if (condition == WeatherCondition.snow) return '🧤 Neige — habille-toi chaudement!';
    if (_effective >= 30) return '🥵 Chaud! Gourde + électrolytes obligatoires';
    if (_effective >= 25) return '💧 Beau mais chaud — hydrate-toi bien!';
    if (_effective <= -10) return '🥶 Frette en titi! Couvre-toi ben comme faut';
    if (_effective <= 0) return '❄️ Sous zéro — couches multiples recommandées';
    if (_effective <= 8) return '🧣 Frisquet — chandail long + gants légers';
    if (condition == WeatherCondition.rain || rainProbability >= 60) return '🌧️ Pluie — casquette + souliers qui grippent';
    if (condition == WeatherCondition.lightRain || rainProbability >= 40) return '🌦️ Crachin possible — p\'tite veste au cas';
    if (windSpeed >= 25) return '💨 Venteux — attache ta tuque!';
    if (humidityPercent >= 80 && _effective >= 20) return '😓 Humide — bandeau recommandé';
    if (condition == WeatherCondition.sunny) return '😎 Météo parfaite — crème solaire + sourire';
    return '👍 Beau temps pour courir!';
  }
}
