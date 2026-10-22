import { Link, useLocation, useNavigate } from "react-router-dom"
import { Headphones, MessageCircle } from "lucide-react"
import { ChurchLogo } from "@/components/icons/ChurchLogo"
import { LANDING_NAV_ITEMS, type NavItem } from "@/data/landingData"

export function LandingFooter() {
  const currentYear = new Date().getFullYear()
  const location = useLocation()
  const navigate = useNavigate()

  const handleNavClick = (e: React.MouseEvent<HTMLAnchorElement>, item: NavItem) => {
    if (item.isRoute) return

    if (item.href.startsWith("#")) {
      e.preventDefault()
      if (location.pathname === "/" || location.pathname === "/landing") {
        const element = document.querySelector(item.href)
        if (element) {
          element.scrollIntoView({ behavior: "smooth" })
        }
      } else {
        navigate(`/${item.href}`)
      }
    }
  }

  return (
    <footer className="border-t border-border/50 bg-card/60 py-10 text-xs text-muted-foreground">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6 text-center md:text-left">
          {/* 1. Left: Brand & Identity */}
          <div className="flex items-center gap-3">
            <ChurchLogo size="md" showText={false} />
            <div className="text-left">
              <p className="font-bold text-foreground text-sm">
                Igreja em Belo Horizonte
              </p>
              <p className="text-[11px] text-muted-foreground mt-0.5">
                Parte do Corpo do Senhor &middot; De casa em casa e nas ruas da cidade.
              </p>
            </div>
          </div>

          {/* 2. Middle: Navigation Links */}
          <nav aria-label="Links do Rodapé" className="flex flex-wrap items-center justify-center gap-4 sm:gap-6">
            {LANDING_NAV_ITEMS.map((item) => {
              if (item.isRoute) {
                return (
                  <Link
                    key={item.label}
                    to={item.href}
                    className="inline-flex min-h-[44px] items-center px-1.5 transition-colors hover:text-foreground font-medium"
                  >
                    {item.label}
                  </Link>
                )
              }
              return (
                <a
                  key={item.label}
                  href={item.href}
                  onClick={(e) => handleNavClick(e, item)}
                  className="inline-flex min-h-[44px] items-center px-1.5 transition-colors hover:text-foreground font-medium"
                >
                  {item.label}
                </a>
              )
            })}
            <Link
              to="/entrar"
              className="inline-flex min-h-[44px] items-center px-1.5 transition-colors hover:text-foreground font-semibold text-primary"
            >
              Entrar
            </Link>
          </nav>

          {/* 3. Right: Direct Action Icons */}
          <div className="flex items-center gap-2">
            <Link
              to="/ensinos?tab=ministracoes"
              aria-label="Ministrações em áudio e vídeo"
              title="Ministrações"
              className="flex min-h-[44px] min-w-[44px] items-center justify-center rounded-full bg-muted/60 text-foreground transition-colors hover:bg-primary hover:text-primary-foreground"
            >
              <Headphones className="h-4 w-4" />
            </Link>

            <Link
              to="/quero-saber-mais"
              aria-label="Caminhe conosco e conheça a igreja"
              title="Caminhe conosco"
              className="flex min-h-[44px] min-w-[44px] items-center justify-center rounded-full bg-muted/60 text-foreground transition-colors hover:bg-primary hover:text-primary-foreground"
            >
              <MessageCircle className="h-4 w-4" />
            </Link>
          </div>
        </div>

        {/* 4. Bottom Line */}
        <div className="mt-8 border-t border-border/40 pt-6 text-center text-[11px] text-muted-foreground/80">
          &copy; {currentYear} Igreja em Belo Horizonte &mdash; Parte do Corpo Único do Senhor na Cidade.
        </div>
      </div>
    </footer>
  )
}
