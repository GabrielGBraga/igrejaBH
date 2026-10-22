import { useState } from "react"
import { getRandomCatequeseVerse, type CatequeseVerseEntry } from "@/data/catequese"

export interface LandingCatequeseQuoteProps {
  className?: string
}

/**
 * Componente editorial simples e sóbrio para o texto bíblico da catequese na Hero da Landing Page.
 * - Sorteia um novo texto bíblico da catequese a cada page load / reload.
 * - Livre de sobrecargas de informação, cards pesados, botões concorrentes ou badges (Anti-AI Slop).
 */
export function LandingCatequeseQuote({ className = "" }: LandingCatequeseQuoteProps) {
  // Sorteia um dos textos bíblicos da catequese a cada montagem inicial / reload da página
  const [verse] = useState<CatequeseVerseEntry>(() => getRandomCatequeseVerse())

  if (!verse) return null

  return (
    <figure
      className={`mx-auto mt-10 max-w-2xl border-t border-border/50 pt-6 text-center ${className}`}
    >
      <blockquote className="font-serif text-sm italic leading-relaxed text-foreground/90 sm:text-base">
        &ldquo;{verse.quote}&rdquo;
      </blockquote>
      <figcaption className="mt-2 text-xs font-medium text-muted-foreground">
        {verse.reference} &middot; {verse.theme}
      </figcaption>
    </figure>
  )
}
