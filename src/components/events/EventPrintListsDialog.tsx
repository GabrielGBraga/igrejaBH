import { useState, useMemo } from "react";
import { createPortal } from "react-dom";
import {
  Printer,
  Users,
  Bed,
  UtensilsCrossed,
  Layers,
  CheckCircle2,
} from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { ChurchSymbol } from "@/components/icons/ChurchLogo";
import { formatDateBR } from "@/lib/utils";
import type { RegistrationWithDetails } from "./RegistrationDetailDialog";
import type { RetreatRoom } from "./RoomManagementTab";
import {
  getParticipantName,
  getParticipantPhone,
  getParticipantCityState,
  getParticipantRoom,
  getParticipantDietaryInfo,
  type PrintReportType,
  type DietaryInfo,
} from "@/lib/eventPrintUtils";

// ==========================================================================
// CABEÇALHO PADRÃO OFICIAL DE IMPRESSÃO A4 (PRETO & BRANCO)
// ==========================================================================
function OfficialPrintHeader({
  reportTitle,
  retreatTitle,
  dates,
  location,
  extraMeta,
}: {
  reportTitle: string;
  retreatTitle: string;
  dates: string;
  location: string;
  extraMeta?: string;
}) {
  const emissionDate = new Date().toLocaleDateString("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });

  return (
    <header className="border-b-2 border-black pb-3 mb-4 print-avoid-break">
      <div className="flex items-start justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="w-12 h-10 border border-black rounded flex items-center justify-center p-1 bg-white">
            <ChurchSymbol className="w-full h-full text-black" />
          </div>
          <div>
            <h1 className="text-sm font-black tracking-wider uppercase text-black">
              Igreja em Belo Horizonte
            </h1>
            <p className="text-[10px] uppercase tracking-wider text-black font-semibold">
              Igreja em BH • Vida Comum nas Casas e nas Ruas
            </p>
          </div>
        </div>

        <div className="text-right text-[10px] text-black">
          <p className="font-semibold">Emissão: {emissionDate}</p>
          <p className="text-black/80">Operação em Campo / Sítio</p>
        </div>
      </div>

      <div className="mt-3 pt-2 border-t border-zinc-400 flex flex-wrap items-end justify-between gap-2">
        <div>
          <h2 className="text-base font-black text-black tracking-tight uppercase">
            {reportTitle}
          </h2>
          <p className="text-xs font-bold text-black mt-0.5">
            Evento: {retreatTitle}
          </p>
        </div>

        <div className="text-right text-[11px] text-black space-y-0.5">
          <p>
            <span className="font-semibold">Período:</span> {dates}
          </p>
          <p>
            <span className="font-semibold">Local:</span> {location}
          </p>
          {extraMeta && (
            <p className="font-bold text-black border-t border-zinc-300 pt-0.5">
              {extraMeta}
            </p>
          )}
        </div>
      </div>
    </header>
  );
}

// ==========================================================================
// 1. LISTA DE PRESENÇA / PORTARIA (A4 EM ORDEM ALFABÉTICA)
// ==========================================================================
function PresenceListDocument({
  retreat,
  registrations,
  sortBy,
}: {
  retreat: {
    title: string;
    start_date?: string | null;
    end_date?: string | null;
    location_text?: string | null;
  };
  registrations: RegistrationWithDetails[];
  sortBy: "name" | "room" | "city";
}) {
  const dates = retreat.start_date
    ? `${formatDateBR(retreat.start_date)} a ${
        retreat.end_date ? formatDateBR(retreat.end_date) : "Término"
      }`
    : "Data a definir";

  const location = retreat.location_text || "Local a confirmar";

  // Ordenação configurável (Default: Alfabética A-Z)
  const sortedRegistrations = useMemo(() => {
    const list = [...registrations];
    if (sortBy === "name") {
      list.sort((a, b) =>
        getParticipantName(a).localeCompare(getParticipantName(b), "pt-BR", {
          sensitivity: "base",
        })
      );
    } else if (sortBy === "room") {
      list.sort((a, b) => {
        const roomA = getParticipantRoom(a);
        const roomB = getParticipantRoom(b);
        if (roomA === roomB) {
          return getParticipantName(a).localeCompare(getParticipantName(b), "pt-BR");
        }
        return roomA.localeCompare(roomB, "pt-BR");
      });
    } else if (sortBy === "city") {
      list.sort((a, b) => {
        const cityA = getParticipantCityState(a);
        const cityB = getParticipantCityState(b);
        if (cityA === cityB) {
          return getParticipantName(a).localeCompare(getParticipantName(b), "pt-BR");
        }
        return cityA.localeCompare(cityB, "pt-BR");
      });
    }
    return list;
  }, [registrations, sortBy]);

  return (
    <div className="text-black bg-white">
      <OfficialPrintHeader
        reportTitle="Lista de Presença & Portaria"
        retreatTitle={retreat.title}
        dates={dates}
        location={location}
        extraMeta={`Total de Discípulos: ${sortedRegistrations.length}`}
      />

      <div className="w-full">
        <table className="w-full border-collapse text-left text-[11px]">
          <thead>
            <tr className="border-b-2 border-black bg-zinc-100 text-black font-extrabold uppercase text-[10px] tracking-wider">
              <th className="py-2 px-1.5 text-center w-8 border border-zinc-400">Nº</th>
              <th className="py-2 px-2 border border-zinc-400">Nome do Discípulo</th>
              <th className="py-2 px-2 w-28 border border-zinc-400">Telefone</th>
              <th className="py-2 px-2 w-36 border border-zinc-400">Cidade / Estado</th>
              <th className="py-2 px-2 w-32 border border-zinc-400">Quarto Alocado</th>
              <th className="py-2 px-2 w-36 text-center border border-zinc-400">Visto / Assinatura</th>
            </tr>
          </thead>
          <tbody>
            {sortedRegistrations.map((reg, index) => {
              const name = getParticipantName(reg);
              const phone = getParticipantPhone(reg);
              const cityState = getParticipantCityState(reg);
              const room = getParticipantRoom(reg);

              return (
                <tr
                  key={reg.id || index}
                  className="border-b border-zinc-300 print-avoid-break hover:bg-zinc-50"
                >
                  <td className="py-1.5 px-1 text-center font-bold text-zinc-700 border-x border-zinc-300 text-[10px]">
                    {String(index + 1).padStart(2, "0")}
                  </td>
                  <td className="py-1.5 px-2 font-bold text-black border-r border-zinc-300">
                    {name}
                  </td>
                  <td className="py-1.5 px-2 text-zinc-800 border-r border-zinc-300 whitespace-nowrap text-[10px]">
                    {phone}
                  </td>
                  <td className="py-1.5 px-2 text-zinc-800 border-r border-zinc-300 text-[10px] break-words">
                    {cityState}
                  </td>
                  <td className="py-1.5 px-2 font-semibold text-black border-r border-zinc-300 text-[10px]">
                    {room}
                  </td>
                  <td className="py-1.5 px-2 border-r border-zinc-300 text-center">
                    <div className="w-full border-b border-zinc-400 h-4" />
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Rodapé da Portaria para Conferência em Campo */}
      <footer className="mt-6 pt-4 border-t-2 border-black print-avoid-break text-[10px] space-y-4">
        <div className="grid grid-cols-2 gap-6">
          <div className="border border-zinc-400 rounded p-2.5 space-y-1.5 bg-zinc-50">
            <p className="font-bold uppercase tracking-wider text-black">
              Conferência de Portaria (Diaconato de Acolhimento):
            </p>
            <p>• Total Previsto: <strong>{sortedRegistrations.length} discípulos</strong></p>
            <p>• Chegadas Confirmadas: [ &nbsp; &nbsp; &nbsp; &nbsp; ] discípulos</p>
            <p>• Ausências / Desistências: [ &nbsp; &nbsp; &nbsp; &nbsp; ] discípulos</p>
          </div>

          <div className="border border-zinc-400 rounded p-2.5 space-y-4 bg-zinc-50">
            <p className="font-bold uppercase tracking-wider text-black">
              Visto dos Diáconos / Responsáveis da Portaria:
            </p>
            <div className="pt-2 border-b border-black text-center text-zinc-500">
              Assinatura do Diácono Responsável
            </div>
          </div>
        </div>

        <div className="text-center text-zinc-500 text-[9px] pt-1">
          Documento gerado para operação local offline no sítio — Igreja em Belo Horizonte
        </div>
      </footer>
    </div>
  );
}

// ==========================================================================
// 2. FOLHAS DE PORTA DE QUARTOS (UMA PÁGINA A4 POR QUARTO)
// ==========================================================================
function RoomSheetsDocument({
  retreat,
  rooms,
  registrations,
  includeEmptyRooms,
  includeUnallocatedSheet,
}: {
  retreat: {
    title: string;
    start_date?: string | null;
    end_date?: string | null;
    location_text?: string | null;
  };
  rooms: RetreatRoom[];
  registrations: RegistrationWithDetails[];
  includeEmptyRooms: boolean;
  includeUnallocatedSheet: boolean;
}) {
  const dates = retreat.start_date
    ? `${formatDateBR(retreat.start_date)} a ${
        retreat.end_date ? formatDateBR(retreat.end_date) : "Término"
      }`
    : "Data a definir";

  // Agrupa os discípulos por quarto
  const registrationsByRoomId = useMemo(() => {
    const map = new Map<string, RegistrationWithDetails[]>();
    rooms.forEach((r) => map.set(r.id, []));

    registrations.forEach((reg) => {
      if (reg.room_id && map.has(reg.room_id)) {
        map.get(reg.room_id)!.push(reg);
      } else if (reg.room_allocation && reg.room_allocation !== "Não alocado") {
        // Encontra quarto por nome se não tiver room_id vinculado
        const matched = rooms.find(
          (r) => r.name.toLowerCase() === reg.room_allocation?.toLowerCase()
        );
        if (matched) {
          map.get(matched.id)!.push(reg);
        }
      }
    });

    return map;
  }, [rooms, registrations]);

  // Inscritos que ainda não foram alocados em nenhum quarto
  const unallocatedAttendees = useMemo(() => {
    return registrations.filter((reg) => {
      const hasRoomId = !!reg.room_id;
      const hasAllocation =
        !!reg.room_allocation && reg.room_allocation !== "Não alocado";
      return !hasRoomId && !hasAllocation;
    });
  }, [registrations]);

  const filteredRooms = useMemo(() => {
    if (includeEmptyRooms) return rooms;
    return rooms.filter((room) => {
      const occ = registrationsByRoomId.get(room.id) || [];
      return occ.length > 0;
    });
  }, [rooms, registrationsByRoomId, includeEmptyRooms]);

  return (
    <div className="text-black bg-white">
      {filteredRooms.map((room) => {
        const occupants = registrationsByRoomId.get(room.id) || [];
        occupants.sort((a, b) =>
          getParticipantName(a).localeCompare(getParticipantName(b), "pt-BR")
        );

        const capacity = room.capacity || 0;
        const remainingSpots = Math.max(0, capacity - occupants.length);
        const isFull = capacity > 0 && occupants.length >= capacity;

        const genderLabel =
          room.gender_type === "masculino"
            ? "Alojamento Masculino"
            : room.gender_type === "feminino"
            ? "Alojamento Feminino"
            : room.gender_type === "suite"
            ? "Suíte de Casal / Família"
            : "Alojamento Geral";

        return (
          <div
            key={room.id}
            className="print-page-break mb-8 pb-4"
            style={{ minHeight: "260mm" }}
          >
            {/* Top Tape Margins / Guias para fita adesiva */}
            <div className="flex justify-between items-center text-[9px] uppercase tracking-widest text-zinc-400 mb-2 border-b border-dashed border-zinc-300 pb-1">
              <span>[ Fixar com fita adesiva aqui ]</span>
              <span>Folha de Porta • Alojamento</span>
              <span>[ Fixar com fita adesiva aqui ]</span>
            </div>

            {/* Cabeçalho do Alojamento */}
            <header className="border-4 border-black p-4 text-center rounded-xl bg-white mb-6">
              <div className="flex items-center justify-center gap-2 mb-1">
                <div className="w-8 h-8 p-1 border border-black rounded">
                  <ChurchSymbol className="w-full h-full text-black" />
                </div>
                <h1 className="text-xs font-black tracking-widest uppercase text-black">
                  Igreja em Belo Horizonte
                </h1>
              </div>

              <p className="text-[11px] font-bold text-zinc-700 uppercase">
                {retreat.title} • {dates}
              </p>

              <div className="mt-3 pt-3 border-t-2 border-black">
                <p className="text-[11px] font-bold uppercase tracking-widest text-zinc-600">
                  Dormitório / Alojamento
                </p>
                <h2 className="text-2xl sm:text-3xl font-black text-black tracking-tight uppercase my-1">
                  {room.name}
                </h2>

                <div className="flex items-center justify-center gap-3 text-xs font-extrabold mt-2 flex-wrap">
                  <span className="px-2.5 py-0.5 border border-black rounded-full uppercase">
                    {genderLabel}
                  </span>
                  <span className="px-2.5 py-0.5 border border-black rounded-full">
                    {occupants.length} de {capacity} Vagas Ocupadas
                  </span>
                  {isFull && (
                    <span className="px-2.5 py-0.5 bg-black text-white font-bold rounded-full uppercase">
                      Lotação Completa
                    </span>
                  )}
                </div>
              </div>
            </header>

            {/* Relação dos Ocupantes */}
            <section className="mb-6">
              <h3 className="text-xs font-black uppercase tracking-wider text-black border-b-2 border-black pb-1 mb-3">
                Discípulos Alocados neste Quarto ({occupants.length}):
              </h3>

              <div className="space-y-2">
                {occupants.map((occ, idx) => {
                  const name = getParticipantName(occ);
                  const phone = getParticipantPhone(occ);
                  const cityState = getParticipantCityState(occ);

                  return (
                    <div
                      key={occ.id || idx}
                      className="border border-black rounded-lg p-2.5 flex items-center justify-between gap-4 bg-zinc-50 print-avoid-break"
                    >
                      <div className="flex items-center gap-3 min-w-0">
                        <span className="w-7 h-7 rounded-full border border-black font-black text-xs flex items-center justify-center shrink-0 bg-white">
                          {idx + 1}
                        </span>
                        <div className="min-w-0">
                          <p className="font-extrabold text-sm text-black truncate">
                            {name}
                          </p>
                          <p className="text-[10px] text-zinc-700 truncate">
                            {cityState}
                          </p>
                        </div>
                      </div>

                      <div className="text-right text-[11px] font-bold text-black shrink-0 whitespace-nowrap">
                        {phone}
                      </div>
                    </div>
                  );
                })}

                {/* Linhas pontilhadas para vagas restantes */}
                {Array.from({ length: remainingSpots }).map((_, emptyIdx) => {
                  const bedNum = occupants.length + emptyIdx + 1;
                  return (
                    <div
                      key={`empty-${emptyIdx}`}
                      className="border border-dashed border-zinc-400 rounded-lg p-2.5 flex items-center justify-between gap-4 bg-white print-avoid-break"
                    >
                      <div className="flex items-center gap-3 w-full">
                        <span className="w-7 h-7 rounded-full border border-dashed border-zinc-400 font-bold text-xs flex items-center justify-center shrink-0 text-zinc-500">
                          {bedNum}
                        </span>
                        <div className="w-full border-b border-dashed border-zinc-400 h-5 flex items-center">
                          <span className="text-[10px] italic text-zinc-400">
                            [ Vaga Disponível / Anotação Manual ]
                          </span>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </section>

            {/* Regras e Responsável do Dormitório */}
            <footer className="border-2 border-black rounded-xl p-3 bg-zinc-50 print-avoid-break text-[10px] space-y-3 mt-auto">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="font-bold uppercase tracking-wider text-black mb-1">
                    Responsável pelo Quarto:
                  </p>
                  <div className="border-b border-black h-5 text-[11px] font-bold text-black pt-0.5">
                    {occupants[0] ? getParticipantName(occupants[0]) : "A definir"}
                  </div>
                </div>

                <div>
                  <p className="font-bold uppercase tracking-wider text-black mb-1">
                    Contato do Diaconato de Apoio:
                  </p>
                  <p className="text-[10px] text-zinc-700">
                    Em caso de necessidade médica ou apoio, procure os servos do Diaconato.
                  </p>
                </div>
              </div>

              <div className="border-t border-zinc-300 pt-2 text-[9px] text-zinc-700 space-y-0.5">
                <p className="font-bold text-black uppercase">
                  Regras de Convivência e Amor Fraternal:
                </p>
                <p>• Respeitar o horário de silêncio (23h00 às 07h00) para o descanso dos irmãos.</p>
                <p>• Manter portas e janelas fechadas para evitar insetos.</p>
                <p>• Apagar as luzes e desligar ventiladores ao sair do alojamento.</p>
                <p>• Cuidar da limpeza e ordem do dormitório como servos de Cristo.</p>
              </div>
            </footer>
          </div>
        );
      })}

      {/* Folha Opcional de Discípulos Não Alocados */}
      {includeUnallocatedSheet && unallocatedAttendees.length > 0 && (
        <div className="print-page-break pt-2" style={{ minHeight: "260mm" }}>
          <OfficialPrintHeader
            reportTitle="Alojamento — Participantes Aguardando Quarto"
            retreatTitle={retreat.title}
            dates={dates}
            location={retreat.location_text || "Sítio"}
            extraMeta={`Pendentes: ${unallocatedAttendees.length} discípulos`}
          />

          <div className="border border-black rounded-lg p-3 mb-4 bg-zinc-50 text-[11px] text-black">
            <p className="font-bold uppercase mb-0.5">Atenção ao Diaconato de Hospedagem:</p>
            <p>
              Estes irmãos estão inscritos e confirmados no evento, porém não foram pré-alocados em dormitórios no sistema.
              Utilize esta folha para realizar a alocação física manual e remanejar vagas disponíveis no sítio.
            </p>
          </div>

          <table className="w-full border-collapse text-left text-[11px]">
            <thead>
              <tr className="border-b-2 border-black bg-zinc-100 text-black font-extrabold uppercase text-[10px]">
                <th className="py-2 px-1.5 text-center w-8 border border-zinc-400">Nº</th>
                <th className="py-2 px-2 border border-zinc-400">Nome do Discípulo</th>
                <th className="py-2 px-2 w-28 border border-zinc-400">Telefone</th>
                <th className="py-2 px-2 w-36 border border-zinc-400">Cidade / Estado</th>
                <th className="py-2 px-2 w-40 border border-zinc-400 text-center">Quarto Atribuído Manualmente</th>
              </tr>
            </thead>
            <tbody>
              {unallocatedAttendees.map((occ, idx) => (
                <tr key={occ.id || idx} className="border-b border-zinc-300 print-avoid-break">
                  <td className="py-2 px-1 text-center font-bold text-zinc-700 border-x border-zinc-300 text-[10px]">
                    {String(idx + 1).padStart(2, "0")}
                  </td>
                  <td className="py-2 px-2 font-bold text-black border-r border-zinc-300">
                    {getParticipantName(occ)}
                  </td>
                  <td className="py-2 px-2 text-zinc-800 border-r border-zinc-300 text-[10px]">
                    {getParticipantPhone(occ)}
                  </td>
                  <td className="py-2 px-2 text-zinc-800 border-r border-zinc-300 text-[10px] break-words">
                    {getParticipantCityState(occ)}
                  </td>
                  <td className="py-2 px-2 border-r border-zinc-300">
                    <div className="w-full border-b border-dashed border-zinc-400 h-5" />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

// ==========================================================================
// 3. RELATÓRIO DA COZINHA (ALIMENTAÇÃO & RESTRIÇÕES DETALHADAS)
// ==========================================================================
function KitchenReportDocument({
  retreat,
  registrations,
}: {
  retreat: {
    title: string;
    start_date?: string | null;
    end_date?: string | null;
    location_text?: string | null;
  };
  registrations: RegistrationWithDetails[];
}) {
  const dates = retreat.start_date
    ? `${formatDateBR(retreat.start_date)} a ${
        retreat.end_date ? formatDateBR(retreat.end_date) : "Término"
      }`
    : "Data a definir";

  // Mapeamento e estatísticas das restrições
  const {
    participantsWithDietary,
    stats,
    totalMeals,
  } = useMemo(() => {
    const list: Array<{
      reg: RegistrationWithDetails;
      dietary: DietaryInfo;
    }> = [];

    const categoryCounts: Record<string, number> = {
      "Celíaco / Glúten": 0,
      "Intolerante a Lactose": 0,
      "Diabético": 0,
      "Vegetariano / Vegano": 0,
      "Alergias Alimentares": 0,
      "Outras Restrições": 0,
    };

    let countWithRestrictions = 0;

    registrations.forEach((reg) => {
      const dietary = getParticipantDietaryInfo(reg);
      if (dietary.hasRestriction) {
        countWithRestrictions++;
        list.push({ reg, dietary });

        dietary.categories.forEach((cat) => {
          if (categoryCounts[cat] !== undefined) {
            categoryCounts[cat]++;
          } else {
            categoryCounts["Outras Restrições"]++;
          }
        });
      }
    });

    list.sort((a, b) =>
      getParticipantName(a.reg).localeCompare(getParticipantName(b.reg), "pt-BR")
    );

    return {
      participantsWithDietary: list,
      stats: {
        total: registrations.length,
        withRestrictions: countWithRestrictions,
        withoutRestrictions: registrations.length - countWithRestrictions,
        categoryCounts,
      },
      totalMeals: registrations.length,
    };
  }, [registrations]);

  return (
    <div className="text-black bg-white">
      <OfficialPrintHeader
        reportTitle="Relatório da Cozinha & Restrições Alimentares"
        retreatTitle={retreat.title}
        dates={dates}
        location={retreat.location_text || "Sítio"}
        extraMeta={`Total de Refeições / Inscritos: ${totalMeals}`}
      />

      {/* Painel Consolidado de Refeições */}
      <section className="mb-6 print-avoid-break">
        <h3 className="text-xs font-black uppercase tracking-wider text-black border-b-2 border-black pb-1 mb-3">
          1. Consolidado Geral de Refeições e Restrições:
        </h3>

        <div className="grid grid-cols-3 gap-3 mb-4">
          <div className="border-2 border-black rounded-lg p-3 text-center bg-zinc-50">
            <p className="text-[10px] font-bold uppercase tracking-wider text-zinc-600">
              Total de Refeições / Pratos
            </p>
            <p className="text-2xl font-black text-black mt-1">{totalMeals}</p>
            <p className="text-[10px] text-zinc-500">100% dos participantes</p>
          </div>

          <div className="border border-black rounded-lg p-3 text-center bg-white">
            <p className="text-[10px] font-bold uppercase tracking-wider text-zinc-600">
              Sem Restrições Declaradas
            </p>
            <p className="text-2xl font-black text-black mt-1">
              {stats.withoutRestrictions}
            </p>
            <p className="text-[10px] text-zinc-500">
              {totalMeals > 0
                ? Math.round((stats.withoutRestrictions / totalMeals) * 100)
                : 0}
              % do total
            </p>
          </div>

          <div className="border-2 border-black rounded-lg p-3 text-center bg-zinc-100">
            <p className="text-[10px] font-bold uppercase tracking-wider text-black">
              Com Restrições Alimentares
            </p>
            <p className="text-2xl font-black text-black mt-1">
              {stats.withRestrictions}
            </p>
            <p className="text-[10px] font-bold text-black">
              {totalMeals > 0
                ? Math.round((stats.withRestrictions / totalMeals) * 100)
                : 0}
              % exigem atenção
            </p>
          </div>
        </div>

        {/* Quadro Detalhado por Categoria */}
        <div className="border border-black rounded-lg overflow-hidden">
          <div className="bg-black text-white px-3 py-1.5 text-[11px] font-bold uppercase tracking-wider">
            Quadro Quantitativo por Tipo de Dieta / Restrição Médica
          </div>
          <table className="w-full text-[11px] border-collapse">
            <tbody>
              <tr className="border-b border-zinc-300">
                <td className="py-2 px-3 font-bold border-r border-zinc-300 w-1/2">
                  🌾 Celíacos / Sem Glúten (Glúten / Trigo)
                </td>
                <td className="py-2 px-3 font-extrabold text-right">
                  {stats.categoryCounts["Celíaco / Glúten"]}{" "}
                  {stats.categoryCounts["Celíaco / Glúten"] === 1 ? "discípulo" : "discípulos"}
                </td>
              </tr>
              <tr className="border-b border-zinc-300 bg-zinc-50">
                <td className="py-2 px-3 font-bold border-r border-zinc-300">
                  🥛 Intolerantes a Lactose (Leite e Derivados)
                </td>
                <td className="py-2 px-3 font-extrabold text-right">
                  {stats.categoryCounts["Intolerante a Lactose"]}{" "}
                  {stats.categoryCounts["Intolerante a Lactose"] === 1 ? "discípulo" : "discípulos"}
                </td>
              </tr>
              <tr className="border-b border-zinc-300">
                <td className="py-2 px-3 font-bold border-r border-zinc-300">
                  🩸 Diabéticos / Controle Glicêmico (Sem Açúcar)
                </td>
                <td className="py-2 px-3 font-extrabold text-right">
                  {stats.categoryCounts["Diabético"]}{" "}
                  {stats.categoryCounts["Diabético"] === 1 ? "discípulo" : "discípulos"}
                </td>
              </tr>
              <tr className="border-b border-zinc-300 bg-zinc-50">
                <td className="py-2 px-3 font-bold border-r border-zinc-300">
                  🥗 Vegetarianos / Veganos (Sem Carne)
                </td>
                <td className="py-2 px-3 font-extrabold text-right">
                  {stats.categoryCounts["Vegetariano / Vegano"]}{" "}
                  {stats.categoryCounts["Vegetariano / Vegano"] === 1 ? "discípulo" : "discípulos"}
                </td>
              </tr>
              <tr className="border-b border-zinc-300">
                <td className="py-2 px-3 font-bold border-r border-zinc-300">
                  ⚠️ Alergias Específicas (Amendoim, Frutos do Mar, etc.)
                </td>
                <td className="py-2 px-3 font-extrabold text-right">
                  {stats.categoryCounts["Alergias Alimentares"]}{" "}
                  {stats.categoryCounts["Alergias Alimentares"] === 1 ? "discípulo" : "discípulos"}
                </td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-bold border-r border-zinc-300 bg-zinc-50">
                  📝 Outras Restrições / Dietas Específicas
                </td>
                <td className="py-2 px-3 font-extrabold text-right bg-zinc-50">
                  {stats.categoryCounts["Outras Restrições"]}{" "}
                  {stats.categoryCounts["Outras Restrições"] === 1 ? "discípulo" : "discípulos"}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      {/* Relação Nominal dos Discípulos com Restrições */}
      <section className="mb-6">
        <h3 className="text-xs font-black uppercase tracking-wider text-black border-b-2 border-black pb-1 mb-3">
          2. Relação Nominal e Descrição Detalhada das Restrições ({participantsWithDietary.length}):
        </h3>

        {participantsWithDietary.length === 0 ? (
          <div className="border border-zinc-400 rounded-lg p-6 text-center bg-zinc-50 text-zinc-600 text-xs">
            <CheckCircle2 className="w-8 h-8 mx-auto mb-2 text-black" />
            <p className="font-bold">Nenhuma restrição alimentar ou alergia registrada.</p>
            <p className="text-[11px] text-zinc-500 mt-1">
              Todos os inscritos informaram dieta comum ou não declararam impedimentos.
            </p>
          </div>
        ) : (
          <table className="w-full border-collapse text-left text-[11px]">
            <thead>
              <tr className="border-b-2 border-black bg-zinc-100 text-black font-extrabold uppercase text-[10px]">
                <th className="py-2 px-1 text-center w-8 border border-zinc-400">Nº</th>
                <th className="py-2 px-2 border border-zinc-400 w-44">Discípulo</th>
                <th className="py-2 px-2 border border-zinc-400 w-32">Quarto</th>
                <th className="py-2 px-2 border border-zinc-400 w-28">Telefone</th>
                <th className="py-2 px-2 border border-zinc-400 w-36">Categoria</th>
                <th className="py-2 px-2 border border-zinc-400">Descrição Declarada na Ficha</th>
              </tr>
            </thead>
            <tbody>
              {participantsWithDietary.map(({ reg, dietary }, idx) => {
                const name = getParticipantName(reg);
                const room = getParticipantRoom(reg);
                const phone = getParticipantPhone(reg);

                return (
                  <tr
                    key={reg.id || idx}
                    className="border-b border-zinc-300 print-avoid-break hover:bg-zinc-50"
                  >
                    <td className="py-2 px-1 text-center font-bold text-zinc-700 border-x border-zinc-300 text-[10px]">
                      {String(idx + 1).padStart(2, "0")}
                    </td>
                    <td className="py-2 px-2 font-bold text-black border-r border-zinc-300">
                      {name}
                    </td>
                    <td className="py-2 px-2 font-semibold text-zinc-900 border-r border-zinc-300 text-[10px]">
                      {room}
                    </td>
                    <td className="py-2 px-2 text-zinc-700 border-r border-zinc-300 text-[10px] whitespace-nowrap">
                      <div>{phone}</div>
                      <div className="text-[9px] text-zinc-500 truncate max-w-[120px]">
                        {getParticipantCityState(reg)}
                      </div>
                    </td>
                    <td className="py-2 px-2 border-r border-zinc-300">
                      <div className="flex flex-wrap gap-1">
                        {dietary.categories.map((cat, cIdx) => (
                          <span
                            key={cIdx}
                            className="px-1.5 py-0.5 border border-black rounded text-[9px] font-black uppercase tracking-tight bg-zinc-100"
                          >
                            {cat}
                          </span>
                        ))}
                      </div>
                    </td>
                    <td className="py-2 px-2 font-medium text-black border-r border-zinc-300 italic text-[10px]">
                      "{dietary.description}"
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </section>

      {/* Instruções e Controle da Cozinha */}
      <footer className="border-2 border-black rounded-xl p-3 bg-zinc-50 print-avoid-break text-[10px] space-y-3">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="font-bold uppercase tracking-wider text-black mb-1">
              Controle do Diaconato da Cozinha:
            </p>
            <div className="space-y-1 text-zinc-800">
              <p>[ &nbsp; ] Panelas e recipientes separados para celíacos / alérgicos</p>
              <p>[ &nbsp; ] Marmitas ou pratos identificados por nome e quarto</p>
              <p>[ &nbsp; ] Cardápio adaptado para intolerantes e vegetarianos</p>
            </div>
          </div>

          <div>
            <p className="font-bold uppercase tracking-wider text-black mb-1">
              Assinatura do Diácono da Cozinha:
            </p>
            <div className="border-b border-black h-6 pt-1 text-center text-zinc-500">
              Responsável pelo Preparo e Distribuição
            </div>
          </div>
        </div>

        <div className="text-center text-zinc-500 text-[9px] pt-1 border-t border-zinc-300">
          Relatório de Logística Alimentar — Igreja em Belo Horizonte
        </div>
      </footer>
    </div>
  );
}

// ==========================================================================
// 4. PACOTE COMPLETO (TODOS OS 3 RELATÓRIOS INTEGRADOS)
// ==========================================================================
function AllReportsDocument({
  retreat,
  rooms,
  registrations,
  sortBy,
  includeEmptyRooms,
  includeUnallocatedSheet,
}: {
  retreat: {
    title: string;
    start_date?: string | null;
    end_date?: string | null;
    location_text?: string | null;
  };
  rooms: RetreatRoom[];
  registrations: RegistrationWithDetails[];
  sortBy: "name" | "room" | "city";
  includeEmptyRooms: boolean;
  includeUnallocatedSheet: boolean;
}) {
  return (
    <div className="text-black bg-white">
      {/* 1. Lista de Presença */}
      <div className="print-page-break mb-10">
        <PresenceListDocument
          retreat={retreat}
          registrations={registrations}
          sortBy={sortBy}
        />
      </div>

      {/* 2. Folhas de Quarto */}
      <div className="print-page-break mb-10">
        <RoomSheetsDocument
          retreat={retreat}
          rooms={rooms}
          registrations={registrations}
          includeEmptyRooms={includeEmptyRooms}
          includeUnallocatedSheet={includeUnallocatedSheet}
        />
      </div>

      {/* 3. Relatório da Cozinha */}
      <div className="mb-6">
        <KitchenReportDocument
          retreat={retreat}
          registrations={registrations}
        />
      </div>
    </div>
  );
}

// ==========================================================================
// DIÁLOGO PRINCIPAL COM PREVIEW INTERATIVO E BOTÃO DE IMPRESSÃO
// ==========================================================================
export interface EventPrintListsDialogProps {
  isOpen: boolean;
  onClose: () => void;
  retreat: {
    id: string;
    title: string;
    start_date?: string | null;
    end_date?: string | null;
    location_text?: string | null;
    price?: number | null;
    status?: string | null;
  };
  registrations: RegistrationWithDetails[];
  retreatRooms: RetreatRoom[];
  homeGroupsMap?: Map<string, string>;
}

export function EventPrintListsDialog({
  isOpen,
  onClose,
  retreat,
  registrations,
  retreatRooms,
  homeGroupsMap: _homeGroupsMap,
}: EventPrintListsDialogProps) {
  const [activeReport, setActiveReport] = useState<PrintReportType>("presence");
  const [paymentFilter, setPaymentFilter] = useState<"all" | "paid">("all");
  const [sortBy, setSortBy] = useState<"name" | "room" | "city">("name");
  const [includeEmptyRooms, setIncludeEmptyRooms] = useState(true);
  const [includeUnallocatedSheet, setIncludeUnallocatedSheet] = useState(true);
  const [zoomLevel, setZoomLevel] = useState<number>(100);

  // Filtro de pagantes
  const filteredRegistrations = useMemo(() => {
    if (paymentFilter === "paid") {
      return registrations.filter((r) => r.paid);
    }
    return registrations;
  }, [registrations, paymentFilter]);

  // Contadores para os cartões de abas
  const participantsCount = filteredRegistrations.length;
  const roomsCount = retreatRooms.length;
  const dietaryCount = useMemo(() => {
    return filteredRegistrations.filter((r) => getParticipantDietaryInfo(r).hasRestriction).length;
  }, [filteredRegistrations]);

  const handleTriggerPrint = () => {
    const previousTitle = document.title;
    const sanitizedTitle = (retreat.title || "Evento")
      .replace(/[^a-zA-Z0-9À-ÿ\s_-]/g, "")
      .trim()
      .replace(/\s+/g, "_");

    let reportName = "Lista_Presenca";
    if (activeReport === "rooms") reportName = "Folhas_Quartos";
    else if (activeReport === "kitchen") reportName = "Relatorio_Cozinha";
    else if (activeReport === "all") reportName = "Pacote_Completo";

    document.title = `${reportName}_${sanitizedTitle}`;

    try {
      window.print();
    } finally {
      document.title = previousTitle;
    }
  };

  // Renderizador do documento atual de acordo com a aba selecionada
  const renderDocumentContent = () => {
    switch (activeReport) {
      case "presence":
        return (
          <PresenceListDocument
            retreat={retreat}
            registrations={filteredRegistrations}
            sortBy={sortBy}
          />
        );
      case "rooms":
        return (
          <RoomSheetsDocument
            retreat={retreat}
            rooms={retreatRooms}
            registrations={filteredRegistrations}
            includeEmptyRooms={includeEmptyRooms}
            includeUnallocatedSheet={includeUnallocatedSheet}
          />
        );
      case "kitchen":
        return (
          <KitchenReportDocument
            retreat={retreat}
            registrations={filteredRegistrations}
          />
        );
      case "all":
        return (
          <AllReportsDocument
            retreat={retreat}
            rooms={retreatRooms}
            registrations={filteredRegistrations}
            sortBy={sortBy}
            includeEmptyRooms={includeEmptyRooms}
            includeUnallocatedSheet={includeUnallocatedSheet}
          />
        );
    }
  };

  return (
    <>
      {/* 1. Modal Interativo Ampliado de Visualização e Configurações */}
      <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
        <DialogContent
          className="w-[96vw] sm:max-w-[95vw] md:max-w-[92vw] lg:max-w-6xl xl:max-w-7xl h-[92vh] max-h-[94vh] overflow-hidden flex flex-col p-4 sm:p-6 rounded-2xl bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 shadow-2xl no-print"
        >
          <DialogHeader className="shrink-0 pb-3 border-b border-zinc-200 dark:border-zinc-800">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-zinc-100 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 flex items-center justify-center shrink-0">
                  <Printer className="w-5 h-5 text-zinc-900 dark:text-zinc-100" />
                </div>
                <div>
                  <div className="flex items-center gap-2 flex-wrap">
                    <DialogTitle className="text-lg sm:text-xl font-black text-zinc-900 dark:text-zinc-50 tracking-tight">
                      Impressão & Relatórios PDF para Sítio
                    </DialogTitle>
                    <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full bg-zinc-100 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-700 dark:text-zinc-300">
                      Formato Oficial A4
                    </span>
                  </div>
                  <DialogDescription className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
                    Gere documentos formatados em preto e branco para operação física e 100% offline em zonas rurais.
                  </DialogDescription>
                </div>
              </div>

              {/* Botão Principal de Disparo de Impressão */}
              <div className="flex items-center gap-2 shrink-0">
                <Button
                  onClick={handleTriggerPrint}
                  className="min-h-[44px] h-11 px-5 rounded-xl bg-zinc-900 hover:bg-zinc-800 dark:bg-zinc-50 dark:hover:bg-zinc-200 text-zinc-50 dark:text-zinc-900 font-bold text-xs flex items-center gap-2 cursor-pointer shadow-md transition-colors"
                >
                  <Printer className="w-4 h-4" />
                  <span>Imprimir / Salvar PDF</span>
                </Button>
              </div>
            </div>

            {/* Abas Espaçosas dos 4 Relatórios com Badges Informativos (Touch Target >= 44x44px) */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-2.5 pt-3">
              {/* Aba 1: Lista de Presença */}
              <button
                type="button"
                onClick={() => setActiveReport("presence")}
                className={`min-h-[48px] p-3 rounded-xl border text-left transition-all flex items-center justify-between gap-3 cursor-pointer ${
                  activeReport === "presence"
                    ? "bg-zinc-900 text-zinc-50 border-zinc-900 dark:bg-zinc-50 dark:text-zinc-900 dark:border-zinc-50 shadow-md ring-1 ring-zinc-900 dark:ring-zinc-100"
                    : "bg-zinc-50 dark:bg-zinc-800/40 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-zinc-800 hover:bg-zinc-100 dark:hover:bg-zinc-800"
                }`}
              >
                <div className="flex items-center gap-2.5 min-w-0">
                  <div
                    className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${
                      activeReport === "presence"
                        ? "bg-white/10 dark:bg-zinc-900/10 text-zinc-50 dark:text-zinc-900"
                        : "bg-zinc-200/60 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-200"
                    }`}
                  >
                    <Users className="w-4 h-4" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-xs font-extrabold truncate">Lista de Presença & Portaria</p>
                    <p
                      className={`text-[10px] truncate ${
                        activeReport === "presence"
                          ? "text-zinc-300 dark:text-zinc-600"
                          : "text-zinc-500 dark:text-zinc-400"
                      }`}
                    >
                      {participantsCount} {participantsCount === 1 ? "discípulo" : "discípulos"}
                    </p>
                  </div>
                </div>
              </button>

              {/* Aba 2: Folhas de Quarto */}
              <button
                type="button"
                onClick={() => setActiveReport("rooms")}
                className={`min-h-[48px] p-3 rounded-xl border text-left transition-all flex items-center justify-between gap-3 cursor-pointer ${
                  activeReport === "rooms"
                    ? "bg-zinc-900 text-zinc-50 border-zinc-900 dark:bg-zinc-50 dark:text-zinc-900 dark:border-zinc-50 shadow-md ring-1 ring-zinc-900 dark:ring-zinc-100"
                    : "bg-zinc-50 dark:bg-zinc-800/40 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-zinc-800 hover:bg-zinc-100 dark:hover:bg-zinc-800"
                }`}
              >
                <div className="flex items-center gap-2.5 min-w-0">
                  <div
                    className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${
                      activeReport === "rooms"
                        ? "bg-white/10 dark:bg-zinc-900/10 text-zinc-50 dark:text-zinc-900"
                        : "bg-zinc-200/60 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-200"
                    }`}
                  >
                    <Bed className="w-4 h-4" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-xs font-extrabold truncate">Folhas de Quarto (Alojamento)</p>
                    <p
                      className={`text-[10px] truncate ${
                        activeReport === "rooms"
                          ? "text-zinc-300 dark:text-zinc-600"
                          : "text-zinc-500 dark:text-zinc-400"
                      }`}
                    >
                      {roomsCount} {roomsCount === 1 ? "dormitório" : "dormitórios"}
                    </p>
                  </div>
                </div>
              </button>

              {/* Aba 3: Relatório da Cozinha */}
              <button
                type="button"
                onClick={() => setActiveReport("kitchen")}
                className={`min-h-[48px] p-3 rounded-xl border text-left transition-all flex items-center justify-between gap-3 cursor-pointer ${
                  activeReport === "kitchen"
                    ? "bg-zinc-900 text-zinc-50 border-zinc-900 dark:bg-zinc-50 dark:text-zinc-900 dark:border-zinc-50 shadow-md ring-1 ring-zinc-900 dark:ring-zinc-100"
                    : "bg-zinc-50 dark:bg-zinc-800/40 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-zinc-800 hover:bg-zinc-100 dark:hover:bg-zinc-800"
                }`}
              >
                <div className="flex items-center gap-2.5 min-w-0">
                  <div
                    className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${
                      activeReport === "kitchen"
                        ? "bg-white/10 dark:bg-zinc-900/10 text-zinc-50 dark:text-zinc-900"
                        : "bg-zinc-200/60 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-200"
                    }`}
                  >
                    <UtensilsCrossed className="w-4 h-4" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-xs font-extrabold truncate">Relatório da Cozinha & Dietas</p>
                    <p
                      className={`text-[10px] truncate ${
                        activeReport === "kitchen"
                          ? "text-zinc-300 dark:text-zinc-600"
                          : "text-zinc-500 dark:text-zinc-400"
                      }`}
                    >
                      {dietaryCount} {dietaryCount === 1 ? "com restrição" : "com restrições"}
                    </p>
                  </div>
                </div>
              </button>

              {/* Aba 4: Pacote Completo */}
              <button
                type="button"
                onClick={() => setActiveReport("all")}
                className={`min-h-[48px] p-3 rounded-xl border text-left transition-all flex items-center justify-between gap-3 cursor-pointer ${
                  activeReport === "all"
                    ? "bg-zinc-900 text-zinc-50 border-zinc-900 dark:bg-zinc-50 dark:text-zinc-900 dark:border-zinc-50 shadow-md ring-1 ring-zinc-900 dark:ring-zinc-100"
                    : "bg-zinc-50 dark:bg-zinc-800/40 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-zinc-800 hover:bg-zinc-100 dark:hover:bg-zinc-800"
                }`}
              >
                <div className="flex items-center gap-2.5 min-w-0">
                  <div
                    className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${
                      activeReport === "all"
                        ? "bg-white/10 dark:bg-zinc-900/10 text-zinc-50 dark:text-zinc-900"
                        : "bg-zinc-200/60 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-200"
                    }`}
                  >
                    <Layers className="w-4 h-4" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-xs font-extrabold truncate">Pacote Completo</p>
                    <p
                      className={`text-[10px] truncate ${
                        activeReport === "all"
                          ? "text-zinc-300 dark:text-zinc-600"
                          : "text-zinc-500 dark:text-zinc-400"
                      }`}
                    >
                      Todos os 3 relatórios unificados
                    </p>
                  </div>
                </div>
              </button>
            </div>

            {/* Barra de Opções, Filtros e Controle de Zoom */}
            <div className="flex flex-wrap items-center justify-between gap-3 pt-3 text-xs">
              <div className="flex flex-wrap items-center gap-3">
                {/* Filtro de Pagamento */}
                <div className="w-[190px]">
                  <Select
                    value={paymentFilter}
                    onValueChange={(val: "all" | "paid") => setPaymentFilter(val)}
                  >
                    <SelectTrigger className="min-h-[44px] h-10 text-xs rounded-xl bg-zinc-50 dark:bg-zinc-800/60 border-zinc-200 dark:border-zinc-700">
                      <SelectValue placeholder="Status de Pagamento" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">
                        Todos os Inscritos ({registrations.length})
                      </SelectItem>
                      <SelectItem value="paid">
                        Apenas Confirmados / Pagos (
                        {registrations.filter((r) => r.paid).length})
                      </SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                {/* Ordenação para Lista de Presença */}
                {(activeReport === "presence" || activeReport === "all") && (
                  <div className="w-[210px]">
                    <Select
                      value={sortBy}
                      onValueChange={(val: "name" | "room" | "city") => setSortBy(val)}
                    >
                      <SelectTrigger className="min-h-[44px] h-10 text-xs rounded-xl bg-zinc-50 dark:bg-zinc-800/60 border-zinc-200 dark:border-zinc-700">
                        <SelectValue placeholder="Ordenar por" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="name">Ordem Alfabética (A-Z)</SelectItem>
                        <SelectItem value="room">Agrupado por Quarto</SelectItem>
                        <SelectItem value="city">Por Cidade / Estado</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                )}

                {/* Opções de Quartos */}
                {(activeReport === "rooms" || activeReport === "all") && (
                  <div className="flex items-center gap-4 text-xs text-zinc-600 dark:text-zinc-300">
                    <label className="flex items-center gap-2 cursor-pointer select-none min-h-[44px]">
                      <input
                        type="checkbox"
                        checked={includeEmptyRooms}
                        onChange={(e) => setIncludeEmptyRooms(e.target.checked)}
                        className="w-4 h-4 rounded text-zinc-900 dark:text-zinc-100 focus:ring-zinc-900"
                      />
                      <span className="font-medium">Incluir quartos vazios</span>
                    </label>

                    <label className="flex items-center gap-2 cursor-pointer select-none min-h-[44px]">
                      <input
                        type="checkbox"
                        checked={includeUnallocatedSheet}
                        onChange={(e) => setIncludeUnallocatedSheet(e.target.checked)}
                        className="w-4 h-4 rounded text-zinc-900 dark:text-zinc-100 focus:ring-zinc-900"
                      />
                      <span className="font-medium">Folha de pendentes</span>
                    </label>
                  </div>
                )}
              </div>

              {/* Controles de Zoom do Preview */}
              <div className="flex items-center gap-1.5 bg-zinc-100 dark:bg-zinc-800/70 p-1 rounded-xl border border-zinc-200 dark:border-zinc-700">
                <span className="text-[10px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 px-2">
                  Zoom Preview:
                </span>
                <button
                  type="button"
                  onClick={() => setZoomLevel((z) => Math.max(60, z - 15))}
                  className="w-8 h-8 rounded-lg flex items-center justify-center font-bold text-sm hover:bg-white dark:hover:bg-zinc-700 text-zinc-700 dark:text-zinc-300 transition-colors cursor-pointer"
                  title="Diminuir Zoom"
                >
                  -
                </button>
                <button
                  type="button"
                  onClick={() => setZoomLevel(100)}
                  className="px-2.5 h-8 rounded-lg flex items-center justify-center text-xs font-bold hover:bg-white dark:hover:bg-zinc-700 text-zinc-800 dark:text-zinc-200 transition-colors cursor-pointer"
                  title="Restaurar 100%"
                >
                  {zoomLevel}%
                </button>
                <button
                  type="button"
                  onClick={() => setZoomLevel((z) => Math.min(140, z + 15))}
                  className="w-8 h-8 rounded-lg flex items-center justify-center font-bold text-sm hover:bg-white dark:hover:bg-zinc-700 text-zinc-700 dark:text-zinc-300 transition-colors cursor-pointer"
                  title="Aumentar Zoom"
                >
                  +
                </button>
              </div>
            </div>
          </DialogHeader>

          {/* Área Espaçosa de Pré-Visualização Interativa do Documento A4 */}
          <div className="flex-1 overflow-auto p-4 sm:p-8 bg-zinc-200/60 dark:bg-zinc-950/80 rounded-xl my-2 border border-zinc-200 dark:border-zinc-800 flex justify-center items-start">
            <div
              style={{
                transform: `scale(${zoomLevel / 100})`,
                transformOrigin: "top center",
                transition: "transform 0.15s ease-out",
              }}
              className="mx-auto max-w-[210mm] w-full bg-white text-black p-6 sm:p-10 rounded-sm shadow-2xl border border-zinc-300"
            >
              {renderDocumentContent()}
            </div>
          </div>

          {/* Rodapé com Dicas de PDF e Botões de Ação */}
          <div className="shrink-0 pt-3 border-t border-zinc-200 dark:border-zinc-800 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <p className="text-[11px] text-zinc-500 dark:text-zinc-400">
              💡 <strong>Como salvar um PDF perfeito:</strong> Na janela de impressão, selecione o destino <strong>"Salvar como PDF"</strong>. Para remover a URL e data nos rodapés, desmarque a caixa <strong>"Cabeçalhos e rodapés"</strong> nas opções do navegador.
            </p>

            <div className="flex items-center gap-2 shrink-0">
              <Button
                variant="outline"
                onClick={onClose}
                className="min-h-[44px] h-11 px-4 rounded-xl text-xs font-semibold cursor-pointer border-zinc-300 dark:border-zinc-700 hover:bg-zinc-100 dark:hover:bg-zinc-800"
              >
                Fechar
              </Button>

              <Button
                onClick={handleTriggerPrint}
                className="min-h-[44px] h-11 px-5 rounded-xl bg-zinc-900 hover:bg-zinc-800 dark:bg-zinc-50 dark:hover:bg-zinc-200 text-zinc-50 dark:text-zinc-900 font-bold text-xs flex items-center gap-2 cursor-pointer shadow-md transition-colors"
              >
                <Printer className="w-4 h-4" />
                <span>Imprimir / Salvar PDF</span>
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* 2. Portal que Renderiza o Documento Físico no Body para window.print() */}
      {isOpen &&
        createPortal(
          <div id="event-print-container" className="event-print-portal">
            {renderDocumentContent()}
          </div>,
          document.body
        )}
    </>
  );
}
