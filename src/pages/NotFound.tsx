import { useNavigate } from "react-router-dom";
import { HomeIcon, ArrowLeftIcon, SearchXIcon } from "lucide-react";
import { Button } from "@/components/ui/button";

export default function NotFound() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-background text-foreground flex items-center justify-center p-6 relative overflow-hidden">
      {/* Ambient background glows */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/10 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-primary/5 rounded-full blur-3xl" />
      </div>

      <div className="relative z-10 flex flex-col items-center text-center max-w-md w-full">
        {/* Icon */}
        <div className="mb-6 p-5 rounded-2xl bg-card/50 border border-border/50 backdrop-blur-md shadow-xl">
          <SearchXIcon className="w-12 h-12 text-primary/70" strokeWidth={1.5} />
        </div>

        {/* 404 number */}
        <h1 className="text-8xl font-black tracking-tighter text-foreground/10 select-none leading-none mb-2">
          404
        </h1>

        {/* Title & description */}
        <h2 className="text-2xl font-bold tracking-tight text-foreground mb-3">
          Página não encontrada
        </h2>
        <p className="text-muted-foreground text-sm leading-relaxed mb-8">
          A página que você está buscando não existe ou foi movida.
          <br />
          Verifique o endereço ou volte ao início.
        </p>

        {/* Actions */}
        <div className="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
          <Button
            className="gap-2 bg-primary hover:bg-primary/90"
            onClick={() => navigate("/")}
          >
            <HomeIcon className="w-4 h-4" />
            Ir para o Início
          </Button>
        </div>
      </div>
    </div>
  );
}
