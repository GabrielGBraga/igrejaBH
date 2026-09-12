import { useState } from "react"
import { Link } from "react-router-dom"
import {
  ArrowRight,
  ChevronDown,
  HeartHandshake,
  Home,
  Menu,
  ShieldCheck,
  Sparkles,
  Users,
  UtensilsCrossed,
  X,
  KeyRound,
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

export default function Landing() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const [expandedFaq, setExpandedFaq] = useState<number | null>(null)

  const navLinks = [
    { name: "A Visão", href: "#visao" },
    { name: "Grupos Caseiros", href: "#grupos-caseiros" },
    { name: "Vida Comum", href: "#vida-comum" },
    { name: "Como Participar", href: "#acesso-portal" },
    { name: "Dúvidas Frequentes", href: "#faq" },
  ]

  const faqs = [
    {
      question: "Onde fica o templo ou prédio da igreja?",
      answer:
        "Não possuímos uma sede central com auditório permanente ou templo físico. Seguindo o padrão bíblico do Novo Testamento, a Igreja em Belo Horizonte se reúne nos lares dos discípulos espalhados pelos bairros da cidade e da região metropolitana, além de encontros periódicos coletivos para adoração e comunhão.",
    },
    {
      question: "O que são os Grupos Caseiros (Oikos)?",
      answer:
        "São pequenos grupos de irmãos e famílias que se encontram semanalmente nas casas para orar, ler a Palavra de Deus, compartilhar refeições e cuidar uns dos outros de maneira próxima e espontânea. É onde a vida do Corpo acontece na prática diária.",
    },
    {
      question: "Como funciona o discipulado?",
      answer:
        "O discipulado acontece através de relacionamentos transparentes ('juntas e ligamentos') entre irmãos do mesmo gênero. Um discípulo mais experiente na fé caminha ao lado de outro, orando, ensinando o evangelho e apoiando nas lutas cotidianas, sem hierarquias corporativas.",
    },
    {
      question: "Já me reúno com os irmãos em um GC. Como ativo meu acesso ao portal?",
      answer:
        "Se você já faz parte de um Grupo Caseiro, seus dados básicos já foram incluídos previamente pelos responsáveis da sua região. Basta clicar em 'Ativar Conta' no topo da página e informar o e-mail ou telefone cadastrado para definir sua senha de acesso.",
    },
    {
      question: "Desejo conhecer a comunidade, como posso fazer?",
      answer:
        "Você é muito bem-vindo(a)! Os Grupos Caseiros estão de portas abertas nos bairros de Belo Horizonte, Contagem, Betim e demais regiões metropolitanas. Você pode se conectar através de um irmão ou nos contatar para indicarmos o Grupo Caseiro mais próximo da sua residência.",
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
          <Link
            to="/"
            className="flex items-center gap-2.5 transition-opacity hover:opacity-90"
          >
            <div className="flex h-9 w-9 items-center justify-center overflow-hidden rounded-xl border border-primary/20 bg-primary/10">
              <img
                src="/logo_igreja.png"
                alt="Logo da Igreja em BH"
                className="h-full w-full object-contain p-1"
              />
            </div>
            <div className="flex flex-col">
              <span className="text-base font-bold tracking-tight sm:text-lg">
                Igreja em BH
              </span>
              <span className="hidden text-[10px] uppercase tracking-wider text-muted-foreground sm:inline-block">
                A Igreja na Cidade
              </span>
            </div>
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
                Ativar Conta
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
                    <SheetTitle className="flex items-center gap-2 text-base font-bold">
                      <div className="flex h-8 w-8 items-center justify-center overflow-hidden rounded-lg border border-primary/20 bg-primary/10">
                        <img
                          src="/logo_igreja.png"
                          alt="Logo"
                          className="h-full w-full object-contain p-0.5"
                        />
                      </div>
                      Igreja em BH
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
                        Ativar meu Acesso
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
              Uma Comunidade Orgânica de Discípulos • Atos 2:42-47
            </Badge>
          </div>

          {/* Headline */}
          <h1 className="mt-6 text-3xl font-extrabold tracking-tight sm:text-5xl md:text-6xl">
            A Igreja que se reúne{" "}
            <span className="bg-gradient-to-r from-primary via-primary/90 to-foreground bg-clip-text text-transparent">
              pelas casas e na cidade
            </span>
            .
          </h1>

          {/* Subtitle */}
          <p className="mx-auto mt-6 max-w-3xl text-base text-muted-foreground sm:text-lg md:text-xl">
            Não somos um prédio comercial ou uma organização institucional.
            Somos uma família de discípulos perseverando no partir do pão de
            casa em casa, na oração, no ensino dos apóstolos e na comunhão diária
            em Belo Horizonte e região metropolitana.
          </p>

          {/* CTAs */}
          <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row sm:gap-4">
            <Button
              asChild
              size="lg"
              className="btn-tactile min-h-[48px] w-full px-6 text-base font-semibold shadow-md sm:w-auto"
            >
              <Link to="/entrar">
                Acessar o Portal
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
            <Button
              asChild
              variant="outline"
              size="lg"
              className="btn-tactile min-h-[48px] w-full px-6 text-base font-semibold sm:w-auto"
            >
              <Link to="/cadastro">
                <KeyRound className="mr-2 h-4 w-4 text-amber-600 dark:text-amber-400" />
                Ativar meu Acesso
              </Link>
            </Button>
          </div>

          {/* Biblical quote card */}
          <div className="card-hover-elevation mx-auto mt-12 max-w-2xl rounded-2xl border border-border/60 border-l-4 border-l-amber-600 dark:border-l-amber-500 bg-card/70 p-6 text-left shadow-xs backdrop-blur-xs sm:p-8">
            <p className="italic text-muted-foreground sm:text-base leading-relaxed">
              &ldquo;E, perseverando unânimes todos os dias no templo, e partindo
              o pão em casa, comiam juntos com alegria e singeleza de coração,
              louvando a Deus e caindo na graça de todo o povo.&rdquo;
            </p>
            <div className="mt-4 flex items-center justify-between border-t border-border/40 pt-4 text-xs font-semibold uppercase tracking-wider text-primary">
              <span className="flex items-center gap-1.5 font-bold">
                <span className="h-1.5 w-1.5 rounded-full bg-amber-600 dark:bg-amber-400 inline-block"></span>
                Atos 2:46-47a
              </span>
              <span className="text-muted-foreground font-medium">O Modelo do Reino</span>
            </div>
          </div>
        </div>
      </section>

      {/* 3. Métricas e Alcance Territorial */}
      <section className="border-b border-border/40 bg-muted/30 py-12">
        <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            <div className="card-hover-elevation flex flex-col items-center justify-center rounded-xl border border-border/60 bg-card p-6 text-center shadow-2xs">
              <span className="text-3xl font-extrabold text-foreground sm:text-4xl">
                24+
              </span>
              <span className="mt-1 text-sm font-semibold text-primary">
                Grupos Caseiros (Oikos)
              </span>
              <p className="mt-1 text-xs text-muted-foreground">
                Reuniões de comunhão e oração nos lares
              </p>
            </div>

            <div className="card-hover-elevation flex flex-col items-center justify-center rounded-xl border border-border/60 bg-card p-6 text-center shadow-2xs">
              <span className="text-3xl font-extrabold text-foreground sm:text-4xl">
                6
              </span>
              <span className="mt-1 text-sm font-semibold text-primary">
                Regiões Conectadas
              </span>
              <p className="mt-1 text-xs text-muted-foreground">
                Barreiro, Betim, Contagem, Pampulha, Santa Luzia e Venda Nova
              </p>
            </div>

            <div className="card-hover-elevation flex flex-col items-center justify-center rounded-xl border border-border/60 bg-card p-6 text-center shadow-2xs">
              <span className="text-3xl font-extrabold text-foreground sm:text-4xl">
                De Casa em Casa
              </span>
              <span className="mt-1 text-sm font-semibold text-primary">
                Vida ao Redor da Mesa
              </span>
              <p className="mt-1 text-xs text-muted-foreground">
                Partir do pão, hospitalidade e amparo mútuo
              </p>
            </div>

            <div className="card-hover-elevation flex flex-col items-center justify-center rounded-xl border border-border/60 bg-card p-6 text-center shadow-2xs">
              <span className="text-3xl font-extrabold text-foreground sm:text-4xl">
                100%
              </span>
              <span className="mt-1 text-sm font-semibold text-primary">
                Relacional & Discipulado
              </span>
              <p className="mt-1 text-xs text-muted-foreground">
                Juntas e ligamentos de cuidado e amizade
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* 4. A Visão: Os Pilares de Atos 2 */}
      <section id="visao" className="scroll-mt-20 py-16 sm:py-24">
        <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <Badge
              variant="outline"
              className="rounded-full border-primary/30 px-3 py-1 text-xs font-semibold text-primary"
            >
              Fundamentos
            </Badge>
            <h2 className="mt-3 text-2xl font-bold tracking-tight sm:text-3xl md:text-4xl">
              Como vivemos o Evangelho na prática
            </h2>
            <p className="mx-auto mt-3 max-w-2xl text-sm text-muted-foreground sm:text-base">
              Nossa dinâmica é moldada pela simplicidade dos primeiros discípulos:
              relacionamentos autênticos no lugar de programas burocráticos.
            </p>
          </div>

          <div className="mt-12 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {/* Pilar 1 */}
            <Card className="card-hover-elevation rounded-xl border border-border/60 hover:border-primary/40 hover:shadow-xs">
              <CardHeader className="space-y-2 pb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <Home className="h-5 w-5" />
                </div>
                <CardTitle className="text-lg font-bold">
                  Grupos Caseiros
                </CardTitle>
                <CardDescription className="text-xs font-medium text-primary">
                  Oikos • Reunião nos Lares
                </CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                As salas de estar e mesas de refeição são o coração da nossa
                reunião. Pequenos grupos onde todos participam, oram e cuidam uns
                dos outros.
              </CardContent>
            </Card>

            {/* Pilar 2 */}
            <Card className="card-hover-elevation rounded-xl border border-border/60 hover:border-primary/40 hover:shadow-xs">
              <CardHeader className="space-y-2 pb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <Users className="h-5 w-5" />
                </div>
                <CardTitle className="text-lg font-bold">
                  Discipulado Pessoal
                </CardTitle>
                <CardDescription className="text-xs font-medium text-primary">
                  Juntas e Ligamentos
                </CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                Nenhum discípulo caminha sozinho. Através de relacionamentos de
                mesmo gênero, irmãos mais maduros caminham lado a lado com os
                mais novos.
              </CardContent>
            </Card>

            {/* Pilar 3 */}
            <Card className="card-hover-elevation rounded-xl border border-border/60 hover:border-primary/40 hover:shadow-xs">
              <CardHeader className="space-y-2 pb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <UtensilsCrossed className="h-5 w-5 text-amber-600 dark:text-amber-400" />
                </div>
                <CardTitle className="text-lg font-bold">
                  O Partir do Pão
                </CardTitle>
                <CardDescription className="text-xs font-medium text-amber-600 dark:text-amber-400">
                  Comunhão e a Mesa
                </CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                A Ceia do Senhor é celebrada com singeleza e alegria tanto nas
                casas quanto nos encontros da cidade, como refeição de aliança e
                amor fraternal.
              </CardContent>
            </Card>

            {/* Pilar 4 */}
            <Card className="card-hover-elevation rounded-xl border border-border/60 hover:border-primary/40 hover:shadow-xs">
              <CardHeader className="space-y-2 pb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <HeartHandshake className="h-5 w-5" />
                </div>
                <CardTitle className="text-lg font-bold">
                  Cuidado e Diaconato
                </CardTitle>
                <CardDescription className="text-xs font-medium text-primary">
                  Suporte Mútuo Fraterno
                </CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                Entre nós não deve haver necessitados. Quando uma família ou
                irmão enfrenta dificuldades, o diaconato e a comunidade se
                mobilizam para apoiar.
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
              A vida cristã não se resume a um evento de domingo. Ela se desdobra
              em três níveis orgânicos de encontro e comunhão:
            </p>
          </div>

          <div className="mt-12 grid grid-cols-1 gap-8 md:grid-cols-3">
            <div className="flex flex-col rounded-xl border border-border/60 bg-card p-6 shadow-2xs">
              <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 font-bold text-primary">
                1
              </div>
              <h3 className="text-lg font-bold">Semanalmente: Nos Lares</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Nos Grupos Caseiros, os discípulos de uma mesma região se
                reúnem semanalmente. Há tempo para orar, partilhar o que Deus tem
                ensinado, cantar salmos e cear juntos ao redor da mesa.
              </p>
              <div className="mt-auto pt-4 text-xs font-medium text-primary">
                Aconchego, proximidade e transparência
              </div>
            </div>

            <div className="flex flex-col rounded-xl border border-border/60 bg-card p-6 shadow-2xs">
              <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 font-bold text-primary">
                2
              </div>
              <h3 className="text-lg font-bold">Diariamente: Discipulado</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Entre as semanas, os irmãos mantêm contato em oração, cafés,
                conversas e apoio mútuo. As juntas de companheirismo garantem que
                cada pessoa tenha com quem contar nas lutas e vitórias.
              </p>
              <div className="mt-auto pt-4 text-xs font-medium text-primary">
                Cuidado pastoral descentralizado
              </div>
            </div>

            <div className="flex flex-col rounded-xl border border-border/60 bg-card p-6 shadow-2xs">
              <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 font-bold text-primary">
                3
              </div>
              <h3 className="text-lg font-bold">
                Periodicamente: O Corpo na Cidade
              </h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Periodicamente, todos os Grupos Caseiros de Belo Horizonte e
                região metropolitana se unem em grandes reuniões coletivas para
                louvor unânime, comunhão ampliada e instrução da Palavra.
              </p>
              <div className="mt-auto pt-4 text-xs font-medium text-primary">
                Unidade do Corpo de Cristo em BH
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 6. Vida Comum e Intranet: Exclusividade e Segurança */}
      <section id="vida-comum" className="scroll-mt-20 py-16 sm:py-24">
        <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
          <div className="rounded-2xl border border-border/80 bg-gradient-to-br from-card via-card to-muted/40 p-6 shadow-xs sm:p-10">
            <div className="flex flex-col items-start gap-6 md:flex-row md:items-center md:justify-between">
              <div className="space-y-3">
                <div className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/5 px-3 py-1 text-xs font-semibold text-primary">
                  <ShieldCheck className="h-3.5 w-3.5" />
                  Intranet Protegida • Acesso por Convite
                </div>
                <h2 className="text-2xl font-bold tracking-tight sm:text-3xl">
                  Um portal feito para cuidar dos irmãos
                </h2>
                <p className="max-w-2xl text-sm text-muted-foreground sm:text-base">
                  Diferente de redes sociais abertas, este portal é um ambiente
                  privativo dedicado ao cuidado, pedidos de oração, avisos
                  internos, gestão de retiros e apoio entre as famílias dos
                  Grupos Caseiros da Igreja em Belo Horizonte.
                </p>
              </div>
            </div>

            <div className="mt-8 grid grid-cols-1 gap-6 border-t border-border/60 pt-8 sm:grid-cols-2">
              <div className="space-y-2 rounded-xl border border-border/40 bg-background/50 p-5">
                <h4 className="flex items-center gap-2 text-sm font-bold">
                  <KeyRound className="h-4 w-4 text-primary" />
                  Já frequento um Grupo Caseiro?
                </h4>
                <p className="text-xs leading-relaxed text-muted-foreground">
                  Se você já caminha em um dos nossos grupos, sua liderança ou
                  discipulador já realizou seu pré-cadastro. Basta clicar no
                  botão abaixo para ativar sua conta informando seu e-mail ou
                  telefone.
                </p>
                <div className="pt-2">
                  <Button asChild size="sm" className="min-h-[44px] w-full sm:w-auto">
                    <Link to="/cadastro">Ativar minha Conta</Link>
                  </Button>
                </div>
              </div>

              <div className="space-y-2 rounded-xl border border-border/40 bg-background/50 p-5">
                <h4 className="flex items-center gap-2 text-sm font-bold">
                  <Users className="h-4 w-4 text-primary" />
                  Deseja conhecer a Igreja na cidade?
                </h4>
                <p className="text-xs leading-relaxed text-muted-foreground">
                  Se você reside em Belo Horizonte ou região metropolitana e quer
                  conhecer nossa dinâmica ou visitar um Grupo Caseiro, fale com um
                  irmão próximo ou venha nos visitar em uma das reuniões nos
                  lares.
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
              Tudo o que você precisa saber sobre como nos reunimos e operamos.
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
            Pronto para se conectar à vida comum?
          </h2>
          <p className="mx-auto mt-3 max-w-xl text-sm text-muted-foreground sm:text-base">
            Se você já faz parte da comunidade, ative sua conta ou acesse o
            portal para acompanhar o mural, os pedidos de oração e os ensinos.
          </p>
          <div className="mt-6 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Button
              asChild
              size="lg"
              className="min-h-[48px] w-full px-6 text-sm font-semibold sm:w-auto"
            >
              <Link to="/entrar">
                Acessar o Portal
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
            <Button
              asChild
              variant="outline"
              size="lg"
              className="min-h-[48px] w-full px-6 text-sm font-semibold sm:w-auto"
            >
              <Link to="/cadastro">
                <KeyRound className="mr-2 h-4 w-4" />
                Ativar meu Acesso
              </Link>
            </Button>
          </div>
        </div>
      </section>

      {/* 9. Footer */}
      <footer className="border-t border-border/50 bg-card/40 py-10 text-xs text-muted-foreground">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-6 px-4 text-center sm:flex-row sm:px-6 sm:text-left lg:px-8">
          <div className="flex items-center gap-3">
            <div className="flex h-8 w-8 items-center justify-center overflow-hidden rounded-lg border border-primary/20 bg-primary/10">
              <img
                src="/logo_igreja.png"
                alt="Logo"
                className="h-full w-full object-contain p-0.5"
              />
            </div>
            <div>
              <p className="font-semibold text-foreground">
                A Igreja em Belo Horizonte
              </p>
              <p className="text-[11px] text-muted-foreground">
                De casa em casa, com alegria e singeleza de coração.
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
            <Link to="/entrar" className="transition-colors hover:text-foreground">
              Entrar
            </Link>
            <Link
              to="/cadastro"
              className="transition-colors hover:text-foreground"
            >
              Ativar Conta
            </Link>
          </div>
        </div>

        <div className="mx-auto mt-8 max-w-6xl border-t border-border/30 px-4 pt-6 text-center text-[11px] text-muted-foreground/80 sm:px-6 lg:px-8">
          © {new Date().getFullYear()} A Igreja em Belo Horizonte • Portal de Vida Comum dos Discípulos
        </div>
      </footer>
    </div>
  )
}
