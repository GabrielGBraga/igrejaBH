/**
 * @file eventsQueryBuilder.ts
 * @description Translates dynamic filter rules into Supabase query modifiers and provides client-side rule evaluation.
 */

import supabase from "@/lib/supabase";
import type { FilterRule, FilterLogic } from "@/types/eventsFilter";
import type { RegistrationWithDetails } from "@/components/events/RegistrationDetailDialog";

interface GuestDataShape {
  full_name?: string;
  email?: string;
  phone?: string;
  cpf?: string;
  gender?: string;
}

/**
 * Extracts participant gender from registration data (profile, guest_data or custom_responses)
 */
export function extractRegistrationGender(reg: RegistrationWithDetails): string {
  const customResps = reg.custom_responses as Record<string, unknown> | null;
  const guestData = reg.guest_data as GuestDataShape | null;

  if (customResps) {
    for (const [key, val] of Object.entries(customResps)) {
      if (
        key.toLowerCase().includes("gênero") ||
        key.toLowerCase().includes("genero") ||
        key.toLowerCase().includes("sexo")
      ) {
        const valStr = String(val).toLowerCase();
        if (valStr.includes("masculino") || valStr === "m" || valStr.includes("homem"))
          return "masculino";
        if (valStr.includes("feminino") || valStr === "f" || valStr.includes("mulher"))
          return "feminino";
      }
    }
  }

  if (guestData?.gender) {
    const gStr = String(guestData.gender).toLowerCase();
    if (gStr.includes("masculino") || gStr === "m" || gStr.includes("homem"))
      return "masculino";
    if (gStr.includes("feminino") || gStr === "f" || gStr.includes("mulher"))
      return "feminino";
  }

  return "indefinido";
}

/**
 * Maps dynamic filter rules directly to Supabase client query modifiers.
 */
export function buildSupabaseRegistrationsQuery(retreatId: string, rules: FilterRule[]) {
  let query = supabase
    .from("registrations")
    .select(`
      *,
      profiles (
        full_name,
        email,
        phone,
        cpf
      ),
      retreat_rooms (
        id,
        name,
        gender_type,
        capacity
      )
    `)
    .eq("retreat_id", retreatId)
    .order("created_at", { ascending: false });

  for (const rule of rules) {
    const isUnaryOperator = rule.operator === "is" || rule.operator === "not_is";
    if (!isUnaryOperator && (rule.value === "" || rule.value === undefined || rule.value === null)) {
      continue;
    }

    // Direct database columns
    if (rule.field === "paid") {
      const boolVal = rule.value === true || rule.value === "true";
      if (rule.operator === "eq") {
        if (boolVal) {
          query = query.eq("paid", true);
        } else {
          query = query.or("paid.eq.false,paid.is.null");
        }
      } else if (rule.operator === "neq") {
        if (boolVal) {
          query = query.or("paid.eq.false,paid.is.null");
        } else {
          query = query.eq("paid", true);
        }
      }
    } else if (rule.field === "payment_method") {
      const strVal = String(rule.value);
      if (rule.operator === "eq") {
        query = query.eq("payment_method", strVal);
      } else if (rule.operator === "neq") {
        query = query.neq("payment_method", strVal);
      } else if (rule.operator === "ilike") {
        query = query.ilike("payment_method", `%${strVal}%`);
      }
    } else if (rule.field === "room_id") {
      if (rule.operator === "is") {
        query = query.is("room_id", null);
      } else if (rule.operator === "not_is") {
        query = query.not("room_id", "is", null);
      } else if (rule.operator === "eq") {
        query = query.eq("room_id", String(rule.value));
      } else if (rule.operator === "neq") {
        query = query.neq("room_id", String(rule.value));
      }
    } else if (rule.field === "created_at") {
      const dateVal = String(rule.value);
      if (rule.operator === "gte") {
        query = query.gte("created_at", dateVal);
      } else if (rule.operator === "lte") {
        query = query.lte("created_at", dateVal);
      }
    } else if (rule.field === "notes") {
      const strVal = String(rule.value);
      if (rule.operator === "ilike") {
        query = query.ilike("notes", `%${strVal}%`);
      }
    }
  }

  return query;
}

/**
 * Tests an individual registration row against a single filter rule.
 */
function testRule(reg: RegistrationWithDetails, rule: FilterRule): boolean {
  const isUnaryOperator = rule.operator === "is" || rule.operator === "not_is";
  if (!isUnaryOperator && (rule.value === "" || rule.value === undefined || rule.value === null)) {
    return true;
  }

  // 1. Payment Status
  if (rule.field === "paid") {
    const targetBool = rule.value === true || rule.value === "true";
    const actualBool = Boolean(reg.paid);
    if (rule.operator === "eq") return actualBool === targetBool;
    if (rule.operator === "neq") return actualBool !== targetBool;
    return true;
  }

  // 2. Payment Method
  if (rule.field === "payment_method") {
    const actual = (reg.payment_method || "").toLowerCase();
    const target = String(rule.value).toLowerCase();
    if (rule.operator === "eq") return actual === target;
    if (rule.operator === "neq") return actual !== target;
    if (rule.operator === "ilike") return actual.includes(target);
    return true;
  }

  // 3. Room Allocation
  if (rule.field === "room_id") {
    const hasRoom = Boolean(
      reg.room_id || (reg.room_allocation && reg.room_allocation !== "Não alocado")
    );
    if (rule.operator === "is") return !hasRoom; // Unallocated
    if (rule.operator === "not_is") return hasRoom; // Allocated
    if (rule.operator === "eq") return reg.room_id === String(rule.value);
    if (rule.operator === "neq") return reg.room_id !== String(rule.value);
    return true;
  }

  // 4. Gender
  if (rule.field === "gender") {
    const actual = extractRegistrationGender(reg);
    const target = String(rule.value).toLowerCase();
    if (rule.operator === "eq") return actual === target;
    if (rule.operator === "neq") return actual !== target;
    return true;
  }

  // 5. Participant Name
  if (rule.field === "participant_name") {
    const guest = reg.guest_data as GuestDataShape | null;
    const name = (reg.profiles?.full_name || guest?.full_name || "").toLowerCase();
    const target = String(rule.value).toLowerCase();
    if (rule.operator === "ilike" || rule.operator === "eq") return name.includes(target);
    if (rule.operator === "neq") return !name.includes(target);
    return true;
  }

  // 6. Registration Date
  if (rule.field === "created_at" && reg.created_at) {
    const regDate = new Date(reg.created_at).getTime();
    const targetDate = new Date(String(rule.value)).getTime();
    if (isNaN(targetDate)) return true;
    if (rule.operator === "gte") return regDate >= targetDate;
    if (rule.operator === "lte") return regDate <= targetDate;
    return true;
  }

  return true;
}

/**
 * Evaluates active filter rules in-memory on the dataset with AND / OR logic.
 */
export function filterRegistrationsClientSide(
  data: RegistrationWithDetails[],
  rules: FilterRule[],
  logic: FilterLogic = "AND"
): RegistrationWithDetails[] {
  const activeRules = rules.filter((r) => {
    if (r.operator === "is" || r.operator === "not_is") return true;
    return r.value !== "" && r.value !== undefined && r.value !== null;
  });

  if (activeRules.length === 0) {
    return data;
  }

  return data.filter((item) => {
    if (logic === "AND") {
      return activeRules.every((rule) => testRule(item, rule));
    } else {
      return activeRules.some((rule) => testRule(item, rule));
    }
  });
}
