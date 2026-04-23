import { Skeleton } from "@/components/ui/skeleton";

export default function EventsLoading() {
  return (
    <div className="space-y-4 px-4 py-6">
      <Skeleton className="h-10 w-40" />
      <Skeleton className="h-10 w-full rounded-xl" />
      <div className="space-y-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="overflow-hidden rounded-2xl border">
            <Skeleton className="h-36 w-full" />
            <div className="space-y-2 p-4">
              <Skeleton className="h-5 w-3/4" />
              <Skeleton className="h-4 w-1/2" />
              <Skeleton className="h-3 w-full" />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
