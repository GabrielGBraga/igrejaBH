import {
  Calendar,
  MapPin,
  Clock,
  Backpack,
  Utensils,
  Bed,
  AlertCircle,
  Info,
  Heart,
  ArrowRight,
  Sparkles,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import type { FormPresentationPage } from "@/lib/forms";

interface FormPresentationViewProps {
  presentation: FormPresentationPage;
  retreat?: {
    title?: string | null;
    start_date?: string | null;
    end_date?: string | null;
    location_text?: string | null;
    max_participants?: number | null;
  } | null;
  onStart: () => void;
  isPreviewMode?: boolean;
}

const ICON_MAP: Record<string, any> = {
  backpack: Backpack,
  clock: Clock,
  "map-pin": MapPin,
  utensils: Utensils,
  bed: Bed,
  info: Info,
  alert: AlertCircle,
  heart: Heart,
  calendar: Calendar,
};

export function FormPresentationView({
  presentation,
  retreat,
  onStart,
  isPreviewMode = false,
}: FormPresentationViewProps) {
  const title = presentation.title || retreat?.title || "Apresentação do Encontro";
  const subtitle = presentation.subtitle;
  const description = presentation.description;
  const infoItems = presentation.infoItems || [];
  const ctaText = presentation.ctaButtonText || "Avançar para Inscrição";

  const formatDateRange = (start?: string | null, end?: string | null) => {
    if (!start) return null;
    const s = new Date(start).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });
    if (!end || end === start) return s;
    const e = new Date(end).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });
    return `${s} — ${e}`;
  };

  const datesFormatted = formatDateRange(retreat?.start_date, retreat?.end_date);

  return (
    <div className="flex flex-col w-full bg-card text-foreground">
      {/* Hero Section */}
      <div className="relative overflow-hidden w-full">
        {presentation.bannerUrl ? (
          <div className="relative h-48 sm:h-64 w-full overflow-hidden bg-zinc-900">
            <img
              src={presentation.bannerUrl}
              alt={title}
              className="h-full w-full object-cover object-center"
              onError={(e) => {
                // Fallback to gradient if image fails
                (e.target as HTMLElement).style.display = "none";
              }}
            />
            <div className="absolute inset-0 bg-gradient-to-t from-zinc-950 via-zinc-950/70 to-transparent" />
            <div className="absolute bottom-0 left-0 right-0 p-5 sm:p-6 text-white space-y-1.5">
              <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-white/20 backdrop-blur-sm text-white">
                <Sparkles className="w-3 h-3" />
                Informações do Encontro
              </span>
              <h1 className="text-lg sm:text-2xl font-extrabold tracking-tight text-white leading-tight">
                {title}
              </h1>
              {subtitle && (
                <p className="text-xs sm:text-sm text-zinc-200 line-clamp-2">
                  {subtitle}
                </p>
              )}
            </div>
          </div>
        ) : (
          <div className="bg-gradient-to-br from-zinc-900 via-zinc-800 to-zinc-950 text-white p-6 sm:p-8 space-y-2">
            <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-white/10 text-zinc-300">
              <Sparkles className="w-3 h-3 text-emerald-400" />
              Informações do Encontro
            </span>
            <h1 className="text-xl sm:text-2xl font-extrabold tracking-tight text-white leading-tight">
              {title}
            </h1>
            {subtitle && (
              <p className="text-xs sm:text-sm text-zinc-300">
                {subtitle}
              </p>
            )}
          </div>
        )}
      </div>

      {/* Body Content */}
      <div className="p-5 sm:p-7 space-y-6">
        {/* Event Quick Details Badges */}
        {(datesFormatted || retreat?.location_text) && (
          <div className="flex flex-wrap items-center gap-2.5 pb-2 border-b border-border/60 text-xs text-muted-foreground">
            {datesFormatted && (
              <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-muted/60 border border-border/50 text-foreground font-semibold">
                <Calendar className="w-3.5 h-3.5 text-primary" />
                <span>{datesFormatted}</span>
              </div>
            )}
            {retreat?.location_text && (
              <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-muted/60 border border-border/50 text-foreground font-semibold">
                <MapPin className="w-3.5 h-3.5 text-primary" />
                <span>{retreat.location_text}</span>
              </div>
            )}
          </div>
        )}

        {/* Description Section */}
        {description && (
          <div className="space-y-2">
            <h2 className="text-xs font-bold text-muted-foreground uppercase tracking-wider">
              Sobre o Encontro
            </h2>
            <div className="text-xs sm:text-sm text-foreground/90 leading-relaxed whitespace-pre-line rounded-xl bg-muted/20 p-4 border border-border/40">
              {description}
            </div>
          </div>
        )}

        {/* Highlight Cards Grid */}
        {infoItems.length > 0 && (
          <div className="space-y-3">
            <h2 className="text-xs font-bold text-muted-foreground uppercase tracking-wider">
              Orientações Práticas
            </h2>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {infoItems.map((item) => {
                const IconComponent = ICON_MAP[item.icon || "info"] || Info;
                return (
                  <div
                    key={item.id}
                    className="p-4 rounded-xl border border-border/70 bg-card hover:bg-muted/10 transition-colors space-y-1.5 shadow-xs"
                  >
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-lg bg-primary/10 text-primary flex items-center justify-center shrink-0">
                        <IconComponent className="w-4 h-4" />
                      </div>
                      <h3 className="text-xs sm:text-sm font-bold text-foreground">
                        {item.title}
                      </h3>
                    </div>
                    <p className="text-xs text-muted-foreground leading-relaxed pl-9">
                      {item.description}
                    </p>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* CTA Action Button */}
        <div className="pt-4 border-t border-border/60">
          <Button
            type="button"
            onClick={onStart}
            className="w-full min-h-[48px] rounded-xl bg-primary text-primary-foreground font-bold text-sm shadow-md hover:bg-primary/90 active:scale-[0.99] transition-all cursor-pointer flex items-center justify-center gap-2"
          >
            <span>{ctaText}</span>
            <ArrowRight className="w-4 h-4" />
          </Button>

          {isPreviewMode && (
            <p className="text-[11px] text-muted-foreground text-center mt-2">
              Modo de visualização rápida do construtor
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
