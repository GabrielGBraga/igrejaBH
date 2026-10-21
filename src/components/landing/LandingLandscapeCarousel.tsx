import { useState } from "react"

export interface LandscapeImage {
  id: string
  title: string
  src: string
  fallbackSrc: string
  alt: string
}

export const BH_LANDSCAPES: LandscapeImage[] = [
  {
    id: "serra-do-curral",
    title: "Serra do Curral & Skyline",
    src: "/images/landscapes/bh-serra-do-curral.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Belo_Horizonte_view_081610.jpg/1920px-Belo_Horizonte_view_081610.jpg",
    alt: "Vista panorâmica da cidade de Belo Horizonte com a Serra do Curral ao fundo",
  },
  {
    id: "praca-do-papa",
    title: "Praça do Papa & Serra das Mangabeiras",
    src: "/images/landscapes/bh-praca-do-papa.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Praca_do_Papa%2C_Belo_Horizonte_%28cropped%292.jpg/1280px-Praca_do_Papa%2C_Belo_Horizonte_%28cropped%292.jpg",
    alt: "Mirante da Praça do Papa com ampla vista panorâmica de Belo Horizonte",
  },
  {
    id: "lagoa-da-pampulha",
    title: "Orla e Lagoa da Pampulha",
    src: "/images/landscapes/bh-lagoa-pampulha.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Panorama_Mineir%C3%A3o_Pampulha_%28cropped%29.jpg/1280px-Panorama_Mineir%C3%A3o_Pampulha_%28cropped%29.jpg",
    alt: "Paisagem panorâmica da Orla da Lagoa da Pampulha",
  },
  {
    id: "panorama-centro",
    title: "Panorama Urbano e Centro de BH",
    src: "/images/landscapes/bh-panorama-centro.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Belo_Horizonte%2C_Brasil.jpg/1280px-Belo_Horizonte%2C_Brasil.jpg",
    alt: "Vista do centro urbano e horizonte de Belo Horizonte",
  },
]

export function LandingLandscapeCarousel() {
  // Select a landscape image randomly on initial page load / reload only
  const [landscape] = useState(() => {
    const randomIndex = Math.floor(Math.random() * BH_LANDSCAPES.length)
    return BH_LANDSCAPES[randomIndex]
  })
  const [hasError, setHasError] = useState(false)

  return (
    <div className="relative h-[240px] w-full overflow-hidden sm:h-[320px] md:h-[400px] lg:h-[460px]">
      <img
        src={hasError ? landscape.fallbackSrc : landscape.src}
        alt={landscape.alt}
        onError={() => setHasError(true)}
        className="h-full w-full object-cover object-center"
        loading="eager"
      />
      {/* Subtle gradient vignette to blend into content */}
      <div className="pointer-events-none absolute inset-0 bg-gradient-to-t from-background via-background/20 to-black/30" />
    </div>
  )
}
