import { NewsTimeline } from "@/components/home/NewsTimeline";
import { ChurchMap } from "@/components/home/ChurchMap";

export default function Home() {
  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <header className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-border gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Bem-vindo(a)</h1>
          <p className="text-muted-foreground mt-1 text-sm md:text-base">Aqui você acompanha tudo o que acontece na Igreja em BH.</p>
        </div>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-stretch">
        <div className="min-h-[500px] bg-card/30 backdrop-blur-sm border border-border/50 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-all duration-300">
          <NewsTimeline />
        </div>
        <div className="min-h-[500px] bg-card/30 backdrop-blur-sm border border-border/50 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-all duration-300">
          <ChurchMap />
        </div>
      </div>
    </div>
  );
}
