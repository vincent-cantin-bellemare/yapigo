"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { BottomNav } from "@/components/bottom-nav";
import { DesktopNav } from "@/components/desktop-nav";
import { useAuth } from "@/lib/auth-context";

export default function MainLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isLoggedIn } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoggedIn) {
      router.replace("/welcome");
    }
  }, [isLoggedIn, router]);

  if (!isLoggedIn) return null;

  return (
    <div className="flex min-h-screen">
      <div className="hidden md:block">
        <DesktopNav />
      </div>
      <div className="flex min-h-screen flex-1 flex-col">
        <main className="flex-1 pb-20 md:pb-0">{children}</main>
        <div className="md:hidden">
          <BottomNav />
        </div>
      </div>
    </div>
  );
}
