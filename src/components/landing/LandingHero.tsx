import { LandingLandscapeCarousel } from "@/components/landing/LandingLandscapeCarousel"
import { CatequeseDiaria } from "@/components/study/CatequeseDiaria"

export function LandingHero() {
  return (
    <section className="relative w-full border-b border-border/40 pt-0 pb-12 sm:pb-16">
      {/* 1. Panoramic Carousel of Belo Horizonte Landscapes */}
      <LandingLandscapeCarousel />

      {/* 2. Hero Content Container */}
      <div className="animate-section-enter mx-auto mt-8 max-w-5xl px-4 text-center sm:mt-12 sm:px-6 lg:px-8">
        {/* Main Title */}
        <h1 className="text-2xl font-extrabold tracking-tight text-foreground sm:text-4xl md:text-5xl">
          Discípulos de Jesus em Belo Horizonte
        </h1>

        {/* Biblical mandate subtitle */}
        <p className="mx-auto mt-3 max-w-2xl text-xs font-medium text-muted-foreground sm:text-sm md:text-base">
          Atendendo a ordem do nosso mestre:{" "}
          <span className="font-serif text-foreground/90 italic">
            &ldquo;Ide e fazei discípulos de todas as nações...&rdquo; (Mt
            28:19)
          </span>
        </p>

        {/* 3. Real Interactive Catequese Diária Component */}
        <div className="mt-8 text-left">
          <CatequeseDiaria className="mx-auto w-full max-w-3xl shadow-sm" />
        </div>
      </div>
    </section>
  )
}
