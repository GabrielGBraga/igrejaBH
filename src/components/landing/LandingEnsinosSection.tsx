import { Link } from "react-router-dom"
import { Book, Mic, FileText, GraduationCap, ArrowRight } from "lucide-react"
import { Button } from "@/components/ui/button"
import { TEACHING_MODULES, type TeachingModule } from "@/data/landingData"

export function LandingEnsinosSection() {
  const renderIcon = (name: TeachingModule["iconName"]) => {
    switch (name) {
      case "book":
        return <Book className="h-5 w-5 text-primary" />
      case "mic":
        return <Mic className="h-5 w-5 text-primary" />
      case "fileText":
        return <FileText className="h-5 w-5 text-primary" />
      case "graduationCap":
        return <GraduationCap className="h-5 w-5 text-primary" />
    }
  }

  return (
    <section id="ensinos" className="scroll-mt-20 py-16 sm:py-20 border-b border-border/40">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-12">
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold tracking-tight text-foreground">
            Ensinos
          </h2>
          <p className="mt-3 text-xs sm:text-sm md:text-base leading-relaxed text-muted-foreground">
            Repositório aberto de trilhas de estudo, apostilas, ministrações e textos bíblicos para o crescimento no conhecimento do Senhor e a edificação mútua do Corpo.
          </p>
        </div>

        {/* 4 Clean Monochromatic Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {TEACHING_MODULES.map((module) => (
            <div
              key={module.id}
              className="flex flex-col justify-between rounded-xl border border-border/70 bg-card p-6 shadow-2xs transition-colors hover:border-border"
            >
              <div>
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 mb-4">
                  {renderIcon(module.iconName)}
                </div>

                <h3 className="text-base sm:text-lg font-bold tracking-tight text-foreground">
                  {module.title}
                </h3>

                <p className="mt-2 text-xs leading-relaxed text-muted-foreground">
                  {module.description}
                </p>
              </div>

              <div className="mt-6 pt-4 border-t border-border/40">
                <Button
                  asChild
                  variant="outline"
                  size="sm"
                  className="min-h-[44px] w-full justify-between rounded-md px-4 text-xs font-semibold"
                >
                  <Link to={module.link}>
                    <span>{module.buttonText}</span>
                    <ArrowRight className="h-3.5 w-3.5" />
                  </Link>
                </Button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
