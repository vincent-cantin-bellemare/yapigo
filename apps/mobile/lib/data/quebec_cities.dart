import 'dart:math' as math;

class QuebecCity {
  final String name;
  final String region;
  final double lat;
  final double lng;
  const QuebecCity({
    required this.name,
    required this.region,
    required this.lat,
    required this.lng,
  });
}

// Hub cities where Run Date events are currently organized.
const activeCityHubs = <QuebecCity>[
  QuebecCity(name: 'Montréal', region: 'Montréal', lat: 45.5017, lng: -73.5673),
];

const montrealNeighborhoods = [
  'Ahuntsic-Cartierville',
  'Anjou',
  'Côte-des-Neiges–Notre-Dame-de-Grâce',
  'Griffintown',
  'Hochelaga-Maisonneuve',
  'Lachine',
  'LaSalle',
  'Le Plateau-Mont-Royal',
  'Le Sud-Ouest',
  'Mercier–Hochelaga-Maisonneuve',
  'Mile-End',
  'Montréal-Nord',
  'Outremont',
  'Petite-Patrie',
  'Pointe-aux-Trembles',
  'Rivière-des-Prairies',
  'Rosemont',
  'Saint-Henri',
  'Saint-Laurent',
  'Saint-Léonard',
  'Verdun',
  'Vieux-Montréal',
  'Ville-Marie',
  'Villeray',
];

