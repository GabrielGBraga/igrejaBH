import { Link } from "react-router-dom"
import { ArrowLeft, Construction } from "lucide-react"
import { LandingHeader } from "@/components/landing/LandingHeader"
import { LandingFooter } from "@/components/landing/LandingFooter"
import { Button } from "@/components/ui/button"

export default function QuemSomos() {
  return (
    <div className="flex min-h-screen w-full flex-col overflow-x-hidden bg-background text-foreground antialiased selection:bg-primary/20 selection:text-primary">
      <LandingHeader />

      <main className="flex-1 w-full flex items-center justify-center py-24 sm:py-32 px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-md mx-auto space-y-4">
          <div className="inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-muted/60 text-muted-foreground mb-2">
            <Construction className="h-8 w-8 text-primary" />
          </div>

          <h1 className="text-2xl sm:text-3xl md:text-4xl font-extrabold tracking-tight text-foreground">
            Em construção
          </h1>

          <div className="pt-4">
            <Button
              asChild
              variant="outline"
              size="sm"
              className="min-h-[44px] rounded-lg px-6 text-xs font-semibold"
            >
              <Link to="/">
                <ArrowLeft className="mr-2 h-4 w-4" />
                Voltar à Página Inicial
              </Link>
            </Button>
          </div>
        </div>
      </main>

      <LandingFooter />
    </div>
  )
}
