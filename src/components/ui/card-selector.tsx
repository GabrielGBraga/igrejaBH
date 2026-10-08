import * as React from "react"
import { RadioGroup as RadioGroupPrimitive } from "radix-ui"
import { Check } from "lucide-react"

import { cn } from "@/lib/utils"

export interface CardSelectorOption {
  value: string
  label: React.ReactNode
  description?: React.ReactNode
  icon?: React.ReactNode
  disabled?: boolean
}

export interface CardSelectorProps
  extends React.ComponentProps<typeof RadioGroupPrimitive.Root> {
  options?: CardSelectorOption[]
  columns?: 1 | 2 | 3 | 4
  size?: "default" | "sm" | "lg"
}

function CardSelector({
  className,
  columns = 1,
  options,
  children,
  size = "default",
  ...props
}: CardSelectorProps) {
  const columnClasses = {
    1: "grid-cols-1",
    2: "grid-cols-1 sm:grid-cols-2",
    3: "grid-cols-1 sm:grid-cols-2 lg:grid-cols-3",
    4: "grid-cols-1 sm:grid-cols-2 lg:grid-cols-4",
  }

  return (
    <RadioGroupPrimitive.Root
      data-slot="card-selector"
      className={cn("grid w-full gap-2.5", columnClasses[columns], className)}
      {...props}
    >
      {options
        ? options.map((opt) => (
            <CardSelectorItem
              key={opt.value}
              value={opt.value}
              label={opt.label}
              description={opt.description}
              icon={opt.icon}
              disabled={opt.disabled}
              size={size}
            />
          ))
        : children}
    </RadioGroupPrimitive.Root>
  )
}

export interface CardSelectorItemProps
  extends React.ComponentProps<typeof RadioGroupPrimitive.Item> {
  label?: React.ReactNode
  description?: React.ReactNode
  icon?: React.ReactNode
  indicatorPosition?: "left" | "right" | "none"
  indicatorType?: "dot" | "check"
  size?: "default" | "sm" | "lg"
}

function CardSelectorItem({
  className,
  children,
  label,
  description,
  icon,
  indicatorPosition = "right",
  indicatorType = "dot",
  size = "default",
  ...props
}: CardSelectorItemProps) {
  const sizeClasses = {
    sm: "min-h-[44px] px-3 py-2 text-xs",
    default: "min-h-[48px] px-4 py-3 text-sm",
    lg: "min-h-[56px] px-5 py-4 text-base",
  }

  return (
    <RadioGroupPrimitive.Item
      data-slot="card-selector-item"
      className={cn(
        "group/card-selector relative flex w-full cursor-pointer items-center justify-between gap-3 rounded-xl border border-border/70 bg-card text-left transition-all duration-150 outline-none select-none",
        "hover:border-primary/50 hover:bg-muted/40",
        "focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2",
        "data-[state=checked]:border-primary data-[state=checked]:bg-primary/5 data-[state=checked]:shadow-xs data-[state=checked]:ring-1 data-[state=checked]:ring-primary/25 dark:data-[state=checked]:bg-primary/10",
        "disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50",
        "motion-reduce:transition-none motion-reduce:transform-none",
        sizeClasses[size],
        className
      )}
      {...props}
    >
      {indicatorPosition === "left" && (
        <CardSelectorIndicator type={indicatorType} />
      )}

      <div className="flex min-w-0 flex-1 flex-col justify-center gap-0.5">
        <div className="flex items-center gap-2">
          {icon && (
            <span className="shrink-0 text-muted-foreground transition-colors group-data-[state=checked]/card-selector:text-primary">
              {icon}
            </span>
          )}
          <span className="truncate font-medium text-foreground">
            {label || children}
          </span>
        </div>
        {description && (
          <span className="line-clamp-2 text-xs text-muted-foreground">
            {description}
          </span>
        )}
      </div>

      {indicatorPosition === "right" && (
        <CardSelectorIndicator type={indicatorType} />
      )}
    </RadioGroupPrimitive.Item>
  )
}

function CardSelectorIndicator({
  type = "dot",
}: {
  type?: "dot" | "check"
}) {
  return (
    <div
      aria-hidden="true"
      className={cn(
        "flex size-4.5 shrink-0 items-center justify-center rounded-full border border-input/80 transition-colors duration-150",
        "group-hover/card-selector:border-primary/60",
        "group-data-[state=checked]/card-selector:border-primary group-data-[state=checked]/card-selector:bg-primary group-data-[state=checked]/card-selector:text-primary-foreground",
        "motion-reduce:transition-none"
      )}
    >
      <RadioGroupPrimitive.Indicator className="flex items-center justify-center">
        {type === "check" ? (
          <Check className="size-3 stroke-[2.5]" />
        ) : (
          <span className="size-1.5 rounded-full bg-white dark:bg-zinc-950" />
        )}
      </RadioGroupPrimitive.Indicator>
    </div>
  )
}

export { CardSelector, CardSelectorItem }
