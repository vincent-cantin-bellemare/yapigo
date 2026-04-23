import { Skeleton } from "@/components/ui/skeleton";

export default function MembersLoading() {
  return (
    <div className="space-y-4 px-4 py-6">
      <Skeleton className="h-8 w-32" />
      <Skeleton className="h-10 w-full rounded-xl" />
      <div className="grid grid-cols-2 gap-3">
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="overflow-hidden rounded-2xl border">
            <Skeleton className="h-32 w-full" />
            <div className="space-y-2 p-3">
              <Skeleton className="h-4 w-3/4" />
              <Skeleton className="h-3 w-1/2" />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
