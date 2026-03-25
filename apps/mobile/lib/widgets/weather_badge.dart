import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaiiak/models/weather_forecast.dart';
import 'package:kaiiak/theme/app_theme.dart';

/// Compact weather badge for event cards.
class WeatherBadge extends StatelessWidget {
  const WeatherBadge({super.key, required this.forecast, this.compact = false});
  final WeatherForecast forecast;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: forecast.isGoodForRun
            ? AppTheme.teal.withValues(alpha: 0.15)
            : AppTheme.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(forecast.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '${forecast.temperature.round()}°',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    final isGood = forecast.isGoodForRun;
    final tipColor = isGood ? AppTheme.teal : AppTheme.warning;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tipColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(forecast.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${forecast.temperature.round()}°C · ${forecast.conditionLabel}',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '💧 ${forecast.rainProbability}%  ·  💨 ${forecast.windSpeed.round()} km/h'
                      '${forecast.feelsLike != null ? "  ·  🌡️ Ressenti ${forecast.feelsLike!.round()}°" : ""}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isGood)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '⚠️ Incertain',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warning,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: tipColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              forecast.weatherTip,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: AppTheme.textColor(context),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
