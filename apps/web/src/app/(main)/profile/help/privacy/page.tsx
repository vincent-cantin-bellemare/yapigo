"use client";

import Link from "next/link";
import { ArrowLeft } from "lucide-react";

const sections = [
  {
    title: "1. Collecte des données",
    body: "Nous collectons les informations que vous nous fournissez lors de la création de votre compte (nom, âge, photo, ville, quartier) ainsi que les données générées par votre utilisation de l'Application (participations, évaluations, messages).",
  },
  {
    title: "2. Utilisation des données",
    body: "Vos données sont utilisées pour :\n• Personnaliser votre expérience et vous proposer des activités pertinentes\n• Former des sous-groupes compatibles via notre algorithme de matching\n• Améliorer nos services et développer de nouvelles fonctionnalités\n• Vous envoyer des notifications relatives à vos activités\n• Assurer la sécurité de la communauté",
  },
  {
    title: "3. Données Strava",
    body: "Si vous connectez votre compte Strava, nous accédons uniquement à vos statistiques d'activité (distance, allure, fréquence). Ces données sont utilisées pour enrichir votre profil et améliorer le matching. Vous pouvez déconnecter Strava à tout moment.",
  },
  {
    title: "4. Partage des données",
    body: "Vos informations de profil sont visibles selon vos paramètres de confidentialité (public, interne ou privé). Nous ne vendons jamais vos données personnelles à des tiers. Nous pouvons partager des données anonymisées à des fins statistiques.",
  },
  {
    title: "5. Stockage et sécurité",
    body: "Vos données sont stockées de manière sécurisée sur des serveurs au Canada. Nous utilisons le chiffrement et des mesures de sécurité conformes aux standards de l'industrie pour protéger vos informations.",
  },
  {
    title: "6. Vos droits",
    body: "Conformément aux lois applicables, vous avez le droit de :\n• Accéder à vos données personnelles\n• Rectifier vos informations\n• Supprimer votre compte et vos données\n• Exporter vos données\n• Retirer votre consentement à tout moment",
  },
  {
    title: "7. Cookies et technologies similaires",
    body: "L'Application peut utiliser des technologies de suivi pour améliorer votre expérience et analyser l'utilisation du service. Vous pouvez gérer vos préférences dans les paramètres de votre appareil.",
  },
  {
    title: "8. Conservation des données",
    body: "Nous conservons vos données aussi longtemps que votre compte est actif. En cas de suppression de compte, vos données personnelles sont supprimées dans un délai de 30 jours, à l'exception des données que nous sommes légalement tenus de conserver.",
  },
  {
    title: "9. Contact",
    body: "Pour toute question concernant cette politique de confidentialité ou pour exercer vos droits, contactez-nous à privacy@rundate.app ou via la section Aide de l'Application.",
  },
];

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-background pb-32">
      <div className="flex items-center gap-3 px-5 pt-6 pb-4">
        <Link href="/profile/help" className="text-foreground">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <h1 className="font-heading text-lg font-bold">
          Politique de confidentialité
        </h1>
      </div>

      <div className="mx-auto max-w-lg px-5">
        <div className="space-y-6">
          {sections.map((s, i) => (
            <section key={i}>
              <h2 className="font-heading text-base font-bold">{s.title}</h2>
              <p className="mt-2 whitespace-pre-line text-sm leading-relaxed text-muted-foreground">
                {s.body}
              </p>
            </section>
          ))}
        </div>
        <p className="mt-10 text-center text-sm text-muted-foreground">
          Dernière mise à jour: Mars 2026
        </p>
      </div>
    </div>
  );
}
