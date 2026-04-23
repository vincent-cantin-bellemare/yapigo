"use client";

import { useState } from "react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { UserAvatar } from "@/components/shared/user-avatar";
import { UserProfileSheet } from "@/components/shared/user-profile-sheet";
import { mockUsers } from "@/lib/data";
import type { User } from "@/lib/types";
import {
  MessageSquare,
  Bell,
  UserPlus,
  Check,
  X,
  Calendar,
  Heart,
  Users,
  AlertCircle,
} from "lucide-react";

const mockConversationPreviews = [
  {
    id: "c1",
    groupName: "🏃 Course · Lachine",
    lastMessage: "Nice! Hâte de recroiser le monde sur la piste 🙌",
    lastSender: "Maude",
    time: "il y a 2h",
    unread: true,
    memberPhotos: [
      mockUsers[1].photoUrl,
      mockUsers[2].photoUrl,
      mockUsers[5].photoUrl,
    ],
  },
  {
    id: "c2",
    groupName: "🥾 Rando · Mont-Royal",
    lastMessage:
      "Si quelqu'un est down pour un yoga à Villeray dimanche puis brunch, écris-moi",
    lastSender: "Toi",
    time: "il y a 6j",
    unread: false,
    memberPhotos: [mockUsers[3].photoUrl, mockUsers[4].photoUrl],
  },
];

const mockNotifs = [
  {
    id: "n1",
    type: "matchFound" as const,
    title: "Groupe formé!",
    body: "Ton groupe pour la course du Plateau est prêt. Consulte les détails.",
    time: "il y a 1h",
    icon: Users,
    read: false,
  },
  {
    id: "n2",
    type: "runConfirmed" as const,
    title: "Activité confirmée",
    body: "La course à Lachine du 28 avril a atteint le seuil minimum!",
    time: "il y a 3h",
    icon: Check,
    read: false,
  },
  {
    id: "n3",
    type: "deadlineReminder" as const,
    title: "Date limite demain",
    body: "L'inscription pour la course du Mont-Royal ferme demain à 23h59.",
    time: "il y a 5h",
    icon: AlertCircle,
    read: true,
  },
  {
    id: "n4",
    type: "rateReminder" as const,
    title: "Note ton expérience",
    body: "Comment s'est passée ta course à Hochelaga? Donne ton avis!",
    time: "il y a 1j",
    icon: Heart,
    read: true,
  },
];

const connectionRequests = [
  {
    id: "cr1",
    user: mockUsers[4],
    message: "Hey! On a couru ensemble à Hochelaga, ça te dit qu'on se reconnecte?",
    time: "il y a 2h",
  },
  {
    id: "cr2",
    user: mockUsers[7],
    message: "Salut! J'ai vu qu'on aime toutes les deux la rando. On se suit?",
    time: "il y a 1j",
  },
];

