import { Link } from "react-router-dom"
import { Book, Mic, FileText, GraduationCap, ArrowRight, Lock } from "lucide-react"
import { Button } from "@/components/ui/button"
import { TEACHING_MODULES, type TeachingModule } from "@/data/landingData"

export function LandingEnsinosSection() {
  const renderIcon = (name: TeachingModule["iconName"]) => {
    switch (name) {
      case "book":
        return <Book className="h-6 w-6 text-emerald-700 dark:text-emerald-400" />
      case "mic":
        return <Mic className="h-6 w-6 text-amber-700 dark:text-amber-400" />
      case "fileText":
        return <FileText className="h-6 w-6 text-teal-700 dark:text-teal-400" />
      case "graduationCap":
        return <GraduationCap className="h-6 w-6 text-zinc-700 dark:text-zinc-300" />
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
            Aqui você encontra um repositório de ensinos, apostilas e artigos, todos com acesso livre, para que você possa crescer no conhecimento do nosso Senhor e para que a edificação do corpo seja rica e profunda. Esta seção é sempre atualizada com novos materiais, confira!
          </p>
        </div>

        {/* 4 Cards Grid (matching mockup) */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {TEACHING_MODULES.map((module) => (
            <div
              key={module.id}
              className="group relative flex flex-col justify-between overflow-hidden rounded-2xl border border-border/60 bg-gradient-to-b from-card via-card to-muted/20 p-6 shadow-2xs transition-all duration-300 hover:border-primary/50 hover:shadow-md hover:-translate-y-1"
            >
              {/* Background Ambient Glow */}
              <div
                className={`pointer-events-none absolute inset-0 -z-10 bg-gradient-to-br ${module.bgPattern} opacity-50 transition-opacity group-hover:opacity-100`}
              />

              <div>
                {/* Icon Container */}
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-background border border-border/60 shadow-xs mb-5 transition-transform group-hover:scale-105">
                  {renderIcon(module.iconName)}
                </div>

                {/* Module Title */}
                <h3 className="text-lg sm:text-xl font-bold font-serif tracking-tight text-foreground">
                  {module.title}
                </h3>

                {/* Description */}
                <p className="mt-2 text-xs leading-relaxed text-muted-foreground">
                  {module.description}
                </p>
              </div>

              {/* Bottom Action Area */}
              <div className="mt-6 pt-4 border-t border-border/30 flex flex-col gap-2">
                {module.isLocked ? (
                  <div className="space-y-2">
                    <div className="flex items-center gap-1.5 text-[11px] font-medium text-muted-foreground">
                      <Lock className="h-3 w-3 shrink-0 text-amber-600 dark:text-amber-400" />
                      <span>{module.badgeText}</span>
                    </div>
                    <Button
                      asChild
                      variant="outline"
                      size="sm"
                      className="min-h-[44px] w-full justify-center rounded-full text-xs font-semibold hover:bg-muted"
                    >
                      <Link to={module.link}>
                        {module.buttonText}
                        <ArrowRight className="ml-1 h-3.5 w-3.5" />
                      </Link>
                    </Button>
                  </div>
                ) : (
                  <Button
                    asChild
                    size="sm"
                    className="min-h-[44px] w-full justify-center rounded-full text-xs font-semibold bg-primary text-primary-foreground hover:bg-primary/90 shadow-xs"
                  >
                    <Link to={module.link}>
                      {module.buttonText}
                      <ArrowRight className="ml-1.5 h-3.5 w-3.5" />
                    </Link>
                  </Button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
