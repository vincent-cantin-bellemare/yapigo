import { Skeleton } from "@/components/ui/skeleton";

export default function MainLoading() {
  return (
    <div className="space-y-6 px-4 py-8">
      <Skeleton className="mx-auto h-8 w-48" />
      <div className="space-y-4">
        <Skeleton className="h-40 w-full rounded-2xl" />
        <div className="grid grid-cols-3 gap-3">
          <Skeleton className="h-24 rounded-xl" />
          <Skeleton className="h-24 rounded-xl" />
          <Skeleton className="h-24 rounded-xl" />
        </div>
        <Skeleton className="h-32 w-full rounded-2xl" />
        <Skeleton className="h-32 w-full rounded-2xl" />
      </div>
    </div>
  );
}
