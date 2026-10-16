import { useState } from "react"
import { Sparkles, Users, Home, HeartHandshake, Flame } from "lucide-react"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"

export function LandingAboutSection() {
  const [detailsOpen, setDetailsOpen] = useState(false)

  const pillars = [
    {
      title: "O Propósito Eterno",
      reference: "Romanos 8:29",
      desc: "Ter uma família de muitos filhos à imagem de Jesus Cristo. A salvação é a porta para a transformação diária do nosso caráter.",
      icon: Sparkles,
    },
    {
      title: "Sacerdócio de Todos",
      reference: "1 Pedro 2:9",
      desc: "Sem clero ou leigos. Todos os discípulos são ministros chamados para servir e edificar o Corpo no cotidiano.",
      icon: Users,
    },
    {
      title: "Juntas e Ligamentos",
      reference: "Efésios 4:16",
      desc: "Discipulado pessoal de cuidado mútuo, oração honesta e companheirismo entre irmãos no dia a dia.",
      icon: HeartHandshake,
    },
    {
      title: "Nas Casas e nas Ruas",
      reference: "Atos 20:20",
      desc: "A igreja não é um templo de tijolos, mas as próprias pessoas. Nos lares somos família; nas ruas, proclamadores da graça.",
      icon: Home,
    },
    {
      title: "Evangelho do Reino e Fruto",
      reference: "João 15:8",
      desc: "Dar fruto é reproduzir a vida de Cristo em novos discípulos com arrependimento sincero e amor à verdade.",
      icon: Flame,
    },
  ]

  return (
    <section id="quem-somos" className="scroll-mt-20 py-16 sm:py-20 border-b border-border/40 bg-muted/10">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
        {/* Title */}
        <div className="text-center mb-8 sm:mb-10">
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold tracking-tight text-foreground">
            Quem somos
          </h2>
        </div>

        {/* Text Paragraphs matching mockup */}
        <div className="space-y-6 text-xs sm:text-sm md:text-base leading-relaxed text-muted-foreground text-center sm:text-justify font-sans">
          <p>
            Somos um grupo de discípulos de Jesus, parte da Igreja do Senhor na Grande Belo Horizonte desde o início da década de 1980. Trata-se de uma comunidade não-denominacional que, por revelação bíblica, decidiu não se organizar em grandes templos e possuir placas e nomes. A afirmação bíblica:{" "}
            <span className="italic text-foreground font-serif">
              &ldquo;O Deus que fez o mundo e tudo o que nele existe, sendo ele Senhor do céu e da terra, não habita em santuários feitos por mãos humanas...&rdquo; (At 17:24)
            </span>{" "}
            direciona a nossa fé a esse respeito. Cremos que a igreja é composta por pessoas, e não prédios, e que a sua expressão prática é no dia a dia, de casa em casa, conforme o modelo vivido e deixado pelos Apóstolos.
          </p>

          <p>
            Usamos a expressão &ldquo;Igreja em BH&rdquo; para fazer referência à nossa existência enquanto instituição e presença local. Usamos essa expressão igualmente por revelação bíblica, compreendendo que era assim que a primeira igreja referia-se às comunidades locais que viviam em Unidade de Corpo. Contudo, não usamos essa expressão para nos exaltar do resto da Igreja de Cristo que existe nessa cidade. Somos parte da igreja que Jesus tem aqui na Grande Belo Horizonte.
          </p>
        </div>

        {/* Interactive CTA Link */}
        <div className="mt-8 text-center">
          <button
            type="button"
            onClick={() => setDetailsOpen(true)}
            className="text-xs sm:text-sm font-semibold text-primary underline underline-offset-4 hover:text-primary/80 transition-colors inline-flex items-center gap-1 cursor-pointer"
          >
            Quer saber mais sobre a nossa história e o que cremos, clique aqui.
          </button>
        </div>
      </div>

      {/* Details Dialog */}
      <Dialog open={detailsOpen} onOpenChange={setDetailsOpen}>
        <DialogContent className="max-w-2xl p-6">
          <DialogHeader className="text-left space-y-1.5">
            <div className="inline-flex items-center gap-1.5 text-xs font-semibold text-primary">
              <Badge variant="outline" className="border-primary/20 bg-primary/5 text-primary">
                Fundamentos do Reino
              </Badge>
            </div>
            <DialogTitle className="text-xl font-bold tracking-tight">
              Os Pilares de Fé e Comunhão
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              Sem tradições humanas ou hierarquias burocráticas: vivemos a simplicidade do Evangelho do Reino.
            </DialogDescription>
          </DialogHeader>

          <div className="mt-4 space-y-3 max-h-[60vh] overflow-y-auto pr-1">
            {pillars.map((pillar) => {
              const Icon = pillar.icon
              return (
                <div
                  key={pillar.title}
                  className="flex items-start gap-3 rounded-xl border border-border/60 bg-muted/20 p-3.5"
                >
                  <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                    <Icon className="h-4 w-4" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <h4 className="text-sm font-bold text-foreground">
                        {pillar.title}
                      </h4>
                      <span className="text-[10px] font-semibold text-amber-600 dark:text-amber-400">
                        {pillar.reference}
                      </span>
                    </div>
                    <p className="mt-1 text-xs text-muted-foreground leading-relaxed">
                      {pillar.desc}
                    </p>
                  </div>
                </div>
              )
            })}
          </div>

          <div className="mt-4 pt-3 border-t border-border/40 flex justify-end">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setDetailsOpen(false)}
              className="min-h-[44px] px-4"
            >
              Fechar
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </section>
  )
}
