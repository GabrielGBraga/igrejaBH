import { useState } from "react"
import { BH_LANDSCAPES } from "@/data/landingData"
import { cn } from "@/lib/utils"

export function LandingLandscapeCarousel() {
  // Select a landscape image randomly on initial page load / reload only
  const [landscape] = useState(() => {
    const randomIndex = Math.floor(Math.random() * BH_LANDSCAPES.length)
    return BH_LANDSCAPES[randomIndex]
  })
  const [hasError, setHasError] = useState(false)
  const [isLoaded, setIsLoaded] = useState(false)

  return (
    <div className="relative h-[180px] w-full overflow-hidden bg-muted/40 sm:h-[220px] md:h-[240px] lg:h-[260px] max-h-[30vh] landscape:max-h-[260px]">
      <img
        src={hasError ? landscape.fallbackSrc : landscape.src}
        alt={landscape.alt}
        onError={() => setHasError(true)}
        onLoad={() => setIsLoaded(true)}
        className={cn(
          "h-full w-full object-cover object-center transition-opacity duration-500 ease-out",
          isLoaded ? "opacity-100" : "opacity-0"
        )}
        loading="eager"
        decoding="async"
      />
      {/* Subtle gradient vignette to blend into content */}
      <div className="pointer-events-none absolute inset-0 bg-gradient-to-t from-background via-background/10 to-black/20" />
    </div>
  )
}
