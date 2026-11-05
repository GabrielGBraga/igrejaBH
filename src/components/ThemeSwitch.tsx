import * as React from "react"
import { Switch as SwitchPrimitive } from "radix-ui"
import { Sun, Moon } from "lucide-react"
import { cn } from "@/lib/utils"

export interface ThemeSwitchProps
  extends React.ComponentPropsWithoutRef<typeof SwitchPrimitive.Root> {
  size?: "sm" | "md" | "lg" | "xl"
}

/**
 * Switch com animação fluida para alternância de tema Claro / Escuro.
 * Design sóbrio e elegante que se integra naturalmente ao visual da página:
 * perfil esbelto e baixo (altura de 32px), trilho alongado, física de mola (spring),
 * squash & stretch tátil, transição rotacional Sol/Lua e detalhes refinados de dia e noite.
 */
export const ThemeSwitch = React.forwardRef<
  React.ComponentRef<typeof SwitchPrimitive.Root>,
  ThemeSwitchProps
>(({ className, checked, onCheckedChange, size = "lg", ...props }, ref) => {
  const isDark = Boolean(checked)

  return (
    <SwitchPrimitive.Root
      ref={ref}
      data-theme-transition
      data-slot="theme-switch"
      checked={checked}
      onCheckedChange={onCheckedChange}
      aria-label={
        props["aria-label"] ||
        (isDark ? "Alternar para modo claro" : "Alternar para modo escuro")
      }
      className={cn(
        "group relative inline-flex shrink-0 cursor-pointer items-center rounded-full border transition-all duration-400 ease-out",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background",
        "disabled:cursor-not-allowed disabled:opacity-50",
        // Expande o alvo de toque para além de 44x44px
        "before:absolute before:-inset-2 before:content-['']",
        // Sizes (Perfil esbelto: altura contida de 28px/32px com largura alongada)
        size === "sm" && "h-7 w-12 p-1",
        size === "md" && "h-8 w-16 p-1",
        size === "lg" && "h-8 w-28 p-1",
        size === "xl" && "h-8 w-32 p-1",
        // Track appearance: Cores neutras e sutis integradas à página (Anti-AI Slop)
        isDark
          ? "border-zinc-800 bg-zinc-900/80 shadow-[inset_0_1px_3px_rgba(0,0,0,0.5)]"
          : "border-border/80 bg-muted/70 hover:bg-muted shadow-[inset_0_1px_2px_rgba(0,0,0,0.06)]",
        className
      )}
      {...props}
    >
      {/* Elementos decorativos no trilho: Estrelas da noite sutis (visíveis no modo escuro) */}
      <span
        aria-hidden="true"
        className={cn(
          "pointer-events-none absolute text-amber-300/70 transition-all duration-400 ease-out motion-reduce:transition-none motion-reduce:transform-none",
          (size === "sm" || size === "md") && "size-2 left-2 top-2",
          size === "lg" && "size-2.5 left-3 top-2",
          size === "xl" && "size-2.5 left-3.5 top-2",
          isDark
            ? "scale-100 opacity-100 delay-75 rotate-0"
            : "scale-0 opacity-0 -rotate-45 -translate-x-1"
        )}
      >
        <svg viewBox="0 0 24 24" fill="currentColor" className="size-full">
          <path d="M12 0L14.59 9.41L24 12L14.59 14.59L12 24L9.41 14.59L0 12L9.41 9.41L12 0Z" />
        </svg>
      </span>

      <span
        aria-hidden="true"
        className={cn(
          "pointer-events-none absolute rounded-full bg-amber-100/70 transition-all duration-400 ease-out motion-reduce:transition-none motion-reduce:transform-none",
          (size === "sm" || size === "md") && "size-1 left-3.5 bottom-1.5",
          size === "lg" && "size-1 left-6 bottom-2",
          size === "xl" && "size-1 left-7 bottom-2",
          isDark
            ? "scale-100 opacity-100 delay-100"
            : "scale-0 opacity-0 -translate-x-1"
        )}
      />

      <span
        aria-hidden="true"
        className={cn(
          "pointer-events-none absolute rounded-full bg-amber-200/60 transition-all duration-400 ease-out motion-reduce:transition-none motion-reduce:transform-none",
          (size === "sm" || size === "md") && "size-0.5 left-1.5 bottom-2",
          size === "lg" && "size-0.5 left-2.5 bottom-2",
          size === "xl" && "size-0.5 left-3 bottom-2",
          isDark
            ? "scale-100 opacity-100 delay-150"
            : "scale-0 opacity-0"
        )}
      />

      {/* Elemento decorativo no trilho: Nuvem suave do dia (visível no modo claro) */}
      <span
        aria-hidden="true"
        className={cn(
          "pointer-events-none absolute text-muted-foreground/35 transition-all duration-400 ease-out motion-reduce:transition-none motion-reduce:transform-none",
          size === "sm" && "size-3.5 right-1.5",
          size === "md" && "size-3.5 right-2",
          size === "lg" && "size-4 right-3",
          size === "xl" && "size-4 right-3.5",
          isDark
            ? "scale-0 opacity-0 translate-x-2"
            : "scale-100 opacity-100 translate-x-0"
        )}
      >
        <svg viewBox="0 0 24 24" fill="currentColor" className="size-full">
          <path d="M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96z" />
        </svg>
      </span>

      {/* Thumb animado com física de mola e feedback tátil */}
      <SwitchPrimitive.Thumb
        data-theme-transition
        data-slot="theme-switch-thumb"
        className={cn(
          "pointer-events-none relative flex items-center justify-center rounded-full transition-all duration-400 ease-[cubic-bezier(0.34,1.3,0.64,1)]",
          // Sizes & Translations
          size === "sm" &&
            "size-5 data-[state=checked]:translate-x-5 data-[state=unchecked]:translate-x-0",
          size === "md" &&
            "size-6 data-[state=checked]:translate-x-8 data-[state=unchecked]:translate-x-0",
          size === "lg" &&
            "size-6 data-[state=checked]:translate-x-20 data-[state=unchecked]:translate-x-0",
          size === "xl" &&
            "size-6 data-[state=checked]:translate-x-24 data-[state=unchecked]:translate-x-0",
          // Appearance: Visual clean e sutil que se integra perfeitamente à página
          isDark
            ? "border border-zinc-700 bg-zinc-800 text-zinc-100 shadow-xs"
            : "border border-border/80 bg-background text-foreground shadow-xs",
          // Squash and stretch ao pressionar
          "group-active:scale-x-110 group-active:scale-y-95",
          "motion-reduce:transition-none motion-reduce:transform-none"
        )}
      >
        {/* Ícone de Sol */}
        <Sun
          className={cn(
            "size-3.5 text-amber-600 dark:text-amber-400 transition-all duration-350 ease-out motion-reduce:transition-none motion-reduce:transform-none",
            isDark
              ? "scale-0 rotate-180 opacity-0"
              : "scale-100 rotate-0 opacity-100"
          )}
        />

        {/* Ícone de Lua */}
        <Moon
          className={cn(
            "absolute size-3.5 text-amber-400 transition-all duration-350 ease-out motion-reduce:transition-none motion-reduce:transform-none",
            isDark
              ? "scale-100 rotate-0 opacity-100"
              : "scale-0 -rotate-180 opacity-0"
          )}
        />
      </SwitchPrimitive.Thumb>
    </SwitchPrimitive.Root>
  )
})

ThemeSwitch.displayName = "ThemeSwitch"
