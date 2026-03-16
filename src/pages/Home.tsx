import { Sidebar } from "@/components/layout/Sidebar";
import { NewsTimeline } from "@/components/home/NewsTimeline";
import { ChurchMap } from "@/components/home/ChurchMap";

export default function Home() {
  return (
    <div className="flex min-h-screen bg-background text-foreground selection:bg-primary/20">
      <Sidebar />
      
      <main className="flex-1 flex flex-col items-center justify-start p-4 md:p-8 overflow-y-auto">
        <div className="w-full max-w-7xl mx-auto space-y-8">
            <header className="flex items-center justify-between pb-6 border-b border-border">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-foreground">Bem-vindo(a)</h1>
                    <p className="text-muted-foreground mt-1">Aqui você acompanha tudo o que acontece na Igreja em BH.</p>
                </div>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-2 lg:grid-rows-[minmax(600px,max-content)] gap-6 h-full items-stretch">
                <div className="col-span-1 h-full min-h-[500px]">
                    <NewsTimeline />
                </div>
                <div className="col-span-1 h-full min-h-[500px]">
                    <ChurchMap />
                </div>
            </div>
        </div>
      </main>
    </div>
  );
}
