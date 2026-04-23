"use client";

import Link from "next/link";
import { ArrowLeft } from "lucide-react";

const sections = [
  {
    title: "1. Acceptation des conditions",
    body: "En téléchargeant, installant ou utilisant l'application Run Date (\"l'Application\"), vous acceptez d'être lié par les présentes conditions d'utilisation. Si vous n'acceptez pas ces conditions, veuillez ne pas utiliser l'Application.",
  },
  {
    title: "2. Description du service",
    body: "Run Date est une plateforme sociale sportive qui permet aux utilisateurs de participer à des activités sportives de groupe. L'Application facilite la mise en relation entre participants partageant des intérêts sportifs similaires.",
  },
  {
    title: "3. Inscription et compte",
    body: "Pour utiliser l'Application, vous devez créer un compte en fournissant des informations exactes et à jour. Vous êtes responsable de la confidentialité de vos identifiants de connexion. Vous devez avoir au moins 18 ans pour créer un compte.",
  },
  {
    title: "4. Règles de conduite",
    body: "Les utilisateurs s'engagent à :\n• Respecter les autres participants\n• Ne pas publier de contenu offensant, discriminatoire ou illégal\n• Ne pas harceler d'autres utilisateurs\n• Respecter les règles de chaque activité\n• Se présenter aux activités auxquelles ils se sont inscrits\n• Signaler tout comportement inapproprié",
  },
  {
    title: "5. Contenu utilisateur",
    body: "Vous conservez vos droits sur le contenu que vous publiez. En publiant du contenu sur Run Date, vous nous accordez une licence non exclusive, mondiale et gratuite pour utiliser, reproduire et afficher ce contenu dans le cadre du service.",
  },
  {
    title: "6. Activités et responsabilité",
    body: "Run Date facilite l'organisation d'activités sportives mais n'est pas responsable des blessures ou incidents pouvant survenir pendant ces activités. Les participants sont responsables de leur propre condition physique et doivent consulter un médecin en cas de doute.",
  },
  {
    title: "7. Paiements et remboursements",
    body: "Certaines activités peuvent nécessiter un paiement. Les conditions de remboursement sont affichées pour chaque activité payante. En cas d'annulation par l'organisateur, un remboursement complet sera effectué automatiquement.",
  },
  {
    title: "8. Suspension et résiliation",
    body: "Nous nous réservons le droit de suspendre ou de résilier votre compte en cas de violation des présentes conditions, de comportement inapproprié ou d'utilisation frauduleuse de l'Application.",
  },
  {
    title: "9. Modifications des conditions",
    body: "Nous pouvons modifier ces conditions à tout moment. Les modifications prendront effet dès leur publication dans l'Application. Votre utilisation continue après une modification constitue votre acceptation des nouvelles conditions.",
  },
  {
    title: "10. Propriété intellectuelle",
    body: "L'Application, son contenu, son design et ses fonctionnalités sont la propriété de Run Date et sont protégés par les lois sur la propriété intellectuelle. Toute reproduction non autorisée est interdite.",
  },
  {
    title: "11. Contact",
    body: "Pour toute question concernant ces conditions d'utilisation, vous pouvez nous contacter via la section Aide de l'Application ou par courriel à legal@rundate.app.",
  },
];

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-background pb-32">
      <div className="flex items-center gap-3 px-5 pt-6 pb-4">
        <Link href="/profile/help" className="text-foreground">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <h1 className="font-heading text-lg font-bold">
          Conditions d&apos;utilisation
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
