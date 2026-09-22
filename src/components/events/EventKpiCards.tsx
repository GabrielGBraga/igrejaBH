import { Users, DollarSign, Bed, CheckCircle2, Clock, AlertCircle } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";

interface EventKpiCardsProps {
  totalRegistered: number;
  maxParticipants: number;
  paidCount: number;
  pendingCount: number;
  totalRevenueEstimated: number;
  totalRevenueConfirmed: number;
  totalBeds: number;
  allocatedBedsCount: number;
  unallocatedCount: number;
}

export function EventKpiCards({
  totalRegistered,
  maxParticipants,
  paidCount,
  pendingCount,
  totalRevenueEstimated,
  totalRevenueConfirmed,
  totalBeds,
  allocatedBedsCount,
  unallocatedCount,
}: EventKpiCardsProps) {
  const occupancyRate =
    maxParticipants > 0
      ? Math.min(100, Math.round((totalRegistered / maxParticipants) * 100))
      : 0;

  const paidRate =
    totalRegistered > 0
      ? Math.min(100, Math.round((paidCount / totalRegistered) * 100))
      : 0;

  const bedsRate =
    totalBeds > 0
      ? Math.min(100, Math.round((allocatedBedsCount / totalBeds) * 100))
      : 0;

  const formatCurrency = (val: number) =>
    new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(val);

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 w-full">
      {/* KPI 1: Inscrições & Capacidade */}
      <Card className="rounded-xl border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900 shadow-sm p-4 flex flex-col justify-between">
        <CardContent className="p-0 space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 flex items-center gap-1.5">
              <Users className="w-3.5 h-3.5 text-zinc-700 dark:text-zinc-300" />
              Inscrições & Vagas
            </span>
            <Badge
              variant="outline"
              className={`text-[10px] font-bold uppercase px-2 py-0.5 ${
                occupancyRate >= 90
                  ? "bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/30"
                  : "bg-zinc-100 text-zinc-700 dark:bg-zinc-800 dark:text-zinc-300 border-zinc-200 dark:border-zinc-700"
              }`}
            >
              {occupancyRate}% Lotação
            </Badge>
          </div>

          <div>
            <div className="text-2xl font-extrabold text-zinc-900 dark:text-zinc-50 tracking-tight">
              {totalRegistered}{" "}
              <span className="text-xs font-semibold text-zinc-500">
                / {maxParticipants} vagas
              </span>
            </div>
          </div>

          <div className="space-y-1">
            <Progress value={occupancyRate} className="h-1.5 bg-zinc-100 dark:bg-zinc-800" />
            <p className="text-[11px] text-zinc-500 dark:text-zinc-400">
              {Math.max(0, maxParticipants - totalRegistered)} vagas disponíveis
            </p>
          </div>
        </CardContent>
      </Card>

      {/* KPI 2: Status dos Pagamentos */}
      <Card className="rounded-xl border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900 shadow-sm p-4 flex flex-col justify-between">
        <CardContent className="p-0 space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 flex items-center gap-1.5">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600 dark:text-emerald-400" />
              Pagamentos
            </span>
            <Badge
              variant="outline"
              className="bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 text-[10px] font-bold uppercase px-2 py-0.5"
            >
              {paidRate}% Quitados
            </Badge>
          </div>

          <div>
            <div className="text-2xl font-extrabold text-emerald-600 dark:text-emerald-400 tracking-tight">
              {paidCount}{" "}
              <span className="text-xs font-semibold text-zinc-500 dark:text-zinc-400">
                pagos
              </span>
            </div>
          </div>

          <div className="flex items-center justify-between text-[11px] pt-1 border-t border-zinc-100 dark:border-zinc-800/80">
            <span className="text-amber-600 dark:text-amber-400 font-semibold flex items-center gap-1">
              <Clock className="w-3 h-3" />
              {pendingCount} pendentes
            </span>
            <span className="text-zinc-500 dark:text-zinc-400">
              {totalRegistered} no total
            </span>
          </div>
        </CardContent>
      </Card>

      {/* KPI 3: Faturamento Confirmado & Estimado */}
      <Card className="rounded-xl border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900 shadow-sm p-4 flex flex-col justify-between">
        <CardContent className="p-0 space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 flex items-center gap-1.5">
              <DollarSign className="w-3.5 h-3.5 text-zinc-700 dark:text-zinc-300" />
              Faturamento
            </span>
            <Badge
              variant="outline"
              className="bg-zinc-100 text-zinc-700 dark:bg-zinc-800 dark:text-zinc-300 border-zinc-200 dark:border-zinc-700 text-[10px] font-bold uppercase px-2 py-0.5"
            >
              Estimado: {formatCurrency(totalRevenueEstimated)}
            </Badge>
          </div>

          <div>
            <div className="text-2xl font-extrabold text-zinc-900 dark:text-zinc-50 tracking-tight truncate">
              {formatCurrency(totalRevenueConfirmed)}
            </div>
          </div>

          <div className="text-[11px] text-zinc-500 dark:text-zinc-400 pt-1 border-t border-zinc-100 dark:border-zinc-800/80 truncate">
            A receber:{" "}
            <strong className="text-amber-600 dark:text-amber-400">
              {formatCurrency(Math.max(0, totalRevenueEstimated - totalRevenueConfirmed))}
            </strong>
          </div>
        </CardContent>
      </Card>

      {/* KPI 4: Alojamentos & Quartos */}
      <Card className="rounded-xl border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900 shadow-sm p-4 flex flex-col justify-between">
        <CardContent className="p-0 space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 flex items-center gap-1.5">
              <Bed className="w-3.5 h-3.5 text-zinc-700 dark:text-zinc-300" />
              Alojamento & Quartos
            </span>
            <Badge
              variant="outline"
              className="bg-zinc-100 text-zinc-700 dark:bg-zinc-800 dark:text-zinc-300 border-zinc-200 dark:border-zinc-700 text-[10px] font-bold uppercase px-2 py-0.5"
            >
              {bedsRate}% Ocupado
            </Badge>
          </div>

          <div>
            <div className="text-2xl font-extrabold text-zinc-900 dark:text-zinc-50 tracking-tight">
              {allocatedBedsCount}{" "}
              <span className="text-xs font-semibold text-zinc-500 dark:text-zinc-400">
                / {totalBeds} camas
              </span>
            </div>
          </div>

          <div className="flex items-center justify-between text-[11px] pt-1 border-t border-zinc-100 dark:border-zinc-800/80">
            {unallocatedCount > 0 ? (
              <span className="text-amber-600 dark:text-amber-400 font-semibold flex items-center gap-1">
                <AlertCircle className="w-3 h-3" />
                {unallocatedCount} sem quarto
              </span>
            ) : (
              <span className="text-emerald-600 dark:text-emerald-400 font-semibold flex items-center gap-1">
                <CheckCircle2 className="w-3 h-3" />
                Todos alocados
              </span>
            )}
            <span className="text-zinc-500 dark:text-zinc-400">
              {Math.max(0, totalBeds - allocatedBedsCount)} camas livres
            </span>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
