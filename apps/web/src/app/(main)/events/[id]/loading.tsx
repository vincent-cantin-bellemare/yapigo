import { Skeleton } from "@/components/ui/skeleton";

export default function EventDetailLoading() {
  return (
    <div>
      <Skeleton className="h-48 w-full" />
      <div className="space-y-4 px-4 py-6">
        <Skeleton className="h-24 w-full rounded-xl" />
        <Skeleton className="h-32 w-full rounded-xl" />
        <Skeleton className="h-20 w-full rounded-xl" />
        <Skeleton className="h-28 w-full rounded-xl" />
      </div>
    </div>
  );
}
