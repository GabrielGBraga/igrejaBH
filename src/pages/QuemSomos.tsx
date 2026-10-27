import { Link } from "react-router-dom"
import {
  ArrowLeft,
  ArrowRight,
  BookOpen,
  HeartHandshake,
  Users,
  Home,
  ShieldCheck,
  Instagram,
  Youtube,
  MessageCircle,
} from "lucide-react"
import { LandingHeader } from "@/components/landing/LandingHeader"
import { LandingFooter } from "@/components/landing/LandingFooter"
import { Button } from "@/components/ui/button"

const PILLARS_OF_FAITH = [
  {
    number: "01",
    title: "O Propósito Eterno de Deus",
    summary: "Uma família de muitos filhos semelhantes a Jesus Cristo.",
    verses: [
      {
        ref: "Romanos 8:28-29",
        text: "Porquanto aos que de antemão conheceu, também os predestinou para serem conformes à imagem de seu Filho, a fim de que ele seja o primogênito entre muitos irmãos.",
      },
      {
        ref: "Gênesis 1:26",
        text: "Também disse Deus: Façamos o homem à nossa imagem, conforme a nossa semelhança; tenha ele domínio sobre os peixes do mar, sobre as aves dos céus...",
      },
    ],
    content: `Antes de lançar os fundamentos da terra, Deus traçou em Seu coração um desígnio eterno: ter uma grande família de muitos filhos semelhantes a Jesus Cristo. O homem não foi criado apenas para habitar o planeta, mas para expressar o caráter de Deus e exercer Seu governo santo em amor.

Quando o homem caiu em pecado, tornou-se inútil para o propósito original, mas Deus jamais desistiu do Seu plano. Em Cristo, fomos recriados para a glória do Pai. Por isso, compreendemos que a salvação não é um fim em si mesma, mas a porta de entrada indispensável para que a vida de Cristo seja gerada e manifestada em nós dia após dia.`,
  },
  {
    number: "02",
    title: "Jesus Cristo: Senhor, Centro e Cabeça",
    summary: "O Verbo eterno feito homem, morto por nós, ressurreto e exaltado.",
    verses: [
      {
        ref: "Filipenses 2:9-11",
        text: "Pelo que também Deus o exaltou sobremaneira e lhe deu o nome que está acima de todo nome, para que ao nome de Jesus se dobre todo joelho... e toda língua confesse que Jesus Cristo é Senhor.",
      },
      {
        ref: "João 1:1, 14",
        text: "No princípio era o Verbo, e o Verbo estava com Deus, e o Verbo era Deus... E o Verbo se fez carne e habitou entre nós, cheio de graça e de verdade.",
      },
    ],
    content: `Cremos na plena divindade e perfeita humanidade de Jesus Cristo. Ele existia antes de todas as coisas e por Ele tudo foi criado. Esvaziou-se a Si mesmo, assumiu a forma de servo, viveu de maneira santa, mansa e irrepreensível, e entregou Sua vida na cruz como sacrifício expiatório pelos nossos pecados.

Ressuscitou corporalmente ao terceiro dia, rompendo para sempre os grilhões da morte, e subiu aos céus, sendo constituído por Deus Pai como único Senhor e Cristo (Atos 2:36). Ele é o Cabeça supremo da Sua Igreja e o único mediador entre Deus e os homens.`,
  },
  {
    number: "03",
    title: "O Evangelho do Reino e o Discipulado",
    summary: "O chamado para renunciar a si mesmo e seguir a Cristo na prática.",
    verses: [
      {
        ref: "Mateus 28:19-20",
        text: "Ide, portanto, fazei discípulos de todas as nações, batizando-os em nome do Pai, e do Filho, e do Espírito Santo; ensinando-os a guardar todas as coisas que vos tenho ordenado.",
      },
      {
        ref: "Lucas 14:33",
        text: "Assim, pois, todo aquele dentre vós que não renuncia a tudo quanto tem não pode ser meu discípulo.",
      },
    ],
    content: `Proclamamos o Evangelho do Reino conforme anunciado pelos apóstolos no dia de Pentecostes: arrependimento sincero de pecados e obras mortas, fé submissa no Senhor Jesus, batismo nas águas por imersão para remissão de pecados e o recebimento do dom do Espírito Santo (Atos 2:38).

Seguir a Jesus não é uma adesão formal a uma lista de dogmas, mas uma entrega total do nosso ser. O discípulo coloca todas as áreas de sua existência — mente, tempo, recursos, família e trabalho — sob o senhorio prático de Cristo, aprendendo a obedecer aos Seus mandamentos.`,
  },
  {
    number: "04",
    title: "Sacerdócio Universal de Todos os Santos",
    summary: "Sem clero e sem leigos: cada discípulo é ministro ativo do Corpo.",
    verses: [
      {
        ref: "1 Pedro 2:9",
        text: "Vós, porém, sois raça eleita, sacerdócio real, nação santa, povo de propriedade exclusiva de Deus, a fim de proclamardes as virtudes daquele que vos chamou das trevas para a sua maravilhosa luz.",
      },
      {
        ref: "Efésios 4:11-12",
        text: "E ele mesmo concedeu uns para apóstolos, outros para profetas, outros para evangelistas e outros para pastores e mestres, com vistas ao aperfeiçoamento dos santos para o desempenho do seu serviço...",
      },
    ],
    content: `Rejeitamos firmemente qualquer divisão hierárquica entre "clero" e "leigos". No Novo Testamento, todo aquele que foi regenerado pelo sangue de Cristo é constituído sacerdote diante de Deus. Todos temos acesso direto ao trono da graça e todos fomos capacitados pelo Espírito com dons espirituais para o serviço mútuo.

Os ministérios de liderança (presbíteros e diáconos) existem não como detentores de poder pastoral centralizado ou super-estrelas de púlpito, mas como irmãos maduros e servos que equipam os santos para que os próprios santos façam a obra do ministério.`,
  },
  {
    number: "05",
    title: "Edificação por Juntas e Ligamentos",
    summary: "A vida na vida: discipulado relacional, oração e cuidado mútuo.",
    verses: [
      {
        ref: "Efésios 4:16",
        text: "De quem todo o corpo, bem ajustado e consolidado pelo auxílio de toda junta, segundo a justa cooperação de cada parte, efetua o seu próprio aumento para a edificação de si mesmo em amor.",
      },
      {
        ref: "Colossenses 2:19",
        text: "...o corpo, suprido e bem vinculado por suas juntas e ligamentos, cresce o crescimento que procede de Deus.",
      },
    ],
    content: `A igreja de Jesus não cresce de maneira sadia através de programas frios ou eventos de entretenimento, mas por relacionamentos genuínos e profundos. Chamamos isso de "juntas e ligamentos": laços de discipulado pessoal e companheirismo sincero.

Na vida cotidiana, os irmãos andam juntos, oram uns pelos outros, abrem seus lares, confessam suas fraquezas, encorajam na obediência e corrigem em amor. Cada irmão é uma junta indispensável para a nutrição e proteção do Corpo de Cristo.`,
  },
  {
    number: "06",
    title: "A Dinâmica da Igreja: Nas Casas e nas Ruas",
    summary: "A igreja são as pessoas salvas, não um templo feito por mãos humanas.",
    verses: [
      {
        ref: "Atos 17:24",
        text: "O Deus que fez o mundo e tudo o que nele existe, sendo ele Senhor do céu e da terra, não habita em santuários feitos por mãos humanas.",
      },
      {
        ref: "Atos 20:20",
        text: "Jamais deixando de vos anunciar coisa alguma que fosse proveitosa e de vo-la ensinar publicamente e também de casa em casa.",
      },
    ],
    content: `Não possuímos nem buscamos templos físicos monumentais. O templo vivo do Espírito Santo somos nós, o povo reunido! A dinâmica da igreja primitiva transcorria essencialmente em dois ambientes: nas casas e nas ruas.

Nas casas, as famílias e discípulos se encontram para partir o pão, orar, examinar as Escrituras e suprir as necessidades uns dos outros. Nas ruas e nos ambientes de trabalho, a igreja está no meio da sociedade para proclamar as boas-novas, demonstrar compaixão e testemunhar a ressurreição do Senhor.`,
  },
  {
    number: "07",
    title: "Unidade da Igreja na Cidade (Corpo Único)",
    summary: "Uma comunhão sem divisões denominacionais: todos pertencemos a Cristo.",
    verses: [
      {
        ref: "1 Coríntios 1:10",
        text: "Rogo-vos, irmãos, pelo nome de nosso Senhor Jesus Cristo, que faleis todos a mesma coisa e que não haja entre vós divisões; antes, sejais inteiramente unidos, na mesma disposição mental e no mesmo parecer.",
      },
      {
        ref: "Efésios 4:4-6",
        text: "Há somente um corpo e um Espírito, como também fostes chamados numa só esperança da vossa vocação; há um só Senhor, uma só fé, um só batismo; um só Deus e Pai de todos...",
      },
    ],
    content: `Cristo não fundou denominações nem dividiu a Sua noiva. Reconhecemos que em Belo Horizonte e na Região Metropolitana há somente uma Igreja do Senhor, composta por todos os que verdadeiramente foram lavados pelo sangue do Cordeiro e nasceram de novo.

Por isso, não assumimos nomes denominacionais ou títulos corporativos. Nos identificamos simplesmente pelo que somos biblicamente: Discípulos de Jesus em Belo Horizonte. Somos irmãos de todos os santos da cidade e buscamos expressar a unidade visível do Corpo.`,
  },
]

