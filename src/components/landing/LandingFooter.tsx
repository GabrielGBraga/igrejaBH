import { Link, useLocation, useNavigate } from "react-router-dom"
import { Youtube, Instagram, Headphones, MessageCircle } from "lucide-react"
import { ChurchLogo } from "@/components/icons/ChurchLogo"
import { LANDING_NAV_ITEMS, type NavItem } from "./LandingHeader"

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
    <footer className="border-t border-border/50 bg-card/60 py-12 text-xs text-muted-foreground">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6 text-center md:text-left">
          {/* 1. Left: Brand & Identity */}
          <div className="flex items-center gap-3">
            <ChurchLogo size="md" showText={false} />
            <div className="text-left">
              <p className="font-bold text-foreground text-sm">
                Discípulos de Cristo em Belo Horizonte
              </p>
              <p className="text-[11px] text-muted-foreground mt-0.5">
                Parte do Corpo do Senhor • De casa em casa e nas ruas da cidade.
              </p>
            </div>
          </div>

          {/* 2. Middle: Navigation Links */}
          <nav aria-label="Links do Rodapé" className="flex flex-wrap items-center justify-center gap-5 sm:gap-6">
            {LANDING_NAV_ITEMS.map((item) => {
              if (item.isRoute) {
                return (
                  <Link
                    key={item.label}
                    to={item.href}
                    className="transition-colors hover:text-foreground font-medium py-1"
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
                  className="transition-colors hover:text-foreground font-medium py-1"
                >
                  {item.label}
                </a>
              )
            })}
            <Link to="/entrar" className="transition-colors hover:text-foreground font-semibold text-primary py-1">
              Entrar
            </Link>
          </nav>

          {/* 3. Right: Social Media Icons */}
          <div className="flex items-center gap-3">
            <a
              href="https://youtube.com"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Canal no YouTube da Igreja em BH"
              className="flex h-9 w-9 items-center justify-center rounded-full bg-muted/60 text-foreground transition-all hover:bg-primary hover:text-primary-foreground"
            >
              <Youtube className="h-4 w-4" />
            </a>

            <a
              href="https://instagram.com"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Instagram da Igreja em BH"
              className="flex h-9 w-9 items-center justify-center rounded-full bg-muted/60 text-foreground transition-all hover:bg-primary hover:text-primary-foreground"
            >
              <Instagram className="h-4 w-4" />
            </a>

            <Link
              to="/ensinos?tab=ministracoes"
              aria-label="Podcast e Ministrações em áudio"
              className="flex h-9 w-9 items-center justify-center rounded-full bg-muted/60 text-foreground transition-all hover:bg-primary hover:text-primary-foreground"
            >
              <Headphones className="h-4 w-4" />
            </Link>

            <Link
              to="/quero-saber-mais"
              aria-label="Fale conosco e conheça a igreja"
              className="flex h-9 w-9 items-center justify-center rounded-full bg-muted/60 text-foreground transition-all hover:bg-primary hover:text-primary-foreground"
            >
              <MessageCircle className="h-4 w-4" />
            </Link>
          </div>
        </div>

        {/* 4. Bottom Line: Unity statement & legal */}
        <div className="mt-8 border-t border-border/40 pt-6 text-center text-[11px] text-muted-foreground/80">
          © {currentYear} DISCÍPULOS DE CRISTO EM BELO HORIZONTE — Parte do Corpo Único do Senhor na Cidade.
        </div>
      </div>
    </footer>
  )
}
