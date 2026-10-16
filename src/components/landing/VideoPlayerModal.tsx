import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog"

interface VideoPlayerModalProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  speaker?: string
  dateLabel?: string
  videoUrl?: string
}

export function VideoPlayerModal({
  open,
  onOpenChange,
  title,
  speaker,
  dateLabel,
  videoUrl,
}: VideoPlayerModalProps) {
  // Converte link comum do YouTube para embed seguro
  const getEmbedUrl = (url?: string) => {
    if (!url) return "https://www.youtube-nocookie.com/embed/ScMzIvxBSi4"
    const match = url.match(/(?:youtu\.be\/|youtube\.com\/(?:watch\?v=|embed\/|v\/|shorts\/))([\w-]{11})/)
    const videoId = match ? match[1] : null
    return videoId
      ? `https://www.youtube-nocookie.com/embed/${videoId}?autoplay=1&rel=0`
      : url
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-4xl w-[94vw] sm:w-full p-4 sm:p-6 bg-card border-border/80 shadow-2xl rounded-2xl">
        <DialogHeader className="text-left space-y-1 mb-2">
          <DialogTitle className="text-base sm:text-xl font-bold tracking-tight text-foreground">
            {title}
          </DialogTitle>
          {(speaker || dateLabel) && (
            <DialogDescription className="text-xs text-muted-foreground flex items-center gap-2">
              {speaker && <span className="font-medium text-foreground/80">Ministrado por {speaker}</span>}
              {speaker && dateLabel && <span>•</span>}
              {dateLabel && <span>{dateLabel}</span>}
            </DialogDescription>
          )}
        </DialogHeader>

        {/* 16:9 Responsive Video Container */}
        <div className="relative w-full overflow-hidden rounded-xl bg-black aspect-video shadow-md border border-border/40">
          {open && (
            <iframe
              src={getEmbedUrl(videoUrl)}
              title={title}
              className="absolute inset-0 h-full w-full border-0"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
              allowFullScreen
            />
          )}
        </div>
      </DialogContent>
    </Dialog>
  )
}
