/**
 * @file KPIBoard.tsx
 * @description Dynamic KPI metrics card board recalculating statistics reactively from the filtered attendee dataset.
 */

import {
  Users,
  DollarSign,
  Bed,
  CheckCircle2,
  Clock,
  AlertCircle,
  TrendingUp,
  BarChart2,
  SlidersHorizontal,
  QrCode,
  Percent,
  Pin,
  Receipt,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import type { ComputedKPICard, KPIConfig } from "@/types/eventsFilter";

interface KPIBoardProps {
  cards: ComputedKPICard[];
  configs?: KPIConfig[];
  isFiltered?: boolean;
  onOpenBuilder?: () => void;
}

export function KPIBoard({
  cards,
  configs,
  isFiltered = false,
  onOpenBuilder,
}: KPIBoardProps) {
  // Render corresponding icon dynamically
  const renderIcon = (iconName: string) => {
    const iconClass = "w-3.5 h-3.5";
    switch (iconName) {
      case "users":
        return <Users className={`${iconClass} text-zinc-700 dark:text-zinc-300`} />;
      case "dollar":
        return <DollarSign className={`${iconClass} text-zinc-700 dark:text-zinc-300`} />;
      case "bed":
        return <Bed className={`${iconClass} text-zinc-700 dark:text-zinc-300`} />;
      case "check":
        return <CheckCircle2 className={`${iconClass} text-emerald-600 dark:text-emerald-400`} />;
      case "clock":
        return <Clock className={`${iconClass} text-amber-600 dark:text-amber-400`} />;
      case "alert":
        return <AlertCircle className={`${iconClass} text-amber-600 dark:text-amber-400`} />;
      case "trending-up":
        return <TrendingUp className={`${iconClass} text-emerald-600 dark:text-emerald-400`} />;
      case "qr_code":
        return <QrCode className={`${iconClass} text-emerald-600 dark:text-emerald-400`} />;
      case "percent":
        return <Percent className={`${iconClass} text-zinc-700 dark:text-zinc-300`} />;
      case "pin":
        return <Pin className={`${iconClass} text-zinc-700 dark:text-zinc-300`} />;
      case "receipt":
        return <Receipt className={`${iconClass} text-zinc-700 dark:text-zinc-300`} />;
      default:
        return <BarChart2 className={`${iconClass} text-zinc-700 dark:text-zinc-300`} />;
    }
  };

  const getAccentBarStyle = (theme?: string) => {
    switch (theme) {
      case "emerald":
        return "bg-emerald-500";
      case "blue":
        return "bg-blue-500";
      case "amber":
        return "bg-amber-500";
      case "rose":
        return "bg-rose-500";
      case "zinc":
      default:
        return "bg-zinc-300 dark:bg-zinc-700";
    }
  };

  const getMetricColorClass = (theme?: string) => {
    switch (theme) {
      case "emerald":
        return "text-emerald-600 dark:text-emerald-400";
      case "blue":
        return "text-blue-600 dark:text-blue-400";
      case "amber":
        return "text-amber-600 dark:text-amber-400";
      case "rose":
        return "text-rose-600 dark:text-rose-400";
      default:
        return "text-zinc-900 dark:text-zinc-50";
    }
  };

  return (
    <div className="space-y-2.5 w-full">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 px-1">
        <div className="flex items-center gap-2 flex-wrap">
          <span className="text-xs font-bold uppercase tracking-wider text-zinc-600 dark:text-zinc-400 flex items-center gap-1.5">
            <BarChart2 className="w-3.5 h-3.5 text-primary" />
            <span>Indicadores do Retiro</span>
          </span>
          {isFiltered && (
            <Badge
              variant="outline"
              className="bg-primary/10 text-primary border-primary/20 text-[10px] font-bold uppercase px-2 py-0.5"
            >
              Recálculo Reativo Ativo
            </Badge>
          )}
          {configs && configs.length > 4 && (
            <Badge
              variant="secondary"
              className="text-[10px] font-semibold px-2 py-0.5"
            >
              {configs.length} métricas
            </Badge>
          )}
        </div>

        {onOpenBuilder && (
          <Button
            variant="outline"
            onClick={onOpenBuilder}
            className="min-h-[44px] px-3.5 text-xs font-semibold rounded-lg flex items-center gap-2 cursor-pointer hover:bg-zinc-100 dark:hover:bg-zinc-800 self-end sm:self-auto"
          >
            <SlidersHorizontal className="w-3.5 h-3.5 text-zinc-500" />
            <span>Construtor de KPIs</span>
          </Button>
        )}
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 w-full">
        {cards.map((card) => {
          return (
            <Card
              key={card.id}
              className="rounded-xl border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900 shadow-sm p-4 pt-5 flex flex-col justify-between transition-all hover:border-zinc-300 dark:hover:border-zinc-700 relative overflow-hidden"
            >
              <div
                className={`absolute top-0 left-0 right-0 h-1 ${getAccentBarStyle(
                  card.colorTheme
                )}`}
              />

              <CardContent className="p-0 space-y-3">
                {/* Header row: Icon, Title & Badge */}
                <div className="flex items-center justify-between gap-2">
                  <span className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 flex items-center gap-1.5 truncate">
                    {renderIcon(card.iconName)}
                    <span className="truncate">{card.title}</span>
                  </span>

                  {card.badgeText && (
                    <Badge
                      variant="outline"
                      className={`text-[10px] font-bold uppercase px-2 py-0.5 shrink-0 ${
                        card.badgeVariant === "warning"
                          ? "bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/30"
                          : card.badgeVariant === "success"
                          ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30"
                          : "bg-zinc-100 text-zinc-700 dark:bg-zinc-800 dark:text-zinc-300 border-zinc-200 dark:border-zinc-700"
                      }`}
                    >
                      {card.badgeText}
                    </Badge>
                  )}
                </div>

                {/* Primary Metric Value */}
                <div>
                  <div
                    className={`text-2xl font-extrabold tracking-tight truncate ${getMetricColorClass(
                      card.colorTheme
                    )}`}
                  >
                    {card.value}{" "}
                    {card.secondaryValue && (
                      <span className="text-xs font-semibold text-zinc-500 dark:text-zinc-400 ml-1">
                        {card.secondaryValue}
                      </span>
                    )}
                  </div>
                </div>

                {/* Progress bar if present */}
                {card.progress !== undefined && (
                  <div className="space-y-1">
                    <Progress
                      value={card.progress}
                      className="h-1.5 bg-zinc-100 dark:bg-zinc-800"
                    />
                  </div>
                )}

                {/* Footer Subtext */}
                {card.description && (
                  <div className="text-[11px] text-zinc-500 dark:text-zinc-400 pt-1 border-t border-zinc-100 dark:border-zinc-800/80 truncate">
                    {card.description}
                  </div>
                )}
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
