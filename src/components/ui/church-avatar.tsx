import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"
import { ChurchSymbol } from "@/components/icons/ChurchLogo"

const churchAvatarVariants = cva(
  "relative inline-flex items-center justify-center overflow-hidden transition-all duration-300 shrink-0 select-none",
  {
    variants: {
      size: {
        xs: "size-6 p-0.5",
        sm: "size-8 p-1",
        md: "size-10 p-1.5",
        lg: "size-14 p-2",
        xl: "size-20 p-3",
        "2xl": "size-28 p-4",
      },
      shape: {
        circle: "rounded-full",
        squircle: "rounded-xl",
      },
      variant: {
        solid:
          "bg-zinc-900 text-zinc-50 border border-zinc-800 dark:bg-zinc-100 dark:text-zinc-900 dark:border-zinc-200 shadow-xs",
        subtle:
          "bg-emerald-50 text-[#1b4332] border border-emerald-200/80 dark:bg-emerald-950/80 dark:text-[#86efac] dark:border-emerald-800/60 shadow-xs",
        outline:
          "bg-background/90 border border-primary/25 text-primary dark:border-emerald-500/30 dark:text-emerald-400 shadow-xs backdrop-blur-xs",
        glow:
          "bg-gradient-to-b from-emerald-500/15 via-background to-primary/10 border border-emerald-500/30 text-primary dark:text-emerald-300 dark:from-emerald-500/20 dark:to-emerald-900/40 shadow-md shadow-emerald-500/10 dark:shadow-emerald-950/40",
      },
    },
    defaultVariants: {
      size: "md",
      shape: "squircle",
      variant: "subtle",
    },
  }
)

export interface ChurchAvatarProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof churchAvatarVariants> {
  src?: string | null
  alt?: string
  showVerifiedBadge?: boolean
  symbolClassName?: string
}

export const ChurchAvatar = React.forwardRef<HTMLDivElement, ChurchAvatarProps>(
  (
    {
      className,
      size,
      shape,
      variant,
      src,
      alt = "Avatar da Igreja em BH",
      showVerifiedBadge = false,
      symbolClassName,
      ...props
    },
    ref
  ) => {
    const [imageError, setImageError] = React.useState(false)

    return (
      <div
        ref={ref}
        className={cn(churchAvatarVariants({ size, shape, variant }), className)}
        {...props}
      >
        {src && !imageError ? (
          <img
            src={src}
            alt={alt}
            onError={() => setImageError(true)}
            className="h-full w-full object-cover rounded-[inherit]"
          />
        ) : (
          <ChurchSymbol
            className={cn(
              "h-full w-full object-contain transition-transform duration-300 hover:scale-105",
              symbolClassName
            )}
          />
        )}

        {showVerifiedBadge && (
          <span className="absolute -bottom-0.5 -right-0.5 flex size-3 items-center justify-center rounded-full bg-emerald-500 ring-2 ring-background">
            <span className="size-1.5 rounded-full bg-white" />
          </span>
        )}
      </div>
    )
  }
)

ChurchAvatar.displayName = "ChurchAvatar"
