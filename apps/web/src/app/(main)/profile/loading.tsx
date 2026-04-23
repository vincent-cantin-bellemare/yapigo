import { Skeleton } from "@/components/ui/skeleton";

export default function ProfileLoading() {
  return (
    <div className="mx-auto max-w-lg px-5 pt-6">
      <div className="flex flex-col items-center gap-4">
        <Skeleton className="h-28 w-28 rounded-full" />
        <Skeleton className="h-6 w-40" />
        <Skeleton className="h-5 w-24 rounded-full" />
        <Skeleton className="h-4 w-48" />
      </div>
      <div className="mt-8 space-y-3">
        {Array.from({ length: 6 }).map((_, i) => (
          <Skeleton key={i} className="h-12 w-full rounded-xl" />
        ))}
      </div>
    </div>
  );
}
