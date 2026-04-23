import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { cn } from "@/lib/utils";

interface UserAvatarProps {
  photoUrl?: string | null;
  firstName: string;
  lastName?: string;
  size?: "sm" | "md" | "lg" | "xl";
  className?: string;
}

const sizeClasses = {
  sm: "h-8 w-8 text-xs",
  md: "h-10 w-10 text-sm",
  lg: "h-14 w-14 text-base",
  xl: "h-20 w-20 text-lg",
};

export function UserAvatar({
  photoUrl,
  firstName,
  lastName,
  size = "md",
  className,
}: UserAvatarProps) {
  const initials = `${firstName[0]}${lastName?.[0] ?? ""}`.toUpperCase();

  return (
    <Avatar className={cn(sizeClasses[size], className)}>
      {photoUrl && <AvatarImage src={photoUrl} alt={firstName} />}
      <AvatarFallback className="bg-ocean text-white font-heading font-bold">
        {initials}
      </AvatarFallback>
    </Avatar>
  );
}
