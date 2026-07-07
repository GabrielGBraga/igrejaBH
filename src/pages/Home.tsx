import { NewsTimeline } from "@/components/home/NewsTimeline"
import { ChurchMap } from "@/components/home/ChurchMap"

export default function Home() {
  return (
    <div className="animate-in space-y-8 duration-500 fade-in slide-in-from-bottom-4">
      <header className="flex flex-col justify-between gap-4 border-b border-border pb-6 md:flex-row md:items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">
            Bem-vindo(a)
          </h1>
          <p className="mt-1 text-sm text-muted-foreground md:text-base">
            Aqui você acompanha tudo o que acontece na Igreja em BH.
          </p>
        </div>
      </header>

      <div className="grid grid-cols-1 items-stretch gap-8 lg:grid-cols-2">
        <div className="min-h-[500px] overflow-hidden rounded-2xl border border-border/50 bg-card/30 shadow-sm backdrop-blur-sm transition-all duration-300 hover:shadow-md">
          <NewsTimeline />
        </div>
        <div className="min-h-[500px] overflow-hidden rounded-2xl border border-border/50 bg-card/30 shadow-sm backdrop-blur-sm transition-all duration-300 hover:shadow-md">
          <ChurchMap />
        </div>
      </div>
    </div>
  )
}
