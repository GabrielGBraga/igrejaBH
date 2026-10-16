import { CatequeseDiaria } from "@/components/study/CatequeseDiaria"

export function LandingHero() {
  return (
    <section className="relative w-full border-b border-border/40 pb-12 pt-0 sm:pb-16">
      {/* 1. Panoramic Banner of Belo Horizonte */}
      <div className="w-full relative overflow-hidden h-[240px] sm:h-[320px] md:h-[400px] lg:h-[460px]">
        <img
          src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Belo_Horizonte_view_081610.jpg/1920px-Belo_Horizonte_view_081610.jpg"
          alt="Vista panorâmica da cidade de Belo Horizonte com a Serra do Curral ao fundo"
          className="w-full h-full object-cover object-center"
          loading="eager"
        />
        {/* Subtle gradient vignette to blend into content */}
        <div className="absolute inset-0 bg-gradient-to-t from-background via-background/20 to-black/30" />
      </div>

      {/* 2. Hero Content Container */}
      <div className="mx-auto max-w-5xl px-4 text-center sm:px-6 lg:px-8 mt-8 sm:mt-12 animate-section-enter">
        {/* Main Title */}
        <h1 className="text-2xl font-extrabold tracking-tight text-foreground sm:text-4xl md:text-5xl">
          Discípulos de Jesus em Belo Horizonte
        </h1>

        {/* Biblical mandate subtitle */}
        <p className="mx-auto mt-3 max-w-2xl text-xs sm:text-sm md:text-base text-muted-foreground font-medium">
          Atendendo a ordem do nosso mestre:{" "}
          <span className="italic text-foreground/90 font-serif">
            &ldquo;Ide e fazei discípulos de todas as nações...&rdquo; (Mt 28:19)
          </span>
        </p>

        {/* 3. Real Interactive Catequese Diária Component */}
        <div className="mt-8 text-left">
          <CatequeseDiaria className="w-full max-w-3xl mx-auto shadow-sm" />
        </div>
      </div>
    </section>
  )
}
