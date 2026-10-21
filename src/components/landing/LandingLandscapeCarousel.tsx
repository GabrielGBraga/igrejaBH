import { useState, useEffect, useRef, useCallback } from "react"
import Autoplay from "embla-carousel-autoplay"
import { MapPin, Pause, Play, Camera } from "lucide-react"

import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselPrevious,
  CarouselNext,
  type CarouselApi,
} from "@/components/ui/carousel"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"

export interface LandscapeImage {
  id: string
  title: string
  subtitle: string
  location: string
  src: string
  fallbackSrc: string
  alt: string
}

export const BH_LANDSCAPES: LandscapeImage[] = [
  {
    id: "serra-do-curral",
    title: "Serra do Curral & Skyline",
    subtitle: "A imponência da serra símbolo que emoldura a capital mineira",
    location: "Belo Horizonte, MG",
    src: "/images/landscapes/bh-serra-do-curral.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Belo_Horizonte_view_081610.jpg/1920px-Belo_Horizonte_view_081610.jpg",
    alt: "Vista panorâmica da cidade de Belo Horizonte com a Serra do Curral ao fundo",
  },
  {
    id: "praca-do-papa",
    title: "Praça do Papa & Mirante das Mangabeiras",
    subtitle: "Mirante natural contemplando a vastidão urbana da capital",
    location: "Mangabeiras, Belo Horizonte",
    src: "/images/landscapes/bh-praca-do-papa.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Praca_do_Papa%2C_Belo_Horizonte_%28cropped%292.jpg/1280px-Praca_do_Papa%2C_Belo_Horizonte_%28cropped%292.jpg",
    alt: "Mirante da Praça do Papa com ampla vista panorâmica de Belo Horizonte",
  },
  {
    id: "lagoa-da-pampulha",
    title: "Orla e Lagoa da Pampulha",
    subtitle: "Espelho d'água e relevo suave ao norte de Belo Horizonte",
    location: "Pampulha, Belo Horizonte",
    src: "/images/landscapes/bh-lagoa-pampulha.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Panorama_Mineir%C3%A3o_Pampulha_%28cropped%29.jpg/1280px-Panorama_Mineir%C3%A3o_Pampulha_%28cropped%29.jpg",
    alt: "Paisagem panorâmica da Orla da Lagoa da Pampulha",
  },
  {
    id: "panorama-centro",
    title: "Panorama Urbano e Centro de BH",
    subtitle: "A confluência entre o relevo montanhoso e as avenidas da cidade",
    location: "Região Central, Belo Horizonte",
    src: "/images/landscapes/bh-panorama-centro.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Belo_Horizonte%2C_Brasil.jpg/1280px-Belo_Horizonte%2C_Brasil.jpg",
    alt: "Vista do centro urbano e horizonte de Belo Horizonte",
  },
]