export default function QuemSomos() {
  return (
    <div className="flex min-h-screen w-full flex-col overflow-x-hidden bg-background text-foreground antialiased selection:bg-primary/20 selection:text-primary">
      <LandingHeader />

      <main className="flex-1 w-full py-10 sm:py-16">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          {/* Back to Home Button */}
          <div className="mb-8">
            <Button
              asChild
              variant="ghost"
              size="sm"
              className="min-h-[44px] gap-2 text-xs sm:text-sm text-muted-foreground hover:text-foreground"
            >
              <Link to="/">
                <ArrowLeft className="h-4 w-4" />
                Voltar à Página Inicial
              </Link>
            </Button>
          </div>

          {/* Page Hero Header */}
          <header className="border-b border-border/50 pb-10 text-center sm:text-left">
            <span className="inline-flex items-center gap-1.5 rounded-full border border-primary/30 bg-primary/10 px-3 py-1 text-xs font-semibold text-primary">
              <ShieldCheck className="h-3.5 w-3.5" />
              Nossa Identidade & Fundamentos Bíblicos
            </span>

            <h1 className="mt-4 text-3xl font-extrabold tracking-tight text-foreground sm:text-4xl md:text-5xl">
              Quem Somos e no que Cremos
            </h1>

            <p className="mt-4 text-sm leading-relaxed text-muted-foreground sm:text-base md:text-lg">
              Somos discípulos de Jesus na cidade de Belo Horizonte e região metropolitana desde o início da década de 1980. Não somos uma instituição religiosa empresarial ou templo de tijolos, mas uma comunhão viva de irmãos que buscam cumprir o propósito eterno de Deus.
            </p>
          </header>

          {/* Quick Summary Cards */}
          <div className="mt-10 grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="rounded-xl border border-border/60 bg-card p-5">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary mb-3">
                <Users className="h-5 w-5" />
              </div>
              <h2 className="text-sm font-bold text-foreground">Uma Família</h2>
              <p className="mt-1.5 text-xs text-muted-foreground leading-relaxed">
                Deus deseja muitos filhos semelhantes a Jesus, vivendo juntos em amor e santidade.
              </p>
            </div>

            <div className="rounded-xl border border-border/60 bg-card p-5">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary mb-3">
                <Home className="h-5 w-5" />
              </div>
              <h2 className="text-sm font-bold text-foreground">De Casa em Casa</h2>
              <p className="mt-1.5 text-xs text-muted-foreground leading-relaxed">
                A igreja se reúne nos lares para comunhão real, oração e o partir do pão.
              </p>
            </div>

            <div className="rounded-xl border border-border/60 bg-card p-5">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary mb-3">
                <HeartHandshake className="h-5 w-5" />
              </div>
              <h2 className="text-sm font-bold text-foreground">Vida na Vida</h2>
              <p className="mt-1.5 text-xs text-muted-foreground leading-relaxed">
                Discipulado mútuo: crescemos juntos, apoiando e exortando uns aos outros no dia a dia.
              </p>
            </div>
          </div>

          {/* Detailed Pillars of Faith */}
          <section className="mt-14 space-y-12">
            <div className="text-center sm:text-left">
              <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-foreground">
                Os Fundamentos da Nossa Fé
              </h2>
              <p className="mt-2 text-xs sm:text-sm text-muted-foreground">
                As Escrituras Sagradas como nossa única regra de fé e prática para viver à semelhança de Cristo.
              </p>
            </div>

            <div className="space-y-10">
              {PILLARS_OF_FAITH.map((pillar) => (
                <article
                  key={pillar.number}
                  className="rounded-2xl border border-border/70 bg-card p-6 sm:p-8 shadow-xs transition-colors hover:border-primary/40"
                >
                  <div className="flex items-center gap-3">
                    <span className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/10 text-xs font-black text-primary">
                      {pillar.number}
                    </span>
                    <h3 className="text-lg sm:text-xl font-bold text-foreground">
                      {pillar.title}
                    </h3>
                  </div>

                  <p className="mt-3 text-xs sm:text-sm font-medium text-foreground/80">
                    {pillar.summary}
                  </p>

                  <div className="mt-4 space-y-3 whitespace-pre-line text-xs sm:text-sm text-muted-foreground leading-relaxed">
                    {pillar.content}
                  </div>

                  {/* Scripture Citations */}
                  <div className="mt-6 space-y-2 border-t border-border/40 pt-4">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground block mb-2">
                      Fundamentação Bíblica:
                    </span>
                    {pillar.verses.map((verse) => (
                      <div
                        key={verse.ref}
                        className="rounded-lg border border-border/40 bg-muted/20 p-3 text-xs"
                      >
                        <p className="font-serif italic text-foreground/90">
                          &ldquo;{verse.text}&rdquo;
                        </p>
                        <span className="mt-1.5 block text-right font-semibold text-primary text-[11px]">
                          — {verse.ref}
                        </span>
                      </div>
                    ))}
                  </div>
                </article>
              ))}
            </div>
          </section>

          {/* Social Channels Section */}
          <section className="mt-14 rounded-2xl border border-border/70 bg-card p-6 sm:p-8 text-center sm:text-left">
            <h2 className="text-xl sm:text-2xl font-bold text-foreground">
              Acompanhe Nossas Mensagens e a Vida da Comunidade
            </h2>
            <p className="mt-2 text-xs sm:text-sm text-muted-foreground max-w-2xl leading-relaxed">
              Compartilhamos mensagens bíblicas, estudos e o dia a dia dos discípulos reunidos de casa em casa através das nossas páginas oficiais:
            </p>

            <div className="mt-6 flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
              <a
                href="https://www.youtube.com/@discipulosembelohorizonte4776"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex min-h-[44px] items-center justify-center gap-2.5 rounded-full bg-[#FF0000] px-5 py-2.5 text-xs sm:text-sm font-semibold text-white shadow-xs transition-opacity hover:opacity-90"
              >
                <Youtube className="h-4 w-4" />
                <span>Canal no YouTube</span>
              </a>

              <a
                href="https://www.instagram.com/discipulos.bh"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex min-h-[44px] items-center justify-center gap-2.5 rounded-full bg-gradient-to-r from-[#833ab4] via-[#fd1d1d] to-[#fcb045] px-5 py-2.5 text-xs sm:text-sm font-semibold text-white shadow-xs transition-opacity hover:opacity-90"
              >
                <Instagram className="h-4 w-4" />
                <span>Instagram @discipulos.bh</span>
              </a>

              <Button
                asChild
                variant="outline"
                className="min-h-[44px] rounded-full px-5 text-xs sm:text-sm font-semibold"
              >
                <Link to="/ensinos">
                  <BookOpen className="mr-2 h-4 w-4" />
                  Biblioteca de Ensinos
                </Link>
              </Button>
            </div>
          </section>

          {/* Bottom Invitation Section */}
          <section className="mt-10 rounded-2xl border border-primary/30 bg-primary/5 p-6 sm:p-8 text-center">
            <h2 className="text-xl sm:text-2xl font-extrabold text-foreground">
              Deseja conversar ou nos conhecer de perto?
            </h2>
            <p className="mt-2 text-xs sm:text-sm text-muted-foreground max-w-xl mx-auto leading-relaxed">
              Não achamos suficiente apenas falar de fé pela internet. Gostaríamos de ouvir você, tomar um café e apresentar discípulos próximos de onde você mora.
            </p>
            <div className="mt-6 flex flex-col sm:flex-row justify-center gap-3">
              <Button asChild size="lg" className="min-h-[44px] rounded-full px-7 font-bold">
                <Link to="/#contato">
                  <MessageCircle className="mr-2 h-4 w-4" />
                  Caminhe Conosco
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
            </div>
          </section>
        </div>
      </main>

      <LandingFooter />
    </div>
  )
}
