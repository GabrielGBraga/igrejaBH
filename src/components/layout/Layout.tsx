import { useState } from "react"
import { Sidebar } from "./Sidebar"
import { MobileNav } from "./MobileNav"
import { BottomNav } from "./BottomNav"
import { ProfileCompletionBlocker } from "../ProfileCompletionBlocker"
import type { ReactNode } from "react"

interface LayoutProps {
  children: ReactNode
}

export function Layout({ children }: LayoutProps) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  return (
    <div className="flex min-h-screen flex-col bg-background md:flex-row">
      <Sidebar />
      <MobileNav menuOpen={mobileMenuOpen} onMenuOpenChange={setMobileMenuOpen} />
      <ProfileCompletionBlocker />
      <main className="mx-auto w-full max-w-7xl flex-1 animate-in p-4 pb-24 duration-500 fade-in md:p-8 md:pb-8">
        {children}
      </main>
      <BottomNav onOpenMenu={() => setMobileMenuOpen(true)} />
    </div>
  )
}
