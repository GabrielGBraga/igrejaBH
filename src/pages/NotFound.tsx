import { useNavigate } from "react-router-dom"
import { HomeIcon, SearchXIcon } from "lucide-react"
import { Button } from "@/components/ui/button"

export default function NotFound() {
  const navigate = useNavigate()

  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-background p-6 text-foreground">
      {/* Ambient background glows */}
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute top-1/4 left-1/4 h-96 w-96 rounded-full bg-primary/10 blur-3xl" />
        <div className="absolute right-1/4 bottom-1/4 h-80 w-80 rounded-full bg-primary/5 blur-3xl" />
      </div>

      <div className="relative z-10 flex w-full max-w-md flex-col items-center text-center">
        {/* Icon */}
        <div className="mb-6 rounded-2xl border border-border/50 bg-card/50 p-5 shadow-xl backdrop-blur-md">
          <SearchXIcon
            className="h-12 w-12 text-primary/70"
            strokeWidth={1.5}
          />
        </div>

        {/* 404 number */}
        <h1 className="mb-2 text-8xl leading-none font-black tracking-tighter text-foreground/10 select-none">
          404
        </h1>

        {/* Title & description */}
        <h2 className="mb-3 text-2xl font-bold tracking-tight text-foreground">
          Página não encontrada
        </h2>
        <p className="mb-8 text-sm leading-relaxed text-muted-foreground">
          A página que você está buscando não existe ou foi movida.
          <br />
          Verifique o endereço ou volte ao início.
        </p>

        {/* Actions */}
        <div className="flex w-full flex-col gap-3 sm:w-auto sm:flex-row">
          <Button
            className="gap-2 bg-primary hover:bg-primary/90"
            onClick={() => navigate("/")}
          >
            <HomeIcon className="h-4 w-4" />
            Ir para o Início
          </Button>
        </div>
      </div>
    </div>
  )
}
