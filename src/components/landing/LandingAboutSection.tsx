import { Link } from "react-router-dom"
import { ArrowRight } from "lucide-react"
import { Button } from "@/components/ui/button"

const FOUNDATIONS = [
  {
    title: "O Propósito Eterno",
    reference: "Romanos 8:29",
    desc: "O desígnio de Deus desde a eternidade é ter uma família de muitos filhos semelhantes a Jesus. A salvação é o início dessa transformação.",
  },
  {
    title: "Sacerdócio de Todos",
    reference: "1 Pedro 2:9",
    desc: "Sem divisão entre clero e leigos. Todo discípulo é chamado para servir e edificar o Corpo de Cristo no dia a dia.",
  },
  {
    title: "Juntas e Ligamentos",
    reference: "Efésios 4:16",
    desc: "A igreja é sustentada por relacionamentos reais de discipulado (vida na vida) e companheirismo mútuo em oração e cuidado.",
  },
  {
    title: "Nas Casas e nas Ruas",
    reference: "Atos 20:20",
    desc: "A igreja são as pessoas, não um prédio. Nos reunimos nos lares para comunhão e ensino, e nas ruas proclamamos o Evangelho do Reino.",
  },
]

export function LandingAboutSection() {
  return (
    <section id="quem-somos" className="scroll-mt-20 py-16 sm:py-20 border-b border-border/40 bg-muted/10">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
        {/* Title */}
        <div className="text-center mb-8 sm:mb-10">
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold tracking-tight text-foreground">
            Quem somos
          </h2>
        </div>

        {/* Core Identity Paragraphs */}
        <div className="space-y-5 text-xs sm:text-sm md:text-base leading-relaxed text-muted-foreground text-left sm:text-justify font-sans">
          <p>
            Somos discípulos de Jesus e parte da Igreja do Senhor na Grande Belo Horizonte desde o início da década de 1980. Como comunidade não-denominacional, não nos organizamos em torno de templos físicos, placas ou marcas religiosas. A afirmação bíblica:{" "}
            <span className="italic text-foreground font-serif">
              &ldquo;O Deus que fez o mundo e tudo o que nele existe, sendo ele Senhor do céu e da terra, não habita em santuários feitos por mãos humanas...&rdquo; (At 17:24)
            </span>{" "}
            orienta a nossa caminhada. Cremos que a igreja são as pessoas reconciliadas com Deus, vivendo a fé no cotidiano, de casa em casa, conforme o ensino dos apóstolos.
          </p>

          <p>
            Usamos a expressão &ldquo;Discípulos de Jesus em Belo Horizonte&rdquo; como identificação bíblica da nossa comunhão local, reconhecendo que o Corpo de Cristo na cidade é um só e não está dividido em denominações. Somos irmãos de todos os que pertencem ao Senhor Jesus em nossa região.
          </p>
        </div>

        {/* Clean Editorial Grid of Biblical Foundations */}
        <div className="mt-10 grid grid-cols-1 sm:grid-cols-2 gap-4 pt-8 border-t border-border/40">
          {FOUNDATIONS.map((item) => (
            <div
              key={item.title}
              className="rounded-xl border border-border/60 bg-card p-5"
            >
              <div className="flex items-baseline justify-between gap-2">
                <h3 className="text-sm sm:text-base font-bold text-foreground">
                  {item.title}
                </h3>
                <span className="text-xs font-medium text-primary shrink-0">
                  {item.reference}
                </span>
              </div>
              <p className="mt-2 text-xs leading-relaxed text-muted-foreground">
                {item.desc}
              </p>
            </div>
          ))}
        </div>

        {/* Dedicated Page Action Button */}
        <div className="mt-10 flex justify-center">
          <Button
            asChild
            size="lg"
            className="min-h-[44px] rounded-full px-8 text-sm font-semibold shadow-xs bg-primary text-primary-foreground hover:bg-primary/90"
          >
            <Link to="/quem-somos">
              Conheça nossa fé em detalhes
              <ArrowRight className="ml-2 h-4 w-4" />
            </Link>
          </Button>
        </div>
      </div>
    </section>
  )
}
