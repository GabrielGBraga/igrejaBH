import { LandingLandscapeCarousel } from "@/components/landing/LandingLandscapeCarousel"
import { CatequeseDiaria } from "@/components/study/CatequeseDiaria"

export function LandingHero() {
  return (
    <section className="relative w-full border-b border-border/40 pt-0 pb-12 sm:pb-16">
      {/* 1. Panoramic Carousel of Belo Horizonte Landscapes */}
      <LandingLandscapeCarousel />

      {/* 2. Hero Content Container */}
      <div className="animate-section-enter mx-auto mt-6 max-w-5xl px-4 text-center sm:mt-8 md:mt-10 sm:px-6 lg:px-8">
        <h1 className="text-2xl font-extrabold tracking-tight text-foreground sm:text-4xl md:text-5xl flex flex-col items-center gap-1 sm:gap-2">
          <span>Discípulos de Jesus</span>
          <span className="text-lg font-semibold tracking-normal text-muted-foreground sm:text-2xl md:text-3xl">
            Belo Horizonte - MG
          </span>
        </h1>

        {/* 3. Catequese Diária do Sistema de Estudos */}
        <div className="mt-8 sm:mt-10 text-left">
          <CatequeseDiaria
            variant="blended"
            className="mx-auto max-w-4xl"
            compact={false}
          />
        </div>
      </div>
    </section>
  )
}
