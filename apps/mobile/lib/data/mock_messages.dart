import 'package:kaiiak/models/message.dart';
import 'package:kaiiak/data/mock_users.dart';

final mockConversations = <Conversation>[
  Conversation(
    id: 'c1',
    groupName: 'Vélo Lachine #3',
    members: [mockUsers[0], mockUsers[1], mockUsers[2], mockUsers[5], mockUsers[6]],
    matchId: 'm1',
    messages: [
      Message(
        id: 'msg0',
        senderId: 'system',
        content: 'Bienvenue dans ton groupe! Présentez-vous après la sortie 🚴',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        isIcebreaker: true,
      ),
      Message(
        id: 'msg1',
        senderId: 'u1',
        content: 'Salut! Sophie ici — t\'as roulé en combien de temps? J\'étais en mode chill à 22 km/h haha',
        timestamp: DateTime.now().subtract(const Duration(hours: 7)),
      ),
      Message(
        id: 'msg2',
        senderId: 'current',
        content: 'Hey! Alex, j\'ai tellement ri sur le bord du canal, t\'es drôle!',
        timestamp: DateTime.now().subtract(const Duration(hours: 6, minutes: 30)),
      ),
      Message(
        id: 'msg3',
        senderId: 'u2',
        content: 'Marc-Antoine! Le café après était parfait, on remet ça?',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Message(
        id: 'msg4',
        senderId: 'u6',
        content: 'Oui! Maude btw — as-tu déjà essayé la piste vers le Vieux-Port?',
        timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
      ),
      Message(
        id: 'msg5',
        senderId: 'u3',
        content: 'Pas encore! Camille — qui revient dimanche prochain pour un autre tour?',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Message(
        id: 'msg6',
        senderId: 'u7',
        content: 'Oli ici — moi j\'y suis si le vent est correct. J\'amène une rustine au cas où',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Message(
        id: 'msg7',
        senderId: 'u1',
        content: 'Parfait! Quelqu\'un veut un 25 km tranquille jeudi soir? 😅',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Message(
        id: 'msg8',
        senderId: 'current',
        content: 'Je suis partant! On se donne le point de départ demain',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      Message(
        id: 'msg9',
        senderId: 'u6',
        content: 'Nice! Hâte de recroiser le monde sur la piste 🙌',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
  ),
  Conversation(
    id: 'c2',
    groupName: 'Rando Mont-Royal #5',
    members: [mockUsers[3], mockUsers[4], mockUsers[7]],
    matchId: 'm2',
    messages: [
      Message(
        id: 'msg10',
        senderId: 'system',
        content: 'Comment s\'est passée votre randonnée? Partagez vos impressions!',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        isIcebreaker: true,
      ),
      Message(
        id: 'msg11',
        senderId: 'u4',
        content: 'C\'était le fun! Le dénivelé était bon pour jaser sans être essoufflé 👌',
        timestamp: DateTime.now().subtract(const Duration(days: 6, hours: 20)),
      ),
      Message(
        id: 'msg12',
        senderId: 'current',
        content: 'Tellement! Si quelqu\'un est down pour un yoga à Villeray dimanche puis brunch, écris-moi',
        timestamp: DateTime.now().subtract(const Duration(days: 6, hours: 18)),
      ),
    ],
  ),
  Conversation(
    id: 'c_private',
    groupName: 'Marc 💘',
    members: [mockUsers[1]],
    matchId: 'match_private',
    messages: [
      Message(
        id: 'pm1',
        senderId: 'system',
        content: 'Vous vous êtes mutuellement likés! La conversation est ouverte 💘',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        isIcebreaker: true,
      ),
      Message(
        id: 'pm2',
        senderId: 'u1',
        content: 'Hey! C\'était vraiment le fun de faire la rando Mont-Royal avec toi samedi. T\'as un bon rythme!',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      Message(
        id: 'pm3',
        senderId: 'current',
        content: 'Merci! Toi aussi! J\'ai adoré le sentier que t\'as proposé 🥾',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 30)),
      ),
      Message(
        id: 'pm4',
        senderId: 'u1',
        content: 'On se refait une sortie kaiiak bientôt? Je connais un beau spot kayak à Lachine',
        timestamp: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      Message(
        id: 'pm5',
        senderId: 'current',
        content: 'Oui tellement! Je suis libre vendredi soir si ça te dit',
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      Message(
        id: 'pm6',
        senderId: 'u1',
        content: 'Parfait! On se dit 18h au quai? ☀️',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
  ),
];
