import { NewsTimeline } from "@/components/home/NewsTimeline"

export default function Home() {
  return (
    <div className="mx-auto max-w-4xl animate-in space-y-8 duration-500 fade-in slide-in-from-bottom-4">
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

      <div>
        <NewsTimeline />
      </div>
    </div>
  )
}
