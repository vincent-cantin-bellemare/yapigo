/// What each runner brings to the group run. Key = userId, value = list of items.
final Map<String, List<String>> mockBringItems = {
  'current': ['Gourde d\'eau', 'Écouteurs'],
  'u1': ['Gourde d\'eau', 'Crème solaire'],
  'u2': ['Gels énergétiques', 'Casquette'],
  'u3': ['Serviette', 'Collation post-run'],
  'u4': ['Gourde d\'eau', 'Gels énergétiques', 'Crème solaire'],
  'u5': ['Écouteurs', 'Casquette'],
  'u6': ['Collation post-run', 'Serviette'],
  'u7': ['Lampe frontale (night run)', 'Gourde d\'eau'],
};

const bringItemEmojis = <String, String>{
  'Gourde d\'eau': '💧',
  'Écouteurs': '🎧',
  'Gels énergétiques': '⚡',
  'Serviette': '🧺',
  'Casquette': '🧢',
  'Lampe frontale (night run)': '🔦',
  'Crème solaire': '☀️',
  'Collation post-run': '🍌',
};
