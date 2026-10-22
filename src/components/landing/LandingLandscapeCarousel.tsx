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
