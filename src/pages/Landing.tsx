import { useState } from "react"
import { Link } from "react-router-dom"
import {
  ArrowRight,
  ChevronDown,
  Compass,
  Flame,
  HeartHandshake,
  Home,
  KeyRound,
  Menu,
  ShieldCheck,
  Sparkles,
  Users,
  X,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
  SheetClose,
} from "@/components/ui/sheet"
import { ThemeToggle } from "@/components/ThemeToggle"
import { ChurchAvatar } from "@/components/ui/church-avatar"
import { ChurchLogo } from "@/components/icons/ChurchLogo"

export default function Landing() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const [expandedFaq, setExpandedFaq] = useState<number | null>(null)

  const navLinks = [
    { name: "A Visão", href: "#visao" },
    { name: "Grupos Caseiros", href: "#grupos-caseiros" },
    { name: "Vida Comum", href: "#vida-comum" },
    { name: "Caminhe Conosco", href: "#acesso-portal" },
    { name: "Dúvidas Frequentes", href: "#faq" },
  ]

  const faqs = [
    {
      question: "Onde fica o templo ou prédio de reuniões?",
      answer:
        "Não possuímos prédios, templos físicos ou sedes administrativas. A Igreja do Senhor não é um endereço, mas as próprias pessoas salvas por Cristo. Como parte da Igreja de Cristo que vive em Belo Horizonte e região metropolitana, os discípulos se reúnem nos lares espalhados pelos bairros e realizam encontros periódicos coletivos para comunhão e o partir do pão.",
    },
    {
      question: "Vocês pertencem a qual denominação religiosa?",
      answer:
        "A nenhuma denominação. Cremos que o Corpo de Cristo é indivisível e universal. Não somos a totalidade da Igreja do Senhor, mas apenas uma parte dela que habita em Belo Horizonte. Por isso, não adotamos nomes sectários ou títulos humanos, reconhecendo como irmãos todos aqueles que nasceram de novo pelo sangue de Jesus.",
    },
    {
      question: "O que são os Grupos Caseiros (Oikos) e o que fazem?",
      answer:
        "São pequenos grupos de discípulos e famílias que se encontram nos lares. Não são reuniões passivas para assistir a um pregador, mas ambientes familiares onde todos funcionam como sacerdotes: partilham a mesa na Ceia do Senhor, oram, cuidam uns dos outros e atuam como equipes de trabalho para compartilhar o Evangelho do Reino na vizinhança e nas ruas.",
    },
    {
      question: "Como funciona o discipulado (juntas e ligamentos)?",
      answer:
        "O discipulado é a reprodução do caráter de Jesus de 'vida na vida'. Irmãos do mesmo gênero caminham juntos no dia a dia, prestando contas com honestidade, orando, ensinando a obedecer às palavras do Senhor e cuidando mutuamente, sem qualquer divisão entre clero e leigos.",
    },
    {
      question: "O que significa 'O Propósito Eterno' de Deus?",
      answer:
        "É o plano original de Deus desenhado antes da fundação do mundo (Romanos 8:29 e Efésios 1): ter uma grande família de muitos filhos semelhantes a Jesus Cristo. A salvação não é o fim em si mesma, mas a porta de entrada pela qual a vida de Deus nos transforma diariamente à imagem de Seu Filho.",
    },
    {
      question: "Como posso conhecer a comunhão ou iniciar meu discipulado?",
      answer:
        "Você é muito bem-vindo(a)! Não temos procedimentos burocráticos ou formulários institucionais de membros. Você pode se conectar com um irmão próximo ou nos contatar para ser recebido em um Grupo Caseiro perto da sua casa, conhecer o testemunho vivo de Cristo e caminhar conosco.",
    },
  ]

  const toggleFaq = (index: number) => {
    setExpandedFaq(expandedFaq === index ? null : index)
  }

  return (
    <div className="flex min-h-screen w-full flex-col overflow-x-hidden bg-background text-foreground antialiased selection:bg-primary/20 selection:text-primary">
      {/* 1. Header / Navbar Pública */}
      <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/85 backdrop-blur-md">
        <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
          {/* Logo & Nome */}
          <Link to="/">
            <ChurchLogo size="md" />
          </Link>

          {/* Desktop Navigation Links */}
          <nav className="hidden items-center gap-6 md:flex">
            {navLinks.map((link) => (
              <a
                key={link.name}
                href={link.href}
                className="text-sm font-medium text-muted-foreground transition-colors hover:text-foreground"
              >
                {link.name}
              </a>
            ))}
          </nav>

          {/* Desktop Actions */}
          <div className="hidden items-center gap-2 sm:flex">
            <ThemeToggle />
            <Button
              asChild
              variant="ghost"
              size="sm"
              className="min-h-[44px] px-4 font-medium"
            >
              <Link to="/entrar">Entrar</Link>
            </Button>
            <Button
              asChild
              size="sm"
              className="min-h-[44px] px-4 font-medium shadow-xs"
            >
              <Link to="/cadastro">
                <KeyRound className="mr-2 h-4 w-4" />
                Caminhe Conosco
              </Link>
            </Button>
          </div>

          {/* Mobile Actions: ThemeToggle + Hamburger */}
          <div className="flex items-center gap-2 md:hidden">
            <ThemeToggle />
            <Sheet open={mobileMenuOpen} onOpenChange={setMobileMenuOpen}>
              <SheetTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon"
                  className="min-h-[44px] min-w-[44px]"
                  aria-label="Abrir menu de navegação"
                >
                  <Menu className="h-6 w-6" />
                </Button>
              </SheetTrigger>
              <SheetContent side="right" className="w-[300px] p-0 sm:w-[350px]">
                <SheetHeader className="border-b border-border/50 p-6 text-left">
                  <div className="flex items-center justify-between">
                    <SheetTitle>
                      <ChurchLogo size="sm" />
                    </SheetTitle>
                    <SheetClose asChild>
                      <Button
                        variant="ghost"
                        size="icon"
                        className="min-h-[44px] min-w-[44px]"
                      >
                        <X className="h-5 w-5" />
                        <span className="sr-only">Fechar</span>
                      </Button>
                    </SheetClose>
                  </div>
                </SheetHeader>

                <div className="flex flex-col gap-6 p-6">
                  <nav className="flex flex-col gap-1">
                    {navLinks.map((link) => (
                      <a
                        key={link.name}
                        href={link.href}
                        onClick={() => setMobileMenuOpen(false)}
                        className="flex min-h-[44px] items-center rounded-lg px-3 text-sm font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
                      >
                        {link.name}
                      </a>
                    ))}
                  </nav>

                  <div className="flex flex-col gap-3 pt-2">
                    <Button
                      asChild
                      variant="outline"
                      className="min-h-[44px] w-full justify-center text-sm font-medium"
                      onClick={() => setMobileMenuOpen(false)}
                    >
                      <Link to="/entrar">Entrar no Portal</Link>
                    </Button>
                    <Button
                      asChild
                      className="min-h-[44px] w-full justify-center text-sm font-medium"
                      onClick={() => setMobileMenuOpen(false)}
                    >
                      <Link to="/cadastro">
                        <KeyRound className="mr-2 h-4 w-4" />
                        Caminhe Conosco
                      </Link>
                    </Button>
                  </div>
                </div>
              </SheetContent>
            </Sheet>
          </div>
        </div>
      </header>

      {/* 2. Hero Section */}
      <section className="relative overflow-hidden border-b border-border/40 py-16 sm:py-24 md:py-32">
        {/* Subtle background glow */}
        <div className="pointer-events-none absolute inset-0 -z-10 flex items-center justify-center opacity-30 dark:opacity-20">
          <div className="h-[320px] w-[320px] rounded-full bg-primary/25 blur-[100px] sm:h-[480px] sm:w-[480px]" />
        </div>

        <div className="mx-auto max-w-5xl px-4 text-center sm:px-6 lg:px-8 animate-section-enter">
          {/* Badge */}
          <div className="inline-flex items-center justify-center">
            <Badge
              variant="outline"
              className="gap-2 rounded-full border-primary/30 bg-primary/10 px-4 py-1.5 text-xs font-semibold text-primary shadow-2xs"
            >
              <Sparkles className="h-3.5 w-3.5 text-amber-600 dark:text-amber-400" />
              O Propósito Eterno de Deus • Romanos 8:29
            </Badge>
          </div>

          {/* Headline */}
          <h1 className="mt-6 text-3xl font-extrabold tracking-tight sm:text-5xl md:text-6xl">
            Uma família de discípulos{" "}
            <span className="bg-gradient-to-r from-primary via-primary/90 to-foreground bg-clip-text text-transparent">
              semelhantes a Jesus pelas casas e ruas
            </span>
            .
          </h1>

          {/* Subtitle */}
          <p className="mx-auto mt-6 max-w-3xl text-base text-muted-foreground sm:text-lg md:text-xl">
            O propósito de Deus antes da fundação do mundo é ter uma família de
            muitos filhos conformados à imagem de Jesus Cristo. Não somos uma
            denominação, nem temos templos físicos ou divisão de clero: somos
            discípulos, parte do Corpo de Cristo em Belo Horizonte,
            reunindo-nos nos lares como equipes de trabalho e proclamando o
            Evangelho do Reino no dia a dia da cidade.
          </p>

          {/* CTAs */}
          <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row sm:gap-4">
            <Button
              asChild
              size="lg"
              className="btn-tactile min-h-[48px] w-full px-6 text-base font-semibold shadow-md sm:w-auto"
            >
              <Link to="/cadastro">
                Caminhe Conosco
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
            <Button
              asChild
              variant="outline"
              size="lg"
              className="btn-tactile min-h-[48px] w-full px-6 text-base font-semibold sm:w-auto"
            >
              <Link to="/entrar">
                <KeyRound className="mr-2 h-4 w-4 text-amber-600 dark:text-amber-400" />
                Acessar o Portal
              </Link>
            </Button>
          </div>

          {/* Biblical quote card */}
          <div className="card-hover-elevation mx-auto mt-12 max-w-2xl rounded-2xl border border-border/60 border-l-4 border-l-amber-600 dark:border-l-amber-500 bg-card/70 p-6 text-left shadow-xs backdrop-blur-xs sm:p-8">
            <p className="italic text-muted-foreground sm:text-base leading-relaxed">
              &ldquo;Porquanto aos que de antemão conheceu, também os predestinou
              para serem conformes à imagem de seu Filho, a fim de que Ele seja o
              primogênito entre muitos irmãos.&rdquo;
            </p>
            <div className="mt-4 flex items-center justify-between border-t border-border/40 pt-4 text-xs font-semibold uppercase tracking-wider text-primary">
              <span className="flex items-center gap-1.5 font-bold">
                <span className="h-1.5 w-1.5 rounded-full bg-amber-600 dark:bg-amber-400 inline-block"></span>
                Romanos 8:29
              </span>
              <span className="text-muted-foreground font-medium">
                O Propósito Eterno de Deus
              </span>
            </div>
          </div>
        </div>
      </section>

      {/* 3. Métricas e Fundamentos de Fé */}
      <section className="border-b border-border/40 bg-muted/30 py-12">
        <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            <div className="card-hover-elevation flex flex-col items-center justify-center rounded-xl border border-border/60 bg-card p-6 text-center shadow-2xs">
              <span className="text-xl font-extrabold text-foreground sm:text-2xl">
                Propósito Eterno
              </span>
              <span className="mt-1 text-sm font-semibold text-primary">
                Semelhança com Cristo
              </span>
              <p className="mt-1 text-xs text-muted-foreground">
                Uma família de muitos filhos formados à imagem de Jesus
              </p>
            </div>

            <div className="card-hover-elevation flex flex-col items-center justify-center rounded-xl border border-border/60 bg-card p-6 text-center shadow-2xs">
              <span className="text-xl font-extrabold text-foreground sm:text-2xl">
                Casas e Ruas
              </span>
              <span className="mt-1 text-sm font-semibold text-primary">
                Equipes de Trabalho
              </span>
              <p className="mt-1 text-xs text-muted-foreground">
                Comunhão nos lares e evangelismo prático na cidade
              </p>
            </div>

            <div className="card-hover-elevation flex flex-col items-center justify-center rounded-xl border border-border/60 bg-card p-6 text-center shadow-2xs">
              <span className="text-xl font-extrabold text-foreground sm:text-2xl">
                100% Sacerdotes
              </span>
              <span className="mt-1 text-sm font-semibold text-primary">
                Sem Divisão Clero/Leigo
              </span>
              <p className="mt-1 text-xs text-muted-foreground">
                Cada discípulo é ministro ativo na edificação mútua do Corpo
              </p>
            </div>

            <div className="card-hover-elevation flex flex-col items-center justify-center rounded-xl border border-border/60 bg-card p-6 text-center shadow-2xs">
              <span className="text-xl font-extrabold text-foreground sm:text-2xl">
                Vida na Vida
              </span>
              <span className="mt-1 text-sm font-semibold text-primary">
                Juntas e Ligamentos
              </span>
              <p className="mt-1 text-xs text-muted-foreground">
                Discipulado pessoal de cuidado mútuo, oração e transparência
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* 4. A Visão: Os Pilares Teológicos */}
      <section id="visao" className="scroll-mt-20 py-16 sm:py-24">
        <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <Badge
              variant="outline"
              className="rounded-full border-primary/30 px-3 py-1 text-xs font-semibold text-primary"
            >
              Fundamentos do Reino
            </Badge>
            <h2 className="mt-3 text-2xl font-bold tracking-tight sm:text-3xl md:text-4xl">
              Como expressamos a vida do Corpo
            </h2>
            <p className="mx-auto mt-3 max-w-2xl text-sm text-muted-foreground sm:text-base">
              Sem modelos corporativos ou tradições religiosas humanas. Tudo o
              que vivemos brota da simplicidade do Evangelho do Reino e do eterno
              propósito de Deus.
            </p>
          </div>

          <div className="mt-12 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {/* Pilar 1: O Propósito Eterno */}
            <Card className="card-hover-elevation rounded-xl border border-border/60 hover:border-primary/40 hover:shadow-xs">
              <CardHeader className="space-y-2 pb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <Sparkles className="h-5 w-5 text-amber-600 dark:text-amber-400" />
                </div>
                <CardTitle className="text-lg font-bold">
                  O Propósito Eterno
                </CardTitle>
                <CardDescription className="text-xs font-medium text-primary">
                  Romanos 8:29 • Família de Filhos
                </CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                O desígnio de Deus não é manter estruturas institucionais, mas ter
                uma família de muitos filhos semelhantes a Jesus Cristo. A
                salvação é a porta para sermos transformados diariamente à Sua
                imagem.
              </CardContent>
            </Card>

            {/* Pilar 2: Sacerdócio Universal */}
            <Card className="card-hover-elevation rounded-xl border border-border/60 hover:border-primary/40 hover:shadow-xs">
              <CardHeader className="space-y-2 pb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <Users className="h-5 w-5" />
                </div>
                <CardTitle className="text-lg font-bold">
                  Sacerdócio de Todos
                </CardTitle>
                <CardDescription className="text-xs font-medium text-primary">
                  1 Pedro 2:9 • Sem Divisão Clero/Leigo
                </CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                Não existem espectadores passivos nem superastros de púlpito.
                Todos os discípulos são sacerdotes e ministros de Cristo. Os
                líderes existem apenas para equipar os santos para a obra do
                ministério.
              </CardContent>
            </Card>

            {/* Pilar 3: Edificação por Relacionamentos */}
            <Card className="card-hover-elevation rounded-xl border border-border/60 hover:border-primary/40 hover:shadow-xs">
              <CardHeader className="space-y-2 pb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <HeartHandshake className="h-5 w-5" />
                </div>
                <CardTitle className="text-lg font-bold">
                  Juntas e Ligamentos
                </CardTitle>
                <CardDescription className="text-xs font-medium text-primary">
                  Efésios 4:16 • Discipulado Vida na Vida
                </CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                O Corpo cresce e se edifica através de vínculos de discipulado
                pessoal e companheirismo honesto entre irmãos do mesmo gênero,
                caminhando juntos nas lutas cotidianas com oração e prestação de
                contas.
              </CardContent>
            </Card>

            {/* Pilar 4: Nas Casas e nas Ruas */}
            <Card className="card-hover-elevation rounded-xl border border-border/60 hover:border-primary/40 hover:shadow-xs">
              <CardHeader className="space-y-2 pb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <Home className="h-5 w-5" />
                </div>
                <CardTitle className="text-lg font-bold">
                  Nas Casas e nas Ruas
                </CardTitle>
                <CardDescription className="text-xs font-medium text-primary">
                  Atos 20:20 • Sem Templismo
                </CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                A igreja são as pessoas, não um prédio. Reunimo-nos nos lares
                como equipes de trabalho e centros de treinamento, e atuamos
                nas ruas como testemunhas vivas de Cristo no contato simples com
                as pessoas.
              </CardContent>
            </Card>

            {/* Pilar 5: Evangelismo e Frutificação */}
            <Card className="card-hover-elevation rounded-xl border border-border/60 hover:border-primary/40 hover:shadow-xs">
              <CardHeader className="space-y-2 pb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <Flame className="h-5 w-5 text-amber-600 dark:text-amber-400" />
                </div>
                <CardTitle className="text-lg font-bold">
                  Evangelismo e Frutos
                </CardTitle>
                <CardDescription className="text-xs font-medium text-primary">
                  João 15:8 • O Evangelho do Reino
                </CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                Dar fruto é indispensável e significa reproduzir o caráter de
                Cristo em novos discípulos. Compartilhamos o testemunho pessoal
                de renovação, proclamando o Reino e ensinando a obediência às
                ordens de Jesus.
              </CardContent>
            </Card>

            {/* Pilar 6: Identidade Não-Denominacional */}
            <Card className="card-hover-elevation rounded-xl border border-border/60 hover:border-primary/40 hover:shadow-xs">
              <CardHeader className="space-y-2 pb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <Compass className="h-5 w-5" />
                </div>
                <CardTitle className="text-lg font-bold">
                  Corpo Único na Cidade
                </CardTitle>
                <CardDescription className="text-xs font-medium text-primary">
                  1 Coríntios 1:10 • Cristo Indivisível
                </CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                Cristo não dividiu Sua Igreja em franquias ou marcas. Reconhecemos
                que não somos a totalidade da Igreja do Senhor, mas apenas parte
                dela em Belo Horizonte, caminhando em amor e unidade com todo o
                povo de Deus.
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* 5. Como Nos Reunimos (Dinâmica) */}
      <section
        id="grupos-caseiros"
        className="scroll-mt-20 border-y border-border/40 bg-muted/20 py-16 sm:py-24"
      >
        <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <Badge
              variant="outline"
              className="rounded-full border-primary/30 px-3 py-1 text-xs font-semibold text-primary"
            >
              Dinâmica Comunitária
            </Badge>
            <h2 className="mt-3 text-2xl font-bold tracking-tight sm:text-3xl md:text-4xl">
              O ritmo da vida em comunidade
            </h2>
            <p className="mx-auto mt-3 max-w-2xl text-sm text-muted-foreground sm:text-base">
              A vida cristã não se resume a assistir a um evento semanal. Ela se
              desdobra em três dimensões orgânicas de comunhão e missão:
            </p>
          </div>

          <div className="mt-12 grid grid-cols-1 gap-8 md:grid-cols-3">
            <div className="flex flex-col rounded-xl border border-border/60 bg-card p-6 shadow-2xs">
              <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 font-bold text-primary">
                1
              </div>
              <h3 className="text-lg font-bold">Semanalmente: Nas Casas</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Nos Grupos Caseiros, os discípulos se reúnem nos lares como
                equipes de trabalho: partilham a mesa na Ceia do Senhor, oram,
                estudam as ordens de Cristo e planejam o evangelismo prático na
                vizinhança.
              </p>
              <div className="mt-auto pt-4 text-xs font-medium text-primary">
                Comunhão ao redor da mesa e alinhamento prático
              </div>
            </div>

            <div className="flex flex-col rounded-xl border border-border/60 bg-card p-6 shadow-2xs">
              <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 font-bold text-primary">
                2
              </div>
              <h3 className="text-lg font-bold">Diariamente: Vida na Vida e nas Ruas</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                No cotidiano, o sacerdócio universal é vivido: irmãos cuidam uns
                dos outros por juntas e ligamentos, oram juntos, prestam contas
                e compartilham o amor de Cristo nos locais de trabalho, estudo e
                nas ruas.
              </p>
              <div className="mt-auto pt-4 text-xs font-medium text-primary">
                Cuidado mútuo e sacerdócio de todos os discípulos
              </div>
            </div>

            <div className="flex flex-col rounded-xl border border-border/60 bg-card p-6 shadow-2xs">
              <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 font-bold text-primary">
                3
              </div>
              <h3 className="text-lg font-bold">
                Periodicamente: Encontros Coletivos
              </h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Periodicamente, os discípulos de todas as regiões se encontram
                para celebrar a Ceia, adorar em louvor unânime e expressar a
                unidade visível do Corpo de Cristo em Belo Horizonte e região
                metropolitana.
              </p>
              <div className="mt-auto pt-4 text-xs font-medium text-primary">
                Unidade e comunhão de toda a cidade
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 6. Vida Comum e Intranet: Ambiente Relacional */}
      <section id="vida-comum" className="scroll-mt-20 py-16 sm:py-24">
        <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
          <div className="rounded-2xl border border-border/80 bg-gradient-to-br from-card via-card to-muted/40 p-6 shadow-xs sm:p-10">
            <div className="flex flex-col items-start gap-6 md:flex-row md:items-center md:justify-between">
              <div className="space-y-3">
                <div className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/5 px-3 py-1 text-xs font-semibold text-primary">
                  <ShieldCheck className="h-3.5 w-3.5" />
                  Ambiente Relacional • Acesso por Vínculo
                </div>
                <h2 className="text-2xl font-bold tracking-tight sm:text-3xl">
                  Um portal relacional a serviço do Corpo
                </h2>
                <p className="max-w-2xl text-sm text-muted-foreground sm:text-base">
                  Diferente de redes sociais abertas ou sistemas burocráticos,
                  este portal é um instrumento dedicado ao cuidado dos irmãos,
                  pedidos de oração, avisos das regiões, acompanhamento do
                  discipulado e apoio mútuo nas necessidades materiais.
                </p>
              </div>
            </div>

            <div className="mt-8 grid grid-cols-1 gap-6 border-t border-border/60 pt-8 sm:grid-cols-2">
              <div className="space-y-2 rounded-xl border border-border/40 bg-background/50 p-5">
                <h4 className="flex items-center gap-2 text-sm font-bold">
                  <KeyRound className="h-4 w-4 text-primary" />
                  Já caminha com os discípulos em um Grupo Caseiro?
                </h4>
                <p className="text-xs leading-relaxed text-muted-foreground">
                  Se você já se reúne com os irmãos, seu discipulador ou os
                  responsáveis pelo seu Grupo Caseiro já realizaram seu pré-cadastro.
                  Basta clicar abaixo para definir sua senha de acesso ao portal.
                </p>
                <div className="pt-2">
                  <Button asChild size="sm" className="min-h-[44px] w-full sm:w-auto">
                    <Link to="/cadastro">Caminhe Conosco / Ativar Acesso</Link>
                  </Button>
                </div>
              </div>

              <div className="space-y-2 rounded-xl border border-border/40 bg-background/50 p-5">
                <h4 className="flex items-center gap-2 text-sm font-bold">
                  <Users className="h-4 w-4 text-primary" />
                  Deseja caminhar com os irmãos na cidade?
                </h4>
                <p className="text-xs leading-relaxed text-muted-foreground">
                  Se você reside em Belo Horizonte ou região metropolitana e quer
                  conhecer a dinâmica dos lares, ouvir o testemunho de transformação
                  do Evangelho ou iniciar um discipulado bíblico, venha nos visitar.
                </p>
                <div className="pt-2">
                  <Button
                    asChild
                    variant="outline"
                    size="sm"
                    className="min-h-[44px] w-full sm:w-auto"
                  >
                    <a href="#faq">Ver Dúvidas Frequentes</a>
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 7. Dúvidas Frequentes (FAQ) */}
      <section
        id="faq"
        className="scroll-mt-20 border-t border-border/40 bg-muted/20 py-16 sm:py-24"
      >
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <Badge
              variant="outline"
              className="rounded-full border-primary/30 px-3 py-1 text-xs font-semibold text-primary"
            >
              Esclarecimentos
            </Badge>
            <h2 className="mt-3 text-2xl font-bold tracking-tight sm:text-3xl md:text-4xl">
              Perguntas Frequentes
            </h2>
            <p className="mt-2 text-sm text-muted-foreground sm:text-base">
              Tudo o que você precisa saber sobre a vida e a dinâmica dos discípulos.
            </p>
          </div>

          <div className="mt-10 space-y-3">
            {faqs.map((faq, index) => {
              const isOpen = expandedFaq === index
              return (
                <div
                  key={faq.question}
                  className="rounded-xl border border-border/60 bg-card transition-all"
                >
                  <button
                    type="button"
                    onClick={() => toggleFaq(index)}
                    className="flex min-h-[48px] w-full items-center justify-between gap-4 p-5 text-left font-medium text-foreground transition-colors hover:text-primary"
                    aria-expanded={isOpen}
                  >
                    <span className="text-sm font-semibold sm:text-base">
                      {faq.question}
                    </span>
                    <ChevronDown
                      className={`h-5 w-5 shrink-0 text-muted-foreground transition-transform duration-200 ${
                        isOpen ? "rotate-180 text-primary" : ""
                      }`}
                    />
                  </button>
                  {isOpen && (
                    <div className="border-t border-border/40 px-5 pb-5 pt-3 text-xs leading-relaxed text-muted-foreground sm:text-sm">
                      {faq.answer}
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* 8. Chamada Final / Banner de Acolhimento */}
      <section id="acesso-portal" className="border-t border-border/40 py-16 text-center">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <h2 className="text-2xl font-bold tracking-tight sm:text-3xl">
            Caminhe conosco no Propósito Eterno
          </h2>
          <p className="mx-auto mt-3 max-w-xl text-sm text-muted-foreground sm:text-base">
            Venha viver o Evangelho na simplicidade dos lares e na força do
            discipulado pessoal, expressando a vida de Cristo na cidade de Belo
            Horizonte.
          </p>
          <div className="mt-6 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Button
              asChild
              size="lg"
              className="min-h-[48px] w-full px-6 text-sm font-semibold sm:w-auto"
            >
              <Link to="/cadastro">
                Caminhe Conosco
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
            <Button
              asChild
              variant="outline"
              size="lg"
              className="min-h-[48px] w-full px-6 text-sm font-semibold sm:w-auto"
            >
              <Link to="/entrar">
                <KeyRound className="mr-2 h-4 w-4 text-amber-600 dark:text-amber-400" />
                Acessar o Portal
              </Link>
            </Button>
          </div>
        </div>
      </section>

      {/* 9. Footer */}
      <footer className="border-t border-border/50 bg-card/40 py-10 text-xs text-muted-foreground">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-6 px-4 text-center sm:flex-row sm:px-6 sm:text-left lg:px-8">
          <div className="flex items-center gap-3">
            <ChurchAvatar size="md" variant="subtle" />
            <div>
              <p className="font-semibold text-foreground">
                Discípulos de Cristo em Belo Horizonte
              </p>
              <p className="text-[11px] text-muted-foreground">
                Parte do Corpo do Senhor • De casa em casa e nas ruas da cidade.
              </p>
            </div>
          </div>

          <div className="flex flex-wrap items-center justify-center gap-4 sm:justify-end">
            <a href="#visao" className="transition-colors hover:text-foreground">
              A Visão
            </a>
            <a
              href="#grupos-caseiros"
              className="transition-colors hover:text-foreground"
            >
              Grupos Caseiros
            </a>
            <a
              href="#vida-comum"
              className="transition-colors hover:text-foreground"
            >
              Vida Comum
            </a>
            <Link to="/entrar" className="transition-colors hover:text-foreground">
              Entrar
            </Link>
            <Link
              to="/cadastro"
              className="transition-colors hover:text-foreground"
            >
              Caminhe Conosco
            </Link>
          </div>
        </div>

        <div className="mx-auto mt-8 max-w-6xl border-t border-border/30 px-4 pt-6 text-center text-[11px] text-muted-foreground/80 sm:px-6 lg:px-8">
          © {new Date().getFullYear()} Discípulos de Cristo em Belo Horizonte • Parte do Corpo Único do Senhor na cidade.
        </div>
      </footer>
    </div>
  )
}
