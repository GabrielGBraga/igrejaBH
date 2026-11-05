import { ChurchAvatar } from "@/components/ui/church-avatar"

export function PageLoadingFallback() {
  return (
    <div
      role="status"
      aria-label="Carregando página"
      className="flex min-h-[60vh] w-full flex-col items-center justify-center p-6"
    >
      {/* Top progress indicator pulse */}
      <div className="fixed top-0 left-0 right-0 z-50 h-1 overflow-hidden bg-primary/15">
        <div className="h-full w-full origin-left-right animate-[progress_1.2s_ease-in-out_infinite] bg-primary" />
      </div>

      <div className="flex flex-col items-center gap-3 animate-pulse motion-reduce:animate-none">
        <ChurchAvatar size="lg" variant="subtle" />
        <span className="text-xs font-medium text-muted-foreground tracking-wide">
          Carregando...
        </span>
      </div>
    </div>
  )
}
