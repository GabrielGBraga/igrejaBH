import * as React from "react"
import { Search, ChevronDown, X, Check } from "lucide-react"
import { Popover, PopoverAnchor, PopoverContent } from "@/components/ui/popover"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"

export interface SearchableSelectOption {
  value: string
  label: string
  description?: string
  badge?: string
  keywords?: string
}

export interface SearchableSelectProps {
  options: SearchableSelectOption[]
  value?: string | null
  onValueChange: (value: string) => void
  placeholder?: string
  emptyMessage?: string
  disabled?: boolean
  className?: string
  triggerClassName?: string
  clearable?: boolean
  id?: string
  name?: string
}

function normalizeSearch(str: string): string {
  return str
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim()
}

export function SearchableSelect({
  options,
  value,
  onValueChange,
  placeholder = "Buscar ou selecionar...",
  emptyMessage = "Nenhum resultado encontrado.",
  disabled = false,
  className,
  triggerClassName,
  clearable = true,
  id,
  name,
}: SearchableSelectProps) {
  const [open, setOpen] = React.useState(false)
  const [typedQuery, setTypedQuery] = React.useState("")
  const [isTyping, setIsTyping] = React.useState(false)
  const [highlightedIndex, setHighlightedIndex] = React.useState(0)

  const inputRef = React.useRef<HTMLInputElement | null>(null)
  const listRef = React.useRef<HTMLDivElement | null>(null)

  // Opção atualmente selecionada
  const selectedOption = React.useMemo(() => {
    if (!value) return null
    return options.find((opt) => opt.value === value) || null
  }, [options, value])

  // Filtragem dinâmica enquanto o usuário escreve
  const filteredOptions = React.useMemo(() => {
    if (!isTyping || !typedQuery.trim()) {
      return options
    }
    const queryNorm = normalizeSearch(typedQuery)
    return options.filter((opt) => {
      const labelNorm = normalizeSearch(opt.label)
      const descNorm = opt.description ? normalizeSearch(opt.description) : ""
      const keyNorm = opt.keywords ? normalizeSearch(opt.keywords) : ""
      return (
        labelNorm.includes(queryNorm) ||
        descNorm.includes(queryNorm) ||
        keyNorm.includes(queryNorm)
      )
    })
  }, [options, typedQuery, isTyping])

  // Reseta índice destacado ao mudar a busca
  React.useEffect(() => {
    setHighlightedIndex(0)
  }, [typedQuery])

  // Valor a ser exibido no input
  const displayInputValue = isTyping
    ? typedQuery
    : selectedOption
    ? selectedOption.label
    : ""

  const handleSelect = (option: SearchableSelectOption) => {
    onValueChange(option.value)
    setIsTyping(false)
    setTypedQuery("")
    setOpen(false)
  }

  const handleClear = (e: React.MouseEvent) => {
    e.stopPropagation()
    // Se existir uma opção "none", usa ela, senão passa string vazia
    const noneOption = options.find((o) => o.value === "none")
    onValueChange(noneOption ? "none" : "")
    setIsTyping(false)
    setTypedQuery("")
    inputRef.current?.focus()
  }

  const handleInputFocus = () => {
    if (disabled) return
    setOpen(true)
    setIsTyping(false)
    setTypedQuery("")
    // Seleciona o texto para facilitar digitação imediata
    setTimeout(() => {
      inputRef.current?.select()
    }, 50)
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const nextVal = e.target.value
    setIsTyping(true)
    setTypedQuery(nextVal)
    if (!open) {
      setOpen(true)
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (disabled) return

    if (!open) {
      if (e.key === "ArrowDown" || e.key === "Enter" || e.key === " ") {
        setOpen(true)
        e.preventDefault()
      }
      return
    }

    if (e.key === "ArrowDown") {
      e.preventDefault()
      setHighlightedIndex((prev) =>
        prev < filteredOptions.length - 1 ? prev + 1 : 0
      )
    } else if (e.key === "ArrowUp") {
      e.preventDefault()
      setHighlightedIndex((prev) =>
        prev > 0 ? prev - 1 : Math.max(0, filteredOptions.length - 1)
      )
    } else if (e.key === "Enter") {
      e.preventDefault()
      if (filteredOptions.length > 0 && highlightedIndex >= 0 && highlightedIndex < filteredOptions.length) {
        handleSelect(filteredOptions[highlightedIndex])
      }
    } else if (e.key === "Escape") {
      e.preventDefault()
      setIsTyping(false)
      setTypedQuery("")
      setOpen(false)
    }
  }

  // Scroll automático para o item destacado
  React.useEffect(() => {
    if (open && listRef.current) {
      const activeElement = listRef.current.children[highlightedIndex] as HTMLElement
      if (activeElement) {
        activeElement.scrollIntoView({ block: "nearest" })
      }
    }
  }, [highlightedIndex, open])

  const hasValue = !!value && value !== "none"

  return (
    <div className={cn("relative w-full", className)}>
      <Popover
        modal={false}
        open={open}
        onOpenChange={(nextOpen) => {
          setOpen(nextOpen)
          if (!nextOpen) {
            setIsTyping(false)
            setTypedQuery("")
          }
        }}
      >
        <PopoverAnchor asChild>
          <div
            className={cn(
              "group relative flex h-11 min-h-[44px] w-full items-center rounded-xl border border-input bg-background px-3 transition-colors",
              "focus-within:border-ring focus-within:ring-2 focus-within:ring-ring/30",
              disabled && "cursor-not-allowed opacity-50 bg-muted/40",
              triggerClassName
            )}
          >
            <Search className="mr-2 h-4 w-4 shrink-0 text-muted-foreground pointer-events-none" />

            <input
              ref={inputRef}
              id={id}
              name={name}
              type="text"
              disabled={disabled}
              value={displayInputValue}
              onChange={handleInputChange}
              onFocus={handleInputFocus}
              onKeyDown={handleKeyDown}
              placeholder={placeholder}
              autoComplete="off"
              className="h-full flex-1 bg-transparent text-xs sm:text-sm text-foreground outline-none placeholder:text-muted-foreground"
            />

            <div className="flex items-center shrink-0 ml-1">
              {clearable && hasValue && !disabled && (
                <button
                  type="button"
                  onClick={handleClear}
                  tabIndex={-1}
                  aria-label="Limpar seleção"
                  className="flex h-11 w-9 items-center justify-center rounded-md text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
                >
                  <X className="h-4 w-4" />
                </button>
              )}

              <button
                type="button"
                tabIndex={-1}
                disabled={disabled}
                onClick={() => {
                  if (disabled) return
                  if (open) {
                    setOpen(false)
                  } else {
                    inputRef.current?.focus()
                  }
                }}
                aria-label="Abrir opções"
                className="flex h-11 w-9 items-center justify-center rounded-md text-muted-foreground transition-transform duration-200"
              >
                <ChevronDown
                  className={cn(
                    "h-4 w-4 transition-transform duration-200",
                    open && "rotate-180"
                  )}
                />
              </button>
            </div>
          </div>
        </PopoverAnchor>

        <PopoverContent
          align="start"
          sideOffset={6}
          onOpenAutoFocus={(e) => e.preventDefault()}
          onCloseAutoFocus={(e) => e.preventDefault()}
          className="z-100 w-[var(--radix-popover-trigger-width)] min-w-[min(280px,calc(100vw-1.5rem))] max-w-[calc(100vw-1.5rem)] p-1.5 rounded-xl border border-border/80 bg-popover text-popover-foreground shadow-xl backdrop-blur-md overflow-hidden"
        >
          {/* Contador de opções quando filtrando */}
          {isTyping && typedQuery.trim() && (
            <div className="px-2.5 py-1 text-[11px] font-medium text-muted-foreground border-b border-border/50 mb-1 flex items-center justify-between">
              <span>Buscando por &ldquo;{typedQuery}&rdquo;</span>
              <span>{filteredOptions.length} resultado(s)</span>
            </div>
          )}

          <div
            ref={listRef}
            className="no-scrollbar max-h-60 overflow-y-auto space-y-0.5"
          >
            {filteredOptions.length === 0 ? (
              <div className="py-6 px-3 text-center text-xs text-muted-foreground">
                <Search className="mx-auto h-5 w-5 mb-1.5 opacity-40" />
                <p>{emptyMessage}</p>
                <p className="text-[10px] opacity-75 mt-0.5">
                  Tente digitar outro termo ou verifique a ortografia.
                </p>
              </div>
            ) : (
              filteredOptions.map((opt, index) => {
                const isSelected = value === opt.value
                const isHighlighted = highlightedIndex === index

                return (
                  <div
                    key={opt.value}
                    onMouseDown={(e) => {
                      // Evita que o input perca o foco antes do clique registrar
                      e.preventDefault()
                    }}
                    onClick={() => handleSelect(opt)}
                    onMouseEnter={() => setHighlightedIndex(index)}
                    className={cn(
                      "relative flex min-h-[44px] cursor-pointer items-center justify-between rounded-lg px-3 py-2 text-xs sm:text-sm transition-colors",
                      isHighlighted
                        ? "bg-accent text-accent-foreground"
                        : "hover:bg-muted/60 text-foreground",
                      isSelected && "font-medium bg-primary/10 text-primary hover:bg-primary/15"
                    )}
                  >
                    <div className="flex flex-col min-w-0 pr-2">
                      <div className="flex items-center gap-2">
                        <span className="truncate">{opt.label}</span>
                        {opt.badge && (
                          <Badge
                            variant="outline"
                            className="text-[10px] px-1.5 py-0 font-normal shrink-0 border-primary/30 bg-primary/10 text-primary"
                          >
                            {opt.badge}
                          </Badge>
                        )}
                      </div>
                      {opt.description && (
                        <span className="text-[11px] text-muted-foreground truncate mt-0.5">
                          {opt.description}
                        </span>
                      )}
                    </div>

                    {isSelected && (
                      <Check className="h-4 w-4 shrink-0 text-primary ml-2" />
                    )}
                  </div>
                )
              })
            )}
          </div>
        </PopoverContent>
      </Popover>
    </div>
  )
}
