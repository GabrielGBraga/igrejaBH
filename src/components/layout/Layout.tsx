import { Sidebar } from "./Sidebar"
import { MobileNav } from "./MobileNav"
import { ProfileCompletionBlocker } from "../ProfileCompletionBlocker"
import type { ReactNode } from "react"

interface LayoutProps {
  children: ReactNode
}

export function Layout({ children }: LayoutProps) {
  return (
    <div className="flex min-h-screen flex-col bg-background md:flex-row">
      <Sidebar />
      <MobileNav />
      <ProfileCompletionBlocker />
      <main className="mx-auto w-full max-w-7xl flex-1 animate-in p-4 duration-500 fade-in md:p-8">
        {children}
      </main>
    </div>
  )
}
