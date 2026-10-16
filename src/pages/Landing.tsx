import { useState } from "react"
import { LandingHeader } from "@/components/landing/LandingHeader"
import { LandingHero } from "@/components/landing/LandingHero"
import { LandingNewsSection } from "@/components/landing/LandingNewsSection"
import { LandingAgendaSection } from "@/components/landing/LandingAgendaSection"
import { LandingEnsinosSection } from "@/components/landing/LandingEnsinosSection"
import { LandingAboutSection } from "@/components/landing/LandingAboutSection"
import { LandingContactSection } from "@/components/landing/LandingContactSection"
import { LandingFooter } from "@/components/landing/LandingFooter"
import { VisitorWelcomeDialog } from "@/components/landing/VisitorWelcomeDialog"

export default function Landing() {
  const [isWelcomeOpen, setIsWelcomeOpen] = useState(false)

  return (
    <div className="flex min-h-screen w-full flex-col overflow-x-hidden bg-background text-foreground antialiased selection:bg-primary/20 selection:text-primary">
      {/* 1. Header & Navigation */}
      <LandingHeader />

      {/* Main Content Sections */}
      <main className="flex-1 w-full">
        {/* 2. Hero Section: Panoramic Belo Horizonte Skyline + Daily Catechesis */}
        <LandingHero />

        {/* 3. Notícias & Mídia: Ministração em Vídeo + Artigos/Retiros/Missões */}
        <LandingNewsSection />

        {/* 4. Agenda Interativa: Calendário do Mês Vigente + Programação dos Encontros */}
        <LandingAgendaSection onOpenWelcomeDialog={() => setIsWelcomeOpen(true)} />

        {/* 5. Ensinos: Acervo Livre de Apostilas, Ministrações, Artigos e Trilhas de Estudo */}
        <LandingEnsinosSection />

        {/* 6. Quem Somos: Propósito Eterno, Igreja Não-Denominacional e nos Lares */}
        <LandingAboutSection />

        {/* 7. Quer Saber Mais? Ponto de Acolhimento, Conexão e Formulário Rápido */}
        <LandingContactSection onOpenDialog={() => setIsWelcomeOpen(true)} />
      </main>

      {/* 8. Rodapé Completo */}
      <LandingFooter />

      {/* Modal Dialog de Acolhimento nos Grupos Caseiros */}
      <VisitorWelcomeDialog open={isWelcomeOpen} onOpenChange={setIsWelcomeOpen} />
    </div>
  )
}
