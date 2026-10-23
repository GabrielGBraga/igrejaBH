import { useState } from "react"
import { BH_LANDSCAPES } from "@/data/landingData"

export function LandingLandscapeCarousel() {
  // Select a landscape image randomly on initial page load / reload only
  const [landscape] = useState(() => {
    const randomIndex = Math.floor(Math.random() * BH_LANDSCAPES.length)
    return BH_LANDSCAPES[randomIndex]
  })
  const [hasError, setHasError] = useState(false)

  return (
    <div className="relative h-[180px] w-full overflow-hidden sm:h-[220px] md:h-[240px] lg:h-[260px] max-h-[30vh] landscape:max-h-[260px]">
      <img
        src={hasError ? landscape.fallbackSrc : landscape.src}
        alt={landscape.alt}
        onError={() => setHasError(true)}
        className="h-full w-full object-cover object-center"
        loading="eager"
      />
      {/* Subtle gradient vignette to blend into content */}
      <div className="pointer-events-none absolute inset-0 bg-gradient-to-t from-background via-background/10 to-black/20" />
    </div>
  )
}
