import { useState } from "react"
import { Link, useLocation, useNavigate } from "react-router-dom"
import { Menu, X, Instagram, Youtube } from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
  SheetClose,
} from "@/components/ui/sheet"
import { ThemeToggle } from "@/components/ThemeToggle"
import { ChurchLogo } from "@/components/icons/ChurchLogo"
import { LANDING_NAV_ITEMS, type NavItem } from "@/data/landingData"

export function LandingHeader() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const location = useLocation()
  const navigate = useNavigate()

  const handleNavClick = (e: React.MouseEvent<HTMLAnchorElement>, item: NavItem) => {
    if (item.isRoute) {
      setMobileMenuOpen(false)
      return // React Router handles route transition via Link
    }

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
      setMobileMenuOpen(false)
    }
  }

  return (
    <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/90 backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
        {/* Brand / Logo */}
        <Link
          to="/"
          className="flex items-center gap-2 outline-none focus-visible:ring-2 focus-visible:ring-primary rounded-md"
        >
          <ChurchLogo size="md" />
        </Link>

        {/* Desktop Navigation Links */}
        <nav
          aria-label="Navegação Principal"
          className="hidden items-center gap-5 md:flex"
        >
          {LANDING_NAV_ITEMS.map((item) => {
            if (item.isRoute) {
              return (
                <Link
                  key={item.label}
                  to={item.href}
                  className="inline-flex min-h-[44px] items-center text-sm font-medium text-muted-foreground transition-colors hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary rounded-md px-2"
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
                className="inline-flex min-h-[44px] items-center text-sm font-medium text-muted-foreground transition-colors hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary rounded-md px-2"
              >
                {item.label}
              </a>
            )
          })}
        </nav>

        {/* Desktop Actions */}
        <div className="hidden items-center gap-3 sm:flex">
          <ThemeToggle />
          <Button
            asChild
            size="sm"
            className="min-h-[44px] min-w-[88px] px-5 font-semibold shadow-xs rounded-full bg-primary text-primary-foreground hover:bg-primary/90 transition-transform active:scale-[0.98]"
          >
            <Link to="/entrar">Entrar</Link>
          </Button>
        </div>

        {/* Mobile Actions: ThemeToggle + Mobile Hamburger Sheet */}
        <div className="flex items-center gap-2 md:hidden">
          <ThemeToggle />
          <Sheet open={mobileMenuOpen} onOpenChange={setMobileMenuOpen}>
            <SheetTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="min-h-[44px] min-w-[44px] text-foreground"
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
                <nav className="flex flex-col gap-1.5">
                  {LANDING_NAV_ITEMS.map((item) => {
                    if (item.isRoute) {
                      return (
                        <Link
                          key={item.label}
                          to={item.href}
                          onClick={() => setMobileMenuOpen(false)}
                          className="flex min-h-[44px] items-center rounded-lg px-3 text-base font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
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
                        className="flex min-h-[44px] items-center rounded-lg px-3 text-base font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
                      >
                        {item.label}
                      </a>
                    )
                  })}
                </nav>

                <div className="flex flex-col gap-3 pt-4 border-t border-border/40">
                  <Button
                    asChild
                    className="min-h-[44px] w-full justify-center text-sm font-semibold rounded-full"
                    onClick={() => setMobileMenuOpen(false)}
                  >
                    <Link to="/entrar">Entrar no Portal</Link>
                  </Button>
                  <Button
                    asChild
                    variant="outline"
                    className="min-h-[44px] w-full justify-center text-sm font-medium rounded-full"
                    onClick={() => setMobileMenuOpen(false)}
                  >
                    <Link to="/quem-somos">Conheça Nossa Fé</Link>
                  </Button>
                </div>

                {/* Mobile Social Links */}
                <div className="pt-2 border-t border-border/40 flex items-center justify-center gap-4">
                  <a
                    href="https://www.instagram.com/discipulos.bh"
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label="Instagram dos Discípulos em BH"
                    className="flex min-h-[44px] min-w-[44px] items-center justify-center rounded-full bg-muted/50 text-foreground transition-colors hover:bg-[#E1306C] hover:text-white"
                  >
                    <Instagram className="h-4 w-4" />
                  </a>
                  <a
                    href="https://www.youtube.com/@discipulosembelohorizonte4776"
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label="YouTube Discípulos de Jesus em BH"
                    className="flex min-h-[44px] min-w-[44px] items-center justify-center rounded-full bg-muted/50 text-foreground transition-colors hover:bg-[#FF0000] hover:text-white"
                  >
                    <Youtube className="h-4 w-4" />
                  </a>
                </div>
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </header>
  )
}
