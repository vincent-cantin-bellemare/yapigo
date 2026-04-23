import type { Metadata } from "next";
import { Nunito, DM_Sans } from "next/font/google";
import { ThemeProvider } from "@/components/theme-provider";
import { AuthProvider } from "@/lib/auth-context";
import { DemoToggle } from "@/components/demo-toggle";
import "./globals.css";

const nunito = Nunito({
  variable: "--font-nunito",
  subsets: ["latin"],
  weight: ["400", "600", "700", "800"],
});

const dmSans = DM_Sans({
  variable: "--font-dm-sans",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

export const metadata: Metadata = {
  title: {
    default: "Run Date — Cours, rencontre, connecte",
    template: "%s | Run Date",
  },
  description:
    "Rencontre des gens en allant courir ensemble. L'app de dating pour les coureurs à Montréal.",
  openGraph: {
    type: "website",
    locale: "fr_CA",
    siteName: "Run Date",
    title: "Run Date — Cours, rencontre, connecte",
    description:
      "Inscris-toi à un Run Date et rencontre des gens qui partagent ta passion pour la course à pied.",
  },
  twitter: {
    card: "summary_large_image",
    title: "Run Date — Cours, rencontre, connecte",
    description:
      "Inscris-toi à un Run Date et rencontre des gens qui partagent ta passion pour la course à pied.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="fr"
      className={`${nunito.variable} ${dmSans.variable} h-full`}
      suppressHydrationWarning
    >
      <body className="min-h-full flex flex-col antialiased bg-muted/30">
        <ThemeProvider
          attribute="class"
          defaultTheme="light"
          enableSystem
          disableTransitionOnChange
        >
          <AuthProvider>
            <div className="relative mx-auto flex min-h-screen w-full max-w-md flex-col bg-background shadow-xl md:max-w-none md:shadow-none">
              <DemoToggle />
              {children}
            </div>
          </AuthProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
