"use client";

import { useState, type ReactNode } from "react";
import type { User } from "@/lib/types";
import { UserProfileSheet } from "./user-profile-sheet";

interface ClickableUserProps {
  user: User;
  children: ReactNode;
  className?: string;
  isOwnProfile?: boolean;
}

export function ClickableUser({ user, children, className, isOwnProfile }: ClickableUserProps) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button className={className} onClick={() => setOpen(true)}>
        {children}
      </button>
      <UserProfileSheet
        user={user}
        open={open}
        onOpenChange={setOpen}
        isOwnProfile={isOwnProfile}
      />
    </>
  );
}
