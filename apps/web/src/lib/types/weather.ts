export type WeatherCondition =
  | "sunny"
  | "partlyCloudy"
  | "cloudy"
  | "lightRain"
  | "rain"
  | "thunderstorm"
  | "snow";

export interface WeatherForecast {
  temperature: number;
  condition: WeatherCondition;
  rainProbability: number;
  windSpeed: number;
  feelsLike?: number;
  humidityPercent: number;
}

const conditionLabels: Record<WeatherCondition, string> = {
  sunny: "Ensoleillé",
  partlyCloudy: "Partiellement nuageux",
  cloudy: "Nuageux",
  lightRain: "Pluie légère",
  rain: "Pluie",
  thunderstorm: "Orage",
  snow: "Neige",
};

const conditionEmojis: Record<WeatherCondition, string> = {
  sunny: "☀️",
  partlyCloudy: "⛅",
  cloudy: "☁️",
  lightRain: "🌦️",
  rain: "🌧️",
  thunderstorm: "⛈️",
  snow: "🌨️",
};

export function getConditionLabel(condition: WeatherCondition): string {
  return conditionLabels[condition];
}

export function getConditionEmoji(condition: WeatherCondition): string {
  return conditionEmojis[condition];
}

export function isGoodForRun(forecast: WeatherForecast): boolean {
  return (
    forecast.rainProbability < 40 &&
    forecast.condition !== "thunderstorm" &&
    forecast.condition !== "snow"
  );
}