export function LandingLandscapeCarousel() {
  const [api, setApi] = useState<CarouselApi>()
  const [current, setCurrent] = useState(0)
  const [isPlaying, setIsPlaying] = useState(true)
  const [imageErrors, setImageErrors] = useState<Record<string, boolean>>({})

  // Detect user motion preferences
  const prefersReducedMotion =
    typeof window !== "undefined" &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches

  // Initialize autoplay plugin (delay 5500ms, paused if user prefers reduced motion)
  const autoplayRef = useRef(
    Autoplay({
      delay: 5500,
      stopOnInteraction: false,
      stopOnMouseEnter: true,
      active: !prefersReducedMotion,
    })
  )

  useEffect(() => {
    if (!api) return

    setCurrent(api.selectedScrollSnap())

    const handleSelect = () => {
      setCurrent(api.selectedScrollSnap())
    }

    api.on("select", handleSelect)
    api.on("reInit", handleSelect)

    return () => {
      api.off("select", handleSelect)
      api.off("reInit", handleSelect)
    }
  }, [api])

  const toggleAutoplay = useCallback(() => {
    const autoplay = autoplayRef.current
    if (!autoplay) return

    if (isPlaying) {
      autoplay.stop()
      setIsPlaying(false)
    } else {
      autoplay.play()
      setIsPlaying(true)
    }
  }, [isPlaying])

  const handleImageError = (id: string) => {
    setImageErrors((prev) => ({ ...prev, [id]: true }))
  }

  const currentLandscape = BH_LANDSCAPES[current] || BH_LANDSCAPES[0]

  return (
    <div
      className="group relative w-full overflow-hidden select-none"
      aria-roledescription="carrossel de fotos"
      aria-label="Paisagens de Belo Horizonte"
    >
      <Carousel
        setApi={setApi}
        plugins={[autoplayRef.current]}
        opts={{
          loop: true,
          align: "start",
        }}
        className="w-full"
      >
        <CarouselContent
          className="ml-0"
          containerClassName="w-full h-[260px] sm:h-[340px] md:h-[420px] lg:h-[480px]"
        >
          {BH_LANDSCAPES.map((item, index) => {
            const isErrored = imageErrors[item.id]
            const imgSrc = isErrored ? item.fallbackSrc : item.src

            return (
              <CarouselItem
                key={item.id}
                className="relative h-full w-full pl-0"
                aria-roledescription="slide"
                aria-label={`${index + 1} de ${BH_LANDSCAPES.length}: ${item.title}`}
              >
                <div className="relative h-full w-full overflow-hidden bg-muted/40">
                  <img
                    src={imgSrc}
                    alt={item.alt}
                    onError={() => handleImageError(item.id)}
                    loading={index === 0 ? "eager" : "lazy"}
                    decoding="async"
                    className="h-full w-full scale-100 transform object-cover object-center transition-transform duration-700 group-hover:scale-105 motion-reduce:transition-none"
                  />
                  {/* Dark gradient vignettes for contrast and bottom blending */}
                  <div className="absolute inset-0 bg-gradient-to-t from-background via-background/25 to-black/40" />
                  <div className="absolute inset-0 bg-black/10 dark:bg-black/20" />
                </div>
              </CarouselItem>
            )
          })}
        </CarouselContent>

        {/* Previous Button - 44px min touch target */}
        <CarouselPrevious
          className="left-2 z-20 min-h-[44px] min-w-[44px] border border-border/50 bg-background/80 text-foreground shadow-md backdrop-blur-md transition-opacity duration-200 hover:bg-background sm:left-4"
          aria-label="Foto anterior"
        />

        {/* Next Button - 44px min touch target */}
        <CarouselNext
          className="right-2 z-20 min-h-[44px] min-w-[44px] border border-border/50 bg-background/80 text-foreground shadow-md backdrop-blur-md transition-opacity duration-200 hover:bg-background sm:right-4"
          aria-label="Próxima foto"
        />
      </Carousel>

      {/* Top Controls: Location & Play/Pause */}
      <div className="absolute top-3 right-3 z-20 flex items-center gap-2 sm:top-4 sm:right-4">
        <Button
          type="button"
          variant="outline"
          size="icon"
          onClick={toggleAutoplay}
          className="min-h-[44px] min-w-[44px] cursor-pointer rounded-full border border-border/50 bg-background/80 text-foreground shadow-md backdrop-blur-md transition-all hover:bg-background"
          aria-label={
            isPlaying
              ? "Pausar troca automática de fotos"
              : "Iniciar troca automática de fotos"
          }
          title={
            isPlaying
              ? "Pausar reprodução automática"
              : "Iniciar reprodução automática"
          }
        >
          {isPlaying ? (
            <Pause className="size-4" data-icon="inline-start" />
          ) : (
            <Play className="size-4 translate-x-0.5" data-icon="inline-start" />
          )}
          <span className="sr-only">
            {isPlaying ? "Pausar carrossel" : "Reproduzir carrossel"}
          </span>
        </Button>
      </div>

      {/* Top Left: Photographic attribution badge */}
      <div className="absolute top-3 left-3 z-20 flex items-center gap-2 sm:top-4 sm:left-4">
        <Badge
          variant="outline"
          className="gap-1.5 rounded-full border-border/50 bg-background/80 px-3 py-1 text-[11px] font-medium text-foreground shadow-sm backdrop-blur-md"
        >
          <Camera className="size-3.5 text-primary" />
          <span>Belo Horizonte</span>
        </Badge>
      </div>

      {/* Bottom Info Overlay Badge: Title, Subtitle, Counter */}
      <div className="pointer-events-none absolute bottom-12 left-3 z-20 max-w-[calc(100%-4rem)] sm:bottom-14 sm:left-6 sm:max-w-lg">
        <div className="pointer-events-auto rounded-xl border border-white/15 bg-black/60 px-3.5 py-2.5 text-white shadow-xl backdrop-blur-md transition-all duration-300 sm:px-4 sm:py-3">
          <div className="flex items-center gap-2 text-[10px] font-semibold tracking-wider text-white/80 uppercase sm:text-xs">
            <MapPin className="size-3 shrink-0 text-primary" />
            <span className="truncate">{currentLandscape.location}</span>
            <span className="text-white/40">•</span>
            <span className="font-mono tabular-nums">
              {current + 1} / {BH_LANDSCAPES.length}
            </span>
          </div>
          <h2 className="mt-1 text-sm font-bold tracking-tight text-white drop-shadow-sm sm:text-base md:text-lg">
            {currentLandscape.title}
          </h2>
          <p className="mt-0.5 hidden text-xs text-white/80 sm:line-clamp-1">
            {currentLandscape.subtitle}
          </p>
        </div>
      </div>

      {/* Bottom Pagination Dots (Each having 44x44px touch target) */}
      <div
        className="pointer-events-auto absolute inset-x-0 bottom-3 z-20 flex items-center justify-center gap-1"
        role="tablist"
        aria-label="Seleção de fotos"
      >
        {BH_LANDSCAPES.map((item, index) => {
          const isSelected = current === index
          return (
            <button
              key={item.id}
              type="button"
              role="tab"
              aria-selected={isSelected}
              aria-label={`Ir para a foto ${index + 1}: ${item.title}`}
              onClick={() => api?.scrollTo(index)}
              className="flex min-h-[44px] min-w-[44px] cursor-pointer items-center justify-center rounded-full p-1 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-primary"
            >
              <span
                className={cn(
                  "block h-2 rounded-full transition-all duration-300",
                  isSelected
                    ? "w-7 bg-primary shadow-sm"
                    : "w-2 bg-white/60 hover:bg-white dark:bg-zinc-400/60"
                )}
              />
            </button>
          )
        })}
      </div>
    </div>
  )
}
