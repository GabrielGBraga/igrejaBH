/**
 * Utilitários para manipulação segura de datas (especialmente strings SQL DATE no formato YYYY-MM-DD).
 * Evita bugs clássicos de timezone UTC em fusos negativos (ex: Horário de Brasília GMT-3),
 * onde '2026-10-05' interpretado como UTC vira '2026-10-04 21:00' e expira antes do dia começar.
 */

/**
 * Converte uma string de data (YYYY-MM-DD ou ISO) em Date local seguro (meio-dia 12:00:00).
 * O horário ao meio-dia evita bordas de mudança de fuso horário / horário de verão.
 */
export function parseLocalDate(dateStr?: string | null): Date | null {
  if (!dateStr) return null;
  const clean = dateStr.split("T")[0];
  const parts = clean.split("-").map(Number);
  if (parts.length === 3 && !isNaN(parts[0]) && !isNaN(parts[1]) && !isNaN(parts[2])) {
    return new Date(parts[0], parts[1] - 1, parts[2], 12, 0, 0);
  }
  const d = new Date(dateStr);
  return isNaN(d.getTime()) ? null : d;
}

/**
 * Converte uma data limite (YYYY-MM-DD) para o final exato do dia local (23:59:59.999).
 * Se o prazo é 05/10/2026, as inscrições continuam válidas durante todo o dia 05/10,
 * expirando apenas na virada para 06/10.
 */
export function parseEndOfDay(dateStr: string): Date {
  const clean = dateStr.split("T")[0];
  const parts = clean.split("-").map(Number);
  if (parts.length === 3 && !isNaN(parts[0]) && !isNaN(parts[1]) && !isNaN(parts[2])) {
    return new Date(parts[0], parts[1] - 1, parts[2], 23, 59, 59, 999);
  }
  const d = new Date(dateStr);
  d.setHours(23, 59, 59, 999);
  return d;
}

/**
 * Formata com segurança uma string YYYY-MM-DD para o padrão brasileiro DD/MM/AAAA.
 */
export function formatDateBR(dateStr?: string | null): string {
  if (!dateStr) return "";
  const clean = dateStr.split("T")[0];
  const parts = clean.split("-");
  if (parts.length === 3) {
    const [y, m, d] = parts;
    return `${d.padStart(2, "0")}/${m.padStart(2, "0")}/${y}`;
  }
  const parsed = new Date(dateStr);
  return isNaN(parsed.getTime()) ? "" : parsed.toLocaleDateString("pt-BR");
}