const quebecCities = <QuebecCity>[
  // Montréal metro
  QuebecCity(name: 'Montréal', region: 'Montréal', lat: 45.5017, lng: -73.5673),
  QuebecCity(name: 'Laval', region: 'Laval', lat: 45.6066, lng: -73.7124),
  QuebecCity(name: 'Longueuil', region: 'Montérégie', lat: 45.5312, lng: -73.5185),
  QuebecCity(name: 'Brossard', region: 'Montérégie', lat: 45.4584, lng: -73.4551),
  QuebecCity(name: 'Boucherville', region: 'Montérégie', lat: 45.5909, lng: -73.4370),
  QuebecCity(name: 'Saint-Bruno-de-Montarville', region: 'Montérégie', lat: 45.5335, lng: -73.3486),
  QuebecCity(name: 'Terrebonne', region: 'Lanaudière', lat: 45.6960, lng: -73.6336),
  QuebecCity(name: 'Blainville', region: 'Laurentides', lat: 45.6700, lng: -73.8810),
  QuebecCity(name: 'Repentigny', region: 'Lanaudière', lat: 45.7422, lng: -73.4672),
  QuebecCity(name: 'Châteauguay', region: 'Montérégie', lat: 45.3804, lng: -73.7492),
  QuebecCity(name: 'Saint-Jean-sur-Richelieu', region: 'Montérégie', lat: 45.3071, lng: -73.2624),
  QuebecCity(name: 'Saint-Jérôme', region: 'Laurentides', lat: 45.7802, lng: -74.0043),
  QuebecCity(name: 'Mascouche', region: 'Lanaudière', lat: 45.7474, lng: -73.5996),
  QuebecCity(name: 'Mirabel', region: 'Laurentides', lat: 45.6502, lng: -74.0826),
  QuebecCity(name: 'Sainte-Thérèse', region: 'Laurentides', lat: 45.6396, lng: -73.8512),
  QuebecCity(name: 'Candiac', region: 'Montérégie', lat: 45.3806, lng: -73.5168),
  QuebecCity(name: 'Chambly', region: 'Montérégie', lat: 45.4479, lng: -73.2874),
  QuebecCity(name: 'Varennes', region: 'Montérégie', lat: 45.6832, lng: -73.4380),
  QuebecCity(name: 'Sainte-Julie', region: 'Montérégie', lat: 45.5827, lng: -73.3392),
  QuebecCity(name: 'Beloeil', region: 'Montérégie', lat: 45.5684, lng: -73.2057),
  QuebecCity(name: 'Mont-Saint-Hilaire', region: 'Montérégie', lat: 45.5617, lng: -73.1918),
  QuebecCity(name: 'Dorval', region: 'Montréal', lat: 45.4503, lng: -73.7507),
  QuebecCity(name: 'Pointe-Claire', region: 'Montréal', lat: 45.4488, lng: -73.8168),
  QuebecCity(name: 'Dollard-Des Ormeaux', region: 'Montréal', lat: 45.4940, lng: -73.8242),
  QuebecCity(name: 'Kirkland', region: 'Montréal', lat: 45.4519, lng: -73.8664),
  QuebecCity(name: 'Saint-Eustache', region: 'Laurentides', lat: 45.5650, lng: -73.9054),
  QuebecCity(name: 'Deux-Montagnes', region: 'Laurentides', lat: 45.5340, lng: -73.8870),
  QuebecCity(name: 'Boisbriand', region: 'Laurentides', lat: 45.6121, lng: -73.8379),
  QuebecCity(name: 'Rosemère', region: 'Laurentides', lat: 45.6367, lng: -73.8000),
  QuebecCity(name: 'L\'Assomption', region: 'Lanaudière', lat: 45.8234, lng: -73.4293),
  QuebecCity(name: 'Joliette', region: 'Lanaudière', lat: 46.0234, lng: -73.4518),
  QuebecCity(name: 'Vaudreuil-Dorion', region: 'Montérégie', lat: 45.4010, lng: -74.0328),

  // Capitale-Nationale
  QuebecCity(name: 'Québec', region: 'Capitale-Nationale', lat: 46.8139, lng: -71.2080),
  QuebecCity(name: 'Lévis', region: 'Chaudière-Appalaches', lat: 46.8032, lng: -71.1827),
  QuebecCity(name: 'Beauport', region: 'Capitale-Nationale', lat: 46.8642, lng: -71.1777),
  QuebecCity(name: 'Charlesbourg', region: 'Capitale-Nationale', lat: 46.8631, lng: -71.2473),
  QuebecCity(name: 'Sainte-Foy', region: 'Capitale-Nationale', lat: 46.7714, lng: -71.2928),
  QuebecCity(name: 'Cap-Rouge', region: 'Capitale-Nationale', lat: 46.7560, lng: -71.3542),
  QuebecCity(name: 'L\'Ancienne-Lorette', region: 'Capitale-Nationale', lat: 46.7920, lng: -71.3519),
  QuebecCity(name: 'Saint-Augustin-de-Desmaures', region: 'Capitale-Nationale', lat: 46.7415, lng: -71.4581),
  QuebecCity(name: 'Val-Bélair', region: 'Capitale-Nationale', lat: 46.8711, lng: -71.3951),
  QuebecCity(name: 'Boischatel', region: 'Capitale-Nationale', lat: 46.9014, lng: -71.0845),
  QuebecCity(name: 'Stoneham-et-Tewkesbury', region: 'Capitale-Nationale', lat: 46.9983, lng: -71.3655),

  // Outaouais
  QuebecCity(name: 'Gatineau', region: 'Outaouais', lat: 45.4765, lng: -75.7013),
  QuebecCity(name: 'Chelsea', region: 'Outaouais', lat: 45.5225, lng: -75.7870),
  QuebecCity(name: 'Cantley', region: 'Outaouais', lat: 45.5606, lng: -75.7833),

  // Estrie
  QuebecCity(name: 'Sherbrooke', region: 'Estrie', lat: 45.4042, lng: -71.8929),
  QuebecCity(name: 'Magog', region: 'Estrie', lat: 45.2659, lng: -72.1469),
  QuebecCity(name: 'Granby', region: 'Montérégie', lat: 45.4000, lng: -72.7329),

  // Mauricie / Centre-du-Québec
  QuebecCity(name: 'Trois-Rivières', region: 'Mauricie', lat: 46.3432, lng: -72.5430),
  QuebecCity(name: 'Shawinigan', region: 'Mauricie', lat: 46.5503, lng: -72.7420),
  QuebecCity(name: 'Drummondville', region: 'Centre-du-Québec', lat: 45.8838, lng: -72.4843),
  QuebecCity(name: 'Victoriaville', region: 'Centre-du-Québec', lat: 46.0503, lng: -71.9590),

  // Saguenay / Lac-Saint-Jean
  QuebecCity(name: 'Saguenay', region: 'Saguenay–Lac-Saint-Jean', lat: 48.4269, lng: -71.0686),
  QuebecCity(name: 'Alma', region: 'Saguenay–Lac-Saint-Jean', lat: 48.5499, lng: -71.6525),
  QuebecCity(name: 'Roberval', region: 'Saguenay–Lac-Saint-Jean', lat: 48.5190, lng: -72.2230),

  // Bas-Saint-Laurent / Gaspésie
  QuebecCity(name: 'Rimouski', region: 'Bas-Saint-Laurent', lat: 48.4489, lng: -68.5230),
  QuebecCity(name: 'Rivière-du-Loup', region: 'Bas-Saint-Laurent', lat: 47.8352, lng: -69.5362),
  QuebecCity(name: 'Matane', region: 'Bas-Saint-Laurent', lat: 48.8454, lng: -67.5324),
  QuebecCity(name: 'Gaspé', region: 'Gaspésie–Îles-de-la-Madeleine', lat: 48.8316, lng: -64.4871),

  // Abitibi-Témiscamingue
  QuebecCity(name: 'Rouyn-Noranda', region: 'Abitibi-Témiscamingue', lat: 48.2394, lng: -79.0225),
  QuebecCity(name: 'Val-d\'Or', region: 'Abitibi-Témiscamingue', lat: 48.0976, lng: -77.7969),
  QuebecCity(name: 'Amos', region: 'Abitibi-Témiscamingue', lat: 48.5668, lng: -78.1169),

  // Côte-Nord
  QuebecCity(name: 'Baie-Comeau', region: 'Côte-Nord', lat: 49.2167, lng: -68.1500),
  QuebecCity(name: 'Sept-Îles', region: 'Côte-Nord', lat: 50.2101, lng: -66.3754),

  // Laurentides touristiques
  QuebecCity(name: 'Mont-Tremblant', region: 'Laurentides', lat: 46.2085, lng: -74.5960),
  QuebecCity(name: 'Sainte-Adèle', region: 'Laurentides', lat: 46.0513, lng: -74.1400),
  QuebecCity(name: 'Saint-Sauveur', region: 'Laurentides', lat: 45.9003, lng: -74.1724),
  QuebecCity(name: 'Prévost', region: 'Laurentides', lat: 45.8718, lng: -74.0832),
  QuebecCity(name: 'Morin-Heights', region: 'Laurentides', lat: 45.9005, lng: -74.2575),

  // Chaudière-Appalaches
  QuebecCity(name: 'Saint-Georges', region: 'Chaudière-Appalaches', lat: 46.1174, lng: -70.6650),
  QuebecCity(name: 'Thetford Mines', region: 'Chaudière-Appalaches', lat: 46.0903, lng: -71.3019),
  QuebecCity(name: 'Montmagny', region: 'Chaudière-Appalaches', lat: 46.9800, lng: -70.5554),

  // Montérégie south
  QuebecCity(name: 'Sorel-Tracy', region: 'Montérégie', lat: 46.0393, lng: -73.1211),
  QuebecCity(name: 'Salaberry-de-Valleyfield', region: 'Montérégie', lat: 45.2548, lng: -74.1304),
  QuebecCity(name: 'Saint-Hyacinthe', region: 'Montérégie', lat: 45.6307, lng: -72.9571),

  // Lanaudière
  QuebecCity(name: 'Rawdon', region: 'Lanaudière', lat: 46.0500, lng: -73.7167),
  QuebecCity(name: 'Saint-Lin-Laurentides', region: 'Lanaudière', lat: 45.8559, lng: -73.7675),
  QuebecCity(name: 'Lavaltrie', region: 'Lanaudière', lat: 45.8833, lng: -73.2833),

  // Other notable
  QuebecCity(name: 'Saint-Constant', region: 'Montérégie', lat: 45.3700, lng: -73.5667),
  QuebecCity(name: 'La Prairie', region: 'Montérégie', lat: 45.4169, lng: -73.4978),
  QuebecCity(name: 'Carignan', region: 'Montérégie', lat: 45.4500, lng: -73.3000),
  QuebecCity(name: 'Sainte-Catherine', region: 'Montérégie', lat: 45.4009, lng: -73.5833),
  QuebecCity(name: 'Saint-Lambert', region: 'Montérégie', lat: 45.5000, lng: -73.5058),
  QuebecCity(name: 'Bois-des-Filion', region: 'Laurentides', lat: 45.6667, lng: -73.7500),
  QuebecCity(name: 'Lorraine', region: 'Laurentides', lat: 45.6833, lng: -73.7833),
  QuebecCity(name: 'Sainte-Anne-des-Plaines', region: 'Laurentides', lat: 45.7598, lng: -73.8218),
  QuebecCity(name: 'L\'Île-Perrot', region: 'Montérégie', lat: 45.3833, lng: -73.9500),
  QuebecCity(name: 'Notre-Dame-de-l\'Île-Perrot', region: 'Montérégie', lat: 45.3667, lng: -73.9333),
  QuebecCity(name: 'Cowansville', region: 'Estrie', lat: 45.2007, lng: -72.7426),
  QuebecCity(name: 'Bromont', region: 'Estrie', lat: 45.3167, lng: -72.6500),
];

