import { Link } from "react-router-dom"
import { ArrowRight, BookOpen } from "lucide-react"
import { Button } from "@/components/ui/button"
import { LandingLandscapeCarousel } from "@/components/landing/LandingLandscapeCarousel"
import { LandingCatequeseQuote } from "@/components/landing/LandingCatequeseQuote"

export function LandingHero() {
  return (
    <section className="relative w-full border-b border-border/40 pt-0 pb-12 sm:pb-16">
      {/* 1. Panoramic Carousel of Belo Horizonte Landscapes */}
      <LandingLandscapeCarousel />

      {/* 2. Hero Content Container */}
      <div className="animate-section-enter mx-auto mt-6 max-w-4xl px-4 text-center sm:mt-8 md:mt-10 sm:px-6 lg:px-8">
        <h1 className="text-2xl font-extrabold tracking-tight text-foreground sm:text-4xl md:text-5xl">
          Igreja em Belo Horizonte
        </h1>

        <p className="mx-auto mt-3 max-w-2xl text-sm leading-relaxed text-muted-foreground sm:text-base">
          Discípulos de Jesus reunidos de casa em casa e nas ruas da cidade, buscando viver como família à semelhança de Cristo.
        </p>

        {/* Primary Relational Actions */}
        <div className="mt-7 flex flex-col items-center justify-center gap-3 sm:flex-row">
          <Button
            asChild
            size="lg"
            className="min-h-[44px] w-full rounded-full px-7 text-sm font-semibold sm:w-auto"
          >
            <Link to="/quero-saber-mais">
              Caminhe Conosco
              <ArrowRight className="ml-2 h-4 w-4" />
            </Link>
          </Button>

          <Button
            asChild
            variant="outline"
            size="lg"
            className="min-h-[44px] w-full rounded-full px-7 text-sm font-medium sm:w-auto"
          >
            <Link to="/ensinos">
              <BookOpen className="mr-2 h-4 w-4" />
              Acessar Ensinos
            </Link>
          </Button>
        </div>

        {/* Simple, understated Catechesis Scripture Quote (rotates on each page load) */}
        <LandingCatequeseQuote />
      </div>
    </section>
  )
}