export default function ActivityPage() {
  const [activeTab, setActiveTab] = useState("messages");
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);

  const openProfile = (user: User) => {
    setSelectedUser(user);
    setSheetOpen(true);
  };

  return (
    <div>
      <header className="bg-gradient-to-r from-ocean to-cyan px-6 pb-4 pt-12 text-white">
        <h1 className="font-heading text-2xl font-bold">Activité</h1>
      </header>

      <div className="mx-auto max-w-2xl px-4 py-4">
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="w-full">
            <TabsTrigger value="messages" className="flex-1 gap-1.5">
              <MessageSquare className="h-4 w-4" />
              Messages
              <Badge variant="secondary" className="text-xs">
                {mockConversationPreviews.filter((c) => c.unread).length}
              </Badge>
            </TabsTrigger>
            <TabsTrigger value="notifications" className="flex-1 gap-1.5">
              <Bell className="h-4 w-4" />
              Notifs
              <Badge variant="secondary" className="text-xs">
                {mockNotifs.filter((n) => !n.read).length}
              </Badge>
            </TabsTrigger>
            <TabsTrigger value="connections" className="flex-1 gap-1.5">
              <UserPlus className="h-4 w-4" />
              Demandes
              <Badge variant="secondary" className="text-xs">
                {connectionRequests.length}
              </Badge>
            </TabsTrigger>
          </TabsList>

          {/* Messages */}
          <TabsContent value="messages" className="mt-4 space-y-3">
            {mockConversationPreviews.map((conv) => (
              <Card
                key={conv.id}
                className={conv.unread ? "border-primary/30 bg-primary/5" : ""}
              >
                <CardContent className="flex items-center gap-3 p-4">
                  <div className="flex -space-x-2">
                    {conv.memberPhotos.slice(0, 3).map((photo, i) => (
                      <UserAvatar
                        key={i}
                        photoUrl={photo}
                        firstName="M"
                        size="sm"
                        className="border-2 border-background"
                      />
                    ))}
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center justify-between">
                      <h3 className="truncate font-heading text-sm font-bold">
                        {conv.groupName}
                      </h3>
                      <span className="shrink-0 text-xs text-muted-foreground">
                        {conv.time}
                      </span>
                    </div>
                    <p className="truncate text-sm text-muted-foreground">
                      <span className="font-medium">{conv.lastSender}:</span>{" "}
                      {conv.lastMessage}
                    </p>
                  </div>
                  {conv.unread && (
                    <span className="h-2.5 w-2.5 shrink-0 rounded-full bg-primary" />
                  )}
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          {/* Notifications */}
          <TabsContent value="notifications" className="mt-4 space-y-3">
            {mockNotifs.map((notif) => {
              const Icon = notif.icon;
              return (
                <Card
                  key={notif.id}
                  className={!notif.read ? "border-primary/30 bg-primary/5" : ""}
                >
                  <CardContent className="flex items-start gap-3 p-4">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary/10">
                      <Icon className="h-5 w-5 text-primary" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center justify-between">
                        <h3 className="font-heading text-sm font-bold">
                          {notif.title}
                        </h3>
                        <span className="shrink-0 text-xs text-muted-foreground">
                          {notif.time}
                        </span>
                      </div>
                      <p className="mt-0.5 text-sm text-muted-foreground">
                        {notif.body}
                      </p>
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </TabsContent>

          {/* Connection Requests */}
          <TabsContent value="connections" className="mt-4 space-y-3">
            {connectionRequests.map((req) => (
              <Card key={req.id}>
                <CardContent className="p-4">
                  <div className="flex items-start gap-3">
                    <button onClick={() => openProfile(req.user)}>
                      <UserAvatar
                        photoUrl={req.user.photoUrl}
                        firstName={req.user.firstName}
                        lastName={req.user.lastName}
                        size="lg"
                      />
                    </button>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center justify-between">
                        <button
                          className="font-heading font-bold hover:underline"
                          onClick={() => openProfile(req.user)}
                        >
                          {req.user.firstName} {req.user.lastName[0]}.
                        </button>
                        <span className="text-xs text-muted-foreground">
                          {req.time}
                        </span>
                      </div>
                      <p className="mt-1 text-sm text-muted-foreground">
                        {req.message}
                      </p>
                      <div className="mt-3 flex gap-2">
                        <button className="flex items-center gap-1 rounded-lg bg-primary px-4 py-1.5 text-sm font-medium text-white hover:bg-primary/90">
                          <Check className="h-4 w-4" /> Accepter
                        </button>
                        <button className="flex items-center gap-1 rounded-lg border border-border px-4 py-1.5 text-sm font-medium hover:bg-muted">
                          <X className="h-4 w-4" /> Refuser
                        </button>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </TabsContent>
        </Tabs>
      </div>

      <UserProfileSheet
        user={selectedUser}
        open={sheetOpen}
        onOpenChange={setSheetOpen}
      />
    </div>
  );
}
