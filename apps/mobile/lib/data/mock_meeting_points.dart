import 'package:kaiiak/models/meeting_point.dart';

/// Mock meeting points for kaiiak group activities in Montreal.
final List<MeetingPoint> mockMeetingPoints = List<MeetingPoint>.unmodifiable([
  const MeetingPoint(
    id: 'mp1',
    name: 'Parc La Fontaine',
    type: MeetingPointType.park,
    address: '3933 Avenue du Parc-La Fontaine, Montréal, QC H2L 3M6',
    neighborhood: 'Plateau Mont-Royal',
    description:
        'Y\'a pas meilleur spot pour chauffer les jambes avant une run : l\'air y est bon, le monde est zen, pis après t\'as le plan d\'eau pour te la jouer romantique en cooldown.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp1/640/400',
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query=Parc+La+Fontaine+Montreal',
  ),
  const MeetingPoint(
    id: 'mp2',
    name: 'Parc Laurier',
    type: MeetingPointType.park,
    address: '2975 Rue Brébeuf, Montréal, QC H2J 3L7',
    neighborhood: 'Plateau Mont-Royal',
    description:
        'Petit parc de quartier où tout l’monde se dit «bonjour» même quand y se connaissent pas. Idéal pour un départ sans pression, comme une gang de cousins.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp2/640/400',
    mapsUrl: 'https://www.google.com/maps/search/?api=1&query=Parc+Laurier+Montreal',
  ),
  const MeetingPoint(
    id: 'mp3',
    name: 'Parc Jarry',
    type: MeetingPointType.park,
    address: '285 Rue Gary-Carter, Montréal, QC H2R 2W1',
    neighborhood: 'Villeray',
    description:
        'Grand, vert, pis plein de coureurs qui font semblant d’être en mode «je suis en vacances». Parfait si tu veux de l’espace pour t’étirer sans frapper personne.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp3/640/400',
    mapsUrl: 'https://www.google.com/maps/search/?api=1&query=Parc+Jarry+Montreal',
  ),
  const MeetingPoint(
    id: 'mp4',
    name: 'Parc Jeanne-Mance',
    type: MeetingPointType.park,
    address: '4397 Avenue de l’Esplanade, Montréal, QC H2W 1T2',
    neighborhood: 'Mile End',
    description:
        'Vue sur le mont Royal, vibe tam-tams à proximité, pis un terrain assez grand pour que personne t’entende jaser de ton dernier date weird.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp4/640/400',
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query=Parc+Jeanne-Mance+Montreal',
  ),
  const MeetingPoint(
    id: 'mp5',
    name: 'Parc du Mont-Royal (monument Cartier)',
    type: MeetingPointType.park,
    address: '1930 Avenue du Parc, Montréal, QC H2V 4G7',
    neighborhood: 'Mont-Royal',
    description:
        'On se retrouve à la statue : c’est le point zéro avant de monter «juste un p’tit peu». Si tu flanches pas ici, t’es déjà dans l’game.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp5/640/400',
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query=Monument+George-Etienne+Cartier+Montreal',
  ),
  const MeetingPoint(
    id: 'mp6',
    name: 'Café Olimpico',
    type: MeetingPointType.cafe,
    address: '124 Rue Saint-Viateur Ouest, Montréal, QC H2T 2L1',
    neighborhood: 'Mile End',
    description:
        'Le classique italien : espresso qui réveille même les pires lendemains de run. Tu commandes, tu socialises, pis après t’es prêt à dévaler Saint-Viateur.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp6/640/400',
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query=Cafe+Olimpico+Montreal',
  ),
  const MeetingPoint(
    id: 'mp7',
    name: 'Dispatch Coffee',
    type: MeetingPointType.cafe,
    address: '4021 Rue Saint-Denis, Montréal, QC H2W 2M7',
    neighborhood: 'Plateau Mont-Royal',
    description:
        'Café third wave où tout l’monde connaît le nom du barista. Parfait pour un départ «j’écoute mon corps»… mais avec un flat white quand même.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp7/640/400',
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query=Dispatch+Coffee+Saint-Denis+Montreal',
  ),
  const MeetingPoint(
    id: 'mp8',
    name: 'Pikolo Espresso Bar',
    type: MeetingPointType.cafe,
    address: '3418 Avenue du Parc, Montréal, QC H2X 2H5',
    neighborhood: 'Mile End',
    description:
        'Micro-café cozy : tu vas jaser en queue comme si t’étais déjà dans le groupe. Idéal pour briser la glace avant même d’avoir lacé tes souliers.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp8/640/400',
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query=Pikolo+Espresso+Bar+Montreal',
  ),
  const MeetingPoint(
    id: 'mp9',
    name: 'Crew Collective & Café',
    type: MeetingPointType.cafe,
    address: '360 Rue Saint-Jacques, Montréal, QC H2Y 4M1',
    neighborhood: 'Vieux-Montréal',
    description:
        'Dans une ancienne banque : t’as l’impression d’être dans un film. Tu sors de là avec le café dans l’body pis l’ego un peu trop beau pour un 5 km.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp9/640/400',
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query=Crew+Collective+Cafe+Montreal',
  ),
  const MeetingPoint(
    id: 'mp10',
    name: 'Bassin Peel (Canal Lachine)',
    type: MeetingPointType.landmark,
    address: '1750 Rue Peel, Montréal, QC H3K 0A1',
    neighborhood: 'Pointe-Saint-Charles',
    description:
        'Bord d’eau, vents capricieux, pis des flatteurs de chien partout. Si t’aimes le côté «on est en ville mais ça sent l’été», c’est ta place.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp10/640/400',
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query=Bassin+Peel+Canal+Lachine+Montreal',
  ),
  const MeetingPoint(
    id: 'mp11',
    name: 'Horloge du Vieux-Port',
    type: MeetingPointType.landmark,
    address: '1 Quai de l’Horloge, Montréal, QC H2Y 2E9',
    neighborhood: 'Vieux-Port',
    description:
        'Point de repère impossible à manquer : si t’es en retard, au moins t’as une excuse photo. L’endroit où les groupes se trouvent sans se texter vingt fois.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp11/640/400',
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query=Clock+Tower+Old+Port+Montreal',
  ),
  const MeetingPoint(
    id: 'mp12',
    name: 'Stade olympique',
    type: MeetingPointType.landmark,
    address: '4141 Avenue Pierre-De Coubertin, Montréal, QC H1V 3N7',
    neighborhood: 'Hochelaga-Maisonneuve',
    description:
        'Le géant de béton te salue. Départ mythique pour ceux qui aiment viser large : pis oui, on finit rarement par monter la tour, on se calme.',
    photoUrl: 'https://picsum.photos/seed/kaiiak-mp12/640/400',
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query=Stade+olympique+Montreal',
  ),
]);