/// Haversine distance in km between two GPS coordinates.
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0; // Earth radius km
  final dLat = _rad(lat2 - lat1);
  final dLng = _rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) *
          math.sin(dLng / 2) * math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

double _rad(double deg) => deg * math.pi / 180;

/// Returns the nearest active hub and distance in km for a given city.
/// Returns null if the city itself is a hub.
({QuebecCity hub, double distanceKm})? nearestHub(QuebecCity city) {
  for (final hub in activeCityHubs) {
    if (hub.name == city.name) return null;
  }
  QuebecCity? closest;
  double best = double.infinity;
  for (final hub in activeCityHubs) {
    final d = haversineKm(city.lat, city.lng, hub.lat, hub.lng);
    if (d < best) {
      best = d;
      closest = hub;
    }
  }
  if (closest == null) return null;
  return (hub: closest, distanceKm: best);
}

/// Search cities by prefix (case-insensitive, accent-tolerant).
List<QuebecCity> searchCities(String query) {
  if (query.isEmpty) return quebecCities;
  final q = _normalize(query);
  return quebecCities
      .where((c) => _normalize(c.name).contains(q))
      .toList();
}

String _normalize(String s) {
  return s
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ô', 'o')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ç', 'c')
      .replaceAll('-', ' ')
      .replaceAll('\'', ' ');
}
