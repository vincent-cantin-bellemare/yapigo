import { Skeleton } from "@/components/ui/skeleton";

export default function ActivityLoading() {
  return (
    <div className="space-y-4 px-5 pt-8">
      <Skeleton className="h-8 w-32" />
      <Skeleton className="h-10 w-full rounded-xl" />
      <div className="space-y-3 pt-2">
        {Array.from({ length: 5 }).map((_, i) => (
          <div key={i} className="flex items-center gap-3 py-3">
            <Skeleton className="h-12 w-14 rounded-full" />
            <div className="flex-1 space-y-2">
              <Skeleton className="h-4 w-3/4" />
              <Skeleton className="h-3 w-1/2" />
            </div>
            <Skeleton className="h-3 w-12" />
          </div>
        ))}
      </div>
    </div>
  );
}
