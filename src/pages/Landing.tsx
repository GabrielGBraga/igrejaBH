import { LandingHeader } from "@/components/landing/LandingHeader"
import { LandingHero } from "@/components/landing/LandingHero"
import { LandingNewsSection } from "@/components/landing/LandingNewsSection"
import { LandingAgendaSection } from "@/components/landing/LandingAgendaSection"
import { LandingEnsinosSection } from "@/components/landing/LandingEnsinosSection"
import { LandingAboutSection } from "@/components/landing/LandingAboutSection"
import { LandingContactSection } from "@/components/landing/LandingContactSection"
import { LandingFooter } from "@/components/landing/LandingFooter"

export default function Landing() {
  return (
    <div className="flex min-h-screen w-full flex-col overflow-x-hidden bg-background text-foreground antialiased selection:bg-primary/20 selection:text-primary">
      <LandingHeader />

      <main className="flex-1 w-full">
        <LandingHero />
        <LandingNewsSection />
        <LandingAgendaSection />
        <LandingEnsinosSection />
        <LandingAboutSection />
        <LandingContactSection />
      </main>

      <LandingFooter />
    </div>
  )
}
